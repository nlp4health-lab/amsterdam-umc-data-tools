DROP VIEW IF EXISTS amc_views.v_icu_procedures;

CREATE VIEW amc_views.v_icu_procedures AS

SELECT
    p.pseudo_id,

    p.patient_contact_id AS original_patient_contact_id,
    icu.patient_contact_id AS icu_patient_contact_id,

    icu.icu_stay_id,
    icu.admission_traject_id,
    icu.icu_start_datetime,
    icu.icu_end_datetime,
    icu.icu_los_hours,

    p.procedure_row_id,
    p.procedure_id,
    p.procedure_source,
    p.procedure_datetime,
    p.procedure_end_datetime,
    p.procedure_code,
    p.procedure_name,
    p.procedure_status,
    p.complications,
    p.complications_discussed,

    p.hospital_location,
    p.workplace,
    p.specialty,
    p.subspecialty,

    p.requesting_specialty_abbreviation,
    p.requesting_sub_specialty,
    p.age_at_procedure,
    p.subtraject_id,
    p.ok_session_number,
    p.laterality,
    p.is_chief_intervention,
    p.ok_anesthesia_type,
    p.order_id,
    p.care_activity,
    p.care_profile_class,
    p.source_module,
    p.source_table,

    -- p.patient_contact_id is a real confirmed contact for every source
    -- except ok_procedure_performed/ok_procedure_planned, where it is
    -- 05_linkage_repair's probable_contact_id instead (see v_procedures) --
    -- the probable_partial_traject_id tier below is checked first for
    -- exactly that reason: it's the more precise signal when it's the only
    -- one available.
    CASE
        WHEN p.probable_partial_traject_id IS NOT NULL
         AND p.probable_partial_traject_id = icu.icu_stay_id
        THEN 'probable_partial_traject_id_match'

        WHEN p.patient_contact_id IS NOT NULL
         AND p.patient_contact_id = icu.patient_contact_id
         AND p.procedure_datetime IS NOT NULL
         AND p.procedure_datetime >= icu.icu_start_datetime
         AND (
              icu.icu_end_datetime IS NULL
              OR p.procedure_datetime <= icu.icu_end_datetime
         )
        THEN 'contact_and_datetime_match'

        WHEN p.patient_contact_id IS NULL
         AND p.procedure_datetime IS NOT NULL
         AND p.procedure_datetime >= icu.icu_start_datetime
         AND (
              icu.icu_end_datetime IS NULL
              OR p.procedure_datetime <= icu.icu_end_datetime
         )
        THEN 'datetime_match_contact_filled_from_icu'

        WHEN p.patient_contact_id IS NOT NULL
         AND p.patient_contact_id = icu.patient_contact_id
        THEN 'contact_match_outside_icu_datetime'

        ELSE 'pseudo_id_match'
    END AS icu_match_type

FROM amc_views.v_procedures p

JOIN amc_views.v_icu_stays icu
    ON icu.pseudo_id = p.pseudo_id
   AND (
        (
            p.procedure_datetime IS NOT NULL
            AND p.procedure_datetime >= icu.icu_start_datetime
            AND (
                 icu.icu_end_datetime IS NULL
                 OR p.procedure_datetime <= icu.icu_end_datetime
            )
        )
        OR (
            p.patient_contact_id IS NOT NULL
            AND p.patient_contact_id = icu.patient_contact_id
        )
        OR (
            p.probable_partial_traject_id IS NOT NULL
            AND p.probable_partial_traject_id = icu.icu_stay_id
        )
   );
