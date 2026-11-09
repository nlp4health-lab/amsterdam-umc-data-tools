-- =====================================================================
-- check_metadata_drift.sql
--
-- Read-only report: lists every amc_core column that doesn't appear in
-- meta.data_dictionary -- the hand-curated, CSV-loaded data dictionary
-- that's meant to document every amc_core column (table name, column
-- name, data type, primary-key flag, FK reference, description).
-- Scoped to amc_core only -- that's the data dictionary's own scope
-- (see its table comment); amc_views and meta.catalog are a separate
-- concern, not what this check is for.
--
-- Nothing in 07_metadata auto-detects new columns (the one script that
-- did, refresh_meta_stats_auto.sql, was archived once the data
-- dictionary's initial curation was complete -- see
-- structured-refresh/archive/NOTES.md). So if a column gets added
-- upstream (a schema change in an earlier stage, or a genuinely new
-- source column in a data pull) after the dictionary was curated, it
-- will not appear there automatically -- it's simply absent, with no
-- warning. Run this manually whenever you suspect drift (e.g. right
-- after a schema change, or periodically) to see what needs curating.
--
-- Cheap and safe to run anytime: pure information_schema/meta-table
-- join, no MIN/MAX/COUNT against real data, so it's fast even against
-- huge tables like lab_result. NOT part of the automatic refresh cycle --
-- lives here in tools/, not in 07_metadata/, specifically so refresh.sh
-- never picks it up.
--
-- Run: psql -f structured-refresh/tools/check_metadata_drift.sql
--   (or \i structured-refresh/tools/check_metadata_drift.sql from psql)
-- =====================================================================

SELECT
    rc.table_name,
    rc.column_name,
    rc.data_type
FROM information_schema.columns rc
LEFT JOIN meta.data_dictionary dd
    ON  dd.table_name  = rc.table_name
    AND dd.column_name = rc.column_name
WHERE rc.table_schema = 'amc_core'
  AND dd.column_name IS NULL
ORDER BY rc.table_name, rc.column_name;
