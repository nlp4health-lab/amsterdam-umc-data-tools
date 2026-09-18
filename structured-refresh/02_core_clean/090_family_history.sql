--===========================================================================
DROP TABLE IF EXISTS amc_core.family_history CASCADE;

CREATE TABLE amc_core.family_history (
  family_history_id bigserial PRIMARY KEY,

  pseudo_id text NOT NULL,
  patient_contact_id text,
  hospital_location text,
  registration_date date,
  family_history text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz
);

INSERT INTO amc_core.family_history (
  pseudo_id,
  patient_contact_id,
  hospital_location,
  registration_date,
  family_history,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  pseudo_id,
  NULLIF(patient_contact_id,''),
  NULLIF(hospital_location,''),
  NULLIF(registration_date,'')::date,
  NULLIF(family_history,''),
  NULLIF(source,''),
  NULLIF(dcm_refreshed_date_time,'')::timestamptz,
  NULLIF(issue_dt,'')::timestamptz
FROM amc_raw.family_history;

CREATE INDEX IF NOT EXISTS idx_core_family_history_pseudo
  ON amc_core.family_history(pseudo_id);

-- all dates are plausible.
