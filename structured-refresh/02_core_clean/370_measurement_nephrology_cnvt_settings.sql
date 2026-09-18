--===========================================================================
DROP TABLE IF EXISTS amc_core.measurement_nephrology_cnvt_settings CASCADE;

CREATE TABLE amc_core.measurement_nephrology_cnvt_settings (
  patient_contact_id text NOT NULL,
  measurement_moment timestamptz NOT NULL,

  pseudo_id text,
  hospital_location text,
  meet_time time,
  meet_date date,

  treatment_type text,
  treatment_status text,
  substitution_fluid text,
  substitution_fluid_additives text,
  dialysate_fluid text,
  dialysate_fluid_additives text,
  filter_type text,

  bloodflow_mlmin numeric,
  dialysate_flow numeric,
  uf_volume_current_set numeric,
  target_uf_volume_ml numeric,
  predilution_flow_rate numeric,
  postdilution_flow_rate numeric,
  liquid_dialysate_temp numeric,

  reason_discontinuation text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz,

  PRIMARY KEY (patient_contact_id, measurement_moment)
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.measurement_nephrology_cnvt_settings (
  patient_contact_id,
  measurement_moment,
  pseudo_id,
  hospital_location,
  meet_time,
  meet_date,
  treatment_type,
  treatment_status,
  substitution_fluid,
  substitution_fluid_additives,
  dialysate_fluid,
  dialysate_fluid_additives,
  filter_type,
  bloodflow_mlmin,
  dialysate_flow,
  uf_volume_current_set,
  target_uf_volume_ml,
  predilution_flow_rate,
  postdilution_flow_rate,
  liquid_dialysate_temp,
  reason_discontinuation,
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

  NULLIF(treatment_type, ''),
  NULLIF(treatment_status, ''),
  NULLIF(substitution_fluid, ''),
  NULLIF(substitution_fluid_additives, ''),
  NULLIF(dialysate_fluid, ''),
  NULLIF(dialysate_fluid_additives, ''),
  NULLIF(filter_type, ''),

  CASE WHEN trim(bloodflow_mlmin) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(bloodflow_mlmin)::numeric END,

  CASE WHEN trim(dialysate_flow) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(dialysate_flow)::numeric END,

  CASE WHEN trim(uf_volume_current_set) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(uf_volume_current_set)::numeric END,

  CASE WHEN trim(target_uf_volume_ml) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(target_uf_volume_ml)::numeric END,

  CASE WHEN trim(predilution_flow_rate) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(predilution_flow_rate)::numeric END,

  CASE WHEN trim(postdilution_flow_rate) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(postdilution_flow_rate)::numeric END,

  CASE WHEN trim(liquid_dialysate_temp) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(liquid_dialysate_temp)::numeric END,

  NULLIF(reason_discontinuation, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.measurement_nephrology_cnvt_settings

WHERE NULLIF(patient_contact_id, '') IS NOT NULL
  AND NULLIF(measurement_moment, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_cnvt_settings_pseudo_id
  ON amc_core.measurement_nephrology_cnvt_settings(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_cnvt_settings_patient_contact_id  
  ON amc_core.measurement_nephrology_cnvt_settings(patient_contact_id);

