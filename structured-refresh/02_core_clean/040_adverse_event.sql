--===========================================================================
DROP TABLE IF EXISTS amc_core.adverse_event CASCADE;

CREATE TABLE amc_core.adverse_event (
  pseudo_id text NOT NULL,
  adverse_event_id text PRIMARY KEY,

  patient_problem_status text,
  is_seriously text,
  is_expected text,

  epic_diagnosis_id text,
  diagnosis text,

  course_date date,
  adverse_event_relation_to_study text,
  solution_date date,

  research_project text,
  research_project_name text,
  research_project_start_date date,
  research_project_status_description text,
  study_code text,
  research_project_participation_alias text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz
);

INSERT INTO amc_core.adverse_event (
  pseudo_id, adverse_event_id,
  patient_problem_status, is_seriously, is_expected,
  epic_diagnosis_id, diagnosis,
  course_date, adverse_event_relation_to_study, solution_date,
  research_project, research_project_name, research_project_start_date,
  research_project_status_description, study_code, research_project_participation_alias,
  source, dcm_refreshed_date_time, issue_dt
)
SELECT
  pseudo_id,
  adverse_event_id,

  NULLIF(patient_problem_status,''),
  NULLIF(is_seriously,''),
  NULLIF(is_expected,''),

  NULLIF(epic_diagnosis_id,''),
  NULLIF(diagnosis,''),

  NULLIF(course_date,'')::date,
  NULLIF(adverse_event_relation_to_study,''),
  NULLIF(solution_date,'')::date,

  NULLIF(research_project,''),
  NULLIF(research_project_name,''),
  NULLIF(research_project_start_date,'')::date,

  NULLIF(research_project_status_description,''),
  NULLIF(study_code,''),
  NULLIF(research_project_participation_alias,''),

  NULLIF(source,''),
  NULLIF(dcm_refreshed_date_time,'')::timestamptz,
  NULLIF(issue_dt,'')::timestamptz
FROM amc_raw.adverse_event;

CREATE INDEX IF NOT EXISTS idx_core_adverse_event_pseudo
  ON amc_core.adverse_event(pseudo_id);

