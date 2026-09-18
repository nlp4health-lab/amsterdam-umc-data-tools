--===========================================================================
DROP TABLE IF EXISTS amc_core.medical_diagnosis CASCADE;

CREATE TABLE amc_core.medical_diagnosis (
  medical_diagnosis_id bigserial PRIMARY KEY,

  pseudo_id text,
  patient_contact_id text,
  hospital_location text,

  diagnosis_contact_date date,
  diagnosis_registration_moment timestamptz,

  diagnosis_code text,
  diagnosis_category text,
  diagnosis_description text,
  diagnosis_type text,

  clinical_outpatient text,
  specialty text,
  is_complication text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz

  -- rn intentionally dropped in core
);

INSERT INTO amc_core.medical_diagnosis (
  pseudo_id,
  patient_contact_id,
  hospital_location,
  diagnosis_contact_date,
  diagnosis_registration_moment,
  diagnosis_code,
  diagnosis_category,
  diagnosis_description,
  diagnosis_type,
  clinical_outpatient,
  specialty,
  is_complication,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(pseudo_id, ''),
  NULLIF(patient_contact_id, ''),
  NULLIF(hospital_location, ''),

  NULLIF(diagnosis_contact_date, '')::date,
  NULLIF(diagnosis_registration_moment, '')::timestamptz,

  NULLIF(diagnosis_code, ''),
  NULLIF(diagnosis_category, ''),
  NULLIF(diagnosis_description, ''),
  NULLIF(diagnosis_type, ''),

  NULLIF(clinical_outpatient, ''),
  NULLIF(specialty, ''),
  NULLIF(is_complication, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.medical_diagnosis;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_diag_pseudo_id
  ON amc_core.medical_diagnosis(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_diag_contact
  ON amc_core.medical_diagnosis(patient_contact_id);

CREATE INDEX IF NOT EXISTS idx_core_diag_code
  ON amc_core.medical_diagnosis(diagnosis_code);

