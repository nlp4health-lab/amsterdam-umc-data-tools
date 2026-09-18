--===========================================================================
DROP TABLE IF EXISTS amc_core.admission_partial_traject CASCADE;

CREATE TABLE amc_core.admission_partial_traject (
  pseudo_id text NOT NULL,
  patient_contact_id text,
  admission_partial_traject_id text PRIMARY KEY,
  admission_traject_id text,                 
  hospital_location text,

  admission_traject_admission_date date,
  admission_traject_admission_date_time timestamptz,
  admission_traject_discharge_date date,
  admission_traject_discharge_date_time timestamptz,

  age_in_years_at_moment_admission int,

  operative_or_reflective text,
  admission_via_seh text,
  admission_traject_type text,
  admission_mode text,
  admission_origin text,
  discharge_method text,
  partial_traject_admission_type text,

  start_date_time timestamptz,
  start_date date,
  start_time time,

  end_date_time timestamptz,
  end_date date,
  end_time time,

  specialty text,
  subspecialty text,
  service_specialty text,

  patient_class text,
  bed text,
  room text,
  workplace text,

  is_temporary_leave text,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt date
  -- rn intentionally dropped in core
);

INSERT INTO amc_core.admission_partial_traject (
  pseudo_id, patient_contact_id, admission_partial_traject_id, admission_traject_id,
  hospital_location,
  admission_traject_admission_date, admission_traject_admission_date_time,
  admission_traject_discharge_date, admission_traject_discharge_date_time,
  age_in_years_at_moment_admission,
  operative_or_reflective, admission_via_seh, admission_traject_type,
  admission_mode, admission_origin, discharge_method, partial_traject_admission_type,
  start_date_time, start_date, start_time,
  end_date_time, end_date, end_time,
  specialty, subspecialty, service_specialty,
  patient_class, bed, room, workplace,
  is_temporary_leave,
  source, dcm_refreshed_date_time, issue_dt
)
SELECT
  pseudo_id,
  NULLIF(patient_contact_id,''),
  admission_partial_traject_id,
  NULLIF(admission_traject_id,''),

  NULLIF(hospital_location,''),

  NULLIF(admission_traject_admission_date,'')::date,
  NULLIF(admission_traject_admission_date_time,'')::timestamptz,
  NULLIF(admission_traject_discharge_date,'')::date,
  NULLIF(admission_traject_discharge_date_time,'')::timestamptz,

  NULLIF(age_in_years_at_moment_admission,'')::numeric,

  NULLIF(operative_or_reflective,''),
  NULLIF(admission_via_seh,''),
  NULLIF(admission_traject_type,''),
  NULLIF(admission_mode,''),
  NULLIF(admission_origin,''),
  NULLIF(discharge_method,''),
  NULLIF(partial_traject_admission_type,''),

  NULLIF(start_date_time,'')::timestamptz,
  NULLIF(start_date,'')::date,
  NULLIF(start_time,'')::time,

  NULLIF(end_date_time,'')::timestamptz,
  NULLIF(end_date,'')::date,
  NULLIF(end_time,'')::time,

  NULLIF(specialty,''),
  NULLIF(subspecialty,''),
  NULLIF(service_specialty,''),

  NULLIF(patient_class,''),
  NULLIF(bed,''),
  NULLIF(room,''),
  NULLIF(workplace,''),

  NULLIF(is_temporary_leave,''),

  NULLIF(source,''),
  NULLIF(dcm_refreshed_date_time,'')::timestamptz,
  NULLIF(issue_dt,'')::date
FROM amc_raw.admission_partial_traject;

CREATE INDEX IF NOT EXISTS idx_core_admpart_contact
  ON amc_core.admission_partial_traject(patient_contact_id);

CREATE INDEX IF NOT EXISTS idx_core_admpart_admtraj
  ON amc_core.admission_partial_traject(admission_traject_id);

CREATE INDEX IF NOT EXISTS idx_core_admpart_pseudo
  ON amc_core.admission_partial_traject(pseudo_id);


