--===========================================================================

DROP TABLE IF EXISTS amc_core.measurement_diurese CASCADE;

CREATE TABLE amc_core.measurement_diurese (
  patient_contact_id text NOT NULL,
  measurement_moment timestamptz NOT NULL,

  pseudo_id text,
  hospital_location text,
  meet_time time,
  meet_date date,
  diuresis_output numeric,
  unit text,
  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt date,

  PRIMARY KEY (patient_contact_id, measurement_moment)
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.measurement_diurese (
  patient_contact_id,
  measurement_moment,
  pseudo_id,
  hospital_location,
  meet_time,
  meet_date,
  diuresis_output,
  unit,
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

  CASE
    WHEN trim(diuresis_output) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(diuresis_output)::numeric
    ELSE NULL
  END,

  NULLIF(unit, ''),
  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::date

FROM amc_raw.measurement_diurese

WHERE NULLIF(patient_contact_id, '') IS NOT NULL
  AND NULLIF(measurement_moment, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_diurese_pseudo_id
  ON amc_core.measurement_diurese(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_diurese_contact_id
  ON amc_core.measurement_diurese(patient_contact_id);

--CREATE INDEX IF NOT EXISTS idx_core_diurese_meet_date
--  ON amc_core.measurement_diurese(meet_date);

