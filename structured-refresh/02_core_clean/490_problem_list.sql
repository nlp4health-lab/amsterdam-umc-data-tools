--===========================================================================
DROP TABLE IF EXISTS amc_core.problem_list CASCADE;

CREATE TABLE amc_core.problem_list (
  patient_contact_id text NOT NULL,
  problem_list_id text NOT NULL,

  pseudo_id text,
  problem_description text,
  problem_code text,
  diagnosis_code text,
  diagnosis_category text,
  patient_problem_status text,
  patient_contact_type text,
  problem_description_display_epic text,

  patient_contact_date date,
  patient_contact_date_time timestamptz,
  observation_date date,
  registration_date date,
  close_date date,

  is_chronic text,
  is_chief_problem text,
  is_hospital_problem text,

  hospital_location text,

  diagnose_thesaurus_code text,
  snomed_code text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz,

  PRIMARY KEY (patient_contact_id, problem_list_id)
);

INSERT INTO amc_core.problem_list (
  patient_contact_id,
  problem_list_id,
  pseudo_id,
  problem_description,
  problem_code,
  diagnosis_code,
  diagnosis_category,
  patient_problem_status,
  patient_contact_type,
  problem_description_display_epic,
  patient_contact_date,
  patient_contact_date_time,
  observation_date,
  registration_date,
  close_date,
  is_chronic,
  is_chief_problem,
  is_hospital_problem,
  hospital_location,
  diagnose_thesaurus_code,
  snomed_code,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(patient_contact_id, ''),
  NULLIF(problem_list_id, ''),

  NULLIF(pseudo_id, ''),
  NULLIF(problem_description, ''),
  NULLIF(problem_code, ''),
  NULLIF(diagnosis_code, ''),
  NULLIF(diagnosis_category, ''),
  NULLIF(patient_problem_status, ''),
  NULLIF(patient_contact_type, ''),
  NULLIF(problem_description_display_epic, ''),

  NULLIF(patient_contact_date, '')::date,
  NULLIF(patient_contact_date_time, '')::timestamptz,
  NULLIF(observation_date, '')::date,
  NULLIF(registration_date, '')::date,
  NULLIF(close_date, '')::date,

  NULLIF(is_chronic, ''),
  NULLIF(is_chief_problem, ''),
  NULLIF(is_hospital_problem, ''),

  NULLIF(hospital_location, ''),

  NULLIF(diagnose_thesaurus_code, ''),
  NULLIF(snomed_code, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.problem_list

WHERE NULLIF(patient_contact_id, '') IS NOT NULL
  AND NULLIF(problem_list_id, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_problem_list_pseudo
  ON amc_core.problem_list(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_problem_list_snomed
  ON amc_core.problem_list(snomed_code);

CREATE INDEX IF NOT EXISTS idx_core_problem_list_diag_code
  ON amc_core.problem_list(diagnosis_code);

