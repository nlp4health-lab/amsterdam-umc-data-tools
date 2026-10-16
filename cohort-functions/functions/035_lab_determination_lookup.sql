-- =====================================================================
-- cohort_functions.lab_determination_lookup
--
-- Small reference table mapping amc_core.lab_result's determination_code
-- (the opaque internal Epic code, 13,117 distinct values) to its
-- determination (the human-readable test name, 7,698 distinct values).
-- Built so cohort_by_lab_test (040_cohort_by_lab_test.sql) can text-
-- search this tiny table instead of scanning all ~168M lab_result rows
-- with an unindexed leading-wildcard ILIKE -- a matched determination_code
-- then drives an indexed lookup against lab_result itself
-- (idx_core_lab_determination_code / idx_core_lab_pseudo_code_date).
--
-- Run this before 040_cohort_by_lab_test.sql the first time, and
-- re-run it whenever lab_result's content changes (e.g. after a real
-- structured-refresh data load) -- NOT wired into
-- structured-refresh/refresh.sh, same "run by hand" convention as the
-- rest of cohort-functions/.
--
-- Staleness is narrowly scoped: cohort_by_lab_test still queries
-- lab_result directly for the actual matching rows, so results are
-- never stale from old data -- only the SET OF SEARCHABLE CODES can be.
-- A determination_code that's genuinely new since this table's last
-- rebuild won't be found by a text search (via cohort_by_lab_test)
-- until this file is re-run, even though that code's rows are already
-- present in lab_result and queryable directly.
--
-- No index on this table -- at <=13,117 rows, a sequential ILIKE scan
-- over it is sub-millisecond regardless.
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS cohort_functions;

DROP TABLE IF EXISTS cohort_functions.lab_determination_lookup;

CREATE TABLE cohort_functions.lab_determination_lookup AS
SELECT DISTINCT determination_code, determination
FROM amc_core.lab_result
WHERE determination_code IS NOT NULL;

-- Manual verification (run by hand against the live database -- no
-- automated test suite in this repo):
--
-- 1. Row count sanity -- expect <= 13,117 (per the determination_code
--    cardinality noted above):
--   SELECT count(*) FROM cohort_functions.lab_determination_lookup;
--
-- 2. One row per code is the expected common case -- if this doesn't
--    match the count above, some determination_code maps to more than
--    one determination text in the source (not an error -- the lookup
--    still works correctly either way -- but worth a closer look):
--   SELECT count(DISTINCT determination_code) FROM cohort_functions.lab_determination_lookup;
