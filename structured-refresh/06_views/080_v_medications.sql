--------------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_medications CASCADE;

CREATE VIEW amc_views.v_medications AS

SELECT
    mp.pseudo_id,
    mp.patient_contact_id,
    pc.patient_contact_date,
    pc.specialty AS patient_contact_specialty,

    NULL::text AS admission_traject_id,
    mp.rule_id AS medication_event_id,
    'prescription' AS medication_event_type,

    mp.prescription_date_time AS event_datetime,
    mp.start_date_time AS start_datetime,
    mp.corrected_stop_date_time AS stop_datetime,
    mp.corrected_stop_date AS stop_date,
    mp.corrected_stop_time AS stop_time,
    mp.ongoing_medication,

    mp.order_status AS status,
    mp.administration_route AS route,

    NULL::numeric AS administered_amount,
    NULL::text AS administered_quantity_unit,
    NULL::text AS administration_reason,
    NULL::text AS medication_remark,

    mp.medication_article_name,
    mp.medication_generic_name,
    mp.medication_substance_name,

    mp.atc_code,
    mp.atc_name,

    atc.atc_code_niv1,
    atc.atc_name_niv1,
    atc.atc_code_niv2,
    atc.atc_name_niv2,
    atc.atc_code_niv3,
    atc.atc_name_niv3,
    atc.atc_code_niv4,
    atc.atc_name_niv4,
    atc.atc_code_niv5,
    atc.atc_name_niv5,

    mp.pharmaceutical_class,
    mp.pharmaceutical_subclass,
    mp.therapeutic_class,

    mp.specialty_description AS specialty,
    mp.sub_specialty_description AS subspecialty,
    mp.workplace_description AS workplace,
    mp.hospital_location,
    mp.clinical_outpatient,

    mp.medication_frequency_description,
    mp.dosage_prescribed_unit_description,
    mp.dosage_prescribed_min,
    mp.dosage_prescribed_max,
    mp.dosage_calculated_unit_description,
    mp.dosage_calculated_min,
    mp.dosage_calculated_max,
    mp.dosage_calculation_information,
    mp.volume,
    mp.weight_patient_kg,

    NULL::text AS medication_strength,
    NULL::text AS medication_strength_dosage,
    NULL::text AS medication_strength_unit,
    NULL::text AS ingredient_type_name,
    NULL::text AS walk_in,
    NULL::numeric AS number_submitted_pieces,

    mp.order_class_description,
    mp.order_description,
    mp.previous_prescription_id,

    'medication_prescription' AS source_table

FROM amc_core.medication_prescription mp

LEFT JOIN amc_core.patient_contact pc
    ON pc.patient_contact_id = mp.patient_contact_id

LEFT JOIN amc_core.medication_atc atc
    ON atc.atc_code = mp.atc_code

UNION ALL

SELECT
    ma.pseudo_id,
    ma.patient_contact_id,
    pc.patient_contact_date,
    pc.specialty AS patient_contact_specialty,

    ma.admission_traject_id,
    ma.medication_administration_id::text AS medication_event_id,
    'administration' AS medication_event_type,

    ma.corrected_administration_date_time AS event_datetime,
    NULL::timestamptz AS start_datetime,
    NULL::timestamptz AS stop_datetime,
    NULL::date AS stop_date,
    NULL::time AS stop_time,
    NULL::boolean AS ongoing_medication,

    ma.administration_status AS status,
    ma.administration_route AS route,

    ma.administered_amount,
    ma.administered_quantity_unit,
    ma.administration_reason,
    ma.medication_remark,

    ma.medication_article_name,
    ma.medication_generic_name,
    ma.medication_substance_name,

    ma.atc_code,
    ma.atc_name,

    atc.atc_code_niv1,
    atc.atc_name_niv1,
    atc.atc_code_niv2,
    atc.atc_name_niv2,
    atc.atc_code_niv3,
    atc.atc_name_niv3,
    atc.atc_code_niv4,
    atc.atc_name_niv4,
    atc.atc_code_niv5,
    atc.atc_name_niv5,

    ma.pharmaceutical_class,
    ma.pharmaceutical_subclass,
    ma.therapeutic_class,

    NULL::text AS specialty,
    NULL::text AS subspecialty,
    ma.workplace,
    ma.hospital_location,
    NULL::text AS clinical_outpatient,

    NULL::text AS medication_frequency_description,
    NULL::text AS dosage_prescribed_unit_description,
    NULL::numeric AS dosage_prescribed_min,
    NULL::numeric AS dosage_prescribed_max,
    NULL::text AS dosage_calculated_unit_description,
    NULL::numeric AS dosage_calculated_min,
    NULL::numeric AS dosage_calculated_max,
    NULL::text AS dosage_calculation_information,
    NULL::numeric AS volume,
    NULL::numeric AS weight_patient_kg,

    ma.medication_strength,
    ma.medication_strength_dosage,
    ma.medication_strength_unit,
    ma.ingredient_type_name,
    ma.walk_in,
    ma.number_submitted_pieces,

    NULL::text AS order_class_description,
    NULL::text AS order_description,
    NULL::text AS previous_prescription_id,

    'medication_administration' AS source_table

FROM amc_core.medication_administration ma

LEFT JOIN amc_core.patient_contact pc
    ON pc.patient_contact_id = ma.patient_contact_id

LEFT JOIN amc_core.medication_atc atc
    ON atc.atc_code = ma.atc_code;
