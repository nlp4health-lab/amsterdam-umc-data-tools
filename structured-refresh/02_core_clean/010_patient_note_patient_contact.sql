-- ===========================================================================
DROP TABLE IF EXISTS amc_core.patient_note_patient_contact CASCADE;

CREATE TABLE amc_core.patient_note_patient_contact (
  pseudo_id text NOT NULL,
  patient_note_id text NOT NULL,
  note_contact_id text PRIMARY KEY,
  note_contact_sequential_number_raw text,
  note_contact_sequential_number int,
  patient_contact_id text,
  note_made_at_date_time timestamptz,
  note_file_time_local_dttm timestamptz,
  entry_instant_local_dttm timestamptz,
  note_status text,
  patient_note_category text,
  patient_contact_patient_note_category text,
  is_confidential text,                 
  hospital_location text,
  hospital_location_code text,
  patient_contact_date_time timestamptz,
  note_made_on_date date,
  note_made_at_time time,
  caregiver_type text,
  healthcare_provider_specialty text,
  healthcare_provider_sub_specialty text,
  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.patient_note_patient_contact (
  pseudo_id, patient_note_id, note_contact_id, note_contact_sequential_number_raw, note_contact_sequential_number,
  patient_contact_id,
  note_made_at_date_time, note_file_time_local_dttm, entry_instant_local_dttm,
  note_status, patient_note_category, patient_contact_patient_note_category,
  is_confidential, hospital_location, hospital_location_code,
  patient_contact_date_time, note_made_on_date, note_made_at_time,
  caregiver_type, healthcare_provider_specialty, healthcare_provider_sub_specialty,
  source, dcm_refreshed_date_time, issue_dt
)
SELECT
  pseudo_id,
  patient_note_id,
  note_contact_id,
  NULLIF(note_contact_sequential_number, ''),

  CASE WHEN trim(note_contact_sequential_number) ~ '^[0-9]+$' THEN trim(note_contact_sequential_number)::int END,
  NULLIF(patient_contact_id,''),
  NULLIF(note_made_at_date_time,'')::timestamptz,
  NULLIF(note_file_time_local_dttm,'')::timestamptz,
  NULLIF(entry_instant_local_dttm,'')::timestamptz,
  NULLIF(note_status,''),
  NULLIF(patient_note_category,''),
  NULLIF(patient_contact_patient_note_category,''),
  NULLIF(is_confidential,''),
  NULLIF(hospital_location,''),
  NULLIF(hospital_location_code,''),
  NULLIF(patient_contact_date_time,'')::timestamptz,
  NULLIF(note_made_on_date,'')::date,
  CASE WHEN trim(note_made_at_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(note_made_at_time)::time END,
  NULLIF(caregiver_type,''),
  NULLIF(healthcare_provider_specialty,''),
  NULLIF(healthcare_provider_sub_specialty,''),
  NULLIF(source,''),
  NULLIF(dcm_refreshed_date_time,'')::timestamptz,
  NULLIF(issue_dt,'')::timestamptz
FROM amc_raw.patient_note_patient_contact;

-- indices
CREATE INDEX IF NOT EXISTS idx_core_pnpc_contact
  ON amc_core.patient_note_patient_contact(patient_contact_id);

--check because patient_note_id is not unique and in the amc_notes note_id is the primary key and it is unique 
CREATE INDEX IF NOT EXISTS idx_core_pnpc_patient_note
  ON amc_core.patient_note_patient_contact(patient_note_id);


