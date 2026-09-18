------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_icu_fluid_balance_long CASCADE;

CREATE VIEW amc_views.v_icu_fluid_balance_long AS

SELECT
    f.pseudo_id,

    f.patient_contact_id AS original_patient_contact_id,
    icu.patient_contact_id AS icu_patient_contact_id,

    icu.icu_stay_id,
    icu.admission_traject_id,
    icu.icu_start_datetime,
    icu.icu_end_datetime,
    icu.icu_los_hours,

    f.measurement_datetime,
    f.meet_date,
    f.meet_time,

    f.measurement_domain,
    f.fluid_direction,
    f.measurement_name,

    f.value_numeric,
    f.value_text,
    f.unit,

    f.hospital_location,
    f.source_table,
    f.source_column,

    CASE
        WHEN f.patient_contact_id IS NOT NULL
         AND f.patient_contact_id = icu.patient_contact_id
        THEN 'contact_and_datetime_match'

        WHEN f.patient_contact_id IS NOT NULL
         AND f.patient_contact_id <> icu.patient_contact_id
        THEN 'datetime_match_different_contact'

        ELSE 'datetime_match_contact_filled_from_icu'
    END AS icu_match_type

FROM amc_views.v_fluid_balance_long f

JOIN amc_views.v_icu_stays icu
    ON icu.pseudo_id = f.pseudo_id
   AND f.measurement_datetime IS NOT NULL
   AND f.measurement_datetime >= icu.icu_start_datetime
   AND (
        icu.icu_end_datetime IS NULL
        OR f.measurement_datetime <= icu.icu_end_datetime
   );
