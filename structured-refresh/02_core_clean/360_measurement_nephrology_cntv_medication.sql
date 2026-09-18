--===========================================================================
DROP TABLE IF EXISTS amc_core.measurement_nephrology_cntv_medication CASCADE;

CREATE TABLE amc_core.measurement_nephrology_cntv_medication (
  patient_contact_id text NOT NULL,
  measurement_moment timestamptz NOT NULL,

  pseudo_id text,
  hospital_location text,
  meet_time time,
  meet_date date,

  citrate_doses_set_raw text,

  citrate_doses_set numeric,
  citrate_flowrate_raw text,
  citrate_flowrate numeric,
  citrate_volume_raw text,
  citrate_volume numeric,
  calcium_doses_set_raw text,
  calcium_doses_set numeric,
  calcium_flowrate_raw text,
  calcium_flowrate numeric,
  calcium_volume_raw text,
  calcium_volume numeric,
  anticoagulation_continuousu_volume_total_raw text,
  anticoagulation_continuousu_volume_total numeric,
  anticoagulation_bolus_volume_total_raw text,
  anticoagulation_bolus_volume_total numeric,
  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz,

  PRIMARY KEY (patient_contact_id, measurement_moment)
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.measurement_nephrology_cntv_medication (
  patient_contact_id,
  measurement_moment,
  pseudo_id,
  hospital_location,
  meet_time,
  meet_date,
  citrate_doses_set_raw, citrate_doses_set,
  citrate_flowrate_raw, citrate_flowrate,
  citrate_volume_raw, citrate_volume,
  calcium_doses_set_raw, calcium_doses_set,
  calcium_flowrate_raw, calcium_flowrate,
  calcium_volume_raw, calcium_volume,
  anticoagulation_continuousu_volume_total_raw, anticoagulation_continuousu_volume_total,
  anticoagulation_bolus_volume_total_raw, anticoagulation_bolus_volume_total,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  patient_contact_id,
  CASE WHEN trim(measurement_moment) ~ '^\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}' THEN trim(measurement_moment)::timestamptz END,

  NULLIF(pseudo_id, ''),
  NULLIF(hospital_location, ''),
  CASE WHEN trim(meet_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(meet_time)::time END,
  CASE WHEN trim(meet_date) ~ '^\d{4}-\d{2}-\d{2}$' THEN trim(meet_date)::date END,

  NULLIF(citrate_doses_set, ''),

  CASE WHEN trim(citrate_doses_set) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(citrate_doses_set)::numeric END,

  NULLIF(citrate_flowrate, ''),

  CASE WHEN trim(citrate_flowrate) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(citrate_flowrate)::numeric END,

  NULLIF(citrate_volume, ''),

  CASE WHEN trim(citrate_volume) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(citrate_volume)::numeric END,

  NULLIF(calcium_doses_set, ''),

  CASE WHEN trim(calcium_doses_set) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(calcium_doses_set)::numeric END,

  NULLIF(calcium_flowrate, ''),

  CASE WHEN trim(calcium_flowrate) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(calcium_flowrate)::numeric END,

  NULLIF(calcium_volume, ''),

  CASE WHEN trim(calcium_volume) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(calcium_volume)::numeric END,

  NULLIF(anticoagulation_continuousu_volume_total, ''),

  CASE WHEN trim(anticoagulation_continuousu_volume_total) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(anticoagulation_continuousu_volume_total)::numeric END,

  NULLIF(anticoagulation_bolus_volume_total, ''),

  CASE WHEN trim(anticoagulation_bolus_volume_total) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(anticoagulation_bolus_volume_total)::numeric END,

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.measurement_nephrology_cntv_medication

WHERE NULLIF(patient_contact_id, '') IS NOT NULL
  AND NULLIF(measurement_moment, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_nephro_pseudo_id
  ON amc_core.measurement_nephrology_cntv_medication(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_nephro_patient_contact_id
  ON amc_core.measurement_nephrology_cntv_medication(patient_contact_id);

