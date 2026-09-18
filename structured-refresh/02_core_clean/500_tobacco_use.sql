--===========================================================================
DROP TABLE IF EXISTS amc_core.tobacco_use CASCADE;

CREATE TABLE amc_core.tobacco_use (
  tobacco_use_id bigserial PRIMARY KEY,

  pseudo_id text,
  patient_contact_id text,
  hospital_location text,

  registration_date date,
  workplace text,
  specialty text,

  start_date date,
  stop_date date,

  status_tobacco_use text,
  tobacco_use_explanation text,
  type_tobacco_use text,

  is_current_smoker text,
  is_former_smoker text,

  quantity_packages_per_day numeric,
  tobacco_use_years numeric,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz

  -- rn intentionally dropped
);

INSERT INTO amc_core.tobacco_use (
  pseudo_id,
  patient_contact_id,
  hospital_location,
  registration_date,
  workplace,
  specialty,
  start_date,
  stop_date,
  status_tobacco_use,
  tobacco_use_explanation,
  type_tobacco_use,
  is_current_smoker,
  is_former_smoker,
  quantity_packages_per_day,
  tobacco_use_years,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(pseudo_id, ''),
  NULLIF(patient_contact_id, ''),
  NULLIF(hospital_location, ''),

  NULLIF(registration_date, '')::date,
  NULLIF(workplace, ''),
  NULLIF(specialty, ''),

  NULLIF(start_date, '')::date,
  NULLIF(stop_date, '')::date,

  NULLIF(status_tobacco_use, ''),
  NULLIF(tobacco_use_explanation, ''),
  NULLIF(type_tobacco_use, ''),

  NULLIF(is_current_smoker, ''),
  NULLIF(is_former_smoker, ''),

  CASE
    WHEN trim(quantity_packages_per_day) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)$'
      THEN trim(quantity_packages_per_day)::numeric
  END,

  CASE
    WHEN trim(tobacco_use_years) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)$'
      THEN trim(tobacco_use_years)::numeric
  END,

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.tobacco_use;

CREATE INDEX IF NOT EXISTS idx_core_tobacco_pseudo
  ON amc_core.tobacco_use(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_tobacco_contact
  ON amc_core.tobacco_use(patient_contact_id);

