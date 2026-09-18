------------------------------------------------------------------------------------------------------------
-- This view combines encounters from patient_contact, patient_appointment, admission_traject, and seh_trajectory.

DROP VIEW IF EXISTS amc_views.v_encounters;

CREATE VIEW amc_views.v_encounters AS

SELECT
    pc.pseudo_id,
    pc.patient_contact_id,
    'patient_contact' AS encounter_type,
    pc.patient_contact_type AS encounter_subtype,
    pc.patient_contact_date_time AS start_datetime,
    NULL::timestamptz AS end_datetime,
    NULL::timestamptz AS appointment_made_at_date_time,
    pc.hospital_location,
    pc.workplace,
    pc.specialty,
    NULL::text AS subspecialty,
    pc.patient_appointment_status AS status,
    pc.abnormal_date,
    'patient_contact' AS source_table,
    pc.patient_contact_id AS source_record_id
FROM amc_core.patient_contact pc

UNION ALL

SELECT
    pa.pseudo_id,
    pa.patient_contact_id,
    'appointment' AS encounter_type,
    pa.appointment_form_level1 AS encounter_subtype,
    pa.appointment_start_moment AS start_datetime,
    pa.appointment_end_moment AS end_datetime,
    pa.appointment_made_at_date_time,
    pa.hospital_location,
    pa.executive_workplace AS workplace,
    pa.executive_specialty AS specialty,
    NULL::text AS subspecialty,
    pa.appointment_status AS status,
    NULL::boolean AS abnormal_date,
    'patient_appointment' AS source_table,
    pa.patient_contact_id AS source_record_id
FROM amc_core.patient_appointment pa

UNION ALL

SELECT
    at.pseudo_id,
    at.patient_contact_id,
    'admission' AS encounter_type,
    at.admission_type AS encounter_subtype,
    at.admission_moment AS start_datetime,
    at.corrected_discharge_moment AS end_datetime,
    NULL::timestamptz AS appointment_made_at_date_time,
    at.hospital_location,
    at.admission_workplace AS workplace,
    at.admission_specialty AS specialty,
    at.admission_subspecialty AS subspecialty,
    CASE
        WHEN at.is_patient_discharged = 'Ja' THEN 'discharged'
        ELSE 'not_discharged'
    END AS status,
    NULL::boolean AS abnormal_date,
    'admission_traject' AS source_table,
    at.admission_traject_id AS source_record_id
FROM amc_core.admission_traject at
WHERE NOT COALESCE(at.ongoing_stay, false)

UNION ALL

SELECT
    seh.pseudo_id,
    seh.patient_contact_id,
    'seh' AS encounter_type,
    seh.seh_presentation_type AS encounter_subtype,
    seh.seh_admission_date_time AS start_datetime,
    seh.corrected_seh_departure_date_time AS end_datetime,
    NULL::timestamptz AS appointment_made_at_date_time,
    seh.hospital_location,
    seh.arrival_workplace AS workplace,
    seh.seh_sub_specialty AS specialty,
    seh.seh_arrival_subspecialty AS subspecialty,
    seh.destination_after_seh AS status,
    NULL::boolean AS abnormal_date,
    'seh_trajectory' AS source_table,
    seh.seh_traject_id AS source_record_id
FROM amc_core.seh_trajectory seh
WHERE NOT COALESCE(seh.ongoing_seh_stay, false);
