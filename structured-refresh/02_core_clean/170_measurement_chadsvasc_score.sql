--===========================================================================

DROP TABLE IF EXISTS amc_core.measurement_chadsvasc_score CASCADE;

CREATE TABLE amc_core.measurement_chadsvasc_score (
  patient_contact_id text NOT NULL,
  measurement_moment timestamptz NOT NULL,

  pseudo_id text,
  hospital_location text,
  meet_time time,
  meet_date date,

  stroke_risk text,
  congestive_heart_failure text,
  hypertension text,
  age text,
  diabetes_mellitus text,
  stroke_ti_athrombo_embolism text,
  vascular_disease text,
  sex text,
  chadsvasc_score numeric,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz,

  PRIMARY KEY (patient_contact_id, measurement_moment)
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.measurement_chadsvasc_score (
  patient_contact_id,
  measurement_moment,
  pseudo_id,
  hospital_location,
  meet_time,
  meet_date,
  stroke_risk,
  congestive_heart_failure,
  hypertension,
  age,
  diabetes_mellitus,
  stroke_ti_athrombo_embolism,
  vascular_disease,
  sex,
  chadsvasc_score,
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

  NULLIF(stroke_risk, ''),
  NULLIF(congestive_heart_failure, ''),
  NULLIF(hypertension, ''),
  NULLIF(age, ''),
  NULLIF(diabetes_mellitus, ''),
  NULLIF(stroke_ti_athrombo_embolism, ''),
  NULLIF(vascular_disease, ''),
  NULLIF(sex, ''),

  CASE
    WHEN trim(chadsvasc_score) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(chadsvasc_score)::numeric
    ELSE NULL
  END,

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.measurement_chadsvasc_score

WHERE NULLIF(patient_contact_id, '') IS NOT NULL
  AND NULLIF(measurement_moment, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_chads_pseudo_id
  ON amc_core.measurement_chadsvasc_score(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_chads_contact_id
  ON amc_core.measurement_chadsvasc_score(patient_contact_id);

--CREATE INDEX IF NOT EXISTS idx_core_chads_meet_date
--  ON amc_core.measurement_chadsvasc_score(meet_date);


