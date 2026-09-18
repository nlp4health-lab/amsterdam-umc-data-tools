--===========================================================================

DROP TABLE IF EXISTS amc_core.measurement_fluid_balance_assessment_feces CASCADE;

CREATE TABLE amc_core.measurement_fluid_balance_assessment_feces (
  patient_contact_id text NOT NULL,
  measurement_moment timestamptz NOT NULL,

  pseudo_id text,
  hospital_location text,
  meet_time time,
  meet_date date,

  incontinence_feces text,
  consistency_feces text,
  consistency_feces_baby text,
  color_feces text,
  quantity_feces text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz,

  PRIMARY KEY (patient_contact_id, measurement_moment)
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.measurement_fluid_balance_assessment_feces (
  patient_contact_id,
  measurement_moment,
  pseudo_id,
  hospital_location,
  meet_time,
  meet_date,
  incontinence_feces,
  consistency_feces,
  consistency_feces_baby,
  color_feces,
  quantity_feces,
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

  NULLIF(incontinence_feces, ''),
  NULLIF(consistency_feces, ''),
  NULLIF(consistency_feces_baby, ''),
  NULLIF(color_feces, ''),
  NULLIF(quantity_feces, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.measurement_fluid_balance_assessment_feces

WHERE NULLIF(patient_contact_id, '') IS NOT NULL
  AND NULLIF(measurement_moment, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_feces_pseudo_id
  ON amc_core.measurement_fluid_balance_assessment_feces(pseudo_id);


