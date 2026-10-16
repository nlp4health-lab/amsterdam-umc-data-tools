-- =====================================================================
-- cohort_functions.cohort_by_lab_test
--
-- Cohort membership by lab test type (case-insensitive substring
-- search on the test's name), optionally bounded by a date range on
-- result_date. Returns pseudo_id only -- combine with other
-- cohort_functions.* calls via plain SQL INTERSECT/EXCEPT/UNION.
--
-- Requires 035_lab_determination_lookup.sql to have been run first --
-- see that file's own header for why and its staleness caveat.
--
-- term: matched via determination ILIKE '%' || term || '%' against
--   cohort_functions.lab_determination_lookup (note: `%` and `_` inside
--   term still act as LIKE wildcards, since term is embedded in an
--   ILIKE pattern), NOT against amc_core.lab_result directly.
--   determination_code (the lab test code) has 13,117 distinct values
--   from the source's internal Epic coding -- opaque, not a clean
--   hierarchy like ICD -- so this searches determination (the test's
--   text name, 7,698 distinct values) instead, same as before. The
--   difference is where: the lookup table is small enough (<=13,117
--   rows) that an unindexed ILIKE scan over it is sub-millisecond, and
--   the determination_codes it returns then drive an INDEXED lookup
--   against lab_result (idx_core_lab_determination_code /
--   idx_core_lab_pseudo_code_date), instead of an unindexed ILIKE scan
--   across all ~168M lab_result rows directly. If you already know the
--   exact determination_code, filtering amc_core.lab_result on it
--   directly is already fast, no wrapper function needed.
-- date_from/date_to: optional, NULL (the default) on either side
--   leaves that bound unbounded. Unlike this function's original
--   version, a date bound is no longer required for performance --
--   the lookup-table indirection above already keeps the lab_result
--   side of the query indexed regardless of whether a date range is
--   given.
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS cohort_functions;

CREATE OR REPLACE FUNCTION cohort_functions.cohort_by_lab_test(
    term       text,
    date_from  date DEFAULT NULL,
    date_to    date DEFAULT NULL
) RETURNS TABLE(pseudo_id text)
LANGUAGE sql
STABLE
AS $$
    SELECT DISTINCT lr.pseudo_id
    FROM amc_core.lab_result lr
    WHERE lr.determination_code = ANY(
        ARRAY(
            SELECT ddl.determination_code
            FROM cohort_functions.lab_determination_lookup ddl
            WHERE ddl.determination ILIKE '%' || term || '%'
        )
    )
      AND (date_from IS NULL OR lr.result_date >= date_from)
      AND (date_to IS NULL OR lr.result_date <= date_to)
$$;

-- Manual verification (run by hand against the live database -- no
-- automated test suite in this repo):
--
-- 1. Spot-check the term actually matches real data first, now via
--    the lookup table (fast regardless of lab_result's size):
--   SELECT * FROM cohort_functions.lab_determination_lookup
--     WHERE determination ILIKE '%troponine%';
--
-- 2. Function returns results and matches a direct query -- unbounded
--    (no date filter), confirming the function works correctly
--    without the date bound now that it's optional:
--   SELECT count(*) FROM cohort_functions.cohort_by_lab_test('troponine');
--   SELECT count(DISTINCT pseudo_id) FROM amc_core.lab_result
--     WHERE determination_code = ANY(
--       ARRAY(SELECT determination_code FROM cohort_functions.lab_determination_lookup WHERE determination ILIKE '%troponine%')
--     );
--   -- both counts must match
--
-- 3. Same check with a date bound, confirming it still filters
--    correctly when given:
--   SELECT count(*) FROM cohort_functions.cohort_by_lab_test('troponine', '2024-01-01', '2024-01-31');
--   SELECT count(DISTINCT pseudo_id) FROM amc_core.lab_result
--     WHERE determination_code = ANY(
--       ARRAY(SELECT determination_code FROM cohort_functions.lab_determination_lookup WHERE determination ILIKE '%troponine%')
--     )
--     AND result_date >= '2024-01-01' AND result_date <= '2024-01-31';
--   -- both counts must match
--
-- 4. Confirm the lab_result side of the plan uses an index, not a
--    sequential scan:
--   EXPLAIN SELECT * FROM cohort_functions.cohort_by_lab_test('troponine', '2024-01-01', '2024-01-31');
--   -- expect an index/bitmap scan on lab_result, not "Seq Scan on lab_result"
