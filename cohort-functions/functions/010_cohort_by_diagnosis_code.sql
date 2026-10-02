-- =====================================================================
-- cohort_functions.cohort_by_diagnosis_code
--
-- Cohort membership by diagnosis code (LIKE pattern), optionally
-- restricted to primary/chief diagnoses and/or a date range on
-- observation_date. Returns pseudo_id only -- combine with other
-- cohort_functions.* calls via plain SQL INTERSECT/EXCEPT/UNION.
--
-- pattern: full SQL LIKE pattern, e.g. 'I50%' for heart failure's
--   ICD-10 family, or an exact code with no wildcard for one code.
-- primary_only: when true, additionally requires is_chief_problem =
--   'true'. Normalized to 'true'/'false' for BOTH sources by
--   v_diagnoses_longitudinal itself (070_v_diagnoses_longitudinal.sql):
--   medical_diagnosis has no such column, so it's derived from
--   diagnosis_type; problem_list has a real is_chief_problem column,
--   but its actual values were  'Ja'/NULL, not 'true'/'false' -- the view maps
--   'Ja' -> 'true', everything else -> 'false', so this function's
--   plain = 'true' check is correct for both sources without any
--   special-casing here.
-- date_from/date_to: inclusive bounds on observation_date (a real
--   `date` column on both source tables, so no time-of-day boundary
--   issue). Either or both may stay NULL to leave that side unbounded.
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS cohort_functions;

CREATE OR REPLACE FUNCTION cohort_functions.cohort_by_diagnosis_code(
    pattern       text,
    primary_only  boolean DEFAULT false,
    date_from     date    DEFAULT NULL,
    date_to       date    DEFAULT NULL
) RETURNS TABLE(pseudo_id text)
LANGUAGE sql
STABLE
AS $$
    SELECT DISTINCT d.pseudo_id
    FROM amc_views.v_diagnoses_longitudinal d
    WHERE d.diagnosis_code LIKE pattern
      AND (NOT primary_only OR d.is_chief_problem = 'true')
      AND (date_from IS NULL OR d.observation_date >= date_from)
      AND (date_to IS NULL OR d.observation_date <= date_to)
$$;
