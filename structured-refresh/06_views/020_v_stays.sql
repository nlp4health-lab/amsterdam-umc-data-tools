------------------------------------------------------------------------------------------------------------
-- This view combines stays from admission_traject, admission_partial_traject, and seh_trajectory.
--
-- stay_los_hours: this row's own segment duration (end_datetime -
-- start_datetime) -- the general-stays equivalent of v_icu_stays'
-- icu_los_hours. hospital_los_hours: the WHOLE hospital admission's
-- duration, joined back via parent_admission_traject_id to
-- admission_traject -- same value for every row that shares an
-- admission (identical to stay_los_hours on the admission_traject
-- branch itself, since that row IS the full admission), mirroring
-- how v_icu_stays computes icu_los_hours and hospital_los_hours
-- independently.
--
-- died_during_stay: death_date_time (the sole source of truth for
-- death timing in views -- never death_registration/discharge_location)
-- falls within THIS row's own start/end window, same comparison
-- v_icu_stays now uses for its own icu-segment-scoped flag.
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
    at.discharge_location,
    EXTRACT(EPOCH FROM (at.corrected_discharge_moment - at.admission_moment)) / 3600.0 AS stay_los_hours,
    EXTRACT(EPOCH FROM (at.corrected_discharge_moment - at.admission_moment)) / 3600.0 AS hospital_los_hours,
    CASE
        WHEN pnt.death_date_time IS NOT NULL
         AND pnt.death_date_time >= at.admission_moment
         AND pnt.death_date_time <= at.corrected_discharge_moment
        THEN true ELSE false
    END AS died_during_stay
FROM amc_core.admission_traject at
LEFT JOIN amc_core.patient_not_traceable pnt
    ON pnt.pseudo_id = at.pseudo_id
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
    NULL::text AS discharge_location,
    EXTRACT(EPOCH FROM (apt.corrected_end_date_time - apt.start_date_time)) / 3600.0 AS stay_los_hours,
    EXTRACT(EPOCH FROM (parent_at.corrected_discharge_moment - parent_at.admission_moment)) / 3600.0 AS hospital_los_hours,
    CASE
        WHEN pnt.death_date_time IS NOT NULL
         AND pnt.death_date_time >= apt.start_date_time
         AND pnt.death_date_time <= apt.corrected_end_date_time
        THEN true ELSE false
    END AS died_during_stay
FROM amc_core.admission_partial_traject apt
LEFT JOIN amc_core.admission_traject parent_at
    ON parent_at.admission_traject_id = apt.admission_traject_id
LEFT JOIN amc_core.patient_not_traceable pnt
    ON pnt.pseudo_id = apt.pseudo_id
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
    seh.destination_after_seh AS discharge_location,
    EXTRACT(EPOCH FROM (seh.corrected_seh_departure_date_time - seh.seh_admission_date_time)) / 3600.0 AS stay_los_hours,
    EXTRACT(EPOCH FROM (parent_at.corrected_discharge_moment - parent_at.admission_moment)) / 3600.0 AS hospital_los_hours,
    CASE
        WHEN pnt.death_date_time IS NOT NULL
         AND pnt.death_date_time >= seh.seh_admission_date_time
         AND pnt.death_date_time <= seh.corrected_seh_departure_date_time
        THEN true ELSE false
    END AS died_during_stay
FROM amc_core.seh_trajectory seh
LEFT JOIN amc_core.admission_traject parent_at
    ON parent_at.admission_traject_id = seh.admission_traject_id
LEFT JOIN amc_core.patient_not_traceable pnt
    ON pnt.pseudo_id = seh.pseudo_id
WHERE NOT COALESCE(seh.ongoing_seh_stay, false);
