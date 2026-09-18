--===========================================================================
DROP TABLE IF EXISTS amc_core.measurement_blood_pressure CASCADE;

CREATE TABLE amc_core.measurement_blood_pressure (
  patient_contact_id text NOT NULL,
  measurement_moment timestamptz NOT NULL,
  demand_observation text NOT NULL,

  pseudo_id text,
  hospital_location text,
  meet_time time,
  meet_date date,
  blood_pressure_supplemented text,
  systolic_blood_pressure_value numeric,
  diastolic_blood_pressure_value numeric,
  question_observation_code text,
  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz,

  PRIMARY KEY (patient_contact_id, measurement_moment, demand_observation)
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.measurement_blood_pressure (
  patient_contact_id,
  measurement_moment,
  demand_observation,
  pseudo_id,
  hospital_location,
  meet_time,
  meet_date,
  blood_pressure_supplemented,
  systolic_blood_pressure_value,
  diastolic_blood_pressure_value,
  question_observation_code,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  patient_contact_id,
  CASE WHEN trim(measurement_moment) ~ '^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}' THEN trim(measurement_moment)::timestamptz END,
  demand_observation,

  NULLIF(pseudo_id, ''),
  NULLIF(hospital_location, ''),
  CASE WHEN trim(meet_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(meet_time)::time END,
  CASE WHEN trim(meet_date) ~ '^\d{4}-\d{2}-\d{2}$' THEN trim(meet_date)::date END,
  NULLIF(blood_pressure_supplemented, ''),

  CASE
    WHEN trim(systolic_blood_pressure_value) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(systolic_blood_pressure_value)::numeric
    ELSE NULL
  END,

  CASE
    WHEN trim(diastolic_blood_pressure_value) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(diastolic_blood_pressure_value)::numeric
    ELSE NULL
  END,

  NULLIF(question_observation_code, ''),
  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz
FROM amc_raw.measurement_blood_pressure
WHERE NULLIF(patient_contact_id, '') IS NOT NULL
  AND NULLIF(measurement_moment, '') IS NOT NULL
  AND NULLIF(demand_observation, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_bp_contact_id
  ON amc_core.measurement_blood_pressure(patient_contact_id);

