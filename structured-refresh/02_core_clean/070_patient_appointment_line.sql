--===========================================================================
DROP TABLE IF EXISTS amc_core.patient_appointment_line CASCADE;

CREATE TABLE amc_core.patient_appointment_line (
  pseudo_id text NOT NULL,

  appointment_id text,
  appointment_line_id text PRIMARY KEY,

  age_in_years_at_moment_appointment_raw text,

  age_in_years_at_moment_appointment int,
  child_age_in_weeks_at_moment_appointment text,

  appointment_made_at_date_time timestamptz,
  appointment_date date,
  appointment_time time,

  daily text,
  office_hours text,

  appointment_start_moment timestamptz,
  appointment_end_moment timestamptz,

  patient_contact_id text,
  patient_contact_type text,

  appointment_form_level1 text,
  appointment_form_level2 text,
  is_new_patient text,

  appointment_agenda_template text,
  appointment_agenda_template_type text,
  appointment_agenda_template_abbreviation text,

  appointment_status text,
  appointment_relocated_to_patient_contact_id text,

  appointment_name text,
  appointment_form text,
  consultation_focus text,
  appointment_name_abbreviation text,

  appointment_cancellation_applicant text,
  appointment_cancellation_reason text,
  appointment_cancellation_reason_type text,
  appointment_cancellation_term text,

  cancellation_to_appointment_days numeric,
  cancellation_to_appointment_hours numeric,

  executive_caregiver_type text,
  caregiver_internal_yes_no text,
  executive_specialty text,
  executive_workplace text,

  waiting_room text,
  hospital_location text,

  order_id text,
  order_type text,
  order_class text,
  order_assignment text,
  order_date date,
  order_time time,

  referring_caregiver_type text,
  referring_caregiver_internal_yes_no text,
  referring_healthcare_institution text,

  requesting_workplace text,

  appointment_realized_duration_hours numeric,
  appointment_realized_duration_minutes numeric,
  appointment_standard_duration_hours numeric,
  appointment_standard_time_minutes numeric,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.patient_appointment_line (
  pseudo_id,
  age_in_years_at_moment_appointment_raw, age_in_years_at_moment_appointment, child_age_in_weeks_at_moment_appointment,
  appointment_id, appointment_line_id,
  appointment_made_at_date_time, appointment_date, appointment_time,
  daily, office_hours,
  appointment_start_moment, appointment_end_moment,
  patient_contact_id, patient_contact_type,
  appointment_form_level1, appointment_form_level2, is_new_patient,
  appointment_agenda_template, appointment_agenda_template_type, appointment_agenda_template_abbreviation,
  appointment_status, appointment_relocated_to_patient_contact_id,
  appointment_name, appointment_form, consultation_focus, appointment_name_abbreviation,
  appointment_cancellation_applicant, appointment_cancellation_reason,
  appointment_cancellation_reason_type, appointment_cancellation_term,
  cancellation_to_appointment_days, cancellation_to_appointment_hours,
  executive_caregiver_type, caregiver_internal_yes_no, executive_specialty, executive_workplace,
  waiting_room, hospital_location,
  order_id, order_type, order_class, order_assignment, order_date, order_time,
  referring_caregiver_type, referring_caregiver_internal_yes_no, referring_healthcare_institution,
  requesting_workplace,
  appointment_realized_duration_hours, appointment_realized_duration_minutes,
  appointment_standard_duration_hours, appointment_standard_time_minutes,
  source, dcm_refreshed_date_time, issue_dt
)
SELECT
  pseudo_id,

  NULLIF(age_in_years_at_moment_appointment, ''),

  CASE
    WHEN trim(age_in_years_at_moment_appointment) ~ '^[0-9]+$'
      THEN trim(age_in_years_at_moment_appointment)::int
    ELSE NULL
  END AS age_in_years_at_moment_appointment,

  NULLIF(child_age_in_weeks_at_moment_appointment,'') AS child_age_in_weeks_at_moment_appointment,

  NULLIF(appointment_id,''),
  appointment_line_id,

  NULLIF(appointment_made_at_date_time,'')::timestamptz,
  NULLIF(appointment_date,'')::date,
  CASE WHEN trim(appointment_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(appointment_time)::time END,

  NULLIF(daily,''),
  NULLIF(office_hours,''),

  NULLIF(appointment_start_moment,'')::timestamptz,
  NULLIF(appointment_end_moment,'')::timestamptz,

  NULLIF(patient_contact_id,''),
  NULLIF(patient_contact_type,''),

  NULLIF(appointment_form_level1,''),
  NULLIF(appointment_form_level2,''),
  NULLIF(is_new_patient,''),

  NULLIF(appointment_agenda_template,''),
  NULLIF(appointment_agenda_template_type,''),
  NULLIF(appointment_agenda_template_abbreviation,''),

  NULLIF(appointment_status,''),
  NULLIF(appointment_relocated_to_patient_contact_id,''),

  NULLIF(appointment_name,''),
  NULLIF(appointment_form,''),
  NULLIF(consultation_focus,''),
  NULLIF(appointment_name_abbreviation,''),

  NULLIF(appointment_cancellation_applicant,''),
  NULLIF(appointment_cancellation_reason,''),
  NULLIF(appointment_cancellation_reason_type,''),
  NULLIF(appointment_cancellation_term,''),

  NULLIF(cancellation_to_appointment_days,'')::numeric,
  NULLIF(cancellation_to_appointment_hours,'')::numeric,

  NULLIF(executive_caregiver_type,''),
  NULLIF(caregiver_internal_yes_no,''),
  NULLIF(executive_specialty,''),
  NULLIF(executive_workplace,''),

  NULLIF(waiting_room,''),
  NULLIF(hospital_location,''),

  NULLIF(order_id,''),
  NULLIF(order_type,''),
  NULLIF(order_class,''),
  NULLIF(order_assignment,''),
  NULLIF(order_date,'')::date,
  CASE WHEN trim(order_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(order_time)::time END,

  NULLIF(referring_caregiver_type,''),
  NULLIF(referring_caregiver_internal_yes_no,''),
  NULLIF(referring_healthcare_institution,''),

  NULLIF(requesting_workplace,''),

  NULLIF(appointment_realized_duration_hours,'')::numeric,
  NULLIF(appointment_realized_duration_minutes,'')::numeric,
  NULLIF(appointment_standard_duration_hours,'')::numeric,
  NULLIF(appointment_standard_time_minutes,'')::numeric,

  NULLIF(source,''),
  NULLIF(dcm_refreshed_date_time,'')::timestamptz,
  NULLIF(issue_dt,'')::timestamptz
FROM amc_raw.patient_appointment_line;


CREATE INDEX IF NOT EXISTS idx_core_apptline_contact
  ON amc_core.patient_appointment_line(patient_contact_id);

CREATE INDEX IF NOT EXISTS idx_core_apptline_apptid
  ON amc_core.patient_appointment_line(appointment_id);

CREATE INDEX IF NOT EXISTS idx_core_apptline_order
  ON amc_core.patient_appointment_line(order_id);

CREATE INDEX IF NOT EXISTS idx_core_apptline_pseudo
  ON amc_core.patient_appointment_line(pseudo_id);

