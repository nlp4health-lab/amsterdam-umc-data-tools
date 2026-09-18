---------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_icu_notes;

CREATE VIEW amc_views.v_icu_notes AS

WITH notes_with_corrected_datetime AS (
    SELECT
        n.*,

        CASE
            WHEN n.note_datetime IS NOT NULL
             AND EXTRACT(YEAR FROM n.note_datetime) >= 2000
            THEN n.note_datetime

            WHEN n.date_note IS NOT NULL
            THEN n.date_note::timestamptz

            ELSE NULL::timestamptz
        END AS corrected_note_datetime

    FROM amc_views.v_notes n
)

SELECT
    n.*,

    n.patient_contact_id AS original_patient_contact_id,
    icu.patient_contact_id AS icu_patient_contact_id,

    icu.icu_stay_id,
    icu.admission_traject_id,
    icu.icu_start_datetime,
    icu.icu_end_datetime,
    icu.icu_los_hours,

    CASE
        WHEN n.patient_contact_id IS NOT NULL
         AND n.patient_contact_id = icu.patient_contact_id
         AND n.corrected_note_datetime IS NOT NULL
         AND n.corrected_note_datetime >= icu.icu_start_datetime
         AND (
              icu.icu_end_datetime IS NULL
              OR n.corrected_note_datetime <= icu.icu_end_datetime
         )
        THEN 'contact_and_datetime_match'

        WHEN n.patient_contact_id IS NULL
         AND n.corrected_note_datetime IS NOT NULL
         AND n.corrected_note_datetime >= icu.icu_start_datetime
         AND (
              icu.icu_end_datetime IS NULL
              OR n.corrected_note_datetime <= icu.icu_end_datetime
         )
        THEN 'datetime_match_contact_filled_from_icu'

        WHEN n.patient_contact_id IS NOT NULL
         AND n.patient_contact_id = icu.patient_contact_id
        THEN 'contact_match_outside_icu_interval'

        ELSE 'pseudo_id_match'
    END AS icu_match_type

FROM notes_with_corrected_datetime n
JOIN amc_views.v_icu_stays icu
    ON icu.pseudo_id = n.pseudo_id
   AND (
        (
            n.corrected_note_datetime IS NOT NULL
            AND n.corrected_note_datetime >= icu.icu_start_datetime
            AND (
                 icu.icu_end_datetime IS NULL
                 OR n.corrected_note_datetime <= icu.icu_end_datetime
            )
        )
        OR (
            n.patient_contact_id IS NOT NULL
            AND n.patient_contact_id = icu.patient_contact_id
        )
   );
