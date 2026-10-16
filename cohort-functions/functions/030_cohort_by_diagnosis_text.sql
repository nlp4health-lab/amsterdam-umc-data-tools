-- =====================================================================
-- cohort_functions.cohort_by_diagnosis_text
--
-- Cohort membership by diagnosis description (case-insensitive
-- substring search), optionally restricted to primary/chief diagnoses
-- and/or a date range on observation_date. Same shape and semantics as
-- cohort_by_diagnosis_code (010_cohort_by_diagnosis_code.sql), except
-- it searches diagnosis_description instead of diagnosis_code -- use
-- this when you know the clinical term but not the ICD/SNOMED code
-- family. Returns pseudo_id only -- combine with other
-- cohort_functions.* calls via plain SQL INTERSECT/EXCEPT/UNION.
--
-- term: matched via diagnosis_description ILIKE '%' || term || '%'
--   (case-insensitive substring; note: `%` and `_` inside term still
--   act as LIKE wildcards, since term is embedded in an ILIKE
--   pattern). No index exists on diagnosis_description, but
--   medical_diagnosis/problem_list are far smaller than lab_result, so
--   an unindexed scan is acceptable for occasional cohort-building use.
-- primary_only: same as cohort_by_diagnosis_code -- when true,
--   additionally requires is_chief_problem = 'true'. Normalized to
--   'true'/'false' for both sources by v_diagnoses_longitudinal itself
--   (070_v_diagnoses_longitudinal.sql) -- see that file's own header
--   for the full history of why this normalization exists.
-- date_from/date_to: inclusive bounds on observation_date (a real
--   `date` column on both source tables, so no time-of-day boundary
--   issue). Either or both may stay NULL to leave that side unbounded.
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS cohort_functions;

CREATE OR REPLACE FUNCTION cohort_functions.cohort_by_diagnosis_text(
    term          text,
    primary_only  boolean DEFAULT false,
    date_from     date    DEFAULT NULL,
    date_to       date    DEFAULT NULL
) RETURNS TABLE(pseudo_id text)
LANGUAGE sql
STABLE
AS $$
    SELECT DISTINCT d.pseudo_id
    FROM amc_views.v_diagnoses_longitudinal d
    WHERE d.diagnosis_description ILIKE '%' || term || '%'
      AND (NOT primary_only OR d.is_chief_problem = 'true')
      AND (date_from IS NULL OR d.observation_date >= date_from)
      AND (date_to IS NULL OR d.observation_date <= date_to)
$$;

-- Manual verification (run by hand against the live database -- no
-- automated test suite in this repo):
--
-- 1. Function returns results and matches a direct query:
--   SELECT count(*) FROM cohort_functions.cohort_by_diagnosis_text('hartfalen', true);
--   SELECT count(DISTINCT pseudo_id) FROM amc_views.v_diagnoses_longitudinal
--     WHERE diagnosis_description ILIKE '%hartfalen%' AND is_chief_problem = 'true';
--   -- both counts must match
--
-- 2. Unbounded dates behave as "no filter":
--   SELECT count(*) FROM cohort_functions.cohort_by_diagnosis_text('hartfalen');
--   SELECT count(DISTINCT pseudo_id) FROM amc_views.v_diagnoses_longitudinal
--     WHERE diagnosis_description ILIKE '%hartfalen%';
--   -- both counts must match
