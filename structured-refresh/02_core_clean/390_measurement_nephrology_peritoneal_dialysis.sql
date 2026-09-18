--===========================================================================
DROP TABLE IF EXISTS amc_core.measurement_nephrology_peritoneal_dialysis CASCADE;

CREATE TABLE amc_core.measurement_nephrology_peritoneal_dialysis (
  patient_contact_id text NOT NULL,
  measurement_moment timestamptz NOT NULL,

  pseudo_id text,
  hospital_location text,
  meet_time time,
  meet_date date,

  choice_flush text,
  liquid text,
  additions text,
  antibiotics text,
  status text,
  cycle text,

  totalvolume_treatment numeric,
  volume_in_ml_old numeric,
  volume_in_ml numeric,
  dwell_time numeric,
  volume_out_ml_old numeric,
  volume_out_ml numeric,
  balance_this_treatment_ml numeric,

  leakage text,
  dialysate_aspect text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz,

  PRIMARY KEY (patient_contact_id, measurement_moment)
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.measurement_nephrology_peritoneal_dialysis (
  patient_contact_id,
  measurement_moment,
  pseudo_id,
  hospital_location,
  meet_time,
  meet_date,
  choice_flush,
  liquid,
  additions,
  antibiotics,
  status,
  cycle,
  totalvolume_treatment,
  volume_in_ml_old,
  volume_in_ml,
  dwell_time,
  volume_out_ml_old,
  volume_out_ml,
  balance_this_treatment_ml,
  leakage,
  dialysate_aspect,
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

  NULLIF(choice_flush, ''),
  NULLIF(liquid, ''),
  NULLIF(additions, ''),
  NULLIF(antibiotics, ''),
  NULLIF(status, ''),
  NULLIF(cycle, ''),

  CASE WHEN trim(totalvolume_treatment) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(totalvolume_treatment)::numeric END,

  CASE WHEN trim(volume_in_ml_old) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(volume_in_ml_old)::numeric END,

  CASE WHEN trim(volume_in_ml) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(volume_in_ml)::numeric END,

  CASE WHEN trim(dwell_time) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(dwell_time)::numeric END,

  CASE WHEN trim(volume_out_ml_old) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(volume_out_ml_old)::numeric END,

  CASE WHEN trim(volume_out_ml) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(volume_out_ml)::numeric END,

  CASE WHEN trim(balance_this_treatment_ml) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
    THEN trim(balance_this_treatment_ml)::numeric END,

  NULLIF(leakage, ''),
  NULLIF(dialysate_aspect, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.measurement_nephrology_peritoneal_dialysis

WHERE NULLIF(patient_contact_id, '') IS NOT NULL
  AND NULLIF(measurement_moment, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_pd_pseudo_id
  ON amc_core.measurement_nephrology_peritoneal_dialysis(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_pd_patient_contact_id
  ON amc_core.measurement_nephrology_peritoneal_dialysis(patient_contact_id);

