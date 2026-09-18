DROP VIEW IF EXISTS amc_views.v_icu_stays;

CREATE VIEW amc_views.v_icu_stays AS

SELECT
    apt.pseudo_id,
    apt.patient_contact_id,

    apt.admission_partial_traject_id AS icu_stay_id,
    apt.admission_traject_id,

    apt.start_date_time AS icu_start_datetime,
    apt.corrected_end_date_time AS icu_end_datetime,

    EXTRACT(
        EPOCH FROM (
            apt.corrected_end_date_time - apt.start_date_time
        )
    ) / 3600.0 AS icu_los_hours,

    at.admission_moment AS hospital_admission_datetime,
    at.corrected_discharge_moment AS hospital_discharge_datetime,

    EXTRACT(
        EPOCH FROM (
            at.corrected_discharge_moment - at.admission_moment
        )
    ) / 3600.0 AS hospital_los_hours,

    apt.hospital_location,
    apt.workplace,
    apt.specialty,
    apt.subspecialty,

    apt.patient_class,
    apt.bed,
    apt.room,

    p.gender,
    p.year_of_birth,
    p.death_date_time,
    p.is_deceased,

    pc.patient_contact_type,
    pc.patient_contact_date_time,
    pc.patient_appointment_status

FROM amc_core.admission_partial_traject apt

LEFT JOIN amc_core.admission_traject at
    ON at.admission_traject_id = apt.admission_traject_id

LEFT JOIN amc_core.patient_contact pc
    ON pc.patient_contact_id = apt.patient_contact_id

LEFT JOIN amc_core.patient_not_traceable p
    ON p.pseudo_id = apt.pseudo_id

WHERE NOT COALESCE(apt.ongoing_partial_stay, false)
  AND (
        apt.workplace ILIKE '%ICU%'
     OR apt.workplace ILIKE '%INTENSIVE%'
  );
