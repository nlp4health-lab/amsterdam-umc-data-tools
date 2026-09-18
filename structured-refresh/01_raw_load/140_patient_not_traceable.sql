--============================================================================

DROP TABLE IF EXISTS amc_raw.patient_not_traceable;

CREATE TABLE amc_raw.patient_not_traceable (
  pseudo_id TEXT,
  year_of_birth TEXT,
  gender TEXT,
  death_date_time TEXT,
  is_deceased TEXT,
  is_objection_patient TEXT,
  objection_research_recruitment TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: patient_not_traceable

-- Sanity checks

-- Row count
SELECT count(*) AS n_rows
FROM amc_raw.patient_not_traceable;

-- Null checks on key
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR btrim(pseudo_id) = '') AS null_pseudo,
  count(*) FILTER (WHERE year_of_birth IS NULL OR btrim(year_of_birth) = '') AS null_yob
FROM amc_raw.patient_not_traceable;

-- Uniqueness of pseudo_id
SELECT
  count(*) AS n,
  count(DISTINCT pseudo_id) AS distinct_pseudo_id
FROM amc_raw.patient_not_traceable;

-- Duplicates?
SELECT pseudo_id, count(*) AS n
FROM amc_raw.patient_not_traceable
GROUP BY pseudo_id
HAVING count(*) > 1
ORDER BY n DESC
LIMIT 20;

--pseudo_id is unique, no nulls.

