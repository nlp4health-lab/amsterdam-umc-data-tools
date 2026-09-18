--===========================================================================
DROP TABLE IF EXISTS amc_core.patient_social CASCADE;

CREATE TABLE amc_core.patient_social (
  pseudo_id text PRIMARY KEY,

  marital_status text,
  education_level text,
  is_multiple text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt date
);

INSERT INTO amc_core.patient_social (
  pseudo_id,
  marital_status,
  education_level,
  is_multiple,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(pseudo_id, ''),

  NULLIF(marital_status, ''),
  NULLIF(education_level, ''),
  NULLIF(is_multiple, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::date

FROM amc_raw.patient_social

WHERE NULLIF(pseudo_id, '') IS NOT NULL;

