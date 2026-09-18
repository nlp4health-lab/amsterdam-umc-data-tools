-- ==========================================================================

DROP TABLE IF EXISTS amc_raw.admission_partial_traject;

CREATE TABLE amc_raw.admission_partial_traject (
  pseudo_id TEXT,
  patient_contact_id TEXT,
  admission_partial_traject_id TEXT,
  admission_traject_id TEXT,
  hospital_location TEXT,
  admission_traject_admission_date TEXT,
  admission_traject_admission_date_time TEXT,
  admission_traject_discharge_date TEXT,
  admission_traject_discharge_date_time TEXT,
  age_in_years_at_moment_admission TEXT,
  operative_or_reflective TEXT,
  admission_via_seh TEXT,
  admission_traject_type TEXT,
  admission_mode TEXT,
  admission_origin TEXT,
  discharge_method TEXT,
  partial_traject_admission_type TEXT,
  start_date_time TEXT,
  start_date TEXT,
  start_time TEXT,
  end_date_time TEXT,
  end_date TEXT,
  end_time TEXT,
  specialty TEXT,
  subspecialty TEXT,
  service_specialty TEXT,
  patient_class TEXT,
  bed TEXT,
  room TEXT,
  workplace TEXT,
  is_temporary_leave TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: admission_partial_traject

--Sanity check:
SELECT count(*) AS n_rows
FROM amc_raw.admission_partial_traject;

SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL) AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL) AS null_contact,
  count(*) FILTER (WHERE admission_traject_id IS NULL) AS null_parent,
  count(*) FILTER (WHERE admission_partial_traject_id IS NULL) AS null_partial_id
FROM amc_raw.admission_partial_traject;

SELECT
  count(*) AS n,
  count(DISTINCT admission_partial_traject_id) AS distinct_partial_ids
FROM amc_raw.admission_partial_traject;

SELECT admission_traject_id, count(*) AS n
FROM amc_raw.admission_partial_traject
WHERE admission_traject_id IS NOT NULL
GROUP BY admission_traject_id
ORDER BY n DESC
LIMIT 20;

-- no nulls, unique, up to 130 subtrajects per traject.

