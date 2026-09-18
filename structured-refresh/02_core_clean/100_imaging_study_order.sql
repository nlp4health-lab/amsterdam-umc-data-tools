--===========================================================================
DROP TABLE IF EXISTS amc_core.imaging_study_order CASCADE;

CREATE TABLE amc_core.imaging_study_order (
  imaging_study_order_id bigserial PRIMARY KEY,

  pseudo_id text NOT NULL,
  patient_contact_id text,

  accession_number text,
  imaging_study_status text,

  start_moment timestamptz,
  start_date date,
  start_time time,

  end_moment timestamptz,
  end_date date,
  end_time time,

  order_assignment text,
  requesting_workplace text,
  executive_workplace text,

  hospital_location_code text,
  hospital_location text,

  final_report_date_time timestamptz,
  is_cancelled text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz
);

INSERT INTO amc_core.imaging_study_order (
  pseudo_id,
  patient_contact_id,
  accession_number,
  imaging_study_status,
  start_moment,
  start_date,
  start_time,
  end_moment,
  end_date,
  end_time,
  order_assignment,
  requesting_workplace,
  executive_workplace,
  hospital_location_code,
  hospital_location,
  final_report_date_time,
  is_cancelled,
  source,
  dcm_refreshed_date_time,
  issue_dt
)

SELECT
  pseudo_id,
  NULLIF(patient_contact_id,''),

  NULLIF(accession_number,''),
  NULLIF(imaging_study_status,''),

  NULLIF(start_moment,'')::timestamptz,
  NULLIF(start_date,'')::date,
  CASE WHEN trim(start_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(start_time)::time END,

  NULLIF(end_moment,'')::timestamptz,
  NULLIF(end_date,'')::date,
  CASE WHEN trim(end_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(end_time)::time END,

  NULLIF(order_assignment,''),
  NULLIF(requesting_workplace,''),
  NULLIF(executive_workplace,''),

  NULLIF(hospital_location_code,''),
  NULLIF(hospital_location,''),

  NULLIF(final_report_date_time,'')::timestamptz,
  NULLIF(is_cancelled,''),

  NULLIF(source,''),
  NULLIF(dcm_refreshed_date_time,'')::timestamptz,
  NULLIF(issue_dt,'')::timestamptz

FROM amc_raw.imaging_study_order;

CREATE INDEX IF NOT EXISTS idx_core_imaging_contact
  ON amc_core.imaging_study_order(patient_contact_id);

CREATE INDEX IF NOT EXISTS idx_core_imaging_pseudo
  ON amc_core.imaging_study_order(pseudo_id);

