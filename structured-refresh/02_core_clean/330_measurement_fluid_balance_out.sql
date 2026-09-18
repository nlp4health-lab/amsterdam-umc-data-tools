--===========================================================================
--===========================================================================
-- measurement_fluid_balance_out: raw → core
--===========================================================================

DROP TABLE IF EXISTS amc_core.measurement_fluid_balance_out CASCADE;

CREATE TABLE amc_core.measurement_fluid_balance_out (
  measurement_moisture_out_id text PRIMARY KEY,

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
  moisture_out_type text,
  moisture_balance_out_type_code text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz

  -- rn intentionally dropped in core
);

INSERT INTO amc_core.measurement_fluid_balance_out (
  measurement_moisture_out_id,
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
  moisture_out_type,
  moisture_balance_out_type_code,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  measurement_moisture_out_id,
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
  NULLIF(moisture_out_type, ''),
  NULLIF(moisture_balance_out_type_code, ''),
  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz
FROM amc_raw.measurement_fluid_balance_out
WHERE NULLIF(measurement_moisture_out_id, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_fluid_out_pseudo_id
  ON amc_core.measurement_fluid_balance_out(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_fluid_out_patient_contact_id
  ON amc_core.measurement_fluid_balance_out(patient_contact_id);

