--===========================================================================
DROP TABLE IF EXISTS amc_core.seh_trajectory CASCADE;

CREATE TABLE amc_core.seh_trajectory (
  pseudo_id text NOT NULL,
  seh_traject_id text PRIMARY KEY,
  patient_contact_id text,

  hospital_location text,

  urgent_contact_created_date_time timestamptz,
  patient_arrived_at_seh_date_time timestamptz,

  seh_admission_moment time,
  seh_admission_date date,
  seh_admission_date_time timestamptz,

  seh_departure_moment time,
  seh_departure_date date,
  seh_departure_date_time timestamptz,

  seh_sub_specialty text,
  seh_arrival_mode text,
  seh_arrival_mode_group text,
  seh_presentation_type text,
  seh_triagecode text,

  chief_seh_complaint text,
  chief_seh_input_complaint text,
  destination_after_seh text,

  referring_caregiver_type text,
  referring_caregiver_is_internal text,

  is_ehh_traject text,

  admission_traject_id text,
  admission_origin text,
  age_in_years_at_moment_admission int,

  seh_arrival_subspecialty text,
  seh_departure_subspecialty text,

  departure_to_workplace text,
  arrival_workplace text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.seh_trajectory (
  pseudo_id, seh_traject_id, patient_contact_id,
  hospital_location,
  urgent_contact_created_date_time, patient_arrived_at_seh_date_time,
  seh_admission_moment, seh_admission_date, seh_admission_date_time,
  seh_departure_moment, seh_departure_date, seh_departure_date_time,
  seh_sub_specialty, seh_arrival_mode, seh_arrival_mode_group, seh_presentation_type, seh_triagecode,
  chief_seh_complaint, chief_seh_input_complaint, destination_after_seh,
  referring_caregiver_type, referring_caregiver_is_internal,
  is_ehh_traject,
  admission_traject_id, admission_origin, age_in_years_at_moment_admission,
  seh_arrival_subspecialty, seh_departure_subspecialty,
  departure_to_workplace, arrival_workplace,
  source, dcm_refreshed_date_time, issue_dt
)
SELECT
  pseudo_id,
  seh_traject_id,
  NULLIF(patient_contact_id,''),

  NULLIF(hospital_location,''),

  NULLIF(urgent_contact_created_date_time,'')::timestamptz,
  NULLIF(patient_arrived_at_seh_date_time,'')::timestamptz,

  CASE WHEN trim(seh_admission_moment) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(seh_admission_moment)::time END,
  NULLIF(seh_admission_date,'')::date,
  NULLIF(seh_admission_date_time,'')::timestamptz,

  CASE WHEN trim(seh_departure_moment) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(seh_departure_moment)::time END,
  NULLIF(seh_departure_date,'')::date,
  NULLIF(seh_departure_date_time,'')::timestamptz,

  NULLIF(seh_sub_specialty,''),
  NULLIF(seh_arrival_mode,''),
  NULLIF(seh_arrival_mode_group,''),
  NULLIF(seh_presentation_type,''),
  NULLIF(seh_triagecode,''),

  NULLIF(chief_seh_complaint,''),
  NULLIF(chief_seh_input_complaint,''),
  NULLIF(destination_after_seh,''),

  NULLIF(referring_caregiver_type,''),
  NULLIF(referring_caregiver_is_internal,''),

  NULLIF(is_ehh_traject,''),

  NULLIF(admission_traject_id,''),
  NULLIF(admission_origin,''),
  NULLIF(age_in_years_at_moment_admission,'')::int,

  NULLIF(seh_arrival_subspecialty,''),
  NULLIF(seh_departure_subspecialty,''),

  NULLIF(departure_to_workplace,''),
  NULLIF(arrival_workplace,''),

  NULLIF(source,''),
  NULLIF(dcm_refreshed_date_time,'')::timestamptz,
  NULLIF(issue_dt,'')::timestamptz
FROM amc_raw.seh_trajectory;

CREATE INDEX IF NOT EXISTS idx_core_seh_contact
  ON amc_core.seh_trajectory(patient_contact_id);

CREATE INDEX IF NOT EXISTS idx_core_seh_admtraj
  ON amc_core.seh_trajectory(admission_traject_id);

CREATE INDEX IF NOT EXISTS idx_core_seh_pseudo
  ON amc_core.seh_trajectory(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_seh_admseh_datetime
  ON amc_core.seh_trajectory(seh_admission_date_time);

