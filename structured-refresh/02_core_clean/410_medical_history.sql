--===========================================================================
DROP TABLE IF EXISTS amc_core.medical_history CASCADE;

CREATE TABLE amc_core.medical_history (
  medical_history_id bigserial PRIMARY KEY,

  pseudo_id text,
  patient_contact_id text,
  hospital_location text,

  registration_date date,

  diagnosis_category text,
  diagnosis_code text,
  diagnosis_description text,

  indication_determination_date_raw text,
  indication_determination_date date,

  history_explanation text,
  history_annotation text,
  anamnese_source text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz

  -- rn intentionally dropped in core
);

INSERT INTO amc_core.medical_history (
  pseudo_id,
  patient_contact_id,
  hospital_location,
  registration_date,
  diagnosis_category,
  diagnosis_code,
  diagnosis_description,
  indication_determination_date_raw,
  indication_determination_date,
  history_explanation,
  history_annotation,
  anamnese_source,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(pseudo_id, ''),
  NULLIF(patient_contact_id, ''),
  NULLIF(hospital_location, ''),

  NULLIF(registration_date, '')::date,

  NULLIF(diagnosis_category, ''),
  NULLIF(diagnosis_code, ''),
  NULLIF(diagnosis_description, ''),

  NULLIF(indication_determination_date, ''),

  CASE
    WHEN trim(indication_determination_date) ~ '^\d{4}-\d{2}-\d{2}$'
      THEN trim(indication_determination_date)::date
    ELSE NULL
  END,

  NULLIF(history_explanation, ''),
  NULLIF(history_annotation, ''),
  NULLIF(anamnese_source, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.medical_history;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_history_pseudo_id
  ON amc_core.medical_history(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_history_contact
  ON amc_core.medical_history(patient_contact_id);

CREATE INDEX IF NOT EXISTS idx_core_history_code
  ON amc_core.medical_history(diagnosis_code);

