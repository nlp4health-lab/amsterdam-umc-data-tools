----------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_questionnaires_long;

CREATE VIEW amc_views.v_questionnaires_long AS

SELECT
    pq.pseudo_id,
    pq.patient_contact_id,

    pq.patient_questionnaire_id::text AS questionnaire_record_id,

    pq.reply_date_time AS questionnaire_datetime,
    pq.reply_date,
    pq.reply_time,

    pq.form AS questionnaire_name,
    pq.form_code AS questionnaire_code,

    pq.questionnaire_answer_group_id,
    pq.questionnaire_answer_line_number,

    pq.questionnaire_question,
    pq.questionnaire_question_formulation,

    pq.questionnaire_answer_numeric AS value_numeric,
    pq.questionnaire_answer AS value_text,

    pq.standard_error,

    pq.age_in_years_at_reply,

    pq.hospital_location,

    'patient_questionnaire' AS source_table

FROM amc_core.patient_questionnaire pq;
