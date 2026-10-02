-- =====================================================================
-- cohort_functions.cohort_by_lab_test
--
-- Cohort membership by lab test type (case-insensitive substring
-- search on the test's name), bounded by a required date range on
-- result_date. Returns pseudo_id only -- combine with other
-- cohort_functions.* calls via plain SQL INTERSECT/EXCEPT/UNION.
--
-- term: matched via determination ILIKE '%' || term || '%' (note: `%`
--   and `_` inside term still act as LIKE wildcards, since term is
--   embedded in an ILIKE pattern). determination_code (the lab test
--   code) has 13,117 distinct values from the source's internal Epic
--   coding -- opaque, not a clean hierarchy like ICD -- so this
--   searches determination (the test's text name, 7,698 distinct
--   values) instead. If you already know the exact determination_code,
--   filter amc_core.lab_result on it directly -- idx_core_lab_determination_code
--   already makes that fast, no wrapper function needed. Two more
--   composite indexes on the same table make an exact-determination_code
--   + date-bounded query even faster still: idx_core_lab_code_date (on
--   determination_code, result_date) and idx_core_lab_pseudo_code_date
--   (on pseudo_id, determination_code, result_date).
-- date_from/date_to: REQUIRED, unlike cohort_by_diagnosis_code/
--   cohort_by_diagnosis_text. lab_result is ~168M rows.
--   idx_core_lab_result_date exists on result_date, but determination
--   has no index, and a leading-wildcard ILIKE can't use a btree index
--   even if one existed -- requiring the date bound keeps the planner
--   able to narrow via the date index before the text filter, instead
--   of scanning the whole table. Same reasoning
--   cohort_active_in_range already uses for requiring its own dates.
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS cohort_functions;

CREATE OR REPLACE FUNCTION cohort_functions.cohort_by_lab_test(
    term       text,
    date_from  date,
    date_to    date
) RETURNS TABLE(pseudo_id text)
LANGUAGE sql
STABLE
AS $$
    SELECT DISTINCT lr.pseudo_id
    FROM amc_core.lab_result lr
    WHERE lr.determination ILIKE '%' || term || '%'
      AND lr.result_date >= date_from
      AND lr.result_date <= date_to
$$;

