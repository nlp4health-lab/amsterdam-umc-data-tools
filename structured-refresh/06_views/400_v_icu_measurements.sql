------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_icu_measurements;

CREATE VIEW amc_views.v_icu_measurements AS

-- ICU vital signs
SELECT
    v.pseudo_id,
    v.original_patient_contact_id,
    v.icu_patient_contact_id,

    v.icu_stay_id,
    v.admission_traject_id,
    v.icu_start_datetime,
    v.icu_end_datetime,
    v.icu_los_hours,

    v.measurement_datetime,

    'vital_sign' AS measurement_category,
    v.measurement_domain,
    NULL::text AS measurement_subdomain,
    v.measurement_name,
    NULL::text AS measurement_code,

    v.value_numeric,
    v.value_text,
    v.unit,

    v.hospital_location,
    NULL::text AS workplace,

    v.source_table,
    v.source_column,
    NULL::text AS source_record_id,

    v.icu_match_type

FROM amc_views.v_icu_vital_signs_long v

UNION ALL

-- ICU labs
SELECT
    l.pseudo_id,
    l.original_patient_contact_id,
    l.patient_contact_id,

    l.icu_stay_id,
    l.admission_traject_id,
    l.icu_start_datetime,
    l.icu_end_datetime,
    l.icu_los_hours,

    l.measurement_datetime,

    'lab' AS measurement_category,
    l.measurement_domain,
    l.material_type AS measurement_subdomain,
    l.measurement_name,
    l.measurement_code,

    l.value_numeric,
    l.value_text,
    l.unit,

    NULL::text AS hospital_location,
    l.requesting_workplace AS workplace,

    l.source_table,
    NULL::text AS source_column,
    l.source_record_id,

    l.icu_match_type

FROM amc_views.v_icu_labs_long l

UNION ALL

-- ICU scores
SELECT
    s.pseudo_id,
    s.original_patient_contact_id,
    s.icu_patient_contact_id,

    s.icu_stay_id,
    s.admission_traject_id,
    s.icu_start_datetime,
    s.icu_end_datetime,
    s.icu_los_hours,

    s.score_datetime AS measurement_datetime,

    'score' AS measurement_category,
    'score' AS measurement_domain,
    NULL::text AS measurement_subdomain,
    s.score_name AS measurement_name,
    NULL::text AS measurement_code,

    s.score_value::numeric AS value_numeric,
    s.score_category AS value_text,
    NULL::text AS unit,

    s.hospital_location,
    NULL::text AS workplace,

    s.source_table,
    s.source_column,
    NULL::text AS source_record_id,

    s.icu_match_type

FROM amc_views.v_icu_scores s

UNION ALL

-- ICU fluid balance
SELECT
    f.pseudo_id,
    f.original_patient_contact_id,
    f.icu_patient_contact_id,

    f.icu_stay_id,
    f.admission_traject_id,
    f.icu_start_datetime,
    f.icu_end_datetime,
    f.icu_los_hours,

    f.measurement_datetime,

    'fluid_balance' AS measurement_category,
    f.measurement_domain,
    f.fluid_direction AS measurement_subdomain,
    f.measurement_name,
    NULL::text AS measurement_code,

    f.value_numeric,
    f.value_text,
    f.unit,

    f.hospital_location,
    NULL::text AS workplace,

    f.source_table,
    f.source_column,
    NULL::text AS source_record_id,

    f.icu_match_type

FROM amc_views.v_icu_fluid_balance_long f

UNION ALL

-- ICU nephrology treatments
SELECT
    n.pseudo_id,
    n.original_patient_contact_id,
    n.icu_patient_contact_id,

    n.icu_stay_id,
    n.admission_traject_id,
    n.icu_start_datetime,
    n.icu_end_datetime,
    n.icu_los_hours,

    n.treatment_datetime AS measurement_datetime,

    'nephrology' AS measurement_category,
    'nephrology' AS measurement_domain,
    n.nephrology_modality AS measurement_subdomain,
    n.treatment_measure AS measurement_name,
    NULL::text AS measurement_code,

    n.value_numeric,
    n.value_text,
    n.unit,

    n.hospital_location,
    NULL::text AS workplace,

    n.source_table,
    n.source_column,
    NULL::text AS source_record_id,

    n.icu_match_type

FROM amc_views.v_icu_nephrology_treatments n;
