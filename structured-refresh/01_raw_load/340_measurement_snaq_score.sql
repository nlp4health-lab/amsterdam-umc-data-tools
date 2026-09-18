--============================================================
DROP TABLE IF EXISTS amc_raw.measurement_snaq_score;

CREATE TABLE amc_raw.measurement_snaq_score (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  meet_time TEXT,
  meet_date TEXT,
  measurement_moment TEXT,
  score TEXT,
  unintentional_weightloss TEXT,
  reduced_appetite TEXT,
  drink_probe_feeding TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: measurement_snaq_score

-- ---------------------------
-- Minimal sanity checks
-- ---------------------------

-- 1) Row count
SELECT count(*) AS n_rows
FROM amc_raw.measurement_snaq_score;

-- 2) Nulls on likely identifiers
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR pseudo_id = '') AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = '') AS null_patient_contact_id,
  count(*) FILTER (WHERE meet_date IS NULL OR meet_date = '') AS null_meet_date,
  count(*) FILTER (WHERE meet_time IS NULL OR meet_time = '') AS null_meet_time,
  count(*) FILTER (WHERE measurement_moment IS NULL OR measurement_moment = '') AS null_measurement_moment
FROM amc_raw.measurement_snaq_score;

-- 3) Cardinality of identifiers
SELECT
  count(*) AS n,
  count(DISTINCT NULLIF(patient_contact_id,'')) AS distinct_patient_contact_id,
  count(DISTINCT NULLIF(measurement_moment,'')) AS distinct_measurement_moment,
  count(DISTINCT NULLIF(score,'')) AS distinct_scores
FROM amc_raw.measurement_snaq_score;

-- 4) Check if patient_contact_id + meet_date + meet_time could define the grain
SELECT
  count(*) AS n_rows,
  count(DISTINCT (
    coalesce(NULLIF(patient_contact_id,''),'') || '|' ||
    coalesce(NULLIF(meet_date,''),'') || '|' ||
    coalesce(NULLIF(meet_time,''),'')
  )) AS distinct_contact_date_time
FROM amc_raw.measurement_snaq_score;

-- 5) Top duplicates if that combination is not unique
SELECT
  patient_contact_id,
  meet_date,
  meet_time,
  count(*) AS n
FROM amc_raw.measurement_snaq_score
WHERE patient_contact_id IS NOT NULL AND patient_contact_id <> ''
GROUP BY patient_contact_id, meet_date, meet_time
HAVING count(*) > 1
ORDER BY n DESC
LIMIT 20;

