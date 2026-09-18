--============================================================================

DROP TABLE IF EXISTS amc_raw.patient_questionnaire;

CREATE TABLE amc_raw.patient_questionnaire (
  pseudo_id TEXT,
  reply_date TEXT,
  reply_time TEXT,
  reply_date_time TEXT,
  age_in_years_at_reply TEXT,
  patient_contact_id TEXT,
  hospital_location TEXT,
  form TEXT,
  form_code TEXT,
  questionnaire_question TEXT,
  questionnaire_question_formulation TEXT,
  questionnaire_answer_group_id TEXT,
  questionnaire_answer_line_number TEXT,
  questionnaire_answer_numeric TEXT,
  questionnaire_answer TEXT,
  standard_error TEXT,
  source TEXT,
  dcm_refreshed_date_time TEXT,
  issue_dt TEXT
);

-- @COPY_PARTS: patient_questionnaire

-- Sanity checks

-- 1) Row count
SELECT count(*) AS n_rows
FROM amc_raw.patient_questionnaire;

-- 2) Null checks for join keys + basics
SELECT
  count(*) FILTER (WHERE pseudo_id IS NULL OR btrim(pseudo_id) = '') AS null_pseudo,
  count(*) FILTER (WHERE patient_contact_id IS NULL OR btrim(patient_contact_id) = '') AS null_contact,
  count(*) FILTER (WHERE reply_date_time IS NULL OR btrim(reply_date_time) = '') AS null_reply_dt,
  count(*) FILTER (WHERE questionnaire_question IS NULL OR btrim(questionnaire_question) = '') AS null_question
FROM amc_raw.patient_questionnaire;

-- 3) Cardinalities (useful to understand grain)
SELECT
  count(*) AS n,
  count(DISTINCT pseudo_id) AS distinct_pseudo,
  count(DISTINCT patient_contact_id) AS distinct_contacts,
  count(DISTINCT form_code) AS distinct_form_codes,
  count(DISTINCT questionnaire_answer_group_id) AS distinct_answer_groups
FROM amc_raw.patient_questionnaire;

-- 4) What is the "row id"? (rn, a row_number-ish export artifact, was dropped from the raw extraction)
-- Check whether (patient_contact_id, questionnaire_answer_line_number) behaves like a key
SELECT
  count(*) AS n,
  count(DISTINCT patient_contact_id || '|' || coalesce(questionnaire_answer_group_id,'') || '|' || coalesce(questionnaire_answer_line_number,'')) AS distinct_combo
FROM amc_raw.patient_questionnaire;

-- 5) If you want: top forms
SELECT form_code, form, count(*) AS n
FROM amc_raw.patient_questionnaire
GROUP BY form_code, form
ORDER BY n DESC
LIMIT 50;

