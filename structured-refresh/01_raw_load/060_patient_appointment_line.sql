-- ==========================================================================

DROP TABLE IF EXISTS amc_raw.patient_appointment_line;

CREATE TABLE amc_raw.patient_appointment_line (
  pseudo_id TEXT,
  age_in_years_at_moment_appointment TEXT,
  child_age_in_weeks_at_moment_appointment TEXT,
  appointment_id TEXT,
  appointment_line_id TEXT,
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
  appointment_form TEXT,
  consultation_focus TEXT,
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
  hospital_location TEXT,
  order_id TEXT,
  order_type TEXT,
  order_class TEXT,
  order_assignment TEXT,
  order_date TEXT,
  order_time TEXT,
  referring_caregiver_type TEXT,
  referring_caregiver_internal_yes_no TEXT,
  referring_healthcare_institution TEXT,
  requesting_workplace TEXT,
  appointment_realized_duration_hours TEXT,
  appointment_realized_duration_minutes TEXT,
  appointment_standard_duration_hours TEXT,
  appointment_standard_time_minutes TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: patient_appointment_line patient_appointment_rule

--Sanity check:
SELECT count(*) AS n_rows
FROM amc_raw.patient_appointment_line;

SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL) AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL) AS null_contact,
  count(*) FILTER (WHERE appointment_line_id IS NULL) AS null_line_id,
  count(*) FILTER (WHERE appointment_id IS NULL) AS null_appt_id
FROM amc_raw.patient_appointment_line;

SELECT
  count(*) AS n,
  count(DISTINCT appointment_line_id) AS distinct_line_ids
FROM amc_raw.patient_appointment_line;

SELECT patient_contact_id, count(*) AS n
FROM amc_raw.patient_appointment_line
WHERE patient_contact_id IS NOT NULL
GROUP BY patient_contact_id
ORDER BY n DESC
LIMIT 20;

WITH header AS (
  SELECT patient_contact_id FROM amc_raw.patient_appointment
),
lines AS (
  SELECT DISTINCT patient_contact_id FROM amc_raw.patient_appointment_line
)
SELECT
  (SELECT count(*) FROM header) AS header_contacts,
  (SELECT count(*) FROM lines) AS line_contacts,
  (SELECT count(*) FROM header h JOIN lines l USING (patient_contact_id)) AS overlap;

SELECT count(*) AS line_contacts_not_in_header
FROM (
  SELECT DISTINCT patient_contact_id
  FROM amc_raw.patient_appointment_line
) l
LEFT JOIN amc_raw.patient_appointment h
  ON h.patient_contact_id = l.patient_contact_id
WHERE h.patient_contact_id IS NULL;

-- 1:1 appointment lines with appointments, but 19M appointment ids and 21M appointment line ids. In appointments lines there are contact ids that are not in appointments.

