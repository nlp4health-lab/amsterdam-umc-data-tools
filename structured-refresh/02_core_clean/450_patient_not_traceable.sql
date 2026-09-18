--===========================================================================
DROP TABLE IF EXISTS amc_core.patient_not_traceable CASCADE;

CREATE TABLE amc_core.patient_not_traceable (
  pseudo_id text PRIMARY KEY,

  year_of_birth integer,
  gender text,
  death_date_time timestamptz,

  is_deceased text,
  is_objection_patient text,
  objection_research_recruitment text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz
);

INSERT INTO amc_core.patient_not_traceable (
  pseudo_id,
  year_of_birth,
  gender,
  death_date_time,
  is_deceased,
  is_objection_patient,
  objection_research_recruitment,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(pseudo_id, ''),

  CASE
    WHEN trim(year_of_birth) ~ '^\d{4}$'
      THEN trim(year_of_birth)::integer
  END,

  NULLIF(gender, ''),

  NULLIF(death_date_time, '')::timestamptz,

  NULLIF(is_deceased, ''),
  NULLIF(is_objection_patient, ''),
  NULLIF(objection_research_recruitment, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.patient_not_traceable

WHERE NULLIF(pseudo_id, '') IS NOT NULL;

