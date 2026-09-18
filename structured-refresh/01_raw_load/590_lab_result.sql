--============================================================
--lab result new extraction, with added column to add to PK
DROP TABLE IF EXISTS amc_raw.lab_result;

CREATE TABLE amc_raw.lab_result (
  pseudo_id TEXT,
  sample_id TEXT,
  sampling_location TEXT,
  collection_location_remark TEXT,
  material_decrease_date TEXT,
  material_decrease_time TEXT,
  material_decrease_date_time TEXT,
  material_type TEXT,
  determination TEXT,
  determination_code TEXT,
  requesting_workplace_abbreviation TEXT,
  result_date TEXT,
  result_time TEXT,
  result_date_time TEXT,
  normalvalue_below TEXT,
  normalvalue_upper_limit TEXT,
  result_text TEXT,
  result_numeric TEXT,
  result_unit TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT,
  result_remark TEXT
);

-- @COPY_PARTS: lab_result

