------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_icu_scores;

CREATE VIEW amc_views.v_icu_scores AS

SELECT
    s.pseudo_id,

    s.patient_contact_id AS original_patient_contact_id,
    icu.patient_contact_id AS icu_patient_contact_id,

    icu.icu_stay_id,
    icu.admission_traject_id,
    icu.icu_start_datetime,
    icu.icu_end_datetime,
    icu.icu_los_hours,

    s.score_datetime,
    s.meet_date,
    s.meet_time,

    s.score_name,
    s.score_value,
    s.score_category,

    s.hospital_location,
    s.source_table,
    s.source_column,

    CASE
        WHEN s.patient_contact_id IS NOT NULL
         AND s.patient_contact_id = icu.patient_contact_id
        THEN 'contact_and_datetime_match'

        WHEN s.patient_contact_id IS NOT NULL
         AND s.patient_contact_id <> icu.patient_contact_id
        THEN 'datetime_match_different_contact'

        ELSE 'datetime_match_contact_filled_from_icu'
    END AS icu_match_type

FROM amc_views.v_scores s

JOIN amc_views.v_icu_stays icu
    ON icu.pseudo_id = s.pseudo_id
   AND s.score_datetime IS NOT NULL
   AND s.score_datetime >= icu.icu_start_datetime
   AND (
        icu.icu_end_datetime IS NULL
        OR s.score_datetime <= icu.icu_end_datetime
   );
