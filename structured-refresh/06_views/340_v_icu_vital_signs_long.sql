-----------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_icu_vital_signs_long;

CREATE VIEW amc_views.v_icu_vital_signs_long AS

SELECT
    v.pseudo_id,

    v.patient_contact_id AS original_patient_contact_id,
    icu.patient_contact_id AS icu_patient_contact_id,

    icu.icu_stay_id,
    icu.admission_traject_id,
    icu.icu_start_datetime,
    icu.icu_end_datetime,
    icu.icu_los_hours,

    v.measurement_datetime,
    v.measurement_domain,
    v.measurement_name,
    v.value_numeric,
    v.value_text,
    v.unit,
    v.hospital_location,
    v.source_table,
    v.source_column,

    CASE
        WHEN v.patient_contact_id IS NOT NULL
         AND v.patient_contact_id = icu.patient_contact_id
        THEN 'contact_and_datetime_match'

        WHEN v.patient_contact_id IS NOT NULL
         AND v.patient_contact_id <> icu.patient_contact_id
        THEN 'datetime_match_different_contact'

        ELSE 'datetime_match_contact_filled_from_icu'
    END AS icu_match_type

FROM amc_views.v_vital_signs_long v

JOIN amc_views.v_icu_stays icu
    ON icu.pseudo_id = v.pseudo_id
   AND v.measurement_datetime IS NOT NULL
   AND v.measurement_datetime >= icu.icu_start_datetime
   AND (
        icu.icu_end_datetime IS NULL
        OR v.measurement_datetime <= icu.icu_end_datetime
   );
