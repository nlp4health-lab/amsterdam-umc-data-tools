-------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS amc_views.v_contact_id_registry;

CREATE VIEW amc_views.v_contact_id_registry AS

SELECT
    pc.pseudo_id,
    pc.patient_contact_id,
    'patient_contact' AS source_table,
    pc.patient_contact_id AS source_record_id,
    pc.patient_contact_type AS contact_type,
    pc.patient_contact_date_time AS contact_datetime,
    pc.hospital_location,
    pc.workplace,
    pc.specialty,
    NULL::text AS subspecialty,
    pc.patient_appointment_status AS status
FROM amc_core.patient_contact pc
WHERE pc.patient_contact_id IS NOT NULL

UNION ALL

SELECT
    pa.pseudo_id,
    pa.patient_contact_id,
    'patient_appointment' AS source_table,
    pa.patient_contact_id AS source_record_id,
    pa.appointment_form_level1 AS contact_type,
    pa.appointment_start_moment AS contact_datetime,
    pa.hospital_location,
    pa.executive_workplace AS workplace,
    pa.executive_specialty AS specialty,
    NULL::text AS subspecialty,
    pa.appointment_status AS status
FROM amc_core.patient_appointment pa
WHERE pa.patient_contact_id IS NOT NULL

UNION ALL

SELECT
    pal.pseudo_id,
    pal.patient_contact_id,
    'patient_appointment_line' AS source_table,
    pal.appointment_line_id AS source_record_id,
    pal.appointment_form_level1 AS contact_type,
    pal.appointment_start_moment AS contact_datetime,
    pal.hospital_location,
    pal.executive_workplace AS workplace,
    pal.executive_specialty AS specialty,
    NULL::text AS subspecialty,
    pal.appointment_status AS status
FROM amc_core.patient_appointment_line pal
WHERE pal.patient_contact_id IS NOT NULL

UNION ALL

SELECT
    at.pseudo_id,
    at.patient_contact_id,
    'admission_traject' AS source_table,
    at.admission_traject_id AS source_record_id,
    at.admission_type AS contact_type,
    at.admission_moment AS contact_datetime,
    at.hospital_location,
    at.admission_workplace AS workplace,
    at.admission_specialty AS specialty,
    at.admission_subspecialty AS subspecialty,
    CASE
        WHEN at.is_patient_discharged = 'Ja' THEN 'discharged'
        ELSE 'not_discharged'
    END AS status
FROM amc_core.admission_traject at
WHERE NOT COALESCE(at.ongoing_stay, false)
  AND at.patient_contact_id IS NOT NULL

UNION ALL

SELECT
    apt.pseudo_id,
    apt.patient_contact_id,
    'admission_partial_traject' AS source_table,
    apt.admission_partial_traject_id AS source_record_id,
    apt.partial_traject_admission_type AS contact_type,
    apt.start_date_time AS contact_datetime,
    apt.hospital_location,
    apt.workplace,
    apt.specialty,
    apt.subspecialty,
    apt.patient_class AS status
FROM amc_core.admission_partial_traject apt
WHERE NOT COALESCE(apt.ongoing_partial_stay, false)
  AND apt.patient_contact_id IS NOT NULL

UNION ALL

SELECT
    seh.pseudo_id,
    seh.patient_contact_id,
    'seh_trajectory' AS source_table,
    seh.seh_traject_id AS source_record_id,
    seh.seh_presentation_type AS contact_type,
    seh.seh_admission_date_time AS contact_datetime,
    seh.hospital_location,
    seh.arrival_workplace AS workplace,
    seh.seh_sub_specialty AS specialty,
    seh.seh_arrival_subspecialty AS subspecialty,
    seh.destination_after_seh AS status
FROM amc_core.seh_trajectory seh
WHERE NOT COALESCE(seh.ongoing_seh_stay, false)
  AND seh.patient_contact_id IS NOT NULL;
