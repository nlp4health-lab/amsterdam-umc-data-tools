--===========================================================================
DROP TABLE IF EXISTS amc_core.measurement_vital_signs_data CASCADE;

CREATE TABLE amc_core.measurement_vital_signs_data (
  measurement_vital_signs_data_id bigserial PRIMARY KEY,

  pseudo_id text NOT NULL,
  patient_contact_id text,
  hospital_location text,

  meet_time time,
  meet_date date,
  measurement_moment timestamptz,

  vital_data_length numeric,
  vital_data_weight numeric,
  vital_data_bmi_calculation_raw text,
  vital_data_bmi_calculation numeric,
  vital_data_pulse_rate_raw text,
  vital_data_pulse_rate numeric,
  vital_data_blood_pressure_sys_dia text,
  vital_data_temperature numeric,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.measurement_vital_signs_data (
  pseudo_id,
  patient_contact_id,
  hospital_location,
  meet_time,
  meet_date,
  measurement_moment,
  vital_data_length,
  vital_data_weight,
  vital_data_bmi_calculation_raw, vital_data_bmi_calculation,
  vital_data_pulse_rate_raw, vital_data_pulse_rate,
  vital_data_blood_pressure_sys_dia,
  vital_data_temperature,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  pseudo_id,
  NULLIF(patient_contact_id,''),
  NULLIF(hospital_location,''),

  CASE WHEN trim(meet_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(meet_time)::time END,
  NULLIF(meet_date,'')::date,
  NULLIF(measurement_moment,'')::timestamptz,

  CASE
    WHEN trim(vital_data_length) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(vital_data_length)::numeric
    ELSE NULL
  END,

  CASE
    WHEN trim(vital_data_weight) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(vital_data_weight)::numeric
    ELSE NULL
  END,

  NULLIF(vital_data_bmi_calculation, ''),

  CASE
    WHEN trim(vital_data_bmi_calculation) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(vital_data_bmi_calculation)::numeric
    ELSE NULL
  END,

  NULLIF(vital_data_pulse_rate, ''),

  CASE
    WHEN trim(vital_data_pulse_rate) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(vital_data_pulse_rate)::numeric
    ELSE NULL
  END,

  NULLIF(vital_data_blood_pressure_sys_dia,''),

  CASE
    WHEN trim(vital_data_temperature) ~ '^[-+]?[0-9]*\.?[0-9]+$'
      THEN trim(vital_data_temperature)::numeric
    ELSE NULL
  END,

  NULLIF(source,''),
  NULLIF(dcm_refreshed_date_time,'')::timestamptz,
  NULLIF(issue_dt,'')::timestamptz
FROM amc_raw.measurement_vital_signs_data;

CREATE INDEX IF NOT EXISTS idx_core_vitals_contact
  ON amc_core.measurement_vital_signs_data(patient_contact_id);

CREATE INDEX IF NOT EXISTS idx_core_vitals_pseudo
  ON amc_core.measurement_vital_signs_data(pseudo_id);

