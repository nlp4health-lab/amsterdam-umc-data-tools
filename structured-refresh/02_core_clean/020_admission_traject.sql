--===========================================================================
DROP TABLE IF EXISTS amc_core.admission_traject CASCADE;

CREATE TABLE amc_core.admission_traject (
  pseudo_id text NOT NULL,
  patient_contact_id text,
  admission_traject_id text PRIMARY KEY,
  admission_moment_subtraject_id text,
  hospital_location text,

  age_in_years_at_moment_admission int,  

  is_patient_discharged text,
  is_admission_start_seh text,
  is_admission_elective text,
  admission_via_seh text,
  operative_or_reflective text,

  admission_moment timestamptz,
  admission_date date,
  admission_time time,

  discharge_moment timestamptz,
  discharge_date date,
  discharge_time time,

  admission_type text,
  admission_mode text,
  admission_origin text,
  accommodation_reason text,
  discharge_method text,
  discharge_location text,

  admission_specialty text,
  admission_subspecialty text,
  admission_service_specialty text,
  admission_patientclass text,
  discharge_patient_class text,
  admission_workplace text,

  -- is_admission_traject_intraclinical_transport_within{24,48}hs_back
  -- retired from the source extract as of the 2026-09-08 pull — removed
  -- here and from 01_raw_load/030_admission_traject.sql.

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt date
);

INSERT INTO amc_core.admission_traject (
  pseudo_id, patient_contact_id, admission_traject_id, admission_moment_subtraject_id,
  hospital_location, age_in_years_at_moment_admission,
  is_patient_discharged, is_admission_start_seh, is_admission_elective, admission_via_seh,
  operative_or_reflective,
  admission_moment, admission_date, admission_time,
  discharge_moment, discharge_date, discharge_time,
  admission_type, admission_mode, admission_origin, accommodation_reason,
  discharge_method, discharge_location,
  admission_specialty, admission_subspecialty, admission_service_specialty,
  admission_patientclass, discharge_patient_class, admission_workplace,
  source, dcm_refreshed_date_time, issue_dt
)
SELECT
  pseudo_id,
  NULLIF(patient_contact_id,''),
  admission_traject_id,
  NULLIF(admission_moment_subtraject_id,''),
  NULLIF(hospital_location,''),

  NULLIF(age_in_years_at_moment_admission,'')::numeric,

  NULLIF(is_patient_discharged,''),
  NULLIF(is_admission_start_seh,''),
  NULLIF(is_admission_elective,''),
  NULLIF(admission_via_seh,''),
  NULLIF(operative_or_reflective,''),

  NULLIF(admission_moment,'')::timestamptz,
  NULLIF(admission_date,'')::date,
  CASE WHEN trim(admission_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(admission_time)::time END,

  NULLIF(discharge_moment,'')::timestamptz,
  NULLIF(discharge_date,'')::date,
  CASE WHEN trim(discharge_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(discharge_time)::time END,

  NULLIF(admission_type,''),
  NULLIF(admission_mode,''),
  NULLIF(admission_origin,''),
  NULLIF(accommodation_reason,''),

  NULLIF(discharge_method,''),
  NULLIF(discharge_location,''),

  NULLIF(admission_specialty,''),
  NULLIF(admission_subspecialty,''),
  NULLIF(admission_service_specialty,''),

  NULLIF(admission_patientclass,''),
  NULLIF(discharge_patient_class,''),
  NULLIF(admission_workplace,''),

  NULLIF(source,''),
  NULLIF(dcm_refreshed_date_time,'')::timestamptz,
  NULLIF(issue_dt,'')::date
FROM amc_raw.admission_traject;

CREATE INDEX IF NOT EXISTS idx_core_admtraj_contact
  ON amc_core.admission_traject(patient_contact_id);

CREATE INDEX IF NOT EXISTS idx_core_admtraj_pseudo
  ON amc_core.admission_traject(pseudo_id);

--patient_contact_id is the same as admission_traject_id 

