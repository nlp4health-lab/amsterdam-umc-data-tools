-- ===========================================================================
-- amc_raw.measurement_vital_signs_data
-- ===========================================================================

DROP TABLE IF EXISTS amc_raw.measurement_vital_signs_data;

CREATE TABLE amc_raw.measurement_vital_signs_data (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  meet_time TEXT,
  meet_date TEXT,
  measurement_moment TEXT,
  vital_data_length TEXT,
  vital_data_weight TEXT,
  vital_data_bmi_calculation TEXT,
  vital_data_pulse_rate TEXT,
  vital_data_blood_pressure_sys_dia TEXT,
  vital_data_temperature TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: measurement_vital_signs_data

-- Minimal sanity
SELECT count(*) AS n_rows
FROM amc_raw.measurement_vital_signs_data;

SELECT count(*) AS null_pseudo
FROM amc_raw.measurement_vital_signs_data
WHERE pseudo_id IS NULL OR btrim(pseudo_id) = '';

SELECT count(DISTINCT patient_contact_id) AS distinct_contacts
FROM amc_raw.measurement_vital_signs_data
WHERE patient_contact_id IS NOT NULL;

