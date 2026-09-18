--===========================================================================
DROP TABLE IF EXISTS amc_raw.medical_history;

CREATE TABLE amc_raw.medical_history (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  registration_date TEXT,
  diagnosis_category TEXT,
  diagnosis_code TEXT,
  diagnosis_description TEXT,
  indication_determination_date TEXT,
  history_explanation TEXT,
  history_annotation TEXT,
  anamnese_source TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: medical_history

-- Sanity checks

-- Row count
SELECT count(*) AS n_rows
FROM amc_raw.medical_history;

-- Null checks on important columns
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL) AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL) AS null_contact,
  count(*) FILTER (WHERE diagnosis_code IS NULL) AS null_diag_code
FROM amc_raw.medical_history;

-- How many history records per contact?
SELECT patient_contact_id, count(*) AS n
FROM amc_raw.medical_history
WHERE patient_contact_id IS NOT NULL
GROUP BY patient_contact_id
ORDER BY n DESC
LIMIT 20;

-- How many per patient?
SELECT pseudo_id, count(*) AS n
FROM amc_raw.medical_history
WHERE pseudo_id IS NOT NULL
GROUP BY pseudo_id
ORDER BY n DESC
LIMIT 20;

-- Registration date range (safe cast)
SELECT
  min(registration_date::date) AS min_registration_date,
  max(registration_date::date) AS max_registration_date
FROM amc_raw.medical_history
WHERE registration_date ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

-- Indication date range
SELECT
  min(indication_determination_date::date) AS min_indication_date,
  max(indication_determination_date::date) AS max_indication_date
FROM amc_raw.medical_history
WHERE indication_determination_date ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

