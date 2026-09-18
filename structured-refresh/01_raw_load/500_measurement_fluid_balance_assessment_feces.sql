--============================================================
DROP TABLE IF EXISTS amc_raw.measurement_fluid_balance_assessment_feces;

CREATE TABLE amc_raw.measurement_fluid_balance_assessment_feces (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  meet_time TEXT,
  meet_date TEXT,
  measurement_moment TEXT,
  incontinence_feces TEXT,
  consistency_feces TEXT,
  consistency_feces_baby TEXT,
  color_feces TEXT,
  quantity_feces TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: measurement_fluid_balance_assessment_feces

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- Row count
SELECT count(*) AS n_rows
FROM amc_raw.measurement_fluid_balance_assessment_feces;

-- Missing identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = '') AS null_patient_contact_id,
  count(*) FILTER (WHERE measurement_moment IS NULL OR measurement_moment = '') AS null_measurement_moment
FROM amc_raw.measurement_fluid_balance_assessment_feces;

-- Cardinality check
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(patient_contact_id,'')) AS distinct_patient_contact_id,
  count(DISTINCT NULLIF(measurement_moment,'')) AS distinct_measurement_moment
FROM amc_raw.measurement_fluid_balance_assessment_feces;

-- Check duplicates per measurement moment
SELECT
  patient_contact_id,
  measurement_moment,
  count(*) AS n
FROM amc_raw.measurement_fluid_balance_assessment_feces
GROUP BY patient_contact_id, measurement_moment
HAVING count(*) > 1
ORDER BY n DESC
LIMIT 20;

