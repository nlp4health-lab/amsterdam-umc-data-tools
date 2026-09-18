--===========================================================================

DROP TABLE IF EXISTS amc_raw.medication_prescription;

CREATE TABLE amc_raw.medication_prescription (
  pseudo_id TEXT,
  hospital_location TEXT,
  rule_id TEXT,
  patient_contact_id TEXT,
  specialty_description TEXT,
  sub_specialty_description TEXT,
  prescription_date_time TEXT,
  prescription_date TEXT,
  prescription_time TEXT,
  start_date_time TEXT,
  start_date TEXT,
  start_time TEXT,
  stop_date_time TEXT,
  stop_date TEXT,
  stop_time TEXT,
  workplace_description TEXT,
  medication_article_name TEXT,
  medication_generic_name TEXT,
  medication_substance_name TEXT,
  pharmaceutical_class TEXT,
  pharmaceutical_subclass TEXT,
  therapeutic_class TEXT,
  order_class_description TEXT,
  order_status TEXT,
  order_description TEXT,
  previous_prescription_id TEXT,
  clinical_outpatient TEXT,
  atc_code TEXT,
  atc_name TEXT,
  medication_frequency_description TEXT,
  administration_route TEXT,
  dosage_prescribed_unit_description TEXT,
  dosage_prescribed_min TEXT,
  dosage_prescribed_max TEXT,
  dosage_calculated_unit_description TEXT,
  dosage_calculated_min TEXT,
  dosage_calculated_max TEXT,
  dosage_calculation_information TEXT,
  volume TEXT,
  weight_patient_kg TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: medication_prescription

-- Row count
SELECT count(*) AS n_rows
FROM amc_raw.medication_prescription;

-- Key fields null check
SELECT
  count(*) FILTER (WHERE rule_id IS NULL OR btrim(rule_id) = '') AS null_rule_id,
  count(*) FILTER (WHERE patient_contact_id IS NULL OR btrim(patient_contact_id) = '') AS null_contact,
  count(*) FILTER (WHERE atc_code IS NULL OR btrim(atc_code) = '') AS null_atc_code
FROM amc_raw.medication_prescription;

-- Is rule_id unique?
SELECT
  count(*) AS n,
  count(DISTINCT rule_id) AS distinct_rule_id
FROM amc_raw.medication_prescription;

-- Max prescriptions per contact
SELECT patient_contact_id, count(*) AS n
FROM amc_raw.medication_prescription
WHERE patient_contact_id IS NOT NULL
GROUP BY patient_contact_id
ORDER BY n DESC
LIMIT 20;

-- Date sanity
SELECT
  min(prescription_date_time::timestamptz) AS min_presc,
  max(prescription_date_time::timestamptz) AS max_presc
FROM amc_raw.medication_prescription
WHERE prescription_date_time ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}';

--ruleid is unique 

