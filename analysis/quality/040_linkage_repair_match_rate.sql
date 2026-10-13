-- =====================================================================
-- Data quality check: 05_linkage_repair's match rate.
--
-- 5 tables have probable_contact_id/probable_partial_traject_id
-- inferred by date-range join against admission_partial_traject
-- (structured-refresh/05_linkage_repair). Nothing until now reports
-- how well that inference actually worked.
--
-- Per table, three counts:
--   total_rows      = every row in the table
--   eligible_rows   = rows 05_linkage_repair actually attempted a match
--                      for -- mirrors each file's own WHERE clause
--                      exactly (a non-null anchor date, and, for the
--                      2 tables that have one, not already flagged
--                      with an implausible date). Rows outside this
--                      set were never attempted, not "unmatched."
--   matched_rows    = eligible AND probable_contact_id IS NOT NULL
--   unmatched_rows  = eligible AND probable_contact_id IS NULL --
--                      attempted, but no overlapping
--                      admission_partial_traject found
--
-- pct_matched_of_eligible is the real signal: how often the match
-- actually succeeds when it's attempted at all. pct_eligible_of_total
-- shows how much of the table couldn't even be attempted (missing
-- anchor date, or an already-known-bad date).
--
-- Usage: run in psql / any Postgres client against carenlp_db. Not
-- fast on lab_result (~168M rows, no index on the anchor-date
-- columns) -- an audit script, not meant for a live demo.
-- =====================================================================

SELECT
    table_name,
    total_rows,
    eligible_rows,
    matched_rows,
    unmatched_rows,
    ROUND(100.0 * eligible_rows / NULLIF(total_rows, 0), 1)    AS pct_eligible_of_total,
    ROUND(100.0 * matched_rows / NULLIF(eligible_rows, 0), 1)  AS pct_matched_of_eligible
FROM (

    SELECT
        'ecg_measurement' AS table_name,
        COUNT(*) AS total_rows,
        COUNT(*) FILTER (
            WHERE ecg_decrease_date_time IS NOT NULL
              AND NOT COALESCE(abnormal_decrease_date_time, false)
        ) AS eligible_rows,
        COUNT(*) FILTER (
            WHERE ecg_decrease_date_time IS NOT NULL
              AND NOT COALESCE(abnormal_decrease_date_time, false)
              AND probable_contact_id IS NOT NULL
        ) AS matched_rows,
        COUNT(*) FILTER (
            WHERE ecg_decrease_date_time IS NOT NULL
              AND NOT COALESCE(abnormal_decrease_date_time, false)
              AND probable_contact_id IS NULL
        ) AS unmatched_rows
    FROM amc_core.ecg_measurement

    UNION ALL

    SELECT
        'echo_measurement_heart_center_extra_check',
        COUNT(*),
        COUNT(*) FILTER (
            WHERE examination_date IS NOT NULL
              AND NOT COALESCE(examination_date_quality_issue, false)
        ),
        COUNT(*) FILTER (
            WHERE examination_date IS NOT NULL
              AND NOT COALESCE(examination_date_quality_issue, false)
              AND probable_contact_id IS NOT NULL
        ),
        COUNT(*) FILTER (
            WHERE examination_date IS NOT NULL
              AND NOT COALESCE(examination_date_quality_issue, false)
              AND probable_contact_id IS NULL
        )
    FROM amc_core.echo_measurement_heart_center_extra_check

    UNION ALL

    SELECT
        'lab_result',
        COUNT(*),
        COUNT(*) FILTER (
            WHERE COALESCE(result_date_time, material_decrease_date_time) IS NOT NULL
        ),
        COUNT(*) FILTER (
            WHERE COALESCE(result_date_time, material_decrease_date_time) IS NOT NULL
              AND probable_contact_id IS NOT NULL
        ),
        COUNT(*) FILTER (
            WHERE COALESCE(result_date_time, material_decrease_date_time) IS NOT NULL
              AND probable_contact_id IS NULL
        )
    FROM amc_core.lab_result

    UNION ALL

    SELECT
        'ok_procedure_performed',
        COUNT(*),
        COUNT(*) FILTER (
            WHERE COALESCE(session_start_date_time, intervention_executed_date) IS NOT NULL
        ),
        COUNT(*) FILTER (
            WHERE COALESCE(session_start_date_time, intervention_executed_date) IS NOT NULL
              AND probable_contact_id IS NOT NULL
        ),
        COUNT(*) FILTER (
            WHERE COALESCE(session_start_date_time, intervention_executed_date) IS NOT NULL
              AND probable_contact_id IS NULL
        )
    FROM amc_core.ok_procedure_performed

    UNION ALL

    SELECT
        'ok_procedure_planned',
        COUNT(*),
        COUNT(*) FILTER (WHERE session_planned_start_date IS NOT NULL),
        COUNT(*) FILTER (
            WHERE session_planned_start_date IS NOT NULL
              AND probable_contact_id IS NOT NULL
        ),
        COUNT(*) FILTER (
            WHERE session_planned_start_date IS NOT NULL
              AND probable_contact_id IS NULL
        )
    FROM amc_core.ok_procedure_planned

) sub
ORDER BY pct_matched_of_eligible ASC NULLS LAST;
