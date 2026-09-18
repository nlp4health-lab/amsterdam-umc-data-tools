--===========================================================================

DROP TABLE IF EXISTS amc_core.ok_procedure_performed CASCADE;

CREATE TABLE amc_core.ok_procedure_performed (
  ok_procedure_performed_id bigserial PRIMARY KEY,

  pseudo_id text,
  ok_session_number text,

  session_start_date date,
  session_start_date_time timestamptz,
  intervention_executed_date date,

  session_ok_specialty text,
  session_specialism text,
  ok_room text,
  ok_location text,
  ok_chief_location text,
  hospital_location text,

  chief_operator_panel_specialty text,
  chief_operator_panel_subspecialty text,
  chief_operator_panel_ok_specialty text,

  intervention text,
  care_activity text,
  is_chief_intervention text,
  laterality text,
  panel text,

  age_in_years_at_moment_of_session numeric,
  child_age_in_weeks_at_moment_of_session_raw text,
  child_age_in_weeks_at_moment_of_session numeric,
  dbc_diagnosis text,
  care_traject_description text,

  subtraject_id text,
  subtrajects_ids text,
  care_traject_id text,

  number_ok_interventions_performed numeric,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz

  -- rn intentionally dropped in core
);

INSERT INTO amc_core.ok_procedure_performed (
  pseudo_id,
  ok_session_number,
  session_start_date,
  session_start_date_time,
  intervention_executed_date,
  session_ok_specialty,
  session_specialism,
  ok_room,
  ok_location,
  ok_chief_location,
  hospital_location,
  chief_operator_panel_specialty,
  chief_operator_panel_subspecialty,
  chief_operator_panel_ok_specialty,
  intervention,
  care_activity,
  is_chief_intervention,
  laterality,
  panel,
  age_in_years_at_moment_of_session,
  child_age_in_weeks_at_moment_of_session_raw, child_age_in_weeks_at_moment_of_session,
  dbc_diagnosis,
  care_traject_description,
  subtraject_id,
  subtrajects_ids,
  care_traject_id,
  number_ok_interventions_performed,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(pseudo_id, ''),
  NULLIF(ok_session_number, ''),

  NULLIF(session_start_date, '')::date,
  NULLIF(session_start_date_time, '')::timestamptz,
  NULLIF(intervention_executed_date, '')::date,

  NULLIF(session_ok_specialty, ''),
  NULLIF(session_specialism, ''),
  NULLIF(ok_room, ''),
  NULLIF(ok_location, ''),
  NULLIF(ok_chief_location, ''),
  NULLIF(hospital_location, ''),

  NULLIF(chief_operator_panel_specialty, ''),
  NULLIF(chief_operator_panel_subspecialty, ''),
  NULLIF(chief_operator_panel_ok_specialty, ''),

  NULLIF(intervention, ''),
  NULLIF(care_activity, ''),
  NULLIF(is_chief_intervention, ''),
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

  NULLIF(dbc_diagnosis, ''),
  NULLIF(care_traject_description, ''),

  NULLIF(subtraject_id, ''),
  NULLIF(subtrajects_ids, ''),
  NULLIF(care_traject_id, ''),

  CASE
    WHEN trim(number_ok_interventions_performed) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(number_ok_interventions_performed)::numeric
    ELSE NULL
  END,

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.ok_procedure_performed;

-- indexes (optional but useful)
CREATE INDEX IF NOT EXISTS idx_core_okproc_pseudo_id
  ON amc_core.ok_procedure_performed(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_okproc_session
  ON amc_core.ok_procedure_performed(ok_session_number);

CREATE INDEX IF NOT EXISTS idx_core_okproc_subtraject
  ON amc_core.ok_procedure_performed(subtraject_id);

