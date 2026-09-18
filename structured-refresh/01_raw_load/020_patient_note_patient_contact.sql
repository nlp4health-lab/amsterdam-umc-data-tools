-- ==========================================================================
DROP TABLE IF EXISTS amc_raw.patient_note_patient_contact;

CREATE TABLE amc_raw.patient_note_patient_contact (
  pseudo_id TEXT,
  patient_note_id TEXT,
  note_contact_id TEXT,
  note_contact_sequential_number TEXT,
  patient_contact_id TEXT,
  note_made_at_date_time TEXT,
  note_file_time_local_dttm TEXT,
  entry_instant_local_dttm TEXT,
  note_status TEXT,
  patient_note_category TEXT,
  patient_contact_patient_note_category TEXT,
  is_confidential TEXT,
  hospital_location TEXT,
  hospital_location_code TEXT,
  patient_contact_date_time TEXT,
  note_made_on_date TEXT,
  note_made_at_time TEXT,
  caregiver_type TEXT,
  healthcare_provider_specialty TEXT,
  healthcare_provider_sub_specialty TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);


-- @COPY_PARTS: patient_note_patient_contact

--Sanity check:
SELECT count(*) FROM amc_raw.patient_note_patient_contact;

SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL) AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL) AS null_contact,
  count(*) FILTER (WHERE note_contact_id IS NULL) AS null_note_contact
FROM amc_raw.patient_note_patient_contact;

SELECT
  count(*) AS n,
  count(DISTINCT note_contact_id) AS n_distinct
FROM amc_raw.patient_note_patient_contact;

-- not all patient_note_id are not null, but all note_contact_id are not null, so we can use note_contact_id as a unique identifier for the table.
-- but to merge with the patient_note table later, we will need to use patient_note_id, so we should check how many distinct patient_note_id there are and how many nulls.

