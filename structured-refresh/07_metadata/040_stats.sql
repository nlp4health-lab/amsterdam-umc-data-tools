-- =====================================================================
-- meta.stats: table + refresh logic
--
-- Populates / refreshes meta.stats for every object registered in
-- meta.catalog: row_count, primary_date_column, min_date, max_date,
-- null_counts_key_columns, date_columns_detected,
-- identifier_columns_detected, last_refreshed_at.
--
-- Trusts meta.catalog.identifier_columns / date_columns (with is_primary
-- flags) as the source of truth, but is resilient to bad catalog data:
--   - date_columns entries that don't exist on the object (typo/wrong view)
--   - date_columns entries that are real TIME columns (can't cast to date)
--   - date_columns entries with garbage data that fails ::date casting
--   - identifier_columns entries that don't exist on the object
-- Instead of aborting the whole object's refresh on any single bad
-- column, each column is processed in its own sub-block: failures are
-- recorded inline (with a note) and the object still gets refreshed
-- with whatever DID work.
--
-- Full drop-and-rebuild every run, same as every other stage in this
-- pipeline -- date_columns_detected/identifier_columns_detected (what
-- was historically a separate one-time alter_meta_stats_add_detected.sql
-- migration) are part of the CREATE TABLE below directly.
-- =====================================================================

DROP TABLE IF EXISTS meta.stats CASCADE;

CREATE TABLE meta.stats (
    schema_name              text        NOT NULL DEFAULT 'public',
    object_name               text        NOT NULL,
    row_count                 bigint,
    primary_date_column       text,
    min_date                  date,
    max_date                  date,
    null_counts_key_columns   jsonb       DEFAULT '{}',
    date_columns_detected       jsonb       DEFAULT '[]',
    identifier_columns_detected text[]      DEFAULT '{}',
    last_refreshed_at         timestamptz DEFAULT now(),
    PRIMARY KEY (schema_name, object_name),
    FOREIGN KEY (schema_name, object_name)
        REFERENCES meta.catalog (schema_name, object_name)
        ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON COLUMN meta.stats.date_columns_detected IS
    'All date/timestamp-typed columns found automatically via information_schema, each with min/max/null_count. Review and promote one to meta.catalog.date_columns as is_primary.';
COMMENT ON COLUMN meta.stats.identifier_columns_detected IS
    'Columns named "id" or ending in "_id", found automatically. Review and copy relevant ones into meta.catalog.identifier_columns.';

DO $$
DECLARE
    rec                 record;
    v_full_name         text;
    v_row_count         bigint;
    v_id_cols           text[];
    v_date_entries      jsonb;
    v_entry             jsonb;
    v_col               text;
    v_data_type         text;
    v_min               date;
    v_max               date;
    v_null_count        bigint;
    v_null_pct          numeric;
    v_date_detected     jsonb;
    v_primary_col       text;
    v_primary_min       date;
    v_primary_max       date;
    v_null_json         jsonb;
    v_col_note          text;
BEGIN
    FOR rec IN
        SELECT schema_name, object_name, identifier_columns, date_columns
        FROM meta.catalog
    LOOP
        v_full_name := format('%I.%I', rec.schema_name, rec.object_name);

        IF to_regclass(v_full_name) IS NULL THEN
            RAISE WARNING 'Skipping %: object not found', v_full_name;
            CONTINUE;
        END IF;

        BEGIN
            -- Row count (whole-object failure here is genuinely fatal, leave as-is)
            EXECUTE format('SELECT count(*) FROM %s', v_full_name) INTO v_row_count;

            v_id_cols      := COALESCE(rec.identifier_columns, '{}');
            v_date_entries := COALESCE(rec.date_columns, '[]'::jsonb);

            v_date_detected := '[]'::jsonb;
            v_primary_col   := NULL;
            v_primary_min   := NULL;
            v_primary_max   := NULL;

            -- ---------------------------------------------------------
            -- Date columns: process each independently
            -- ---------------------------------------------------------
            FOR v_entry IN SELECT * FROM jsonb_array_elements(v_date_entries)
            LOOP
                v_col     := v_entry->>'column';
                v_min     := NULL;
                v_max     := NULL;
                v_null_count := NULL;
                v_col_note   := NULL;

                -- Does the column actually exist on this object?
                SELECT data_type INTO v_data_type
                FROM information_schema.columns
                WHERE table_schema = rec.schema_name
                  AND table_name = rec.object_name
                  AND column_name = v_col;

                IF v_data_type IS NULL THEN
                    v_col_note := 'column not found on object -- check catalog';

                ELSIF v_data_type IN ('time without time zone', 'time with time zone') THEN
                    v_col_note := format('skipped: actual type is %s, not date/timestamp', v_data_type);
                    -- still grab a null count, that part can't fail on type
                    BEGIN
                        EXECUTE format('SELECT count(*) FROM %s WHERE %I IS NULL', v_full_name, v_col)
                        INTO v_null_count;
                    EXCEPTION WHEN OTHERS THEN
                        v_null_count := NULL;
                    END;

                ELSE
                    -- Real date/timestamp (or something we'll attempt to cast) --
                    -- isolate failures to this column only
                    BEGIN
                        EXECUTE format(
                            'SELECT min(%I)::date, max(%I)::date, count(*) FILTER (WHERE %I IS NULL) FROM %s',
                            v_col, v_col, v_col, v_full_name
                        ) INTO v_min, v_max, v_null_count;
                    EXCEPTION WHEN OTHERS THEN
                        v_col_note := format('unparseable data in this column: %s', SQLERRM);
                        v_min := NULL;
                        v_max := NULL;
                        -- null count alone is usually safe even if MIN/MAX choke on garbage values
                        BEGIN
                            EXECUTE format('SELECT count(*) FROM %s WHERE %I IS NULL', v_full_name, v_col)
                            INTO v_null_count;
                        EXCEPTION WHEN OTHERS THEN
                            v_null_count := NULL;
                        END;
                    END;
                END IF;

                v_null_pct := CASE WHEN v_row_count > 0 AND v_null_count IS NOT NULL
                                   THEN round(100.0 * v_null_count / v_row_count, 2)
                                   ELSE NULL END;

                v_date_detected := v_date_detected || jsonb_build_object(
                    'column', v_col,
                    'is_primary', COALESCE((v_entry->>'is_primary')::boolean, false),
                    'min', v_min,
                    'max', v_max,
                    'null_count', v_null_count,
                    'null_pct', v_null_pct,
                    'note', v_col_note
                );

                -- Only trust the catalog's is_primary flag if the column
                -- actually resolved cleanly (has a min/max)
                IF COALESCE((v_entry->>'is_primary')::boolean, false)
                   AND v_min IS NOT NULL THEN
                    v_primary_col := v_col;
                    v_primary_min := v_min;
                    v_primary_max := v_max;
                ELSIF COALESCE((v_entry->>'is_primary')::boolean, false)
                      AND v_min IS NULL THEN
                    RAISE WARNING '  % marked as_primary in catalog for % but could not be resolved to min/max -- primary left unset for this refresh',
                        v_col, v_full_name;
                END IF;
            END LOOP;

            -- ---------------------------------------------------------
            -- Identifier columns: null counts, tolerating missing columns
            -- ---------------------------------------------------------
            v_null_json := '{}'::jsonb;
            IF v_id_cols IS NOT NULL THEN
                FOREACH v_col IN ARRAY v_id_cols
                LOOP
                    BEGIN
                        EXECUTE format(
                            'SELECT count(*) FROM %s WHERE %I IS NULL',
                            v_full_name, v_col
                        ) INTO v_null_count;
                        v_null_json := v_null_json || jsonb_build_object(v_col, v_null_count);
                    EXCEPTION WHEN OTHERS THEN
                        RAISE WARNING '  identifier column % not found on % -- check catalog', v_col, v_full_name;
                        v_null_json := v_null_json || jsonb_build_object(v_col, 'column not found');
                    END;
                END LOOP;
            END IF;

            IF v_primary_col IS NOT NULL AND NOT (v_null_json ? v_primary_col) THEN
                BEGIN
                    EXECUTE format('SELECT count(*) FROM %s WHERE %I IS NULL', v_full_name, v_primary_col)
                    INTO v_null_count;
                    v_null_json := v_null_json || jsonb_build_object(v_primary_col, v_null_count);
                EXCEPTION WHEN OTHERS THEN
                    NULL; -- non-fatal, already have min/max
                END;
            END IF;

            -- ---------------------------------------------------------
            -- Upsert
            -- ---------------------------------------------------------
            INSERT INTO meta.stats (
                schema_name, object_name, row_count,
                date_columns_detected, identifier_columns_detected,
                primary_date_column, min_date, max_date,
                null_counts_key_columns, last_refreshed_at
            )
            VALUES (
                rec.schema_name, rec.object_name, v_row_count,
                v_date_detected, v_id_cols,
                v_primary_col, v_primary_min, v_primary_max,
                v_null_json, now()
            )
            ON CONFLICT (schema_name, object_name) DO UPDATE SET
                row_count                    = EXCLUDED.row_count,
                date_columns_detected        = EXCLUDED.date_columns_detected,
                identifier_columns_detected  = EXCLUDED.identifier_columns_detected,
                primary_date_column          = EXCLUDED.primary_date_column,
                min_date                     = EXCLUDED.min_date,
                max_date                     = EXCLUDED.max_date,
                null_counts_key_columns      = EXCLUDED.null_counts_key_columns,
                last_refreshed_at            = now();

            RAISE NOTICE 'Refreshed % (% row(s), primary date: %)',
                v_full_name, v_row_count, coalesce(v_primary_col, 'none');

        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Failed to refresh % (whole-object failure, likely row_count itself): %', v_full_name, SQLERRM;
        END;

    END LOOP;
END $$;

-- =====================================================================
-- Review query
-- =====================================================================
SELECT
    schema_name,
    object_name,
    row_count,
    primary_date_column,
    min_date,
    max_date,
    identifier_columns_detected
FROM meta.stats
ORDER BY schema_name, object_name;
