CREATE SCHEMA IF NOT EXISTS amc_raw;
CREATE SCHEMA IF NOT EXISTS amc_core;
CREATE SCHEMA IF NOT EXISTS amc_meta;

-- ===========================================================================
-- raw_load_log.csv (4 columns)
CREATE TABLE IF NOT EXISTS amc_meta.raw_load_log (
  loaded_at  timestamptz DEFAULT now(),
  table_name text NOT NULL,
  csv_file   text NOT NULL,
  notes      text
);
