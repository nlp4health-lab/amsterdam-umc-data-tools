--===========================================================================
DROP TABLE IF EXISTS amc_core.medication_prescription CASCADE;

CREATE TABLE amc_core.medication_prescription (
  rule_id text PRIMARY KEY,

  pseudo_id text,
  patient_contact_id text,
  hospital_location text,

  specialty_description text,
  sub_specialty_description text,

  prescription_date_time timestamptz,
  prescription_date date,
  prescription_time time,

  start_date_time timestamptz,
  start_date date,
  start_time time,

  stop_date_time timestamptz,
  stop_date date,
  stop_time time,

  workplace_description text,

  medication_article_name text,
  medication_generic_name text,
  medication_substance_name text,

  pharmaceutical_class text,
  pharmaceutical_subclass text,
  therapeutic_class text,

  order_class_description text,
  order_status text,
  order_description text,

  previous_prescription_id text,
  clinical_outpatient text,

  atc_code text,
  atc_name text,

  medication_frequency_description text,
  administration_route text,

  dosage_prescribed_unit_description text,
  dosage_prescribed_min numeric,
  dosage_prescribed_max numeric,

  dosage_calculated_unit_description text,
  dosage_calculated_min numeric,
  dosage_calculated_max numeric,
  dosage_calculation_information text,

  volume numeric,
  weight_patient_kg numeric,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt date

  -- rn intentionally dropped
);

INSERT INTO amc_core.medication_prescription (
  rule_id,
  pseudo_id,
  patient_contact_id,
  hospital_location,
  specialty_description,
  sub_specialty_description,
  prescription_date_time,
  prescription_date,
  prescription_time,
  start_date_time,
  start_date,
  start_time,
  stop_date_time,
  stop_date,
  stop_time,
  workplace_description,
  medication_article_name,
  medication_generic_name,
  medication_substance_name,
  pharmaceutical_class,
  pharmaceutical_subclass,
  therapeutic_class,
  order_class_description,
  order_status,
  order_description,
  previous_prescription_id,
  clinical_outpatient,
  atc_code,
  atc_name,
  medication_frequency_description,
  administration_route,
  dosage_prescribed_unit_description,
  dosage_prescribed_min,
  dosage_prescribed_max,
  dosage_calculated_unit_description,
  dosage_calculated_min,
  dosage_calculated_max,
  dosage_calculation_information,
  volume,
  weight_patient_kg,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(rule_id, ''),
  NULLIF(pseudo_id, ''),
  NULLIF(patient_contact_id, ''),
  NULLIF(hospital_location, ''),

  NULLIF(specialty_description, ''),
  NULLIF(sub_specialty_description, ''),

  NULLIF(prescription_date_time, '')::timestamptz,
  NULLIF(prescription_date, '')::date,
  CASE WHEN trim(prescription_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(prescription_time)::time END,

  NULLIF(start_date_time, '')::timestamptz,
  NULLIF(start_date, '')::date,
  CASE WHEN trim(start_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(start_time)::time END,

  NULLIF(stop_date_time, '')::timestamptz,
  NULLIF(stop_date, '')::date,
  CASE WHEN trim(stop_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(stop_time)::time END,

  NULLIF(workplace_description, ''),

  NULLIF(medication_article_name, ''),
  NULLIF(medication_generic_name, ''),
  NULLIF(medication_substance_name, ''),

  NULLIF(pharmaceutical_class, ''),
  NULLIF(pharmaceutical_subclass, ''),
  NULLIF(therapeutic_class, ''),

  NULLIF(order_class_description, ''),
  NULLIF(order_status, ''),
  NULLIF(order_description, ''),

  NULLIF(previous_prescription_id, ''),
  NULLIF(clinical_outpatient, ''),

  NULLIF(atc_code, ''),
  NULLIF(atc_name, ''),

  NULLIF(medication_frequency_description, ''),
  NULLIF(administration_route, ''),

  NULLIF(dosage_prescribed_unit_description, ''),

  CASE WHEN trim(dosage_prescribed_min) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(dosage_prescribed_min)::numeric END,

  CASE WHEN trim(dosage_prescribed_max) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(dosage_prescribed_max)::numeric END,

  NULLIF(dosage_calculated_unit_description, ''),

  CASE WHEN trim(dosage_calculated_min) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(dosage_calculated_min)::numeric END,

  CASE WHEN trim(dosage_calculated_max) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(dosage_calculated_max)::numeric END,

  NULLIF(dosage_calculation_information, ''),

  CASE WHEN trim(volume) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(volume)::numeric END,

  CASE WHEN trim(weight_patient_kg) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(weight_patient_kg)::numeric END,

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::date

FROM amc_raw.medication_prescription

WHERE NULLIF(rule_id, '') IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_core_med_presc_patient_contact
  ON amc_core.medication_prescription(patient_contact_id);

