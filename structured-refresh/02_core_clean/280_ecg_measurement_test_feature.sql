--===========================================================================

DROP TABLE IF EXISTS amc_core.ecg_measurement_test_feature CASCADE;

CREATE TABLE amc_core.ecg_measurement_test_feature (
  pseudo_id text NOT NULL,
  ecg_measurement_id text NOT NULL,

  test_code text,
  site_code text,

  ecg_decrease_date date,
  ecg_decrease_time time,
  ecg_decrease_date_time timestamptz,
  ecg_change_date_time timestamptz,

  test_status text,
  test_status_code text,
  test_status_abbreviation text,

  test_type_description text,
  test_type_code text,
  test_type_abbreviation text,

  priority text,
  priority_code text,
  priority_abbreviation text,

  workplace_muse text,
  workplace_muse_abbreviation text,
  workplace_muse_code text,

  ecg_cartnumber text,
  ecg_decrease_device text,
  ecg_decrease_software_version text,
  ecg_analysis_software_version text,

  source text,
  issue_dt timestamptz,

  PRIMARY KEY (pseudo_id, ecg_measurement_id)
);

INSERT INTO amc_core.ecg_measurement_test_feature
SELECT
  pseudo_id,
  ecg_measurement_id,

  NULLIF(test_code, ''),
  NULLIF(site_code, ''),

  NULLIF(ecg_decrease_date, '')::date,
  NULLIF(ecg_decrease_time, '')::time,
  NULLIF(ecg_decrease_date_time, '')::timestamptz,
  NULLIF(ecg_change_date_time, '')::timestamptz,

  NULLIF(test_status, ''),
  NULLIF(test_status_code, ''),
  NULLIF(test_status_abbreviation, ''),

  NULLIF(test_type_description, ''),
  NULLIF(test_type_code, ''),
  NULLIF(test_type_abbreviation, ''),

  NULLIF(priority, ''),
  NULLIF(priority_code, ''),
  NULLIF(priority_abbreviation, ''),

  NULLIF(workplace_muse, ''),
  NULLIF(workplace_muse_abbreviation, ''),
  NULLIF(workplace_muse_code, ''),

  NULLIF(ecg_cartnumber, ''),
  NULLIF(ecg_decrease_device, ''),
  NULLIF(ecg_decrease_software_version, ''),
  NULLIF(ecg_analysis_software_version, ''),

  NULLIF(source, ''),
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.ecg_measurement_test_feature

WHERE NULLIF(pseudo_id, '') IS NOT NULL
  AND NULLIF(ecg_measurement_id, '') IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_core_ecg_feat_pseudo_id
  ON amc_core.ecg_measurement_test_feature(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_ecg_feat_measurement_id
  ON amc_core.ecg_measurement_test_feature(ecg_measurement_id);

