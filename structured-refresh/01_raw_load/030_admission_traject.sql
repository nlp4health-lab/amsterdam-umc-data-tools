-- ==========================================================================

DROP TABLE IF EXISTS amc_raw.admission_traject;

CREATE TABLE amc_raw.admission_traject (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  admission_traject_id TEXT,
  admission_moment_subtraject_id TEXT,
  hospital_location TEXT,
  age_in_years_at_moment_admission TEXT,
  is_patient_discharged TEXT,
  is_admission_start_seh TEXT,
  is_admission_elective TEXT,
  admission_via_seh TEXT,
  operative_or_reflective TEXT,
  admission_moment TEXT,
  admission_date TEXT,
  admission_time TEXT,
  discharge_moment TEXT,
  discharge_date TEXT,
  discharge_time TEXT,
  admission_type TEXT,
  admission_mode TEXT,
  admission_origin TEXT,
  accommodation_reason TEXT,
  discharge_method TEXT,
  discharge_location TEXT,
  admission_specialty TEXT,
  admission_subspecialty TEXT,
  admission_service_specialty TEXT,
  admission_patientclass TEXT,
  discharge_patient_class TEXT,
  admission_workplace TEXT,
  -- is_admission_traject_intraclinical_transport_within{24,48}hs_back
  -- retired from the source extract as of the 2026-09-08 pull (confirmed:
  -- the real CSV is exactly 2 columns shorter, ending right where these
  -- used to sit) — removed here and from 02_core_clean/020_admission_traject.sql.
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: admission_traject

--Sanity check:
-- row count
SELECT count(*) AS n_rows
FROM amc_raw.admission_traject;

-- key nulls
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL) AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL) AS null_contact,
  count(*) FILTER (WHERE admission_traject_id IS NULL) AS null_traject_id
FROM amc_raw.admission_traject;

-- uniqueness candidates (not assumptions; just profiling)
SELECT
  count(*) AS n,
  count(DISTINCT admission_traject_id) AS distinct_traject_id
FROM amc_raw.admission_traject;

-- contact -> traject multiplicity (how many trajects per contact)
SELECT patient_contact_id, count(*) AS n
FROM amc_raw.admission_traject
WHERE patient_contact_id IS NOT NULL
GROUP BY patient_contact_id
ORDER BY n DESC
LIMIT 20;

-- size
SELECT pg_size_pretty(pg_total_relation_size('amc_raw.admission_traject')) AS table_size;

-- patient_contact_id has only 1 traject, but pseudo_id has many trajects up to 800-400. 

