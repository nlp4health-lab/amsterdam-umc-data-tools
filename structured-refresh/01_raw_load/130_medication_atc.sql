--===========================================================================


DROP TABLE IF EXISTS amc_raw.medication_atc;

CREATE TABLE amc_raw.medication_atc (
  atc_code TEXT,
  atc_name TEXT,
  atc_label TEXT,
  atc_name_niv1 TEXT,
  atc_code_niv1 TEXT,
  atc_name_niv2 TEXT,
  atc_code_niv2 TEXT,
  atc_name_niv3 TEXT,
  atc_code_niv3 TEXT,
  atc_name_niv4 TEXT,
  atc_code_niv4 TEXT,
  atc_name_niv5 TEXT,
  atc_code_niv5 TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: medication_atc

-- Sanity checks
SELECT count(*) AS n_rows
FROM amc_raw.medication_atc;

SELECT
  count(*) FILTER (WHERE atc_code IS NULL OR btrim(atc_code) = '') AS null_atc_code,
  count(*) FILTER (WHERE atc_name IS NULL OR btrim(atc_name) = '') AS null_atc_name
FROM amc_raw.medication_atc;

SELECT
  count(*) AS n,
  count(DISTINCT atc_code) AS distinct_atc_code
FROM amc_raw.medication_atc;

SELECT atc_code, count(*) AS n
FROM amc_raw.medication_atc
WHERE atc_code IS NOT NULL AND btrim(atc_code) <> ''
GROUP BY atc_code
HAVING count(*) > 1
ORDER BY n DESC, atc_code
LIMIT 50;

