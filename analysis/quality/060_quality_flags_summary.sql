-- =====================================================================
-- Data quality check: rollup of every boolean quality-flag column
-- structured-refresh/04_quality_flags computes, in one place.
--
-- 11 per-row flags across 10 tables, plus 1 patient-level aggregate
-- (patient_not_traceable.has_any_quality_issue -- true if that patient
-- has any of the 11 per-row flags set true anywhere in this stage;
-- reported separately below since its denominator is patients, not
-- rows). Nothing until now showed "how much of my data is flagged,
-- and for what" without reading all 11 files individually.
--
-- Usage: run in psql / any Postgres client against carenlp_db. Each
-- row of the first result = one (table, flag_column) pair.
-- =====================================================================

-- Per-row flags
SELECT
    table_name,
    flag_column,
    total_rows,
    flagged_rows,
    ROUND(100.0 * flagged_rows / NULLIF(total_rows, 0), 2) AS pct_flagged
FROM (

    SELECT 'admission_partial_traject'::text AS table_name, 'ongoing_partial_stay'::text AS flag_column,
        COUNT(*) AS total_rows, COUNT(*) FILTER (WHERE ongoing_partial_stay) AS flagged_rows
    FROM amc_core.admission_partial_traject

    UNION ALL

    SELECT 'admission_partial_traject', 'ongoing_admission_traject',
        COUNT(*), COUNT(*) FILTER (WHERE ongoing_admission_traject)
    FROM amc_core.admission_partial_traject

    UNION ALL

    SELECT 'admission_traject', 'ongoing_stay',
        COUNT(*), COUNT(*) FILTER (WHERE ongoing_stay)
    FROM amc_core.admission_traject

    UNION ALL

    SELECT 'ecg_measurement', 'abnormal_decrease_date_time',
        COUNT(*), COUNT(*) FILTER (WHERE abnormal_decrease_date_time)
    FROM amc_core.ecg_measurement

    UNION ALL

    SELECT 'ecg_measurement_test_feature', 'abnormal_date_flag',
        COUNT(*), COUNT(*) FILTER (WHERE abnormal_date_flag)
    FROM amc_core.ecg_measurement_test_feature

    UNION ALL

    SELECT 'echo_measurement_heart_center_extra_check', 'examination_date_quality_issue',
        COUNT(*), COUNT(*) FILTER (WHERE examination_date_quality_issue)
    FROM amc_core.echo_measurement_heart_center_extra_check

    UNION ALL

    SELECT 'ic_procedure_note_central_venous_catheter', 'end_procedure_quality_issue',
        COUNT(*), COUNT(*) FILTER (WHERE end_procedure_quality_issue)
    FROM amc_core.ic_procedure_note_central_venous_catheter

    UNION ALL

    SELECT 'medication_administration', 'ongoing_medication_administration',
        COUNT(*), COUNT(*) FILTER (WHERE ongoing_medication_administration)
    FROM amc_core.medication_administration

    UNION ALL

    SELECT 'medication_prescription', 'ongoing_medication',
        COUNT(*), COUNT(*) FILTER (WHERE ongoing_medication)
    FROM amc_core.medication_prescription

    UNION ALL

    SELECT 'patient_contact', 'abnormal_date',
        COUNT(*), COUNT(*) FILTER (WHERE abnormal_date)
    FROM amc_core.patient_contact

    UNION ALL

    SELECT 'seh_trajectory', 'ongoing_seh_stay',
        COUNT(*), COUNT(*) FILTER (WHERE ongoing_seh_stay)
    FROM amc_core.seh_trajectory

) sub
ORDER BY pct_flagged DESC NULLS LAST;

-- Patient-level aggregate: true if that patient has any of the 11
-- flags above set true anywhere (04_quality_flags/130_patient_not_traceable.sql)
SELECT
    COUNT(*) AS total_patients,
    COUNT(*) FILTER (WHERE has_any_quality_issue) AS patients_flagged,
    ROUND(100.0 * COUNT(*) FILTER (WHERE has_any_quality_issue) / NULLIF(COUNT(*), 0), 2) AS pct_patients_flagged
FROM amc_core.patient_not_traceable;
