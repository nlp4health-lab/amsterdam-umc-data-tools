--============================================================
DROP TABLE IF EXISTS amc_raw.measurement_nephrology_cntv_medication;

CREATE TABLE amc_raw.measurement_nephrology_cntv_medication (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  meet_time TEXT,
  meet_date TEXT,
  measurement_moment TEXT,
  citrate_doses_set TEXT,
  citrate_flowrate TEXT,
  citrate_volume TEXT,
  calcium_doses_set TEXT,
  calcium_flowrate TEXT,
  calcium_volume TEXT,
  anticoagulation_continuousu_volume_total TEXT,
  anticoagulation_bolus_volume_total TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: measurement_nephrology_cntv_medication

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- Row count
SELECT count(*) AS n_rows
FROM amc_raw.measurement_nephrology_cntv_medication;

-- Missing identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = '') AS null_patient_contact_id,
  count(*) FILTER (WHERE measurement_moment IS NULL OR measurement_moment = '') AS null_measurement_moment
FROM amc_raw.measurement_nephrology_cntv_medication;

-- Cardinality check
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(patient_contact_id,'')) AS distinct_patient_contact_id,
  count(DISTINCT NULLIF(measurement_moment,'')) AS distinct_measurement_moment
FROM amc_raw.measurement_nephrology_cntv_medication;

-- Check duplicates
SELECT
  patient_contact_id,
  measurement_moment,
  count(*) AS n
FROM amc_raw.measurement_nephrology_cntv_medication
GROUP BY patient_contact_id, measurement_moment
HAVING count(*) > 1
ORDER BY n DESC
LIMIT 20;

