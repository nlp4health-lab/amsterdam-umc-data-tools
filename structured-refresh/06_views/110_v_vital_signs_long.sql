----------------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_vital_signs_long;

-- ── Combined table: ONLY for measures with no individual table equivalent ──

CREATE VIEW amc_views.v_vital_signs_long AS

SELECT
    vs.pseudo_id,
    vs.patient_contact_id,
    vs.measurement_moment AS measurement_datetime,
    'vital_signs' AS measurement_domain,
    'blood_pressure_sys_dia' AS measurement_name,
    NULL::numeric AS value_numeric,
    vs.vital_data_blood_pressure_sys_dia AS value_text,
    'mmHg' AS unit,
    vs.hospital_location,
    'measurement_vital_signs_data' AS source_table,
    'vital_data_blood_pressure_sys_dia' AS source_column
FROM amc_core.measurement_vital_signs_data vs
WHERE vs.vital_data_blood_pressure_sys_dia IS NOT NULL

UNION ALL

SELECT
    vs.pseudo_id,
    vs.patient_contact_id,
    vs.measurement_moment,
    'vital_signs',
    'temperature',
    vs.vital_data_temperature::numeric,
    NULL::text,
    '°C',
    vs.hospital_location,
    'measurement_vital_signs_data',
    'vital_data_temperature'
FROM amc_core.measurement_vital_signs_data vs
WHERE vs.vital_data_temperature IS NOT NULL

-- ── Individual tables: authoritative source; combined fills orphan rows only ──

UNION ALL

SELECT
    bp.pseudo_id,
    bp.patient_contact_id,
    bp.measurement_moment::timestamptz,
    'vital_signs',
    'systolic_blood_pressure',
    bp.systolic_blood_pressure_value::numeric,
    NULL::text,
    'mmHg',
    bp.hospital_location,
    'measurement_blood_pressure',
    'systolic_blood_pressure_value'
FROM amc_core.measurement_blood_pressure bp
WHERE bp.systolic_blood_pressure_value IS NOT NULL

UNION ALL

SELECT
    bp.pseudo_id,
    bp.patient_contact_id,
    bp.measurement_moment::timestamptz,
    'vital_signs',
    'diastolic_blood_pressure',
    bp.diastolic_blood_pressure_value::numeric,
    NULL::text,
    'mmHg',
    bp.hospital_location,
    'measurement_blood_pressure',
    'diastolic_blood_pressure_value'
FROM amc_core.measurement_blood_pressure bp
WHERE bp.diastolic_blood_pressure_value IS NOT NULL

UNION ALL

SELECT
    bpa.pseudo_id,
    bpa.patient_contact_id,
    bpa.measurement_moment::timestamptz,
    'vital_signs',
    'blood_pressure_average',
    bpa.blood_pressure_average::numeric,
    NULL::text,
    'mmHg',
    bpa.hospital_location,
    'measurement_blood_pressure_average',
    'blood_pressure_average'
FROM amc_core.measurement_blood_pressure_average bpa
WHERE bpa.blood_pressure_average IS NOT NULL

-- ── Heart rate: individual table preferred, combined fills ~109k orphans ──

UNION ALL

SELECT
    pseudo_id,
    patient_contact_id,
    measurement_datetime,
    'vital_signs',
    'heart_rate',
    value_numeric,
    NULL::text,
    unit,
    hospital_location,
    source_table,
    'heart_rate'
FROM (
    SELECT DISTINCT ON (pseudo_id, patient_contact_id, measurement_datetime)
        pseudo_id,
        patient_contact_id,
        measurement_datetime,
        value_numeric,
        unit,
        hospital_location,
        source_table,
        source_priority
    FROM (
        SELECT
            hf.pseudo_id,
            hf.patient_contact_id,
            hf.measurement_moment::timestamptz AS measurement_datetime,
            hf.heart_rate::numeric AS value_numeric,
            hf.unit,
            hf.hospital_location,
            'measurement_heart_frequency' AS source_table,
            1 AS source_priority
        FROM amc_core.measurement_heart_frequency hf
        WHERE hf.heart_rate IS NOT NULL

        UNION ALL

        SELECT
            vs.pseudo_id,
            vs.patient_contact_id,
            vs.measurement_moment::timestamptz,
            vs.vital_data_pulse_rate::numeric,
            NULL::text,
            vs.hospital_location,
            'measurement_vital_signs_data',
            2
        FROM amc_core.measurement_vital_signs_data vs
        WHERE vs.vital_data_pulse_rate IS NOT NULL
    ) hr_all
    ORDER BY pseudo_id, patient_contact_id, measurement_datetime, source_priority
) hr_deduped

-- ── BMI: individual table preferred, combined fills ~2,308 orphans ──

UNION ALL

-- All rows from individual table (no dedup needed, source is authoritative)
SELECT
    bmi.pseudo_id,
    bmi.patient_contact_id,
    bmi.measurement_moment::timestamptz AS measurement_datetime,
    'vital_signs',
    'bmi',
    bmi.bmi::numeric,
    NULL::text,
    NULL::text,
    bmi.hospital_location,
    'measurement_bmi',
    'bmi'
FROM amc_core.measurement_bmi bmi
WHERE bmi.bmi IS NOT NULL

UNION ALL

-- Only combined-table rows with no timestamp match in individual table
SELECT
    vs.pseudo_id,
    vs.patient_contact_id,
    vs.measurement_moment::timestamptz,
    'vital_signs',
    'bmi',
    vs.vital_data_bmi_calculation::numeric,
    NULL::text,
    NULL::text,
    vs.hospital_location,
    'measurement_vital_signs_data',
    'bmi'
FROM amc_core.measurement_vital_signs_data vs
WHERE vs.vital_data_bmi_calculation IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM amc_core.measurement_bmi b
      WHERE b.pseudo_id = vs.pseudo_id
        AND b.measurement_moment::timestamptz = vs.measurement_moment
  )

-- ── Height: individual table only (~10 combined-only rows dropped, not worth complexity) ──

UNION ALL

SELECT
    h.pseudo_id,
    h.patient_contact_id,
    h.measurement_moment::timestamptz,
    'vital_signs',
    'height',
    h.body_length::numeric,
    NULL::text,
    h.unit,
    h.hospital_location,
    'measurement_height',
    'body_length'
FROM amc_core.measurement_height h
WHERE h.body_length IS NOT NULL

-- ── Weight: individual table only (~20 combined-only rows dropped, not worth complexity) ──

UNION ALL

SELECT
    w.pseudo_id,
    w.patient_contact_id,
    w.measurement_moment::timestamptz,
    'vital_signs',
    'weight',
    w.body_weight::numeric,
    NULL::text,
    w.unit,
    w.hospital_location,
    'measurement_weight',
    'body_weight'
FROM amc_core.measurement_weight w
WHERE w.body_weight IS NOT NULL

-- ── Oxygen saturation: individual table only, no combined equivalent ──

UNION ALL

SELECT
    ox.pseudo_id,
    ox.patient_contact_id,
    ox.measurement_moment::timestamptz,
    'vital_signs',
    'oxygen_saturation',
    ox.o2saturation::numeric,
    NULL::text,
    '%',
    ox.hospital_location,
    'measurement_o2_saturation',
    'o2saturation'
FROM amc_core.measurement_o2_saturation ox
WHERE ox.o2saturation IS NOT NULL;
