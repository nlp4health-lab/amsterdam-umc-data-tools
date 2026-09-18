--===========================================================================
DROP TABLE IF EXISTS amc_core.death_registration CASCADE;

CREATE TABLE amc_core.death_registration (
  pseudo_id text NOT NULL,

  patient_contact_id text NOT NULL,
  meet_time time NOT NULL,

  meet_date date,
  measurement_moment timestamptz,

  hospital_location text,

  department_of_death text,
  location_of_death text,
  mode_of_entry text,

  risk_of_contamination_filled_in_nurse text,
  ab_statement_issued_to text,

  date_transfer_mortuary date,
  time_transfer_mortuary time,

  probable_cause_of_death text,
  probable_cause_of_death_specific text,

  cremation_fetus_by_hospital text,
  chance_of_contamination_risk_filled_in_doctor text,
  other_additional_examinations text,

  destination_deceased text,

  autopsy text,
  information_autopsy_data text,
  permission_autopsy_next_of_kin text,
  body_autopsy text,
  skull_autopsy text,

  natural_death text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz,

  PRIMARY KEY (patient_contact_id, meet_time)
);

INSERT INTO amc_core.death_registration (
  pseudo_id,
  patient_contact_id,
  meet_time,
  meet_date,
  measurement_moment,
  hospital_location,
  department_of_death,
  location_of_death,
  mode_of_entry,
  risk_of_contamination_filled_in_nurse,
  ab_statement_issued_to,
  date_transfer_mortuary,
  time_transfer_mortuary,
  probable_cause_of_death,
  probable_cause_of_death_specific,
  cremation_fetus_by_hospital,
  chance_of_contamination_risk_filled_in_doctor,
  other_additional_examinations,
  destination_deceased,
  autopsy,
  information_autopsy_data,
  permission_autopsy_next_of_kin,
  body_autopsy,
  skull_autopsy,
  natural_death,
  source,
  dcm_refreshed_date_time,
  issue_dt
)

SELECT
  pseudo_id,

  NULLIF(patient_contact_id,'') AS patient_contact_id,

  CASE WHEN trim(meet_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(meet_time)::time END,

  CASE WHEN trim(meet_date) ~ '^\d{4}-\d{2}-\d{2}$' THEN trim(meet_date)::date END,

  CASE WHEN trim(measurement_moment) ~ '^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}' THEN trim(measurement_moment)::timestamptz END,

  NULLIF(hospital_location,''),

  NULLIF(department_of_death,''),
  NULLIF(location_of_death,''),
  NULLIF(mode_of_entry,''),

  NULLIF(risk_of_contamination_filled_in_nurse,''),
  NULLIF(ab_statement_issued_to,''),

  CASE WHEN trim(date_transfer_mortuary) ~ '^\d{4}-\d{2}-\d{2}$' THEN trim(date_transfer_mortuary)::date END,
  CASE WHEN trim(time_transfer_mortuary) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(time_transfer_mortuary)::time END,

  NULLIF(probable_cause_of_death,''),
  NULLIF(probable_cause_of_death_specific,''),

  NULLIF(cremation_fetus_by_hospital,''),
  NULLIF(chance_of_contamination_risk_filled_in_doctor,''),
  NULLIF(other_additional_examinations,''),

  NULLIF(destination_deceased,''),

  NULLIF(autopsy,''),
  NULLIF(information_autopsy_data,''),
  NULLIF(permission_autopsy_next_of_kin,''),
  NULLIF(body_autopsy,''),
  NULLIF(skull_autopsy,''),

  NULLIF(natural_death,''),

  NULLIF(source,''),

  NULLIF(dcm_refreshed_date_time,'')::timestamptz,
  NULLIF(issue_dt,'')::timestamptz

FROM amc_raw.death_registration;

CREATE INDEX IF NOT EXISTS idx_core_death_contact
  ON amc_core.death_registration(patient_contact_id);

CREATE INDEX IF NOT EXISTS idx_core_death_pseudo
  ON amc_core.death_registration(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_death_date
  ON amc_core.death_registration(meet_date);

