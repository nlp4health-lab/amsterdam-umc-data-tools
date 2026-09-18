--===========================================================================
DROP TABLE IF EXISTS amc_core.medication_administration CASCADE;

CREATE TABLE amc_core.medication_administration (
  medication_administration_id bigserial PRIMARY KEY,

  pseudo_id text,
  rule_id text,
  patient_contact_id text,
  admission_traject_id text,

  administration_date_time timestamptz,
  administration_date date,
  administration_time time,

  administration_status text,
  walk_in text,
  walk_in_rate_unit text,

  number_submitted_pieces numeric,
  administered_amount numeric,
  administered_quantity_unit text,

  administration_route text,

  medication_article_name text,
  medication_substance_name text,
  medication_generic_name text,
  ingredient_type_name text,

  atc_code text,
  atc_name text,
  pharmaceutical_class text,
  pharmaceutical_subclass text,
  therapeutic_class text,

  medication_strength text,
  medication_strength_dosage text,
  medication_strength_unit text,

  workplace text,
  hospital_location text,

  administration_reason text,
  medication_remark text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt date

  -- rn intentionally dropped in core
);

INSERT INTO amc_core.medication_administration (
  pseudo_id,
  rule_id,
  patient_contact_id,
  admission_traject_id,
  administration_date_time,
  administration_date,
  administration_time,
  administration_status,
  walk_in,
  walk_in_rate_unit,
  number_submitted_pieces,
  administered_amount,
  administered_quantity_unit,
  administration_route,
  medication_article_name,
  medication_substance_name,
  medication_generic_name,
  ingredient_type_name,
  atc_code,
  atc_name,
  pharmaceutical_class,
  pharmaceutical_subclass,
  therapeutic_class,
  medication_strength,
  medication_strength_dosage,
  medication_strength_unit,
  workplace,
  hospital_location,
  administration_reason,
  medication_remark,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(pseudo_id, ''),
  NULLIF(rule_id, ''),
  NULLIF(patient_contact_id, ''),
  NULLIF(admission_traject_id, ''),

  NULLIF(administration_date_time, '')::timestamptz,
  NULLIF(administration_date, '')::date,
  CASE WHEN trim(administration_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(administration_time)::time END,

  NULLIF(administration_status, ''),
  NULLIF(walk_in, ''),
  NULLIF(walk_in_rate_unit, ''),

  CASE WHEN trim(number_submitted_pieces) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(number_submitted_pieces)::numeric END,

  CASE WHEN trim(administered_amount) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(administered_amount)::numeric END,

  NULLIF(administered_quantity_unit, ''),
  NULLIF(administration_route, ''),

  NULLIF(medication_article_name, ''),
  NULLIF(medication_substance_name, ''),
  NULLIF(medication_generic_name, ''),
  NULLIF(ingredient_type_name, ''),

  NULLIF(atc_code, ''),
  NULLIF(atc_name, ''),
  NULLIF(pharmaceutical_class, ''),
  NULLIF(pharmaceutical_subclass, ''),
  NULLIF(therapeutic_class, ''),

  NULLIF(medication_strength, ''),
  NULLIF(medication_strength_dosage, ''),
  NULLIF(medication_strength_unit, ''),

  NULLIF(workplace, ''),
  NULLIF(hospital_location, ''),

  NULLIF(administration_reason, ''),
  NULLIF(medication_remark, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::date

FROM amc_raw.medication_administration;

CREATE INDEX IF NOT EXISTS idx_core_med_admin_patient_contact_id
  ON amc_core.medication_administration(patient_contact_id);

