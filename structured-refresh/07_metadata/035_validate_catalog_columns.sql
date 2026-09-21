-- =====================================================================
-- validate_catalog_columns.sql
--
-- Flags every identifier_columns / date_columns entry in meta.catalog
-- that does NOT correspond to a real column on the underlying table/view.
-- Run before 040_stats.sql to catch catalog data errors (typos, columns
-- that don't exist on that particular view) rather than discovering them
-- one at a time via WARNINGs during the stats refresh. Read-only --
-- reports issues, does not fix them.
-- =====================================================================

WITH id_cols AS (
    SELECT schema_name, object_name, unnest(identifier_columns) AS col
    FROM meta.catalog
    WHERE identifier_columns IS NOT NULL
),
date_cols AS (
    SELECT schema_name, object_name, elem->>'column' AS col
    FROM meta.catalog, jsonb_array_elements(date_columns) elem
    WHERE date_columns IS NOT NULL AND jsonb_array_length(date_columns) > 0
)
SELECT 'identifier_columns' AS source, i.schema_name, i.object_name, i.col AS missing_column
FROM id_cols i
LEFT JOIN information_schema.columns c
  ON c.table_schema = i.schema_name AND c.table_name = i.object_name AND c.column_name = i.col
WHERE c.column_name IS NULL

UNION ALL

SELECT 'date_columns' AS source, d.schema_name, d.object_name, d.col AS missing_column
FROM date_cols d
LEFT JOIN information_schema.columns c
  ON c.table_schema = d.schema_name AND c.table_name = d.object_name AND c.column_name = d.col
WHERE c.column_name IS NULL

ORDER BY 2, 3, 1;

-- =====================================================================
-- Second check: date_columns entries that DO exist, but aren't actually
-- date/timestamp typed (e.g. real TIME columns like admission_time,
-- or text/varchar columns masquerading as dates).
-- =====================================================================

SELECT d.schema_name, d.object_name, d.col, c.data_type
FROM (
    SELECT schema_name, object_name, elem->>'column' AS col
    FROM meta.catalog, jsonb_array_elements(date_columns) elem
    WHERE date_columns IS NOT NULL AND jsonb_array_length(date_columns) > 0
) d
JOIN information_schema.columns c
  ON c.table_schema = d.schema_name AND c.table_name = d.object_name AND c.column_name = d.col
WHERE c.data_type NOT IN ('date', 'timestamp without time zone', 'timestamp with time zone')
ORDER BY 1, 2, 3;
