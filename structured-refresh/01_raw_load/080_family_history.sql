-- ==========================================================================

DROP TABLE IF EXISTS amc_raw.family_history;

CREATE TABLE amc_raw.family_history (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  registration_date TEXT,
  family_history TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: family_history

-- Sanity checks
SELECT count(*) AS n_rows
FROM amc_raw.family_history;

SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL) AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL) AS null_contact,
  count(*) FILTER (WHERE registration_date IS NULL) AS null_registration_date,
  count(*) FILTER (WHERE family_history IS NULL OR btrim(family_history) = '') AS empty_family_history
FROM amc_raw.family_history;

-- cardinality per contact / per patient
SELECT patient_contact_id, count(*) AS n
FROM amc_raw.family_history
WHERE patient_contact_id IS NOT NULL
GROUP BY patient_contact_id
ORDER BY n DESC
LIMIT 20;

SELECT pseudo_id, count(*) AS n
FROM amc_raw.family_history
WHERE pseudo_id IS NOT NULL
GROUP BY pseudo_id
ORDER BY n DESC
LIMIT 20;

-- date range, only where parseable as ISO date
SELECT
  min(registration_date::date) AS min_registration_date,
  max(registration_date::date) AS max_registration_date
FROM amc_raw.family_history
WHERE registration_date ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

-- how many distinct contacts and patients covered
SELECT
  count(DISTINCT pseudo_id) AS distinct_patients,
  count(DISTINCT patient_contact_id) FILTER (WHERE patient_contact_id IS NOT NULL) AS distinct_contacts
FROM amc_raw.family_history;

--183 with empty family_history
--several contact_ids per pseudo_id 
--several records per pseudo_id and patient_contact_id with different family history info with the same registration date
-- primary key could be contact_id + family history, since family history can be long text.
-- (rn was dropped from the raw extraction — no longer available as a key candidate)

