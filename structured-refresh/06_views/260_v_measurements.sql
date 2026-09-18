---------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_measurements;

CREATE VIEW amc_views.v_measurements AS

-- vital signs
SELECT
    v.pseudo_id,
    v.patient_contact_id,
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
    NULL::text AS source_record_id

FROM amc_views.v_vital_signs_long v

UNION ALL

-- labs
SELECT
    l.pseudo_id,
    l.patient_contact_id,
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
    l.source_record_id

FROM amc_views.v_labs_long l

UNION ALL

-- scores
SELECT
    s.pseudo_id,
    s.patient_contact_id,
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
    NULL::text AS source_record_id

FROM amc_views.v_scores s

UNION ALL

-- fluid balance
SELECT
    f.pseudo_id,
    f.patient_contact_id,
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
    NULL::text AS source_record_id

FROM amc_views.v_fluid_balance_long f

UNION ALL

-- nephrology treatments
SELECT
    n.pseudo_id,
    n.patient_contact_id,
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
    NULL::text AS source_record_id

FROM amc_views.v_nephrology_treatments n;
