-- ===========================================================================
-- amc_raw.problem_list

DROP TABLE IF EXISTS amc_raw.problem_list;

CREATE TABLE amc_raw.problem_list (
  pseudo_id TEXT,
  problem_list_id TEXT,
  problem_description TEXT,
  problem_code TEXT,
  diagnosis_code TEXT,
  diagnosis_category TEXT,
  patient_problem_status TEXT,
  patient_contact_id TEXT,
  patient_contact_type TEXT,
  problem_description_display_epic TEXT,
  patient_contact_date TEXT,
  patient_contact_date_time TEXT,
  observation_date TEXT,
  registration_date TEXT,
  close_date TEXT,
  is_chronic TEXT,
  is_chief_problem TEXT,
  is_hospital_problem TEXT,
  hospital_location TEXT,
  diagnose_thesaurus_code TEXT,
  snomed_code TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: problem_list

-- Minimal sanity
SELECT count(*) AS n_rows
FROM amc_raw.problem_list;

SELECT count(*) AS null_problem_list_id
FROM amc_raw.problem_list
WHERE problem_list_id IS NULL OR btrim(problem_list_id) = '';

