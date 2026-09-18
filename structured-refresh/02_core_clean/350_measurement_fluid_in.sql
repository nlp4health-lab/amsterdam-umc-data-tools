--===========================================================================
DROP TABLE IF EXISTS amc_core.measurement_fluid_in CASCADE;

CREATE TABLE amc_core.measurement_fluid_in (
  measurement_moisture_at_id text PRIMARY KEY,

  pseudo_id text,
  patient_contact_id text,
  meet_time time,
  meet_date date,
  measurement_moment timestamptz,
  hospital_location text,

  lda_observation_id text,
  lda_description text,
  question_observation_description text,
  question_observation_code text,

  value text,
  unit text,
  moisture_balance_at_type text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz

  -- rn intentionally dropped in core
);

INSERT INTO amc_core.measurement_fluid_in (
  measurement_moisture_at_id,
  pseudo_id,
  patient_contact_id,
  meet_time,
  meet_date,
  measurement_moment,
  hospital_location,
  lda_observation_id,
  lda_description,
  question_observation_description,
  question_observation_code,
  value,
  unit,
  moisture_balance_at_type,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  measurement_moisture_at_id,
  NULLIF(pseudo_id, ''),
  NULLIF(patient_contact_id, ''),
  CASE WHEN trim(meet_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(meet_time)::time END,
  CASE WHEN trim(meet_date) ~ '^\d{4}-\d{2}-\d{2}$' THEN trim(meet_date)::date END,
  CASE WHEN trim(measurement_moment) ~ '^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}' THEN trim(measurement_moment)::timestamptz END,
  NULLIF(hospital_location, ''),
  NULLIF(lda_observation_id, ''),
  NULLIF(lda_description, ''),
  NULLIF(question_observation_description, ''),
  NULLIF(question_observation_code, ''),
  NULLIF(value, ''),
  NULLIF(unit, ''),
  NULLIF(moisture_balance_at_type, ''),
  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz
FROM amc_raw.measurement_fluid_in
WHERE NULLIF(measurement_moisture_at_id, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_fluid_in_pseudo_id
  ON amc_core.measurement_fluid_in(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_fluid_in_patient_contact_id
  ON amc_core.measurement_fluid_in(patient_contact_id);

