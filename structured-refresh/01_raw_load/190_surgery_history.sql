-- ===========================================================================
-- amc_raw.surgery_history
-- ===========================================================================

DROP TABLE IF EXISTS amc_raw.surgery_history;

CREATE TABLE amc_raw.surgery_history (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  registration_date TEXT,
  procedure_start_date TEXT,
  procedure_end_date TEXT,
  surgical_past_history_code TEXT,
  type_code TEXT,
  surgical_past_history TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: surgery_history

-- Minimal sanity
SELECT count(*) AS n_rows
FROM amc_raw.surgery_history;

SELECT count(*) AS null_pseudo
FROM amc_raw.surgery_history
WHERE pseudo_id IS NULL OR btrim(pseudo_id) = '';

