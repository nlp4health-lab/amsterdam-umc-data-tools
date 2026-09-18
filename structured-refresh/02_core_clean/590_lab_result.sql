--===============================================================
DROP TABLE IF EXISTS amc_core.lab_result CASCADE;

CREATE TABLE amc_core.lab_result (
  lab_result_id bigserial PRIMARY KEY,

  pseudo_id text,
  sample_id text,
  determination_code text,

  sampling_location text,
  collection_location_remark text,

  material_decrease_date date,
  material_decrease_time time,
  material_decrease_date_time timestamptz,

  material_type text,
  determination text,
  requesting_workplace_abbreviation text,

  result_date date,
  result_time time,
  result_date_time timestamptz,

  normalvalue_below numeric,
  normalvalue_upper_limit numeric,

  result_text text,
  result_numeric numeric,
  result_unit text,
  result_remark text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz
);

INSERT INTO amc_core.lab_result (
  pseudo_id,
  sample_id,
  determination_code,
  sampling_location,
  collection_location_remark,
  material_decrease_date,
  material_decrease_time,
  material_decrease_date_time,
  material_type,
  determination,
  requesting_workplace_abbreviation,
  result_date,
  result_time,
  result_date_time,
  normalvalue_below,
  normalvalue_upper_limit,
  result_text,
  result_numeric,
  result_unit,
  result_remark,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(pseudo_id, ''),
  NULLIF(sample_id, ''),
  NULLIF(determination_code, ''),

  NULLIF(sampling_location, ''),
  NULLIF(collection_location_remark, ''),

  NULLIF(material_decrease_date, '')::date,
  NULLIF(material_decrease_time, '')::time,
  NULLIF(material_decrease_date_time, '')::timestamptz,

  NULLIF(material_type, ''),
  NULLIF(determination, ''),
  NULLIF(requesting_workplace_abbreviation, ''),

  NULLIF(result_date, '')::date,
  NULLIF(result_time, '')::time,
  NULLIF(result_date_time, '')::timestamptz,

  CASE
    WHEN trim(normalvalue_below) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
      THEN trim(normalvalue_below)::numeric
  END,

  CASE
    WHEN trim(normalvalue_upper_limit) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
      THEN trim(normalvalue_upper_limit)::numeric
  END,

  NULLIF(result_text, ''),

  CASE
    WHEN trim(result_numeric) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$'
      THEN trim(result_numeric)::numeric
  END,

  NULLIF(result_unit, ''),
  NULLIF(result_remark, ''),

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.lab_result

WHERE NULLIF(pseudo_id, '') IS NOT NULL
  AND NULLIF(sample_id, '') IS NOT NULL
  AND NULLIF(determination_code, '') IS NOT NULL;

-- indexes
CREATE INDEX IF NOT EXISTS idx_core_lab_pseudo_id
  ON amc_core.lab_result(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_lab_sample_id
  ON amc_core.lab_result(sample_id);

CREATE INDEX IF NOT EXISTS idx_core_lab_result_datetime
  ON amc_core.lab_result(result_date_time);

