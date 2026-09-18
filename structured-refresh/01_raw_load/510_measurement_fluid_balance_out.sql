--============================================================
DROP TABLE IF EXISTS amc_raw.measurement_fluid_balance_out;

CREATE TABLE amc_raw.measurement_fluid_balance_out (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  measurement_moisture_out_id TEXT,
  meet_time TEXT,
  meet_date TEXT,
  measurement_moment TEXT,
  hospital_location TEXT,
  lda_observation_id TEXT,
  lda_description TEXT,
  question_observation_description TEXT,
  question_observation_code TEXT,
  value TEXT,
  unit TEXT,
  moisture_out_type TEXT,
  moisture_balance_out_type_code TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: measurement_fluid_balance_out

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- Row count
SELECT count(*) AS n_rows
FROM amc_raw.measurement_fluid_balance_out;

-- Missing identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = '') AS null_patient_contact_id,
  count(*) FILTER (WHERE measurement_moment IS NULL OR measurement_moment = '') AS null_measurement_moment,
  count(*) FILTER (WHERE measurement_moisture_out_id IS NULL OR measurement_moisture_out_id = '') AS null_measurement_moisture_out_id
FROM amc_raw.measurement_fluid_balance_out;

-- Cardinality check
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(patient_contact_id,'')) AS distinct_patient_contact_id,
  count(DISTINCT NULLIF(measurement_moment,'')) AS distinct_measurement_moment,
  count(DISTINCT NULLIF(measurement_moisture_out_id,'')) AS distinct_measurement_moisture_out_id
FROM amc_raw.measurement_fluid_balance_out;

-- Check duplicates
SELECT
  measurement_moisture_out_id,
  count(*) AS n
FROM amc_raw.measurement_fluid_balance_out
WHERE measurement_moisture_out_id IS NOT NULL
GROUP BY measurement_moisture_out_id
HAVING count(*) > 1
ORDER BY n DESC
LIMIT 20;

