--============================================================
DROP TABLE IF EXISTS amc_raw.ok_procedure_performed;

CREATE TABLE amc_raw.ok_procedure_performed (
  pseudo_id TEXT,
  ok_session_number TEXT,
  session_start_date TEXT,
  session_start_date_time TEXT,
  intervention_executed_date TEXT,
  session_ok_specialty TEXT,
  session_specialism TEXT,
  ok_room TEXT,
  ok_location TEXT,
  ok_chief_location TEXT,
  hospital_location TEXT,
  chief_operator_panel_specialty TEXT,
  chief_operator_panel_subspecialty TEXT,
  chief_operator_panel_ok_specialty TEXT,
  intervention TEXT,
  care_activity TEXT,
  is_chief_intervention TEXT,
  laterality TEXT,
  panel TEXT,
  age_in_years_at_moment_of_session TEXT,
  child_age_in_weeks_at_moment_of_session TEXT,
  dbc_diagnosis TEXT,
  care_traject_description TEXT,
  subtraject_id TEXT,
  subtrajects_ids TEXT,
  care_traject_id TEXT,
  number_ok_interventions_performed TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: ok_procedure_performed ok_procedures_performed

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- 1) Row count
SELECT count(*) AS n_rows
FROM amc_raw.ok_procedure_performed;

-- 2) Nulls on likely identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE ok_session_number IS NULL OR ok_session_number = '') AS null_ok_session_number,
  count(*) FILTER (WHERE session_start_date IS NULL OR session_start_date = '') AS null_session_start_date,
  count(*) FILTER (WHERE subtraject_id IS NULL OR subtraject_id = '') AS null_subtraject_id,
  count(*) FILTER (WHERE care_traject_id IS NULL OR care_traject_id = '') AS null_care_traject_id
FROM amc_raw.ok_procedure_performed;

-- 3) Cardinality of identifiers
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(ok_session_number,'')) AS distinct_sessions,
  count(DISTINCT NULLIF(subtraject_id,'')) AS distinct_subtrajects,
  count(DISTINCT NULLIF(care_traject_id,'')) AS distinct_care_trajects
FROM amc_raw.ok_procedure_performed;

-- 4) Check duplicates by session
SELECT
  ok_session_number,
  count(*) AS n
FROM amc_raw.ok_procedure_performed
WHERE ok_session_number IS NOT NULL AND ok_session_number <> ''
GROUP BY ok_session_number
HAVING count(*) > 1
ORDER BY n DESC
LIMIT 20;

-- 5) Distribution of interventions per session
SELECT
  ok_session_number,
  count(*) AS interventions_in_session
FROM amc_raw.ok_procedure_performed
WHERE ok_session_number IS NOT NULL AND ok_session_number <> ''
GROUP BY ok_session_number
ORDER BY interventions_in_session DESC
LIMIT 20;

