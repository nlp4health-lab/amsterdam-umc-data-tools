------------------------------------------------------------------------------------------------------------
-- This view combines stays from admission_traject, admission_partial_traject, and seh_trajectory.
DROP VIEW IF EXISTS amc_views.v_stays CASCADE;

CREATE VIEW amc_views.v_stays AS

SELECT
    at.pseudo_id,
    at.patient_contact_id,
    at.admission_traject_id AS stay_id,
    at.admission_traject_id AS parent_admission_traject_id,
    'admission_traject' AS stay_type,
    at.admission_moment AS start_datetime,
    at.corrected_discharge_moment AS end_datetime,
    at.hospital_location,
    at.admission_workplace AS workplace,
    at.admission_specialty AS specialty,
    at.admission_subspecialty AS subspecialty,
    at.admission_patientclass AS patient_class,
    at.admission_origin,
    at.discharge_location
FROM amc_core.admission_traject at
WHERE NOT COALESCE(at.ongoing_stay, false)

UNION ALL

SELECT
    apt.pseudo_id,
    apt.patient_contact_id,
    apt.admission_partial_traject_id AS stay_id,
    apt.admission_traject_id AS parent_admission_traject_id,
    'admission_partial_traject' AS stay_type,
    apt.start_date_time AS start_datetime,
    apt.corrected_end_date_time AS end_datetime,
    apt.hospital_location,
    apt.workplace,
    apt.specialty,
    apt.subspecialty,
    apt.patient_class,
    apt.admission_origin,
    NULL::text AS discharge_location
FROM amc_core.admission_partial_traject apt
WHERE NOT COALESCE(apt.ongoing_partial_stay, false)

UNION ALL

SELECT
    seh.pseudo_id,
    seh.patient_contact_id,
    seh.seh_traject_id AS stay_id,
    seh.admission_traject_id AS parent_admission_traject_id,
    'seh_trajectory' AS stay_type,
    seh.seh_admission_date_time AS start_datetime,
    seh.corrected_seh_departure_date_time AS end_datetime,
    seh.hospital_location,
    seh.arrival_workplace AS workplace,
    seh.seh_sub_specialty AS specialty,
    seh.seh_arrival_subspecialty AS subspecialty,
    NULL::text AS patient_class,
    seh.admission_origin,
    seh.destination_after_seh AS discharge_location
FROM amc_core.seh_trajectory seh
WHERE NOT COALESCE(seh.ongoing_seh_stay, false);
