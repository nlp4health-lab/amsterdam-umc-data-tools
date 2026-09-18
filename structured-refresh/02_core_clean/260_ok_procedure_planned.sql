--===========================================================================

DROP TABLE IF EXISTS amc_core.ok_procedure_planned CASCADE;

CREATE TABLE amc_core.ok_procedure_planned (
  ok_procedure_planned_id bigserial PRIMARY KEY,

  pseudo_id text,
  ok_session_number text,

  session_planned_start_date date,

  chief_operator_panel_specialty text,
  chief_operator_panel_subspecialty text,
  chief_operator_panel_ok_specialty text,

  session_specialism text,
  session_subspecialty text,
  session_ok_specialty text,
  session_ok_plan_status text,

  ok_anesthesia_type text,
  ok_room text,
  ok_location text,
  ok_chief_location text,
  hospital_location text,

  intervention text,
  intervention_code text,
  laterality text,
  panel text,

  age_in_years_at_moment_of_session numeric,
  child_age_in_weeks_at_moment_of_session_raw text,
  child_age_in_weeks_at_moment_of_session numeric,
  is_patient_deceased text,

  care_traject_description text,
  dbc_diagnosis text,

  lowest_subtraject_id text,
  subtrajects_ids text,
  care_traject_id text,

  scheduled_time_minutes numeric,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz

  -- rn intentionally dropped in core
);

INSERT INTO amc_core.ok_procedure_planned (
  pseudo_id,
  ok_session_number,
  session_planned_start_date,
  chief_operator_panel_specialty,
  chief_operator_panel_subspecialty,
  chief_operator_panel_ok_specialty,
  session_specialism,
  session_subspecialty,
  session_ok_specialty,
  session_ok_plan_status,
  ok_anesthesia_type,
  ok_room,
  ok_location,
  ok_chief_location,
  hospital_location,
  intervention,
  intervention_code,
  laterality,
  panel,
  age_in_years_at_moment_of_session,
  child_age_in_weeks_at_moment_of_session_raw, child_age_in_weeks_at_moment_of_session,
  is_patient_deceased,
  care_traject_description,
  dbc_diagnosis,
  lowest_subtraject_id,
  subtrajects_ids,
  care_traject_id,
  scheduled_time_minutes,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(pseudo_id, ''),
  NULLIF(ok_session_number, ''),

  NULLIF(session_planned_start_date, '')::date,

  NULLIF(chief_operator_panel_specialty, ''),
  NULLIF(chief_operator_panel_subspecialty, ''),
  NULLIF(chief_operator_panel_ok_specialty, ''),

  NULLIF(session_specialism, ''),
  NULLIF(session_subspecialty, ''),
  NULLIF(session_ok_specialty, ''),
  NULLIF(session_ok_plan_status, ''),

  NULLIF(ok_anesthesia_type, ''),
  NULLIF(ok_room, ''),
  NULLIF(ok_location, ''),
  NULLIF(ok_chief_location, ''),
  NULLIF(hospital_location, ''),

  NULLIF(intervention, ''),
  NULLIF(intervention_code, ''),
  NULLIF(laterality, ''),
  NULLIF(panel, ''),

  CASE
    WHEN trim(age_in_years_at_moment_of_session) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(age_in_years_at_moment_of_session)::numeric
    ELSE NULL
  END,

  NULLIF(child_age_in_weeks_at_moment_of_session, ''),

  CASE
    WHEN trim(child_age_in_weeks_at_moment_of_session) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(child_age_in_weeks_at_moment_of_session)::numeric
    ELSE NULL
  END,

  NULLIF(is_patient_deceased, ''),

  NULLIF(care_traject_description, ''),
  NULLIF(dbc_diagnosis, ''),

  NULLIF(lowest_subtraject_id, ''),
  NULLIF(subtrajects_ids, ''),
  NULLIF(care_traject_id, ''),

  CASE
    WHEN trim(scheduled_time_minutes) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(scheduled_time_minutes)::numeric
    ELSE NULL
  END,

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.ok_procedure_planned;

-- indexes (optional but useful)
CREATE INDEX IF NOT EXISTS idx_core_okplan_pseudo_id
  ON amc_core.ok_procedure_planned(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_okplan_session
  ON amc_core.ok_procedure_planned(ok_session_number);

