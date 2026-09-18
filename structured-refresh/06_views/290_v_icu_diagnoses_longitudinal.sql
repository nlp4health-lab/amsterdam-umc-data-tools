-------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_icu_diagnoses_longitudinal;

CREATE VIEW amc_views.v_icu_diagnoses_longitudinal AS

SELECT
    d.*,
    icu.icu_stay_id,
    icu.admission_traject_id,
    icu.icu_start_datetime,
    icu.icu_end_datetime,
    icu.icu_los_hours,

    CASE
        WHEN d.registration_datetime >= icu.icu_start_datetime
         AND (
              icu.icu_end_datetime IS NULL
              OR d.registration_datetime <= icu.icu_end_datetime
         )
        THEN 1
        ELSE 0
    END AS diagnosis_during_icu_stay

FROM amc_views.v_diagnoses_longitudinal d
JOIN amc_views.v_icu_stays icu
    ON icu.patient_contact_id = d.patient_contact_id;
