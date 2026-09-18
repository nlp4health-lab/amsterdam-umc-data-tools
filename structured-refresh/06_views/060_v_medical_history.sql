---------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS amc_views.v_medical_history;

CREATE VIEW amc_views.v_medical_history AS

SELECT
    mh.pseudo_id,
    mh.patient_contact_id,
    pc.specialty AS patient_contact_specialty,

    mh.medical_history_id AS history_item_id,
    'medical_history' AS history_type,

    mh.registration_date,
    mh.indication_determination_date AS start_date,
    NULL::date AS end_date,

    mh.diagnosis_code AS code,
    mh.diagnosis_category AS category,
    mh.diagnosis_description AS description,

    COALESCE(
        mh.history_explanation,
        mh.history_annotation
    ) AS explanation,

    mh.hospital_location,
    'medical_history' AS source_table

FROM amc_core.medical_history mh
LEFT JOIN amc_core.patient_contact pc
    ON pc.patient_contact_id = mh.patient_contact_id

UNION ALL

SELECT
    sh.pseudo_id,
    sh.patient_contact_id,
    pc.specialty AS patient_contact_specialty,

    sh.surgery_history_id AS history_item_id,
    'surgery_history' AS history_type,

    sh.registration_date,
    sh.procedure_start_date AS start_date,
    sh.procedure_end_date AS end_date,

    sh.surgical_past_history_code AS code,
    sh.type_code AS category,
    sh.surgical_past_history AS description,

    NULL::text AS explanation,

    sh.hospital_location,
    'surgery_history' AS source_table

FROM amc_core.surgery_history sh
LEFT JOIN amc_core.patient_contact pc
    ON pc.patient_contact_id = sh.patient_contact_id

UNION ALL

SELECT
    fh.pseudo_id,
    fh.patient_contact_id,
    pc.specialty AS patient_contact_specialty,

    fh.family_history_id AS history_item_id,
    'family_history' AS history_type,

    fh.registration_date,
    NULL::date AS start_date,
    NULL::date AS end_date,

    NULL::text AS code,
    NULL::text AS category,
    fh.family_history AS description,

    NULL::text AS explanation,

    fh.hospital_location,
    'family_history' AS source_table

FROM amc_core.family_history fh
LEFT JOIN amc_core.patient_contact pc
    ON pc.patient_contact_id = fh.patient_contact_id;
