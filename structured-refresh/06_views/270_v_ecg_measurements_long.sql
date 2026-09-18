----------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_ecg_measurements_long;

CREATE VIEW amc_views.v_ecg_measurements_long AS

SELECT
    e.pseudo_id,
    COALESCE(ex.patient_contact_id, NULL::text) AS patient_contact_id,

    COALESCE(ex.ecg_datetime, e.ecg_decrease_date_time) AS measurement_datetime,

    'ecg' AS measurement_domain,
    m.measurement_name,
    m.value_numeric,
    NULL::text AS value_text,
    m.unit,

    COALESCE(ex.workplace_muse, e.workplace_muse) AS hospital_location,

    ex.test_status,
    ex.test_type_description,
    ex.priority,
    ex.ecg_decrease_device,
    ex.ecg_analysis_software_version,

    'ecg_measurement' AS source_table,
    m.source_column,
    e.ecg_measurement_id AS source_record_id

FROM amc_core.ecg_measurement e

LEFT JOIN amc_views.v_ecg_exams ex
    ON ex.pseudo_id = e.pseudo_id
   AND ex.ecg_measurement_id = e.ecg_measurement_id

CROSS JOIN LATERAL (
    VALUES
        ('pr_interval',  e.pr_interval_at_rest,       'ms',      'pr_interval_at_rest'),
        ('qrs_duration', e.qrs_duration_at_rest,      'ms',      'qrs_duration_at_rest'),
        ('qt_interval',  e.qt_interval_at_rest,       'ms',      'qt_interval_at_rest'),
        ('qtc',          e.qtc_calculation_at_rest,   'ms',      'qtc_calculation_at_rest'),
        ('heart_rate',   e.ventricular_rate_at_rest,  'bpm',     'ventricular_rate_at_rest'),
        ('atrial_rate',  e.atrial_rate_at_rest,       'bpm',     'atrial_rate_at_rest'),
        ('p_axis',       e.p_axis_at_rest,            'degrees', 'p_axis_at_rest'),
        ('r_axis',       e.r_axis_at_rest,            'degrees', 'r_axis_at_rest'),
        ('t_axis',       e.t_axis_at_rest,            'degrees', 't_axis_at_rest')
) AS m(
    measurement_name,
    value_numeric,
    unit,
    source_column
)

WHERE m.value_numeric IS NOT NULL;
