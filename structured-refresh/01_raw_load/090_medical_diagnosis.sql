--===========================================================================
--medical_history_part1.csv 

DROP TABLE IF EXISTS amc_raw.medical_diagnosis;

CREATE TABLE amc_raw.medical_diagnosis (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  diagnosis_contact_date TEXT,
  diagnosis_registration_moment TEXT,
  diagnosis_code TEXT,
  diagnosis_category TEXT,
  diagnosis_description TEXT,
  diagnosis_type TEXT,
  clinical_outpatient TEXT,
  specialty TEXT,
  is_complication TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: medical_diagnosis

-- Sanity checks

-- Row count
SELECT count(*) AS n_rows
FROM amc_raw.medical_diagnosis;

-- Null check on key columns
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL) AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL) AS null_contact,
  count(*) FILTER (WHERE diagnosis_code IS NULL) AS null_diag_code
FROM amc_raw.medical_diagnosis;

-- How many diagnoses per contact?
SELECT patient_contact_id, count(*) AS n
FROM amc_raw.medical_diagnosis
WHERE patient_contact_id IS NOT NULL
GROUP BY patient_contact_id
ORDER BY n DESC
LIMIT 20;

-- How many diagnoses per patient?
SELECT pseudo_id, count(*) AS n
FROM amc_raw.medical_diagnosis
WHERE pseudo_id IS NOT NULL
GROUP BY pseudo_id
ORDER BY n DESC
LIMIT 20;

-- Date range (safe cast only where ISO format)
SELECT
  min(diagnosis_contact_date::date) AS min_diag_contact_date,
  max(diagnosis_contact_date::date) AS max_diag_contact_date
FROM amc_raw.medical_diagnosis
WHERE diagnosis_contact_date ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

-- Registration moment range
SELECT
  min(diagnosis_registration_moment::timestamptz) AS min_registration,
  max(diagnosis_registration_moment::timestamptz) AS max_registration
FROM amc_raw.medical_diagnosis
WHERE diagnosis_registration_moment ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}';

--some 14M of contact ids from the medical diagnisis table have an odd contact id location;nmr/null;nmr

