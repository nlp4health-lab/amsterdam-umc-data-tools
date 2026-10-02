-- =====================================================================
-- check_metadata_drift.sql
--
-- Read-only report: lists every column on a real amc_core/amc_views
-- table or view that isn't documented anywhere in the meta schema --
-- neither in meta.catalog's curated identifier_columns/date_columns,
-- nor in meta.data_dictionary.
--
-- Run this manually whenever you suspect drift (e.g. right
-- after a schema change, or periodically) to see what needs curating.
--
-- Cheap and safe to run anytime: pure information_schema/meta-table
-- joins, no MIN/MAX/COUNT against real data, so it's fast even against
-- huge tables like lab_result. NOT part of the automatic refresh cycle --
-- lives here in tools/, not in 07_metadata/, specifically so refresh.sh
-- never picks it up.
--
-- Run: psql -f structured-refresh/tools/check_metadata_drift.sql
--   (or \i structured-refresh/tools/check_metadata_drift.sql from psql)
-- =====================================================================

WITH real_columns AS (
    SELECT table_schema, table_name, column_name, data_type
    FROM information_schema.columns
    WHERE table_schema IN ('amc_core', 'amc_views')
),

-- Every column name meta.catalog's curation actually mentions, per
-- object -- identifier_columns (a plain array) and date_columns (a
-- jsonb array of {"column": ...} objects).
catalog_columns AS (
    SELECT
        schema_name AS table_schema,
        object_name AS table_name,
        unnest(identifier_columns) AS column_name
    FROM meta.catalog
    WHERE identifier_columns IS NOT NULL

    UNION

    SELECT
        schema_name,
        object_name,
        elem->>'column'
    FROM meta.catalog, jsonb_array_elements(date_columns) elem
    WHERE date_columns IS NOT NULL AND jsonb_array_length(date_columns) > 0
)

SELECT
    rc.table_schema,
    rc.table_name,
    rc.column_name,
    rc.data_type
FROM real_columns rc
LEFT JOIN catalog_columns cc
    ON  cc.table_schema = rc.table_schema
    AND cc.table_name   = rc.table_name
    AND cc.column_name  = rc.column_name
-- meta.data_dictionary has no schema column (its own header comment
-- only ever claimed amc_core coverage) -- match on table_name/column_name
-- alone, same pragmatic scope its original design already had.
LEFT JOIN meta.data_dictionary dd
    ON  dd.table_name  = rc.table_name
    AND dd.column_name = rc.column_name
WHERE cc.column_name IS NULL
  AND dd.column_name IS NULL
ORDER BY rc.table_schema, rc.table_name, rc.column_name;
