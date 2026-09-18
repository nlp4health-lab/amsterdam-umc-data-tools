-- ===========================================================================
-- amc_raw.tobacco_use
-- ===========================================================================

DROP TABLE IF EXISTS amc_raw.tobacco_use;

CREATE TABLE amc_raw.tobacco_use (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  registration_date TEXT,
  workplace TEXT,
  specialty TEXT,
  start_date TEXT,
  stop_date TEXT,
  status_tobacco_use TEXT,
  tobacco_use_explanation TEXT,
  type_tobacco_use TEXT,
  is_current_smoker TEXT,
  is_former_smoker TEXT,
  quantity_packages_per_day TEXT,
  tobacco_use_years TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: tobacco_use

-- Minimal sanity
SELECT count(*) AS n_rows
FROM amc_raw.tobacco_use;

SELECT count(*) AS null_pseudo
FROM amc_raw.tobacco_use
WHERE pseudo_id IS NULL OR btrim(pseudo_id) = '';

