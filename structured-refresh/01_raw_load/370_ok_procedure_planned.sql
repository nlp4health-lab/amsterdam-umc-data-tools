--============================================================
DROP TABLE IF EXISTS amc_raw.ok_procedure_planned;

CREATE TABLE amc_raw.ok_procedure_planned (
  pseudo_id TEXT,
  ok_session_number TEXT,
  session_planned_start_date TEXT,
  chief_operator_panel_specialty TEXT,
  chief_operator_panel_subspecialty TEXT,
  chief_operator_panel_ok_specialty TEXT,
  session_specialism TEXT,
  session_subspecialty TEXT,
  session_ok_specialty TEXT,
  session_ok_plan_status TEXT,
  ok_anesthesia_type TEXT,
  ok_room TEXT,
  ok_location TEXT,
  ok_chief_location TEXT,
  hospital_location TEXT,
  intervention TEXT,
  intervention_code TEXT,
  laterality TEXT,
  panel TEXT,
  age_in_years_at_moment_of_session TEXT,
  child_age_in_weeks_at_moment_of_session TEXT,
  is_patient_deceased TEXT,
  care_traject_description TEXT,
  dbc_diagnosis TEXT,
  lowest_subtraject_id TEXT,
  subtrajects_ids TEXT,
  care_traject_id TEXT,
  scheduled_time_minutes TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: ok_procedure_planned ok_procedures_planned

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- 1) Row count
SELECT count(*) AS n_rows
FROM amc_raw.ok_procedure_planned;

-- 2) Nulls on likely identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE ok_session_number IS NULL OR ok_session_number = '') AS null_ok_session_number,
  count(*) FILTER (WHERE session_planned_start_date IS NULL OR session_planned_start_date = '') AS null_session_planned_start_date,
  count(*) FILTER (WHERE lowest_subtraject_id IS NULL OR lowest_subtraject_id = '') AS null_lowest_subtraject_id,
  count(*) FILTER (WHERE care_traject_id IS NULL OR care_traject_id = '') AS null_care_traject_id
FROM amc_raw.ok_procedure_planned;

-- 3) Cardinality of identifiers
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(ok_session_number,'')) AS distinct_sessions,
  count(DISTINCT NULLIF(lowest_subtraject_id,'')) AS distinct_lowest_subtrajects,
  count(DISTINCT NULLIF(care_traject_id,'')) AS distinct_care_trajects
FROM amc_raw.ok_procedure_planned;

-- 4) Check duplicates by session
SELECT
  ok_session_number,
  count(*) AS n
FROM amc_raw.ok_procedure_planned
WHERE ok_session_number IS NOT NULL AND ok_session_number <> ''
GROUP BY ok_session_number
HAVING count(*) > 1
ORDER BY n DESC
LIMIT 20;

-- 5) Distribution of planned interventions per session
SELECT
  ok_session_number,
  count(*) AS planned_interventions_in_session
FROM amc_raw.ok_procedure_planned
WHERE ok_session_number IS NOT NULL AND ok_session_number <> ''
GROUP BY ok_session_number
ORDER BY planned_interventions_in_session DESC
LIMIT 20;

