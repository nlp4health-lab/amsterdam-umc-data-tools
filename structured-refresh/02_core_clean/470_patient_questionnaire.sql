--===========================================================================

DROP TABLE IF EXISTS amc_core.patient_questionnaire CASCADE;

CREATE TABLE amc_core.patient_questionnaire (
  patient_questionnaire_id bigserial PRIMARY KEY,

  pseudo_id text,
  patient_contact_id text,
  hospital_location text,

  reply_date date,
  reply_time time,
  reply_date_time timestamptz,
  age_in_years_at_reply_raw text,
  age_in_years_at_reply numeric,
  form text,
  form_code text,

  questionnaire_question text,
  questionnaire_question_formulation text,

  questionnaire_answer_group_id text,
  questionnaire_answer_line_number text,

  questionnaire_answer_numeric numeric,
  questionnaire_answer text,
  standard_error numeric,

  source text,
  dcm_refreshed_date_time timestamptz,
  issue_dt timestamptz

  -- rn intentionally dropped
);

INSERT INTO amc_core.patient_questionnaire (
  pseudo_id,
  patient_contact_id,
  hospital_location,
  reply_date,
  reply_time,
  reply_date_time,
  age_in_years_at_reply_raw, age_in_years_at_reply,
  form,
  form_code,
  questionnaire_question,
  questionnaire_question_formulation,
  questionnaire_answer_group_id,
  questionnaire_answer_line_number,
  questionnaire_answer_numeric,
  questionnaire_answer,
  standard_error,
  source,
  dcm_refreshed_date_time,
  issue_dt
)
SELECT
  NULLIF(pseudo_id, ''),
  NULLIF(patient_contact_id, ''),
  NULLIF(hospital_location, ''),

  NULLIF(reply_date, '')::date,
  CASE WHEN trim(reply_time) ~ '^\d{1,2}:\d{2}(:\d{2})?' THEN trim(reply_time)::time END,
  NULLIF(reply_date_time, '')::timestamptz,

  NULLIF(age_in_years_at_reply, ''),

  CASE
    WHEN trim(age_in_years_at_reply) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)$'
      THEN trim(age_in_years_at_reply)::numeric
  END,

  NULLIF(form, ''),
  NULLIF(form_code, ''),

  NULLIF(questionnaire_question, ''),
  NULLIF(questionnaire_question_formulation, ''),

  NULLIF(questionnaire_answer_group_id, ''),
  NULLIF(questionnaire_answer_line_number, ''),

  CASE
    WHEN trim(questionnaire_answer_numeric) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)$'
      THEN trim(questionnaire_answer_numeric)::numeric
  END,

  NULLIF(questionnaire_answer, ''),

  CASE
    WHEN trim(standard_error) ~ '^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)$'
      THEN trim(standard_error)::numeric
  END,

  NULLIF(source, ''),
  NULLIF(dcm_refreshed_date_time, '')::timestamptz,
  NULLIF(issue_dt, '')::timestamptz

FROM amc_raw.patient_questionnaire;

CREATE INDEX IF NOT EXISTS idx_core_questionnaire_pseudo
  ON amc_core.patient_questionnaire(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_questionnaire_contact
  ON amc_core.patient_questionnaire(patient_contact_id);

