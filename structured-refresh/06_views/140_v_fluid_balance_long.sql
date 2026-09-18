---------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_fluid_balance_long;

CREATE VIEW amc_views.v_fluid_balance_long AS

SELECT
    d.pseudo_id,
    d.patient_contact_id,
    d.measurement_moment::timestamptz AS measurement_datetime,
    d.meet_date,
    d.meet_time,
    'fluid_balance' AS measurement_domain,
    'output' AS fluid_direction,
    'diuresis_output' AS measurement_name,
    d.diuresis_output::numeric AS value_numeric,
    NULL::text AS value_text,
    d.unit,
    d.hospital_location,
    'measurement_diurese' AS source_table,
    'diuresis_output' AS source_column
FROM amc_core.measurement_diurese d
WHERE d.diuresis_output IS NOT NULL

UNION ALL

SELECT
    fad.pseudo_id,
    fad.patient_contact_id,
    fad.measurement_moment::timestamptz AS measurement_datetime,
    fad.meet_date,
    fad.meet_time,
    'fluid_balance' AS measurement_domain,
    'assessment' AS fluid_direction,
    'bladderscan_ml' AS measurement_name,
    fad.bladderscan_ml::numeric AS value_numeric,
    NULL::text AS value_text,
    'mL' AS unit,
    fad.hospital_location,
    'measurement_fluid_assessment_diuresis' AS source_table,
    'bladderscan_ml' AS source_column
FROM amc_core.measurement_fluid_assessment_diuresis fad
WHERE fad.bladderscan_ml IS NOT NULL

UNION ALL

SELECT
    fad.pseudo_id,
    fad.patient_contact_id,
    fad.measurement_moment::timestamptz AS measurement_datetime,
    fad.meet_date,
    fad.meet_time,
    'fluid_balance',
    'assessment',
    'description_urine',
    NULL::numeric,
    fad.description_urine,
    NULL::text,
    fad.hospital_location,
    'measurement_fluid_assessment_diuresis',
    'description_urine'
FROM amc_core.measurement_fluid_assessment_diuresis fad
WHERE fad.description_urine IS NOT NULL

UNION ALL

SELECT
    fad.pseudo_id,
    fad.patient_contact_id,
    fad.measurement_moment::timestamptz,
    fad.meet_date,
    fad.meet_time,
    'fluid_balance',
    'assessment',
    'urine_odor',
    NULL::numeric,
    fad.urine_odor,
    NULL::text,
    fad.hospital_location,
    'measurement_fluid_assessment_diuresis',
    'urine_odor'
FROM amc_core.measurement_fluid_assessment_diuresis fad
WHERE fad.urine_odor IS NOT NULL

UNION ALL

SELECT
    fad.pseudo_id,
    fad.patient_contact_id,
    fad.measurement_moment::timestamptz,
    fad.meet_date,
    fad.meet_time,
    'fluid_balance',
    'assessment',
    'incontinence_urine',
    NULL::numeric,
    fad.incontinence_urine,
    NULL::text,
    fad.hospital_location,
    'measurement_fluid_assessment_diuresis',
    'incontinence_urine'
FROM amc_core.measurement_fluid_assessment_diuresis fad
WHERE fad.incontinence_urine IS NOT NULL

UNION ALL

SELECT
    fi.pseudo_id,
    fi.patient_contact_id,
    fi.measurement_moment::timestamptz,
    fi.meet_date,
    fi.meet_time,
    'fluid_balance',
    'input',
    COALESCE(fi.question_observation_description, fi.moisture_balance_at_type, 'fluid_input'),
    CASE
        WHEN fi.value ~ '^[-+]?[0-9]*\.?[0-9]+$'
        THEN fi.value::numeric
    END,
    fi.value,
    fi.unit,
    fi.hospital_location,
    'measurement_fluid_in',
    'value'
FROM amc_core.measurement_fluid_in fi
WHERE fi.value IS NOT NULL

UNION ALL

SELECT
    fo.pseudo_id,
    fo.patient_contact_id,
    fo.measurement_moment::timestamptz,
    fo.meet_date,
    fo.meet_time,
    'fluid_balance',
    'output',
    COALESCE(fo.question_observation_description, fo.moisture_out_type, 'fluid_output'),
    CASE
        WHEN fo.value ~ '^[-+]?[0-9]*\.?[0-9]+$'
        THEN fo.value::numeric
    END,
    fo.value,
    fo.unit,
    fo.hospital_location,
    'measurement_fluid_balance_out',
    'value'
FROM amc_core.measurement_fluid_balance_out fo
WHERE fo.value IS NOT NULL

UNION ALL

SELECT
    e.pseudo_id,
    e.patient_contact_id,
    e.measurement_moment::timestamptz AS measurement_datetime,
    e.meet_date,
    e.meet_time,
    'fluid_balance' AS measurement_domain,
    'output' AS fluid_direction,
    'emesis_assessment' AS measurement_name,
    NULL::numeric AS value_numeric,
    e.assessment_emesis AS value_text,
    NULL::text AS unit,
    e.hospital_location,
    'measurement_fluid_balance_assessment_emesis' AS source_table,
    'assessment_emesis' AS source_column
FROM amc_core.measurement_fluid_balance_assessment_emesis e
WHERE e.assessment_emesis IS NOT NULL

UNION ALL

SELECT
    e.pseudo_id,
    e.patient_contact_id,
    e.measurement_moment::timestamptz,
    e.meet_date,
    e.meet_time,
    'fluid_balance',
    'output',
    'vomiting_amount',
    NULL::numeric,
    e.vomiting_amount,
    NULL::text,
    e.hospital_location,
    'measurement_fluid_balance_assessment_emesis',
    'vomiting_amount'
FROM amc_core.measurement_fluid_balance_assessment_emesis e
WHERE e.vomiting_amount IS NOT NULL

UNION ALL

SELECT
    f.pseudo_id,
    f.patient_contact_id,
    f.measurement_moment::timestamptz,
    f.meet_date,
    f.meet_time,
    'fluid_balance',
    'output',
    'incontinence_feces',
    NULL::numeric,
    f.incontinence_feces,
    NULL::text,
    f.hospital_location,
    'measurement_fluid_balance_assessment_feces',
    'incontinence_feces'
FROM amc_core.measurement_fluid_balance_assessment_feces f
WHERE f.incontinence_feces IS NOT NULL

UNION ALL

SELECT
    f.pseudo_id,
    f.patient_contact_id,
    f.measurement_moment::timestamptz,
    f.meet_date,
    f.meet_time,
    'fluid_balance',
    'output',
    'consistency_feces',
    NULL::numeric,
    f.consistency_feces,
    NULL::text,
    f.hospital_location,
    'measurement_fluid_balance_assessment_feces',
    'consistency_feces'
FROM amc_core.measurement_fluid_balance_assessment_feces f
WHERE f.consistency_feces IS NOT NULL

UNION ALL

SELECT
    f.pseudo_id,
    f.patient_contact_id,
    f.measurement_moment::timestamptz,
    f.meet_date,
    f.meet_time,
    'fluid_balance',
    'output',
    'consistency_feces_baby',
    NULL::numeric,
    f.consistency_feces_baby,
    NULL::text,
    f.hospital_location,
    'measurement_fluid_balance_assessment_feces',
    'consistency_feces_baby'
FROM amc_core.measurement_fluid_balance_assessment_feces f
WHERE f.consistency_feces_baby IS NOT NULL

UNION ALL

SELECT
    f.pseudo_id,
    f.patient_contact_id,
    f.measurement_moment::timestamptz,
    f.meet_date,
    f.meet_time,
    'fluid_balance',
    'output',
    'color_feces',
    NULL::numeric,
    f.color_feces,
    NULL::text,
    f.hospital_location,
    'measurement_fluid_balance_assessment_feces',
    'color_feces'
FROM amc_core.measurement_fluid_balance_assessment_feces f
WHERE f.color_feces IS NOT NULL

UNION ALL

SELECT
    f.pseudo_id,
    f.patient_contact_id,
    f.measurement_moment::timestamptz,
    f.meet_date,
    f.meet_time,
    'fluid_balance',
    'output',
    'quantity_feces',
    NULL::numeric,
    f.quantity_feces,
    NULL::text,
    f.hospital_location,
    'measurement_fluid_balance_assessment_feces',
    'quantity_feces'
FROM amc_core.measurement_fluid_balance_assessment_feces f
WHERE f.quantity_feces IS NOT NULL

UNION ALL

SELECT
    sr.pseudo_id,
    sr.patient_contact_id,
    sr.measurement_moment::timestamptz,
    sr.meet_date,
    sr.meet_time,
    'fluid_balance',
    'output',
    'stomach_retention',
    sr.stomach_retention::numeric,
    NULL::text,
    'mL',
    sr.hospital_location,
    'measurement_fluid_balance_stomach_retention',
    'stomach_retention'
FROM amc_core.measurement_fluid_balance_stomach_retention sr
WHERE sr.stomach_retention IS NOT NULL

UNION ALL

SELECT
    sr.pseudo_id,
    sr.patient_contact_id,
    sr.measurement_moment::timestamptz,
    sr.meet_date,
    sr.meet_time,
    'fluid_balance',
    'assessment',
    'assessment_stomach_retention',
    NULL::numeric,
    sr.assessment_stomach_retention,
    NULL::text,
    sr.hospital_location,
    'measurement_fluid_balance_stomach_retention',
    'assessment_stomach_retention'
FROM amc_core.measurement_fluid_balance_stomach_retention sr
WHERE sr.assessment_stomach_retention IS NOT NULL

UNION ALL

SELECT
    sr.pseudo_id,
    sr.patient_contact_id,
    sr.measurement_moment::timestamptz,
    sr.meet_date,
    sr.meet_time,
    'fluid_balance',
    'output',
    'air_retention',
    sr.air_retention::numeric,
    NULL::text,
    'mL',
    sr.hospital_location,
    'measurement_fluid_balance_stomach_retention',
    'air_retention'
FROM amc_core.measurement_fluid_balance_stomach_retention sr
WHERE sr.air_retention IS NOT NULL;
