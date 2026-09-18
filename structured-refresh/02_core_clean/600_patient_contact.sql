--===============================================================
DROP TABLE IF EXISTS amc_core.patient_contact CASCADE;

CREATE TABLE amc_core.patient_contact (
  patient_contact_id text PRIMARY KEY,

  pseudo_id text,
  patient_contact_type text,

  patient_contact_date date,
  patient_contact_time time,
  patient_contact_date_time timestamptz,

  cancellation_date date,
  patient_appointment_status text,

  hospital_location text,
  workplace text,
  specialty text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz
);

INSERT INTO amc_core.patient_contact (
  patient_contact_id,
  pseudo_id,
  patient_contact_type,
  patient_contact_date,
  patient_contact_time,
  patient_contact_date_time,
  cancellation_date,
  patient_appointment_status,
  hospital_location,
  workplace,
  specialty,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(patient_contact_id, ''),
  NULLIF(pseudo_id, ''),
  NULLIF(patient_contact_type, ''),

  NULLIF(patient_contact_date, '')::date,
  CASE WHEN trim(patient_contact_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(patient_contact_time)::time END,
  NULLIF(patient_contact_date_time, '')::timestamptz,

  NULLIF(cancellation_date, '')::date,
  NULLIF(patient_appointment_status, ''),

  NULLIF(hospital_location, ''),
  NULLIF(workplace, ''),
  NULLIF(specialty, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.patient_contact

WHERE NULLIF(patient_contact_id, '') IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_core_patient_contact_pseudo_id
  ON amc_core.patient_contact(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_patient_contact_datetime
  ON amc_core.patient_contact(patient_contact_date_time);