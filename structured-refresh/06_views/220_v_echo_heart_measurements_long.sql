----------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_echo_heart_measurements_long;

CREATE VIEW amc_views.v_echo_heart_measurements_long AS

SELECT
    e.pseudo_id,
    NULL::text AS patient_contact_id,

    e.id::text AS echo_exam_id,
    e.accession_number AS source_record_id,

    e.examination_date::timestamptz AS measurement_datetime,
    e.examination_type,
    e.examination_status,

    'echo_heart' AS measurement_domain,
    m.measurement_group,
    m.measurement_name,
    m.value_numeric,
    m.value_text,
    m.unit,

    e.hospital_location,

    'echo_measurement_heart_center_extra_check' AS source_table,
    m.source_column

-- echo_measurement_heart was retired in favor of this table when its CSV
-- disappeared from the source extract (2026-09-11) -- every column below
-- exists here under the same name, except mv_e_f_slope, renamed to
-- e_f_slope (added below as a new measurement row); see
-- archive/580_echo_measurement_heart.sql for the retired definition.
FROM amc_core.echo_measurement_heart_center_extra_check e

CROSS JOIN LATERAL (
    VALUES
        -- body size
        ('body_size', 'bmi', e.bmi, NULL::text, 'kg/m2', 'bmi'),
        ('body_size', 'bsa', e.bsa, NULL::text, 'm2', 'bsa'),

        -- left ventricle / systolic function
        ('left_ventricle', 'lvef_out_summary', NULL::numeric, e.lvef_out_summary, NULL::text, 'lvef_out_summary'),
        -- new on echo_measurement_heart_center_extra_check (renamed from
        -- echo_measurement_heart's mv_e_f_slope)
        ('left_ventricle', 'e_f_slope', e.e_f_slope, NULL::text, NULL::text, 'e_f_slope'),

        -- left atrium
        ('left_atrium', 'la_diameter', e.la_diam, NULL::text, NULL::text, 'la_diam'),
        ('left_atrium', 'la_area', e.la_area, NULL::text, NULL::text, 'la_area'),
        ('left_atrium', 'la_volume_index_mod_bip', e.laesvi_mod_bip, NULL::text, NULL::text, 'laesvi_mod_bip'),
        ('left_atrium', 'thrombus', NULL::numeric, e.thrombus, NULL::text, 'thrombus'),
        ('left_atrium', 'spontaneous_echocontrast', NULL::numeric, e.spontaneous_echocontrast, NULL::text, 'spontaneous_echocontrast'),

        -- aorta
        ('aorta', 'aortic_root_diameter', e.ao_root_diam, NULL::text, NULL::text, 'ao_root_diam'),
        ('aorta', 'ascending_aorta_diameter', e.ao_asc_diam, NULL::text, NULL::text, 'ao_asc_diam'),
        ('aorta', 'sinus_valsalva_diameter', e.diam_sinus_valsalva, NULL::text, NULL::text, 'diam_sinus_valsalva'),
        ('aorta', 'aortic_dilation', NULL::numeric, e.dilation, NULL::text, 'dilation'),

        -- aortic valve
        ('aortic_valve', 'aortic_valve_vmax', e.av_vmax, NULL::text, NULL::text, 'av_vmax'),
        ('aortic_valve', 'aortic_valve_mean_gradient', e.av_mean_pg, NULL::text, NULL::text, 'av_mean_pg'),
        ('aortic_valve', 'aortic_valve_max_gradient', e.av_max_pg, NULL::text, NULL::text, 'av_max_pg'),
        ('aortic_valve', 'aortic_valve_area_vti', e.ava_vti, NULL::text, NULL::text, 'ava_vti'),
        ('aortic_valve', 'aortic_valve_area_vmax', e.ava_vmax, NULL::text, NULL::text, 'ava_vmax'),
        ('aortic_valve', 'aortic_valve_stenosis', NULL::numeric, e.stenosis, NULL::text, 'stenosis'),
        ('aortic_valve', 'aortic_valve_insufficiency', NULL::numeric, e.insufficiency, NULL::text, 'insufficiency'),

        -- right atrium / right ventricle
        ('right_atrium', 'right_atrium_size', NULL::numeric, e.ra_size, NULL::text, 'ra_size'),
        ('right_atrium', 'right_atrium_pressure', e.rap, NULL::text, NULL::text, 'rap'),

        ('right_ventricle', 'right_ventricle_size', NULL::numeric, e.rv_size, NULL::text, 'rv_size'),
        ('right_ventricle', 'right_ventricle_systolic_function', NULL::numeric, e.systolic_function, NULL::text, 'systolic_function'),
        ('right_ventricle', 'rvsp', e.rvsp, NULL::text, NULL::text, 'rvsp'),

        -- tricuspid valve
        ('tricuspid_valve', 'tricuspid_regurgitation_vmax', e.tr_vmax, NULL::text, NULL::text, 'tr_vmax'),
        ('tricuspid_valve', 'tricuspid_regurgitation_max_gradient', e.tr_max_pg, NULL::text, NULL::text, 'tr_max_pg'),
        ('tricuspid_valve', 'tricuspid_valve_mean_gradient', e.tv_mean_pg, NULL::text, NULL::text, 'tv_mean_pg'),

        -- pulmonary valve / pulmonary artery
        ('pulmonary_valve', 'pulmonary_valve_vmax', e.pv_vmax, NULL::text, NULL::text, 'pv_vmax'),
        ('pulmonary_valve', 'pulmonary_valve_mean_gradient', e.pv_mean_pg, NULL::text, NULL::text, 'pv_mean_pg'),

        -- IVC / venous
        ('venous', 'ivc_2d', e.ivc_2d, NULL::text, NULL::text, 'ivc_2d'),
        ('venous', 'respiratory_change', NULL::numeric, e.resp_change, NULL::text, 'resp_change'),
        ('venous', 'ivc', NULL::numeric, e.ivc, NULL::text, 'ivc')

) AS m(
    measurement_group,
    measurement_name,
    value_numeric,
    value_text,
    unit,
    source_column
)

WHERE m.value_numeric IS NOT NULL
   OR m.value_text IS NOT NULL;
