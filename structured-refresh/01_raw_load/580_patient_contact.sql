--============================================================
DROP TABLE IF EXISTS amc_raw.patient_contact;

CREATE TABLE amc_raw.patient_contact (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  patient_contact_type TEXT,
  patient_contact_date TEXT,
  patient_contact_time TEXT,
  patient_contact_date_time TEXT,
  cancellation_date TEXT,
  patient_appointment_status TEXT,
  hospital_location TEXT,
  workplace TEXT,
  specialty TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: patient_contact

