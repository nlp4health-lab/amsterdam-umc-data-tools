----------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_adverse_events;

CREATE VIEW amc_views.v_adverse_events AS

SELECT
    ae.pseudo_id,
    NULL::text AS patient_contact_id,

    ae.adverse_event_id,

    ae.course_date::timestamptz AS event_datetime,
    ae.solution_date::timestamptz AS event_end_datetime,

    ae.patient_problem_status,
    ae.is_seriously,
    ae.is_expected,

    ae.epic_diagnosis_id,
    ae.diagnosis,

    ae.adverse_event_relation_to_study,

    ae.research_project,
    ae.research_project_name,
    ae.research_project_start_date,
    ae.research_project_status_description,
    ae.study_code,
    ae.research_project_participation_alias,

    ae.source,
    ae.dcm_refreshed_date_time,
    ae.issue_dt,

    'adverse_event' AS source_table

FROM amc_core.adverse_event ae;
