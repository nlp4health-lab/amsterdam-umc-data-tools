--===========================================================================
DROP TABLE IF EXISTS amc_core.measurement_fluid_balance_stomach_retention CASCADE;

CREATE TABLE amc_core.measurement_fluid_balance_stomach_retention (
  patient_contact_id text NOT NULL,
  measurement_moment timestamptz NOT NULL,

  pseudo_id text,
  hospital_location text,
  meet_time time,
  meet_date date,

  stomach_retention_raw text,

  stomach_retention numeric,
  assessment_stomach_retention text,
  air_retention_raw text,
  air_retention numeric,
  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt date,

  PRIMARY KEY (patient_contact_id, measurement_moment)
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.measurement_fluid_balance_stomach_retention (
  patient_contact_id,
  measurement_moment,
  pseudo_id,
  hospital_location,
  meet_time,
  meet_date,
  stomach_retention_raw, stomach_retention,
  assessment_stomach_retention,
  air_retention_raw, air_retention,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  patient_contact_id,
  CASE WHEN trim(measurement_moment) ~ '^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}' THEN trim(measurement_moment)::timestamptz END,

  NULLIF(pseudo_id, ''),
  NULLIF(hospital_location, ''),
  CASE WHEN trim(meet_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(meet_time)::time END,
  CASE WHEN trim(meet_date) ~ '^\d{4}-\d{2}-\d{2}$' THEN trim(meet_date)::date END,

  NULLIF(stomach_retention, ''),

  CASE
    WHEN trim(stomach_retention) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
      THEN trim(stomach_retention)::numeric
    ELSE NULL
  END,

  NULLIF(assessment_stomach_retention, ''),

  NULLIF(air_retention, ''),

  CASE
    WHEN trim(air_retention) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
      THEN trim(air_retention)::numeric
    ELSE NULL
  END,

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::date

FROM amc_raw.measurement_fluid_balance_stomach_retention

WHERE NULLIF(patient_contact_id, '') IS NOT NULL
  AND NULLIF(measurement_moment, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_stomach_pseudo_id
  ON amc_core.measurement_fluid_balance_stomach_retention(pseudo_id);

create index if not exists idx_core_stomach_patient_contact_id
  on amc_core.measurement_fluid_balance_stomach_retention(patient_contact_id);  

