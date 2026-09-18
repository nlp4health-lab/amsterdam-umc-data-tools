-- ===========================================================================
DROP TABLE IF EXISTS amc_raw.adverse_event;

CREATE TABLE amc_raw.adverse_event (
  pseudo_id TEXT,
  adverse_event_id TEXT,
  patient_problem_status TEXT,
  is_seriously TEXT,
  is_expected TEXT,
  epic_diagnosis_id TEXT,
  diagnosis TEXT,
  course_date TEXT,
  adverse_event_relation_to_study TEXT,
  solution_date TEXT,
  research_project TEXT,
  research_project_name TEXT,
  research_project_start_date TEXT,
  research_project_status_description TEXT,
  study_code TEXT,
  research_project_participation_alias TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: adverse_event

--Sanity check:
SELECT count(*) AS n_rows FROM amc_raw.adverse_event;

SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL) AS null_pseudo,
  count(*) FILTER (WHERE adverse_event_id IS NULL) AS null_event_id
FROM amc_raw.adverse_event;

SELECT pg_size_pretty(pg_total_relation_size('amc_raw.adverse_event')) AS table_size;

