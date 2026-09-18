--============================================================================

DROP TABLE IF EXISTS amc_raw.seh_trajectory;

CREATE TABLE amc_raw.seh_trajectory (
  pseudo_id TEXT,
  seh_traject_id TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  urgent_contact_created_date_time TEXT,
  patient_arrived_at_seh_date_time TEXT,
  seh_admission_moment TEXT,
  seh_admission_date TEXT,
  seh_admission_date_time TEXT,
  seh_departure_moment TEXT,
  seh_departure_date TEXT,
  seh_departure_date_time TEXT,
  seh_sub_specialty TEXT,
  seh_arrival_mode TEXT,
  seh_arrival_mode_group TEXT,
  seh_presentation_type TEXT,
  seh_triagecode TEXT,
  chief_seh_complaint TEXT,
  chief_seh_input_complaint TEXT,
  destination_after_seh TEXT,
  referring_caregiver_type TEXT,
  referring_caregiver_is_internal TEXT,
  is_ehh_traject TEXT,
  admission_traject_id TEXT,
  admission_origin TEXT,
  age_in_years_at_moment_admission TEXT,
  seh_arrival_subspecialty TEXT,
  seh_departure_subspecialty TEXT,
  departure_to_workplace TEXT,
  arrival_workplace TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: seh_trajectory

-- Sanity checks

-- Row count
SELECT count(*) AS n_rows
FROM amc_raw.seh_trajectory;

-- Null checks on key
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR btrim(pseudo_id) = '') AS null_pseudo,
  count(*) FILTER (WHERE seh_traject_id IS NULL OR btrim(seh_traject_id) = '') AS null_seh_traject_id
FROM amc_raw.seh_trajectory;

-- Uniqueness of seh_traject_id
SELECT
  count(*) AS n,
  count(DISTINCT seh_traject_id) AS distinct_seh_traject_id
FROM amc_raw.seh_trajectory;

-- Duplicates?
SELECT seh_traject_id, count(*) AS n
FROM amc_raw.seh_trajectory
GROUP BY seh_traject_id
HAVING count(*) > 1
ORDER BY n DESC
LIMIT 20;
