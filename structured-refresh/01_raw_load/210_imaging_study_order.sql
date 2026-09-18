-- ===========================================================================
-- amc_raw.imaging_study_order
-- ===========================================================================

DROP TABLE IF EXISTS amc_raw.imaging_study_order;

CREATE TABLE amc_raw.imaging_study_order (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  accession_number TEXT,
  imaging_study_status TEXT,
  start_moment TEXT,
  start_date TEXT,
  start_time TEXT,
  end_moment TEXT,
  end_date TEXT,
  end_time TEXT,
  order_assignment TEXT,
  requesting_workplace TEXT,
  executive_workplace TEXT,
  hospital_location_code TEXT,
  hospital_location TEXT,
  final_report_date_time TEXT,
  is_cancelled TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: imaging_study_order

-- Minimal sanity
SELECT count(*) AS n_rows
FROM amc_raw.imaging_study_order;

SELECT count(*) AS null_accession
FROM amc_raw.imaging_study_order
WHERE accession_number IS NULL OR btrim(accession_number) = '';

