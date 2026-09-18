--------------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_diagnoses_longitudinal;

CREATE VIEW amc_views.v_diagnoses_longitudinal AS

SELECT
    md.pseudo_id,
    md.patient_contact_id,
    md.medical_diagnosis_id::text AS condition_id,
    'medical_diagnosis' AS condition_source,
    md.diagnosis_type AS condition_type,
    NULL::text AS contact_type,
    NULL::text AS condition_status,
    md.diagnosis_registration_moment AS registration_datetime,
    md.diagnosis_contact_date AS observation_date,
    NULL::date AS close_date,
    md.diagnosis_code,
    NULL::text AS problem_code,
    NULL::text AS snomed_code,
    md.diagnosis_category,
    md.diagnosis_description,
    md.specialty,
    NULL::text AS is_chronic,
    md.is_complication,
    CASE
        WHEN md.diagnosis_type IN ('Hoofddiagnose', 'Primaire diagnose') THEN 'true'
        ELSE 'false'
    END AS is_chief_problem,
    md.hospital_location
FROM amc_core.medical_diagnosis md

UNION ALL

SELECT
    pl.pseudo_id,
    pl.patient_contact_id,
    pl.problem_list_id::text AS condition_id,
    'problem_list' AS condition_source,
    NULL::text AS condition_type,
    pl.patient_contact_type AS contact_type,
    pl.patient_problem_status AS condition_status,
    pl.registration_date::timestamptz AS registration_datetime,
    pl.observation_date,
    pl.corrected_close_date AS close_date,
    pl.diagnosis_code,
    pl.problem_code,
    pl.snomed_code,
    pl.diagnosis_category,
    COALESCE(
        pl.problem_description,
        pl.problem_description_display_epic
    ) AS diagnosis_description,
    NULL::text AS specialty,
    pl.is_chronic,
    NULL::text AS is_complication,
    pl.is_chief_problem,
    pl.hospital_location
FROM amc_core.problem_list pl;
