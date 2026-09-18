-- ==========================================================================

DROP TABLE IF EXISTS amc_raw.death_registration;

CREATE TABLE amc_raw.death_registration (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  meet_time TEXT,
  meet_date TEXT,
  measurement_moment TEXT,
  department_of_death TEXT,
  location_of_death TEXT,
  mode_of_entry TEXT,
  risk_of_contamination_filled_in_nurse TEXT,
  ab_statement_issued_to TEXT,
  date_transfer_mortuary TEXT,
  time_transfer_mortuary TEXT,
  probable_cause_of_death TEXT,
  probable_cause_of_death_specific TEXT,
  cremation_fetus_by_hospital TEXT,
  chance_of_contamination_risk_filled_in_doctor TEXT,
  other_additional_examinations TEXT,
  destination_deceased TEXT,
  autopsy TEXT,
  information_autopsy_data TEXT,
  permission_autopsy_next_of_kin TEXT,
  body_autopsy TEXT,
  skull_autopsy TEXT,
  natural_death TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: death_registration

-- Sanity checks
SELECT count(*) AS n_rows
FROM amc_raw.death_registration;

SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL) AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL) AS null_contact,
  count(*) FILTER (WHERE meet_date IS NULL) AS null_meet_date
FROM amc_raw.death_registration;

-- how many death records per patient_contact_id?
SELECT patient_contact_id, count(*) AS n
FROM amc_raw.death_registration
WHERE patient_contact_id IS NOT NULL
GROUP BY patient_contact_id
ORDER BY n DESC
LIMIT 20;

-- how many death records per pseudo_id?
SELECT pseudo_id, count(*) AS n
FROM amc_raw.death_registration
WHERE pseudo_id IS NOT NULL
GROUP BY pseudo_id
ORDER BY n DESC
LIMIT 20;

-- quick date range checks (raw TEXT → cast only where parseable)
SELECT
  min(meet_date::date) AS min_meet_date,
  max(meet_date::date) AS max_meet_date
FROM amc_raw.death_registration
WHERE meet_date ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

--several death registrations per pseudo_id and contact_id. weird. info of other columns spreads across many rows, so maybe each row is a different piece of info about the same death registration with different measurement moment
-- primary key could be patient_contact_id + meet_time

