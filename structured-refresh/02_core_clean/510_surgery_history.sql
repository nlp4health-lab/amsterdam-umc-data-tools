--===========================================================================
DROP TABLE IF EXISTS amc_core.surgery_history CASCADE;

CREATE TABLE amc_core.surgery_history (
  surgery_history_id bigserial PRIMARY KEY,

  pseudo_id text,
  patient_contact_id text,
  hospital_location text,

  registration_date date,
  procedure_start_date date,
  procedure_end_date date,

  surgical_past_history_code text,
  type_code text,
  surgical_past_history text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz

  -- rn intentionally dropped
);

INSERT INTO amc_core.surgery_history (
  pseudo_id,
  patient_contact_id,
  hospital_location,
  registration_date,
  procedure_start_date,
  procedure_end_date,
  surgical_past_history_code,
  type_code,
  surgical_past_history,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(pseudo_id, ''),
  NULLIF(patient_contact_id, ''),
  NULLIF(hospital_location, ''),

  NULLIF(registration_date, '')::date,
  NULLIF(procedure_start_date, '')::date,
  NULLIF(procedure_end_date, '')::date,

  NULLIF(surgical_past_history_code, ''),
  NULLIF(type_code, ''),
  NULLIF(surgical_past_history, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.surgery_history;

CREATE INDEX IF NOT EXISTS idx_core_surgery_pseudo
  ON amc_core.surgery_history(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_surgery_contact
  ON amc_core.surgery_history(patient_contact_id);

