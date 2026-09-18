--===========================================================================

DROP TABLE IF EXISTS amc_core.measurement_bmi CASCADE;

CREATE TABLE amc_core.measurement_bmi (
  patient_contact_id text NOT NULL,
  measurement_moment timestamptz NOT NULL,
  bmi numeric NOT NULL,

  pseudo_id text,
  hospital_location text,
  meet_time time,
  meet_date date,
  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz,

  PRIMARY KEY (patient_contact_id, measurement_moment, bmi)
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.measurement_bmi (
  patient_contact_id,
  measurement_moment,
  bmi,
  pseudo_id,
  hospital_location,
  meet_time,
  meet_date,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT DISTINCT
  patient_contact_id,
  CASE WHEN trim(measurement_moment) ~ '^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}' THEN trim(measurement_moment)::timestamptz END,

  trim(bmi)::numeric,

  NULLIF(pseudo_id, ''),
  NULLIF(hospital_location, ''),
  CASE WHEN trim(meet_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(meet_time)::time END,
  CASE WHEN trim(meet_date) ~ '^\d{4}-\d{2}-\d{2}$' THEN trim(meet_date)::date END,
  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.measurement_bmi

WHERE NULLIF(patient_contact_id, '') IS NOT NULL
  AND NULLIF(measurement_moment, '') IS NOT NULL
  -- drop NULL / empty BMI
  AND NULLIF(trim(bmi), '') IS NOT NULL
  -- ensure numeric
  AND trim(bmi) ~ '^[-+]?[0-9]*\.?[0-9]+$';

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_bmi_pseudo_id
  ON amc_core.measurement_bmi(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_bmi_contact_id
  ON amc_core.measurement_bmi(patient_contact_id);

--CREATE INDEX IF NOT EXISTS idx_core_bmi_meet_date
--  ON amc_core.measurement_bmi(meet_date);

