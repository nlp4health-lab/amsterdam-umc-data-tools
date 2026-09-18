--===========================================================================

DROP TABLE IF EXISTS amc_raw.medication_administration;

CREATE TABLE amc_raw.medication_administration (
  pseudo_id TEXT,
  rule_id TEXT,
  patient_contact_id TEXT,
  admission_traject_id TEXT,
  administration_date_time TEXT,
  administration_date TEXT,
  administration_time TEXT,
  administration_status TEXT,
  walk_in TEXT,
  walk_in_rate_unit TEXT,
  number_submitted_pieces TEXT,
  administered_amount TEXT,
  administered_quantity_unit TEXT,
  administration_route TEXT,
  medication_article_name TEXT,
  medication_substance_name TEXT,
  medication_generic_name TEXT,
  ingredient_type_name TEXT,
  atc_code TEXT,
  atc_name TEXT,
  pharmaceutical_class TEXT,
  pharmaceutical_subclass TEXT,
  therapeutic_class TEXT,
  medication_strength TEXT,
  medication_strength_dosage TEXT,
  medication_strength_unit TEXT,
  workplace TEXT,
  hospital_location TEXT,
  administration_reason TEXT,
  medication_remark TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: medication_administration

-- Sanity checks

-- Row count
SELECT count(*) AS n_rows
FROM amc_raw.medication_administration;

-- Null checks on likely key / join columns
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL) AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL) AS null_contact,
  count(*) FILTER (WHERE rule_id IS NULL) AS null_rule_id,
  count(*) FILTER (WHERE admission_traject_id IS NULL) AS null_adm_traject_id
FROM amc_raw.medication_administration;

-- Uniqueness hints
SELECT
  count(*) AS n,
  count(DISTINCT rule_id) AS distinct_rule_id,
  count(DISTINCT patient_contact_id) AS distinct_contacts,
  count(DISTINCT admission_traject_id) FILTER (WHERE admission_traject_id IS NOT NULL) AS distinct_adm_trajects
FROM amc_raw.medication_administration;

-- Max meds per contact
SELECT patient_contact_id, count(*) AS n
FROM amc_raw.medication_administration
WHERE patient_contact_id IS NOT NULL
GROUP BY patient_contact_id
ORDER BY n DESC
LIMIT 20;

-- Max meds per admission_traject
SELECT admission_traject_id, count(*) AS n
FROM amc_raw.medication_administration
WHERE admission_traject_id IS NOT NULL
GROUP BY admission_traject_id
ORDER BY n DESC
LIMIT 20;

-- Date range checks (only where ISO-like)
SELECT
  min(administration_date_time::timestamptz) AS min_admin_dt,
  max(administration_date_time::timestamptz) AS max_admin_dt
FROM amc_raw.medication_administration
WHERE administration_date_time ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}';

-- no clear primary key. Maybe pseudo_id or contact_id + rule_id
-- min date 2015 max date 2404

