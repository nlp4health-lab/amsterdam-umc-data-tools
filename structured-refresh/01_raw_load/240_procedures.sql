-- ===========================================================================
-- procedures.csv  (raw load)
-- ===========================================================================

DROP TABLE IF EXISTS amc_raw.procedures;

CREATE TABLE amc_raw.procedures (
  pseudo_id TEXT,
  intervention_id TEXT,
  intervention_date TEXT,
  intervention_code TEXT,
  intervention TEXT,
  hospital_location TEXT,
  patient_contact_id TEXT,
  age_in_years_at_moment_of_intervention TEXT,
  subtraject_id TEXT,
  ok_session_number TEXT,
  order_id TEXT,
  care_activity TEXT,
  care_profile_class TEXT,
  requesting_specialty_abbreviation TEXT,
  requesting_sub_specialty_code TEXT,
  requesting_sub_specialty TEXT,
  executive_specialty TEXT,
  executive_sub_specialty TEXT,
  executive_workplace TEXT,
  source_module TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: procedures

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- 1) Row count
SELECT count(*) AS n_rows
FROM amc_raw.procedures;

-- 2) Nulls on the likely join keys
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = '') AS null_patient_contact_id,
  count(*) FILTER (WHERE intervention_id IS NULL OR intervention_id = '') AS null_intervention_id,
  count(*) FILTER (WHERE subtraject_id IS NULL OR subtraject_id = '') AS null_subtraject_id,
  count(*) FILTER (WHERE order_id IS NULL OR order_id = '') AS null_order_id
FROM amc_raw.procedures;

-- 3) Uniqueness / cardinality of IDs (helps infer grain)
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(intervention_id,'')) AS distinct_intervention_id,
  count(DISTINCT NULLIF(patient_contact_id,'')) AS distinct_patient_contact_id,
  count(DISTINCT NULLIF(subtraject_id,'')) AS distinct_subtraject_id,
  count(DISTINCT NULLIF(order_id,'')) AS distinct_order_id
FROM amc_raw.procedures;

-- 4) Quick “is intervention_id unique?” check (top duplicates if not)
SELECT intervention_id, count(*) AS n
FROM amc_raw.procedures
WHERE intervention_id IS NOT NULL AND intervention_id <> ''
GROUP BY intervention_id
HAVING count(*) > 1
ORDER BY n DESC
LIMIT 20;

