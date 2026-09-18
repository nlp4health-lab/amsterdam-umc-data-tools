------------------------------------------------------------------------------------------------------------
-- This view combines appointments from patient_appointment and patient_appointment_line. Since there is no unique identifier for appointments, we keep all records from both tables and indicate the source table and record id. This means that if an appointment has records in both tables, it will appear twice in the view, once with source_table = 'patient_appointment' and once with source_table = 'patient_appointment_line'. The linkage_quality column indicates whether the appointment is linked to a patient contact (linked_contact) or not (orphan_contact), which can be used as a quality check for analyses focusing on appointments linked to patient contacts.
DROP VIEW IF EXISTS amc_views.v_appointments;

CREATE VIEW amc_views.v_appointments AS

SELECT
    pa.pseudo_id,
    pa.patient_contact_id,
    NULL::text AS appointment_id,
    NULL::text AS appointment_line_id,

    'patient_appointment' AS source_table,
    pa.patient_contact_id AS source_record_id,

    pa.age_in_years_at_moment_appointment,
    pa.child_age_in_weeks_at_moment_appointment,

    pa.appointment_made_at_date_time,
    pa.appointment_date,
    pa.appointment_time,

    pa.appointment_start_moment,
    pa.appointment_end_moment,

    pa.patient_contact_type,
    pa.appointment_form_level1,
    pa.appointment_form_level2,
    pa.is_new_patient,

    pa.appointment_status,
    pa.appointment_relocated_to_patient_contact_id,

    pa.appointment_name,
    pa.appointment_name_code,
    NULL::text AS appointment_form,
    NULL::text AS consultation_focus,
    pa.appointment_name_abbreviation,

    pa.appointment_cancellation_reason,
    pa.appointment_cancellation_reason_type,

    pa.executive_caregiver_type,
    pa.caregiver_internal_yes_no,
    pa.executive_specialty,
    pa.executive_workplace,
    pa.is_outpatient,
    pa.hospital_location,

    pa.order_id,
    pa.order_type,
    pa.order_class,
    pa.order_assignment,
    pa.order_assignment_code,
    pa.order_date,
    pa.order_time,

    pa.referring_caregiver_type,
    pa.referring_caregiver_internal_yes_no,
    pa.referring_specialty,
    pa.referring_healthcare_institution,

    pa.is_multidisciplinary_appointment,
    pa.requesting_workplace

FROM amc_core.patient_appointment pa

UNION ALL

SELECT
    pal.pseudo_id,
    pal.patient_contact_id,
    pal.appointment_id,
    pal.appointment_line_id,

    'patient_appointment_line' AS source_table,
    pal.appointment_line_id AS source_record_id,

    pal.age_in_years_at_moment_appointment,
    pal.child_age_in_weeks_at_moment_appointment,

    pal.appointment_made_at_date_time,
    pal.appointment_date,
    pal.appointment_time,

    pal.appointment_start_moment,
    pal.appointment_end_moment,

    pal.patient_contact_type,
    pal.appointment_form_level1,
    pal.appointment_form_level2,
    pal.is_new_patient,

    pal.appointment_status,
    pal.appointment_relocated_to_patient_contact_id,

    pal.appointment_name,
    NULL::text AS appointment_name_code,
    pal.appointment_form,
    pal.consultation_focus,
    pal.appointment_name_abbreviation,

    pal.appointment_cancellation_reason,
    pal.appointment_cancellation_reason_type,

    pal.executive_caregiver_type,
    pal.caregiver_internal_yes_no,
    pal.executive_specialty,
    pal.executive_workplace,
    NULL::text AS is_outpatient,
    pal.hospital_location,

    pal.order_id,
    pal.order_type,
    pal.order_class,
    pal.order_assignment,
    NULL::text AS order_assignment_code,
    pal.order_date,
    pal.order_time,

    pal.referring_caregiver_type,
    pal.referring_caregiver_internal_yes_no,
    NULL::text AS referring_specialty,
    pal.referring_healthcare_institution,

    NULL::text AS is_multidisciplinary_appointment,
    pal.requesting_workplace

FROM amc_core.patient_appointment_line pal;
