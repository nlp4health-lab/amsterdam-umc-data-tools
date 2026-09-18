--============================================================
DROP TABLE IF EXISTS amc_raw.ecg_measurement_test_feature;

CREATE TABLE amc_raw.ecg_measurement_test_feature (
  pseudo_id TEXT,
  ecg_measurement_id TEXT,
  test_code TEXT,
  site_code TEXT,
  ecg_decrease_date TEXT,
  ecg_decrease_time TEXT,
  ecg_decrease_date_time TEXT,
  ecg_change_date_time TEXT,
  test_status TEXT,
  test_status_code TEXT,
  test_status_abbreviation TEXT,
  test_type_description TEXT,
  test_type_code TEXT,
  test_type_abbreviation TEXT,
  priority TEXT,
  priority_code TEXT,
  priority_abbreviation TEXT,
  workplace_muse TEXT,
  workplace_muse_abbreviation TEXT,
  workplace_muse_code TEXT,
  ecg_cartnumber TEXT,
  ecg_decrease_device TEXT,
  ecg_decrease_software_version TEXT,
  ecg_analysis_software_version TEXT,
  source TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: ecg_measurement_test_feature

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- 1) Row count
SELECT count(*) AS n_rows
FROM amc_raw.ecg_measurement_test_feature;

-- 2) Nulls on likely identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE ecg_measurement_id IS NULL OR ecg_measurement_id = '') AS null_ecg_measurement_id,
  count(*) FILTER (WHERE ecg_decrease_date IS NULL OR ecg_decrease_date = '') AS null_ecg_date
FROM amc_raw.ecg_measurement_test_feature;

-- 3) Cardinality of identifiers
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(ecg_measurement_id,'')) AS distinct_ecg_measurements,
  count(DISTINCT NULLIF(pseudo_id,'')) AS distinct_patients
FROM amc_raw.ecg_measurement_test_feature;

-- 4) Check if ecg_measurement_id is unique
SELECT
  ecg_measurement_id,
  count(*) AS n
FROM amc_raw.ecg_measurement_test_feature
WHERE ecg_measurement_id IS NOT NULL AND ecg_measurement_id <> ''
GROUP BY ecg_measurement_id
HAVING count(*) > 1
ORDER BY n DESC
LIMIT 20;

-- 5) Date range
SELECT
  min(ecg_decrease_date::date) AS min_ecg_date,
  max(ecg_decrease_date::date) AS max_ecg_date
FROM amc_raw.ecg_measurement_test_feature
WHERE ecg_decrease_date ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

