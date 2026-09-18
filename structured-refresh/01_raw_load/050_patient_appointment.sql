-- ==========================================================================

DROP TABLE IF EXISTS amc_raw.patient_appointment;

CREATE TABLE amc_raw.patient_appointment (
  pseudo_id TEXT,
  age_in_years_at_moment_appointment TEXT,
  child_age_in_weeks_at_moment_appointment TEXT,
  appointment_made_at_date_time TEXT,
  appointment_date TEXT,
  appointment_time TEXT,
  daily TEXT,
  office_hours TEXT,
  appointment_start_moment TEXT,
  appointment_end_moment TEXT,
  patient_contact_id TEXT,
  patient_contact_type TEXT,
  appointment_form_level1 TEXT,
  appointment_form_level2 TEXT,
  is_new_patient TEXT,
  appointment_agenda_template TEXT,
  appointment_agenda_template_type TEXT,
  appointment_agenda_template_abbreviation TEXT,
  appointment_status TEXT,
  appointment_relocated_to_patient_contact_id TEXT,
  appointment_name TEXT,
  appointment_name_code TEXT,
  appointment_name_abbreviation TEXT,
  appointment_cancellation_applicant TEXT,
  appointment_cancellation_reason TEXT,
  appointment_cancellation_reason_type TEXT,
  appointment_cancellation_term TEXT,
  cancellation_to_appointment_days TEXT,
  cancellation_to_appointment_hours TEXT,
  executive_caregiver_type TEXT,
  caregiver_internal_yes_no TEXT,
  executive_specialty TEXT,
  executive_workplace TEXT,
  waiting_room TEXT,
  is_outpatient TEXT,
  hospital_location TEXT,
  order_id TEXT,
  order_type TEXT,
  order_class TEXT,
  order_assignment TEXT,
  order_assignment_code TEXT,
  order_date TEXT,
  order_time TEXT,
  access_time_order_to_plans_level1 TEXT,
  access_time_order_to_plans_level2 TEXT,
  order_to_plans_days TEXT,
  order_to_plans_hours TEXT,
  referring_caregiver_type TEXT,
  referring_caregiver_internal_yes_no TEXT,
  referring_specialty TEXT,
  referring_healthcare_institution TEXT,
  is_multidisciplinary_appointment TEXT,
  access_time_schedule_to_appointment_level TEXT,
  schedule_to_appointment_hours TEXT,
  schedule_to_appointment_days TEXT,
  requesting_workplace TEXT,
  appointment_realized_duration_hours TEXT,
  appointment_realized_duration_minutes TEXT,
  appointment_standard_duration_hours TEXT,
  appointment_standard_time_minutes TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: patient_appointment

--Sanity check:
SELECT count(*) AS n_rows
FROM amc_raw.patient_appointment;

SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL) AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL) AS null_contact,
  count(*) FILTER (WHERE order_id IS NULL) AS null_order_id
FROM amc_raw.patient_appointment;

SELECT
  count(*) AS n,
  count(DISTINCT patient_contact_id) AS distinct_contacts,
  count(DISTINCT order_id) AS distinct_orders
FROM amc_raw.patient_appointment;

SELECT patient_contact_id, count(*) AS n
FROM amc_raw.patient_appointment
WHERE patient_contact_id IS NOT NULL
GROUP BY patient_contact_id
ORDER BY n DESC
LIMIT 20;

-- 3.4M order_ids null
-- 1 appointment per contact. 
-- age in years contained the age and some Ong. (approximate?) that was turned to null in core.
-- it the schema says that this table has a appointment_id but in our extract this is not present. 
----is this a problem? i can identify by contact_id and join appointment lines by contact_id and obtain the appointment_id from there.
---- not a problem. contact id = appointment line id. if there qre not lines then appointment id = contact id = appointmnent line id.

