--===========================================================================
-- New table, first appears in the 2026-09-08 extract. Coexists alongside
-- seh_trajectory (not a replacement -- no decision yet on retiring it).
-- *_moment columns are timestamptz (repo-wide convention, e.g.
-- admission_traject.admission_moment/discharge_moment), NOT time-only like
-- seh_trajectory's own *_moment columns -- this table has no *_date_time
-- column at all, just independent *_moment/*_date/*_time triads per event.
DROP TABLE IF EXISTS amc_core.emergency_care_traject CASCADE;

CREATE TABLE amc_core.emergency_care_traject (
  pseudo_id text NOT NULL,
  emergency_care_traject_id text PRIMARY KEY,
  patient_contact_id text,

  hospital_location text,

  emergency_care_event_created_moment timestamptz,
  emergency_care_event_created_date date,
  emergency_care_event_created_time time,

  emergency_care_event_patient_arrived_moment timestamptz,
  emergency_care_event_patient_arrived_date date,
  emergency_care_event_patient_arrived_time time,

  emergency_care_admission_start_moment timestamptz,
  emergency_care_admission_start_date date,
  emergency_care_admission_start_time time,

  emergency_care_admission_end_moment timestamptz,
  emergency_care_admission_end_date date,
  emergency_care_admission_end_time time,

  emergency_care_event_arrival_workplace text,
  emergency_care_arrival_mode text,
  emergency_care_admission_subspecialty text,
  emergency_care_triage text,

  chief_emergency_care_complaint text,
  chief_emergency_care_input_complaint text,

  emergency_care_admission_arrival_subspecialty text,
  emergency_care_admission_departure_subspecialty text,
  emergency_care_admission_arrival_workplace text,
  emergency_care_admission_next_workplace text,
  emergency_care_admission_departure_to_workplace text,

  destination_after_emergency_care text,
  emergency_care_duration_class text,
  emergency_care_presentation_type text,

  is_clinical_follow_up text,
  is_high_care text,
  is_ehh_traject text,
  is_patient_discharged text,
  is_emergency_care_event_created text,
  is_emergency_care_event_arrived text,
  is_emergency_care_event_end text,

  emergency_care_admission_duration_minutes numeric,
  emergency_care_admission_duration_hours numeric,
  emergency_care_stay_duration_minutes numeric,
  emergency_care_waiting_time_minutes numeric,

  number_emergency_care_trajects int,
  number_emergency_care_admission_partial_trajects int,
  number_emergency_care_stays_shorter_than_4_hours int,
  number_emergency_care_stays_longer_than_4_hours int,

  issue_dt timestamptz
);

INSERT INTO amc_core.emergency_care_traject (
  pseudo_id, emergency_care_traject_id, patient_contact_id,
  hospital_location,
  emergency_care_event_created_moment, emergency_care_event_created_date, emergency_care_event_created_time,
  emergency_care_event_patient_arrived_moment, emergency_care_event_patient_arrived_date, emergency_care_event_patient_arrived_time,
  emergency_care_admission_start_moment, emergency_care_admission_start_date, emergency_care_admission_start_time,
  emergency_care_admission_end_moment, emergency_care_admission_end_date, emergency_care_admission_end_time,
  emergency_care_event_arrival_workplace, emergency_care_arrival_mode, emergency_care_admission_subspecialty, emergency_care_triage,
  chief_emergency_care_complaint, chief_emergency_care_input_complaint,
  emergency_care_admission_arrival_subspecialty, emergency_care_admission_departure_subspecialty,
  emergency_care_admission_arrival_workplace, emergency_care_admission_next_workplace, emergency_care_admission_departure_to_workplace,
  destination_after_emergency_care, emergency_care_duration_class, emergency_care_presentation_type,
  is_clinical_follow_up, is_high_care, is_ehh_traject, is_patient_discharged,
  is_emergency_care_event_created, is_emergency_care_event_arrived, is_emergency_care_event_end,
  emergency_care_admission_duration_minutes, emergency_care_admission_duration_hours,
  emergency_care_stay_duration_minutes, emergency_care_waiting_time_minutes,
  number_emergency_care_trajects, number_emergency_care_admission_partial_trajects,
  number_emergency_care_stays_shorter_than_4_hours, number_emergency_care_stays_longer_than_4_hours,
  issue_dt
)
SELECT
  pseudo_id,
  emergency_care_traject_id,
  NULLIF(patient_contact_id,''),

  NULLIF(hospital_location,''),

  NULLIF(emergency_care_event_created_moment,'')::timestamptz,
  NULLIF(emergency_care_event_created_date,'')::date,
  NULLIF(emergency_care_event_created_time,'')::time,

  NULLIF(emergency_care_event_patient_arrived_moment,'')::timestamptz,
  NULLIF(emergency_care_event_patient_arrived_date,'')::date,
  NULLIF(emergency_care_event_patient_arrived_time,'')::time,

  NULLIF(emergency_care_admission_start_moment,'')::timestamptz,
  NULLIF(emergency_care_admission_start_date,'')::date,
  NULLIF(emergency_care_admission_start_time,'')::time,

  NULLIF(emergency_care_admission_end_moment,'')::timestamptz,
  NULLIF(emergency_care_admission_end_date,'')::date,
  NULLIF(emergency_care_admission_end_time,'')::time,

  NULLIF(emergency_care_event_arrival_workplace,''),
  NULLIF(emergency_care_arrival_mode,''),
  NULLIF(emergency_care_admission_subspecialty,''),
  NULLIF(emergency_care_triage,''),

  NULLIF(chief_emergency_care_complaint,''),
  NULLIF(chief_emergency_care_input_complaint,''),

  NULLIF(emergency_care_admission_arrival_subspecialty,''),
  NULLIF(emergency_care_admission_departure_subspecialty,''),
  NULLIF(emergency_care_admission_arrival_workplace,''),
  NULLIF(emergency_care_admission_next_workplace,''),
  NULLIF(emergency_care_admission_departure_to_workplace,''),

  NULLIF(destination_after_emergency_care,''),
  NULLIF(emergency_care_duration_class,''),
  NULLIF(emergency_care_presentation_type,''),

  NULLIF(is_clinical_follow_up,''),
  NULLIF(is_high_care,''),
  NULLIF(is_ehh_traject,''),
  NULLIF(is_patient_discharged,''),
  NULLIF(is_emergency_care_event_created,''),
  NULLIF(is_emergency_care_event_arrived,''),
  NULLIF(is_emergency_care_event_end,''),

  NULLIF(emergency_care_admission_duration_minutes,'')::numeric,
  NULLIF(emergency_care_admission_duration_hours,'')::numeric,
  NULLIF(emergency_care_stay_duration_minutes,'')::numeric,
  NULLIF(emergency_care_waiting_time_minutes,'')::numeric,

  NULLIF(number_emergency_care_trajects,'')::int,
  NULLIF(number_emergency_care_admission_partial_trajects,'')::int,
  NULLIF(number_emergency_care_stays_shorter_than_4_hours,'')::int,
  NULLIF(number_emergency_care_stays_longer_than_4_hours,'')::int,

  NULLIF(issue_dt,'')::timestamptz
FROM amc_raw.emergency_care_traject;

CREATE INDEX IF NOT EXISTS idx_core_emergency_care_traject_pseudo
  ON amc_core.emergency_care_traject(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_emergency_care_traject_contact
  ON amc_core.emergency_care_traject(patient_contact_id);
