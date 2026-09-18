------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_icu_nephrology_treatments;

CREATE VIEW amc_views.v_icu_nephrology_treatments AS

SELECT
    n.pseudo_id,

    n.patient_contact_id AS original_patient_contact_id,
    icu.patient_contact_id AS icu_patient_contact_id,

    icu.icu_stay_id,
    icu.admission_traject_id,
    icu.icu_start_datetime,
    icu.icu_end_datetime,
    icu.icu_los_hours,

    n.treatment_datetime,
    n.meet_date,
    n.meet_time,

    n.nephrology_modality,
    n.treatment_measure,

    n.value_numeric,
    n.value_text,
    n.unit,

    n.treatment_status,

    n.hospital_location,
    n.source_table,
    n.source_column,

    CASE
        WHEN n.patient_contact_id IS NOT NULL
         AND n.patient_contact_id = icu.patient_contact_id
        THEN 'contact_and_datetime_match'

        WHEN n.patient_contact_id IS NOT NULL
         AND n.patient_contact_id <> icu.patient_contact_id
        THEN 'datetime_match_different_contact'

        ELSE 'datetime_match_contact_filled_from_icu'
    END AS icu_match_type

FROM amc_views.v_nephrology_treatments n

JOIN amc_views.v_icu_stays icu
    ON icu.pseudo_id = n.pseudo_id
   AND n.treatment_datetime IS NOT NULL
   AND n.treatment_datetime >= icu.icu_start_datetime
   AND (
        icu.icu_end_datetime IS NULL
        OR n.treatment_datetime <= icu.icu_end_datetime
   );
