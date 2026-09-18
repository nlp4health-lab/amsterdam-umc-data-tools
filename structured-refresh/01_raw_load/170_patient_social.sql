--=============================================================================
-- ===========================================================================
-- amc_raw.patient_social
-- ===========================================================================

DROP TABLE IF EXISTS amc_raw.patient_social;

CREATE TABLE amc_raw.patient_social (
  pseudo_id TEXT,
  marital_status TEXT,
  education_level TEXT,
  is_multiple TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: patient_social

-- Minimal sanity
SELECT count(*) AS n_rows
FROM amc_raw.patient_social;

SELECT count(DISTINCT pseudo_id) AS distinct_pseudo_id
FROM amc_raw.patient_social;

