--===========================================================================

DROP TABLE IF EXISTS amc_core.procedures CASCADE;

CREATE TABLE amc_core.procedures (
  pseudo_id text NOT NULL,
  intervention_id text NOT NULL,

  intervention_date date,
  intervention_code text,
  intervention text,
  hospital_location text,
  patient_contact_id text,
  age_in_years_at_moment_of_intervention_raw text,
  age_in_years_at_moment_of_intervention numeric,
  subtraject_id text,
  ok_session_number text,
  order_id text,
  care_activity text,
  care_profile_class text,
  requesting_specialty_abbreviation text,
  requesting_sub_specialty_code text,
  requesting_sub_specialty text,
  executive_specialty text,
  executive_sub_specialty text,
  executive_workplace text,
  source_module text,
  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz,

  PRIMARY KEY (pseudo_id, intervention_id)
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.procedures (
  pseudo_id,
  intervention_id,
  intervention_date,
  intervention_code,
  intervention,
  hospital_location,
  patient_contact_id,
  age_in_years_at_moment_of_intervention_raw, age_in_years_at_moment_of_intervention,
  subtraject_id,
  ok_session_number,
  order_id,
  care_activity,
  care_profile_class,
  requesting_specialty_abbreviation,
  requesting_sub_specialty_code,
  requesting_sub_specialty,
  executive_specialty,
  executive_sub_specialty,
  executive_workplace,
  source_module,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  pseudo_id,
  intervention_id,

  NULLIF(intervention_date, '')::date,
  NULLIF(intervention_code, ''),
  NULLIF(intervention, ''),
  NULLIF(hospital_location, ''),
  NULLIF(patient_contact_id, ''),

  NULLIF(age_in_years_at_moment_of_intervention, ''),

  CASE
    WHEN trim(age_in_years_at_moment_of_intervention) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(age_in_years_at_moment_of_intervention)::numeric
    ELSE NULL
  END,

  NULLIF(subtraject_id, ''),
  NULLIF(ok_session_number, ''),
  NULLIF(order_id, ''),
  NULLIF(care_activity, ''),
  NULLIF(care_profile_class, ''),
  NULLIF(requesting_specialty_abbreviation, ''),
  NULLIF(requesting_sub_specialty_code, ''),
  NULLIF(requesting_sub_specialty, ''),
  NULLIF(executive_specialty, ''),
  NULLIF(executive_sub_specialty, ''),
  NULLIF(executive_workplace, ''),
  NULLIF(source_module, ''),
  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz
FROM amc_raw.procedures
WHERE NULLIF(pseudo_id, '') IS NOT NULL
  AND NULLIF(intervention_id, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_procedures_intervention_date
  ON amc_core.procedures(intervention_date);

CREATE INDEX IF NOT EXISTS idx_core_procedures_patient_contact_id
  ON amc_core.procedures(patient_contact_id);

CREATE INDEX IF NOT EXISTS idx_core_procedures_subtraject_id
  ON amc_core.procedures(subtraject_id);

