----------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_nephrology_treatments;

CREATE VIEW amc_views.v_nephrology_treatments AS

SELECT
    hd.pseudo_id,
    hd.patient_contact_id,
    hd.measurement_moment::timestamptz AS treatment_datetime,
    hd.meet_date,
    hd.meet_time,
    'hemodialysis' AS nephrology_modality,
    'hemodialysis_output_ml' AS treatment_measure,
    hd.hemodialysis_output_ml::numeric AS value_numeric,
    NULL::text AS value_text,
    'mL' AS unit,
    NULL::text AS treatment_status,
    hd.hospital_location,
    'measurement_nephrology_hemodialysis' AS source_table,
    'hemodialysis_output_ml' AS source_column
FROM amc_core.measurement_nephrology_hemodialysis hd
WHERE hd.hemodialysis_output_ml IS NOT NULL

UNION ALL

SELECT
    pd.pseudo_id,
    pd.patient_contact_id,
    pd.measurement_moment::timestamptz,
    pd.meet_date,
    pd.meet_time,
    'peritoneal_dialysis',
    'volume_in_ml',
    pd.volume_in_ml::numeric,
    NULL::text,
    'mL',
    pd.status,
    pd.hospital_location,
    'measurement_nephrology_peritoneal_dialysis',
    'volume_in_ml'
FROM amc_core.measurement_nephrology_peritoneal_dialysis pd
WHERE pd.volume_in_ml IS NOT NULL

UNION ALL

SELECT
    pd.pseudo_id,
    pd.patient_contact_id,
    pd.measurement_moment::timestamptz,
    pd.meet_date,
    pd.meet_time,
    'peritoneal_dialysis',
    'volume_out_ml',
    pd.volume_out_ml::numeric,
    NULL::text,
    'mL',
    pd.status,
    pd.hospital_location,
    'measurement_nephrology_peritoneal_dialysis',
    'volume_out_ml'
FROM amc_core.measurement_nephrology_peritoneal_dialysis pd
WHERE pd.volume_out_ml IS NOT NULL

UNION ALL

SELECT
    pd.pseudo_id,
    pd.patient_contact_id,
    pd.measurement_moment::timestamptz,
    pd.meet_date,
    pd.meet_time,
    'peritoneal_dialysis',
    'balance_this_treatment_ml',
    pd.balance_this_treatment_ml::numeric,
    NULL::text,
    'mL',
    pd.status,
    pd.hospital_location,
    'measurement_nephrology_peritoneal_dialysis',
    'balance_this_treatment_ml'
FROM amc_core.measurement_nephrology_peritoneal_dialysis pd
WHERE pd.balance_this_treatment_ml IS NOT NULL

UNION ALL

SELECT
    ns.pseudo_id,
    ns.patient_contact_id,
    ns.measurement_moment::timestamptz,
    ns.meet_date,
    ns.meet_time,
    'continuous_nephrology',
    'bloodflow_mlmin',
    ns.bloodflow_mlmin::numeric,
    NULL::text,
    'mL/min',
    ns.treatment_status,
    ns.hospital_location,
    'measurement_nephrology_cnvt_settings',
    'bloodflow_mlmin'
FROM amc_core.measurement_nephrology_cnvt_settings ns
WHERE ns.bloodflow_mlmin IS NOT NULL

UNION ALL

SELECT
    nm.pseudo_id,
    nm.patient_contact_id,
    nm.measurement_moment::timestamptz,
    nm.meet_date,
    nm.meet_time,
    'continuous_nephrology',
    'citrate_flowrate',
    nm.citrate_flowrate::numeric,
    NULL::text,
    'mL/h',
    NULL::text,
    nm.hospital_location,
    'measurement_nephrology_cntv_medication',
    'citrate_flowrate'
FROM amc_core.measurement_nephrology_cntv_medication nm
WHERE nm.citrate_flowrate IS NOT NULL;
