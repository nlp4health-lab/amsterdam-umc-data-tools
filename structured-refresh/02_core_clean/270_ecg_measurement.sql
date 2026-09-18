--===========================================================================

DROP TABLE IF EXISTS amc_core.ecg_measurement CASCADE;

CREATE TABLE amc_core.ecg_measurement (
  pseudo_id text NOT NULL,
  ecg_measurement_id text NOT NULL,

  test_code text,
  site_code text,

  ecg_decrease_date date,
  ecg_decrease_time time,
  ecg_decrease_date_time timestamptz,

  test_status text,
  test_status_code text,
  test_status_abbreviation text,

  test_type text,
  test_type_code text,
  test_type_abbreviation text,

  priority text,
  priority_code text,
  priority_abbreviation text,

  workplace_muse text,
  workplace_muse_code text,
  workplace_muse_abbreviation text,

  is_ecg_measured_median_beat text,
  is_ecg_measured_at_rest text,

  p_onset_at_medianbeat numeric,
  p_offset_at_medianbeat numeric,
  q_onset_at_medianbeat numeric,
  q_offset_at_medianbeat numeric,
  t_onset_at_medianbeat numeric,
  t_offset_at_medianbeat numeric,

  pr_interval_at_medianbeat numeric,
  ventricular_rate_at_medianbeat numeric,
  avg_rr_interval numeric,
  qrs_count numeric,
  qrs_duration_at_medianbeat numeric,
  qt_interval_at_medianbeat numeric,
  q_tc_bazett_at_medianbeat numeric,

  systolic_bp_at_rest numeric,
  diastolic_bp_at_rest numeric,
  ventricular_rate_at_rest numeric,
  atrial_rate_at_rest numeric,

  p_axis_at_rest numeric,
  r_axis_at_rest numeric,
  t_axis_at_rest numeric,

  p_onset_at_rest numeric,
  p_offset_at_rest numeric,
  q_onset_at_rest numeric,
  q_offset_at_rest numeric,
  t_offset_at_rest numeric,

  pr_interval_at_rest numeric,
  qrs_count_at_rest numeric,
  qrs_duration_at_rest numeric,
  qt_interval_at_rest numeric,

  qtc_calculation_at_rest numeric,
  qtc_fredericia_at_rest numeric,
  qtc_framingham_at_rest numeric,

  ecg_sample_base_at_rest numeric,
  ecg_sample_exponent_at_rest numeric,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz,

  PRIMARY KEY (pseudo_id, ecg_measurement_id)
);

INSERT INTO amc_core.ecg_measurement
SELECT
  pseudo_id,
  ecg_measurement_id,

  NULLIF(test_code, ''),
  NULLIF(site_code, ''),

  NULLIF(ecg_decrease_date, '')::date,
  CASE WHEN trim(ecg_decrease_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(ecg_decrease_time)::time END,
  NULLIF(ecg_decrease_date_time, '')::timestamptz,

  NULLIF(test_status, ''),
  NULLIF(test_status_code, ''),
  NULLIF(test_status_abbreviation, ''),

  NULLIF(test_type, ''),
  NULLIF(test_type_code, ''),
  NULLIF(test_type_abbreviation, ''),

  NULLIF(priority, ''),
  NULLIF(priority_code, ''),
  NULLIF(priority_abbreviation, ''),

  NULLIF(workplace_muse, ''),
  NULLIF(workplace_muse_code, ''),
  NULLIF(workplace_muse_abbreviation, ''),

  NULLIF(is_ecg_measured_median_beat, ''),
  NULLIF(is_ecg_measured_at_rest, ''),

  -- numeric block
  CASE WHEN trim(p_onset_at_medianbeat) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(p_onset_at_medianbeat)::numeric END,
  CASE WHEN trim(p_offset_at_medianbeat) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(p_offset_at_medianbeat)::numeric END,
  CASE WHEN trim(q_onset_at_medianbeat) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(q_onset_at_medianbeat)::numeric END,
  CASE WHEN trim(q_offset_at_medianbeat) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(q_offset_at_medianbeat)::numeric END,
  CASE WHEN trim(t_onset_at_medianbeat) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(t_onset_at_medianbeat)::numeric END,
  CASE WHEN trim(t_offset_at_medianbeat) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(t_offset_at_medianbeat)::numeric END,

  CASE WHEN trim(pr_interval_at_medianbeat) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(pr_interval_at_medianbeat)::numeric END,
  CASE WHEN trim(ventricular_rate_at_medianbeat) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(ventricular_rate_at_medianbeat)::numeric END,
  CASE WHEN trim(avg_rr_interval) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(avg_rr_interval)::numeric END,
  CASE WHEN trim(qrs_count) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(qrs_count)::numeric END,
  CASE WHEN trim(qrs_duration_at_medianbeat) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(qrs_duration_at_medianbeat)::numeric END,
  CASE WHEN trim(qt_interval_at_medianbeat) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(qt_interval_at_medianbeat)::numeric END,
  CASE WHEN trim(q_tc_bazett_at_medianbeat) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(q_tc_bazett_at_medianbeat)::numeric END,

  CASE WHEN trim(systolic_bp_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(systolic_bp_at_rest)::numeric END,
  CASE WHEN trim(diastolic_bp_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(diastolic_bp_at_rest)::numeric END,
  CASE WHEN trim(ventricular_rate_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(ventricular_rate_at_rest)::numeric END,
  CASE WHEN trim(atrial_rate_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(atrial_rate_at_rest)::numeric END,

  CASE WHEN trim(p_axis_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(p_axis_at_rest)::numeric END,
  CASE WHEN trim(r_axis_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(r_axis_at_rest)::numeric END,
  CASE WHEN trim(t_axis_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(t_axis_at_rest)::numeric END,

  CASE WHEN trim(p_onset_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(p_onset_at_rest)::numeric END,
  CASE WHEN trim(p_offset_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(p_offset_at_rest)::numeric END,
  CASE WHEN trim(q_onset_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(q_onset_at_rest)::numeric END,
  CASE WHEN trim(q_offset_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(q_offset_at_rest)::numeric END,
  CASE WHEN trim(t_offset_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(t_offset_at_rest)::numeric END,

  CASE WHEN trim(pr_interval_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(pr_interval_at_rest)::numeric END,
  CASE WHEN trim(qrs_count_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(qrs_count_at_rest)::numeric END,
  CASE WHEN trim(qrs_duration_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(qrs_duration_at_rest)::numeric END,
  CASE WHEN trim(qt_interval_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(qt_interval_at_rest)::numeric END,

  CASE WHEN trim(qtc_calculation_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(qtc_calculation_at_rest)::numeric END,
  CASE WHEN trim(qtc_fredericia_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(qtc_fredericia_at_rest)::numeric END,
  CASE WHEN trim(qtc_framingham_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(qtc_framingham_at_rest)::numeric END,

  CASE WHEN trim(ecg_sample_base_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(ecg_sample_base_at_rest)::numeric END,
  CASE WHEN trim(ecg_sample_exponent_at_rest) ~ '^[-+]?[0-9]*\.?[0-9]+$' THEN trim(ecg_sample_exponent_at_rest)::numeric END,

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.ecg_measurement

WHERE NULLIF(pseudo_id, '') IS NOT NULL
  AND NULLIF(ecg_measurement_id, '') IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_core_ecg_pseudo_id
  ON amc_core.ecg_measurement(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_ecg_measurement_id
  ON amc_core.ecg_measurement(ecg_measurement_id);

