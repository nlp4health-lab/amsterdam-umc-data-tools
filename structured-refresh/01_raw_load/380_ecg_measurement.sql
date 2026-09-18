--============================================================
DROP TABLE IF EXISTS amc_raw.ecg_measurement;

CREATE TABLE amc_raw.ecg_measurement (
  pseudo_id TEXT,
  ecg_measurement_id TEXT,
  test_code TEXT,
  site_code TEXT,
  ecg_decrease_date TEXT,
  ecg_decrease_time TEXT,
  ecg_decrease_date_time TEXT,
  test_status TEXT,
  test_status_code TEXT,
  test_status_abbreviation TEXT,
  test_type TEXT,
  test_type_code TEXT,
  test_type_abbreviation TEXT,
  priority TEXT,
  priority_code TEXT,
  priority_abbreviation TEXT,
  workplace_muse TEXT,
  workplace_muse_code TEXT,
  workplace_muse_abbreviation TEXT,
  is_ecg_measured_median_beat TEXT,
  is_ecg_measured_at_rest TEXT,
  p_onset_at_medianbeat TEXT,
  p_offset_at_medianbeat TEXT,
  q_onset_at_medianbeat TEXT,
  q_offset_at_medianbeat TEXT,
  t_onset_at_medianbeat TEXT,
  t_offset_at_medianbeat TEXT,
  pr_interval_at_medianbeat TEXT,
  ventricular_rate_at_medianbeat TEXT,
  avg_rr_interval TEXT,
  qrs_count TEXT,
  qrs_duration_at_medianbeat TEXT,
  qt_interval_at_medianbeat TEXT,
  q_tc_bazett_at_medianbeat TEXT,
  systolic_bp_at_rest TEXT,
  diastolic_bp_at_rest TEXT,
  ventricular_rate_at_rest TEXT,
  atrial_rate_at_rest TEXT,
  p_axis_at_rest TEXT,
  r_axis_at_rest TEXT,
  t_axis_at_rest TEXT,
  p_onset_at_rest TEXT,
  p_offset_at_rest TEXT,
  q_onset_at_rest TEXT,
  q_offset_at_rest TEXT,
  t_offset_at_rest TEXT,
  pr_interval_at_rest TEXT,
  qrs_count_at_rest TEXT,
  qrs_duration_at_rest TEXT,
  qt_interval_at_rest TEXT,
  qtc_calculation_at_rest TEXT,
  qtc_fredericia_at_rest TEXT,
  qtc_framingham_at_rest TEXT,
  ecg_sample_base_at_rest TEXT,
  ecg_sample_exponent_at_rest TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: ecg_measurement

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- 1) Row count
SELECT count(*) AS n_rows
FROM amc_raw.ecg_measurement;

-- 2) Nulls on likely identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE ecg_measurement_id IS NULL OR ecg_measurement_id = '') AS null_ecg_measurement_id,
  count(*) FILTER (WHERE ecg_decrease_date IS NULL OR ecg_decrease_date = '') AS null_ecg_date
FROM amc_raw.ecg_measurement;

-- 3) Cardinality of identifiers
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(ecg_measurement_id,'')) AS distinct_ecg_measurements,
  count(DISTINCT NULLIF(pseudo_id,'')) AS distinct_patients
FROM amc_raw.ecg_measurement;

-- 4) Check if ecg_measurement_id is unique
SELECT
  ecg_measurement_id,
  count(*) AS n
FROM amc_raw.ecg_measurement
WHERE ecg_measurement_id IS NOT NULL AND ecg_measurement_id <> ''
GROUP BY ecg_measurement_id
HAVING count(*) > 1
ORDER BY n DESC
LIMIT 20;

-- 5) Date range
SELECT
  min(ecg_decrease_date::date) AS min_ecg_date,
  max(ecg_decrease_date::date) AS max_ecg_date
FROM amc_raw.ecg_measurement
WHERE ecg_decrease_date ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

