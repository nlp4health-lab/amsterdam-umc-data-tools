--===========================================================================
DROP TABLE IF EXISTS amc_core.ic_procedure_note_icarus CASCADE;

CREATE TABLE amc_core.ic_procedure_note_icarus (
  patient_contact_id text NOT NULL,
  order_id text NOT NULL,

  pseudo_id text,
  hospital_location text,
  intervention_date_time timestamptz,
  intervention_name text,

  start_procedure text,
  date_time_authorization timestamptz,
  informed_consent text,
  complications_discussed text,
  time_out_executed text,
  indication text,
  certified_echographer text,
  conclusion text,

  lung_sliding_left text,
  lung_sliding_right text,
  plaps_left text,
  plaps_right text,
  blue_profile text,

  lung_aeration_score_right_field1_raw text,

  lung_aeration_score_right_field1 numeric,
  lung_aeration_score_right_field2_raw text,
  lung_aeration_score_right_field2 numeric,
  lung_aeration_score_right_field3_raw text,
  lung_aeration_score_right_field3 numeric,
  lung_aeration_score_right_field4_raw text,
  lung_aeration_score_right_field4 numeric,
  lung_aeration_score_right_field5_raw text,
  lung_aeration_score_right_field5 numeric,
  lung_aeration_score_right_field6_raw text,
  lung_aeration_score_right_field6 numeric,
  lung_aeration_score_right_field8_raw text,
  lung_aeration_score_right_field8 numeric,
  lung_aeration_score_left_field1_raw text,
  lung_aeration_score_left_field1 numeric,
  lung_aeration_score_lefts_field2_raw text,
  lung_aeration_score_lefts_field2 numeric,
  lung_aeration_score_left_field3_raw text,
  lung_aeration_score_left_field3 numeric,
  lung_aeration_score_left_field4_raw text,
  lung_aeration_score_left_field4 numeric,
  lung_aeration_score_left_field5_raw text,
  lung_aeration_score_left_field5 numeric,
  lung_aeration_score_left_field6_raw text,
  lung_aeration_score_left_field6 numeric,
  lung_aeration_score_left_field8_raw text,
  lung_aeration_score_left_field8 numeric,
  lung_aeration_total_score numeric,

  left_atrium text,
  right_atrium text,
  left_ventricle text,
  right_ventricle text,
  left_ventricular_function text,

  lvot_diameter_mm numeric,
  lvot_vti numeric,
  heart_rate_bpm numeric,
  cardiac_output_with_vti_liter_per_minute numeric,

  right_ventricular_function text,

  tapered_mm numeric,
  mitral_insufficiency text,
  tricuspid_insufficiency text,

  cvd_mm_hg numeric,
  cvd_source text,
  rsvp numeric,
  ti_speed numeric,
  ti_gradient numeric,

  pericardial_effusion text,
  suspicion_tamponande text,

  vci_measured_cm numeric,
  vci_collapse_percentage numeric,

  filling_status text,

  end_procedure text,
  tolerance_patient_for_intervention text,
  intervention_remarks text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz,

  PRIMARY KEY (patient_contact_id, order_id)
);

INSERT INTO amc_core.ic_procedure_note_icarus (
  patient_contact_id,
  order_id,
  pseudo_id,
  hospital_location,
  intervention_date_time,
  intervention_name,
  start_procedure,
  date_time_authorization,
  informed_consent,
  complications_discussed,
  time_out_executed,
  indication,
  certified_echographer,
  conclusion,
  lung_sliding_left,
  lung_sliding_right,
  plaps_left,
  plaps_right,
  blue_profile,
  lung_aeration_score_right_field1_raw, lung_aeration_score_right_field1,
  lung_aeration_score_right_field2_raw, lung_aeration_score_right_field2,
  lung_aeration_score_right_field3_raw, lung_aeration_score_right_field3,
  lung_aeration_score_right_field4_raw, lung_aeration_score_right_field4,
  lung_aeration_score_right_field5_raw, lung_aeration_score_right_field5,
  lung_aeration_score_right_field6_raw, lung_aeration_score_right_field6,
  lung_aeration_score_right_field8_raw, lung_aeration_score_right_field8,
  lung_aeration_score_left_field1_raw, lung_aeration_score_left_field1,
  lung_aeration_score_lefts_field2_raw, lung_aeration_score_lefts_field2,
  lung_aeration_score_left_field3_raw, lung_aeration_score_left_field3,
  lung_aeration_score_left_field4_raw, lung_aeration_score_left_field4,
  lung_aeration_score_left_field5_raw, lung_aeration_score_left_field5,
  lung_aeration_score_left_field6_raw, lung_aeration_score_left_field6,
  lung_aeration_score_left_field8_raw, lung_aeration_score_left_field8,
  lung_aeration_total_score,
  left_atrium,
  right_atrium,
  left_ventricle,
  right_ventricle,
  left_ventricular_function,
  lvot_diameter_mm,
  lvot_vti,
  heart_rate_bpm,
  cardiac_output_with_vti_liter_per_minute,
  right_ventricular_function,
  tapered_mm,
  mitral_insufficiency,
  tricuspid_insufficiency,
  cvd_mm_hg,
  cvd_source,
  rsvp,
  ti_speed,
  ti_gradient,
  pericardial_effusion,
  suspicion_tamponande,
  vci_measured_cm,
  vci_collapse_percentage,
  filling_status,
  end_procedure,
  tolerance_patient_for_intervention,
  intervention_remarks,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(patient_contact_id, ''),
  NULLIF(order_id, ''),

  NULLIF(pseudo_id, ''),
  NULLIF(hospital_location, ''),
  NULLIF(intervention_date_time, '')::timestamptz,
  NULLIF(intervention_name, ''),

  NULLIF(start_procedure, ''),
  NULLIF(date_time_authorization, '')::timestamptz,
  NULLIF(informed_consent, ''),
  NULLIF(complications_discussed, ''),
  NULLIF(time_out_executed, ''),
  NULLIF(indication, ''),
  NULLIF(certified_echographer, ''),
  NULLIF(conclusion, ''),

  NULLIF(lung_sliding_left, ''),
  NULLIF(lung_sliding_right, ''),
  NULLIF(plaps_left, ''),
  NULLIF(plaps_right, ''),
  NULLIF(blue_profile, ''),

  NULLIF(lung_aeration_score_right_field1, ''),

  CASE WHEN trim(lung_aeration_score_right_field1) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_score_right_field1)::numeric END,
  NULLIF(lung_aeration_score_right_field2, ''),

  CASE WHEN trim(lung_aeration_score_right_field2) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_score_right_field2)::numeric END,
  NULLIF(lung_aeration_score_right_field3, ''),

  CASE WHEN trim(lung_aeration_score_right_field3) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_score_right_field3)::numeric END,
  NULLIF(lung_aeration_score_right_field4, ''),

  CASE WHEN trim(lung_aeration_score_right_field4) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_score_right_field4)::numeric END,
  NULLIF(lung_aeration_score_right_field5, ''),

  CASE WHEN trim(lung_aeration_score_right_field5) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_score_right_field5)::numeric END,
  NULLIF(lung_aeration_score_right_field6, ''),

  CASE WHEN trim(lung_aeration_score_right_field6) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_score_right_field6)::numeric END,
  NULLIF(lung_aeration_score_right_field8, ''),

  CASE WHEN trim(lung_aeration_score_right_field8) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_score_right_field8)::numeric END,

  NULLIF(lung_aeration_score_left_field1, ''),

  CASE WHEN trim(lung_aeration_score_left_field1) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_score_left_field1)::numeric END,
  NULLIF(lung_aeration_score_lefts_field2, ''),

  CASE WHEN trim(lung_aeration_score_lefts_field2) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_score_lefts_field2)::numeric END,
  NULLIF(lung_aeration_score_left_field3, ''),

  CASE WHEN trim(lung_aeration_score_left_field3) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_score_left_field3)::numeric END,
  NULLIF(lung_aeration_score_left_field4, ''),

  CASE WHEN trim(lung_aeration_score_left_field4) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_score_left_field4)::numeric END,
  NULLIF(lung_aeration_score_left_field5, ''),

  CASE WHEN trim(lung_aeration_score_left_field5) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_score_left_field5)::numeric END,
  NULLIF(lung_aeration_score_left_field6, ''),

  CASE WHEN trim(lung_aeration_score_left_field6) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_score_left_field6)::numeric END,
  NULLIF(lung_aeration_score_left_field8, ''),

  CASE WHEN trim(lung_aeration_score_left_field8) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_score_left_field8)::numeric END,

  CASE WHEN trim(lung_aeration_total_score) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lung_aeration_total_score)::numeric END,

  NULLIF(left_atrium, ''),
  NULLIF(right_atrium, ''),
  NULLIF(left_ventricle, ''),
  NULLIF(right_ventricle, ''),
  NULLIF(left_ventricular_function, ''),

  CASE WHEN trim(lvot_diameter_mm) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lvot_diameter_mm)::numeric END,
  CASE WHEN trim(lvot_vti) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(lvot_vti)::numeric END,
  CASE WHEN trim(heart_rate_bpm) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(heart_rate_bpm)::numeric END,
  CASE WHEN trim(cardiac_output_with_vti_liter_per_minute) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(cardiac_output_with_vti_liter_per_minute)::numeric END,

  NULLIF(right_ventricular_function, ''),

  CASE WHEN trim(tapered_mm) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(tapered_mm)::numeric END,
  NULLIF(mitral_insufficiency, ''),
  NULLIF(tricuspid_insufficiency, ''),

  CASE WHEN trim(cvd_mm_hg) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(cvd_mm_hg)::numeric END,
  NULLIF(cvd_source, ''),
  CASE WHEN trim(rsvp) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(rsvp)::numeric END,
  CASE WHEN trim(ti_speed) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(ti_speed)::numeric END,
  CASE WHEN trim(ti_gradient) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(ti_gradient)::numeric END,

  NULLIF(pericardial_effusion, ''),
  NULLIF(suspicion_tamponande, ''),

  CASE WHEN trim(vci_measured_cm) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(vci_measured_cm)::numeric END,
  CASE WHEN trim(vci_collapse_percentage) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$' THEN trim(vci_collapse_percentage)::numeric END,

  NULLIF(filling_status, ''),

  NULLIF(end_procedure, ''),
  NULLIF(tolerance_patient_for_intervention, ''),
  NULLIF(intervention_remarks, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.ic_procedure_note_icarus

WHERE NULLIF(patient_contact_id, '') IS NOT NULL
  AND NULLIF(order_id, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_icarus_pseudo_id
  ON amc_core.ic_procedure_note_icarus(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_icarus_contact_id
  ON amc_core.ic_procedure_note_icarus(patient_contact_id);

