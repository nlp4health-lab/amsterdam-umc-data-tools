-- ============================================================================
-- Data quality check: MIN, MAX, NULL COUNT, and % NULL
-- for every date/timestamp/time-like column identified in date_columns.csv
-- (covers amc_core tables; includes typed date/time/timestamptz columns and
--  text columns that are date-like by name)
--
-- Generated automatically from date_columns.csv (331 columns across
-- 59 tables).
--
-- Usage: run in psql / any Postgres client against the carenlp_db database.
-- Each row of the result = one (table, column) pair.
-- ============================================================================

SELECT * FROM (
  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'admission_traject_admission_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(admission_traject_admission_date)::text        AS min_value,
    MAX(admission_traject_admission_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE admission_traject_admission_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE admission_traject_admission_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'admission_traject_admission_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(admission_traject_admission_date_time)::text        AS min_value,
    MAX(admission_traject_admission_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE admission_traject_admission_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE admission_traject_admission_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'admission_traject_discharge_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(admission_traject_discharge_date)::text        AS min_value,
    MAX(admission_traject_discharge_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE admission_traject_discharge_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE admission_traject_discharge_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'admission_traject_discharge_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(admission_traject_discharge_date_time)::text        AS min_value,
    MAX(admission_traject_discharge_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE admission_traject_discharge_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE admission_traject_discharge_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'corrected_end_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(corrected_end_date)::text        AS min_value,
    MAX(corrected_end_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE corrected_end_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE corrected_end_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'corrected_end_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(corrected_end_date_time)::text        AS min_value,
    MAX(corrected_end_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE corrected_end_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE corrected_end_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'corrected_end_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(corrected_end_time)::text        AS min_value,
    MAX(corrected_end_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE corrected_end_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE corrected_end_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'end_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(end_date)::text        AS min_value,
    MAX(end_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE end_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'end_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(end_date_time)::text        AS min_value,
    MAX(end_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE end_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'end_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(end_time)::text        AS min_value,
    MAX(end_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE end_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'start_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(start_date)::text        AS min_value,
    MAX(start_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'start_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(start_date_time)::text        AS min_value,
    MAX(start_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_partial_traject'::text            AS table_name,
    'start_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(start_time)::text        AS min_value,
    MAX(start_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_partial_traject

  UNION ALL

  SELECT
    'amc_core.admission_traject'::text            AS table_name,
    'admission_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(admission_date)::text        AS min_value,
    MAX(admission_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE admission_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE admission_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_traject

  UNION ALL

  SELECT
    'amc_core.admission_traject'::text            AS table_name,
    'admission_moment'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(admission_moment)::text        AS min_value,
    MAX(admission_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE admission_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE admission_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_traject

  UNION ALL

  SELECT
    'amc_core.admission_traject'::text            AS table_name,
    'admission_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(admission_time)::text        AS min_value,
    MAX(admission_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE admission_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE admission_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_traject

  UNION ALL

  SELECT
    'amc_core.admission_traject'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_traject

  UNION ALL

  SELECT
    'amc_core.admission_traject'::text            AS table_name,
    'discharge_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(discharge_date)::text        AS min_value,
    MAX(discharge_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE discharge_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE discharge_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_traject

  UNION ALL

  SELECT
    'amc_core.admission_traject'::text            AS table_name,
    'discharge_moment'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(discharge_moment)::text        AS min_value,
    MAX(discharge_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE discharge_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE discharge_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_traject

  UNION ALL

  SELECT
    'amc_core.admission_traject'::text            AS table_name,
    'discharge_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(discharge_time)::text        AS min_value,
    MAX(discharge_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE discharge_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE discharge_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_traject

  UNION ALL

  SELECT
    'amc_core.admission_traject'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.admission_traject

  UNION ALL

  SELECT
    'amc_core.adverse_event'::text            AS table_name,
    'course_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(course_date)::text        AS min_value,
    MAX(course_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE course_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE course_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.adverse_event

  UNION ALL

  SELECT
    'amc_core.adverse_event'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.adverse_event

  UNION ALL

  SELECT
    'amc_core.adverse_event'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.adverse_event

  UNION ALL

  SELECT
    'amc_core.adverse_event'::text            AS table_name,
    'research_project_start_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(research_project_start_date)::text        AS min_value,
    MAX(research_project_start_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE research_project_start_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE research_project_start_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.adverse_event

  UNION ALL

  SELECT
    'amc_core.adverse_event'::text            AS table_name,
    'solution_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(solution_date)::text        AS min_value,
    MAX(solution_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE solution_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE solution_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.adverse_event

  UNION ALL

  SELECT
    'amc_core.death_registration'::text            AS table_name,
    'date_transfer_mortuary'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(date_transfer_mortuary)::text        AS min_value,
    MAX(date_transfer_mortuary)::text        AS max_value,
    COUNT(*) FILTER (WHERE date_transfer_mortuary IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE date_transfer_mortuary IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.death_registration

  UNION ALL

  SELECT
    'amc_core.death_registration'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.death_registration

  UNION ALL

  SELECT
    'amc_core.death_registration'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.death_registration

  UNION ALL

  SELECT
    'amc_core.death_registration'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.death_registration

  UNION ALL

  SELECT
    'amc_core.death_registration'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.death_registration

  UNION ALL

  SELECT
    'amc_core.death_registration'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.death_registration

  UNION ALL

  SELECT
    'amc_core.death_registration'::text            AS table_name,
    'time_transfer_mortuary'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(time_transfer_mortuary)::text        AS min_value,
    MAX(time_transfer_mortuary)::text        AS max_value,
    COUNT(*) FILTER (WHERE time_transfer_mortuary IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE time_transfer_mortuary IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.death_registration

  UNION ALL

  SELECT
    'amc_core.ecg_measurement'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ecg_measurement

  UNION ALL

  SELECT
    'amc_core.ecg_measurement'::text            AS table_name,
    'ecg_decrease_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(ecg_decrease_date)::text        AS min_value,
    MAX(ecg_decrease_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE ecg_decrease_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE ecg_decrease_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ecg_measurement

  UNION ALL

  SELECT
    'amc_core.ecg_measurement'::text            AS table_name,
    'ecg_decrease_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(ecg_decrease_date_time)::text        AS min_value,
    MAX(ecg_decrease_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE ecg_decrease_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE ecg_decrease_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ecg_measurement

  UNION ALL

  SELECT
    'amc_core.ecg_measurement'::text            AS table_name,
    'ecg_decrease_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(ecg_decrease_time)::text        AS min_value,
    MAX(ecg_decrease_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE ecg_decrease_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE ecg_decrease_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ecg_measurement

  UNION ALL

  SELECT
    'amc_core.ecg_measurement'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ecg_measurement

  UNION ALL

  SELECT
    'amc_core.ecg_measurement_test_feature'::text            AS table_name,
    'ecg_change_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(ecg_change_date_time)::text        AS min_value,
    MAX(ecg_change_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE ecg_change_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE ecg_change_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ecg_measurement_test_feature

  UNION ALL

  SELECT
    'amc_core.ecg_measurement_test_feature'::text            AS table_name,
    'ecg_decrease_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(ecg_decrease_date)::text        AS min_value,
    MAX(ecg_decrease_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE ecg_decrease_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE ecg_decrease_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ecg_measurement_test_feature

  UNION ALL

  SELECT
    'amc_core.ecg_measurement_test_feature'::text            AS table_name,
    'ecg_decrease_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(ecg_decrease_date_time)::text        AS min_value,
    MAX(ecg_decrease_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE ecg_decrease_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE ecg_decrease_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ecg_measurement_test_feature

  UNION ALL

  SELECT
    'amc_core.ecg_measurement_test_feature'::text            AS table_name,
    'ecg_decrease_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(ecg_decrease_time)::text        AS min_value,
    MAX(ecg_decrease_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE ecg_decrease_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE ecg_decrease_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ecg_measurement_test_feature

  UNION ALL

  SELECT
    'amc_core.ecg_measurement_test_feature'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ecg_measurement_test_feature

  UNION ALL

  SELECT
    'amc_core.echo_measurement_heart'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.echo_measurement_heart

  UNION ALL

  SELECT
    'amc_core.echo_measurement_heart'::text            AS table_name,
    'end_time_of_examination'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(end_time_of_examination)::text        AS min_value,
    MAX(end_time_of_examination)::text        AS max_value,
    COUNT(*) FILTER (WHERE end_time_of_examination IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_time_of_examination IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.echo_measurement_heart

  UNION ALL

  SELECT
    'amc_core.echo_measurement_heart'::text            AS table_name,
    'examination_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(examination_date)::text        AS min_value,
    MAX(examination_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE examination_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE examination_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.echo_measurement_heart

  UNION ALL

  SELECT
    'amc_core.echo_measurement_heart'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.echo_measurement_heart

  UNION ALL

  SELECT
    'amc_core.family_history'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.family_history

  UNION ALL

  SELECT
    'amc_core.family_history'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.family_history

  UNION ALL

  SELECT
    'amc_core.family_history'::text            AS table_name,
    'registration_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(registration_date)::text        AS min_value,
    MAX(registration_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE registration_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE registration_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.family_history

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_bronchoscopy'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_bronchoscopy

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_bronchoscopy'::text            AS table_name,
    'intervention_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(intervention_date_time)::text        AS min_value,
    MAX(intervention_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE intervention_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE intervention_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_bronchoscopy

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_bronchoscopy'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_bronchoscopy

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_central_venous_catheter'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_central_venous_catheter

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_central_venous_catheter'::text            AS table_name,
    'end_procedure'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(end_procedure)::text        AS min_value,
    MAX(end_procedure)::text        AS max_value,
    COUNT(*) FILTER (WHERE end_procedure IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_procedure IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_central_venous_catheter

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_central_venous_catheter'::text            AS table_name,
    'end_sedation'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(end_sedation)::text        AS min_value,
    MAX(end_sedation)::text        AS max_value,
    COUNT(*) FILTER (WHERE end_sedation IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_sedation IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_central_venous_catheter

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_central_venous_catheter'::text            AS table_name,
    'intervention_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(intervention_date_time)::text        AS min_value,
    MAX(intervention_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE intervention_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE intervention_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_central_venous_catheter

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_central_venous_catheter'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_central_venous_catheter

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_central_venous_catheter'::text            AS table_name,
    'start_procedure'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(start_procedure)::text        AS min_value,
    MAX(start_procedure)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_procedure IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_procedure IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_central_venous_catheter

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_central_venous_catheter'::text            AS table_name,
    'start_sedation'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(start_sedation)::text        AS min_value,
    MAX(start_sedation)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_sedation IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_sedation IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_central_venous_catheter

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_electric_cardioversion'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_electric_cardioversion

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_electric_cardioversion'::text            AS table_name,
    'end_procedure'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(end_procedure)::text        AS min_value,
    MAX(end_procedure)::text        AS max_value,
    COUNT(*) FILTER (WHERE end_procedure IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_procedure IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_electric_cardioversion

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_electric_cardioversion'::text            AS table_name,
    'end_sedation'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(end_sedation)::text        AS min_value,
    MAX(end_sedation)::text        AS max_value,
    COUNT(*) FILTER (WHERE end_sedation IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_sedation IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_electric_cardioversion

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_electric_cardioversion'::text            AS table_name,
    'intervention_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(intervention_date_time)::text        AS min_value,
    MAX(intervention_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE intervention_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE intervention_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_electric_cardioversion

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_electric_cardioversion'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_electric_cardioversion

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_electric_cardioversion'::text            AS table_name,
    'start_procedure'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(start_procedure)::text        AS min_value,
    MAX(start_procedure)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_procedure IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_procedure IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_electric_cardioversion

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_electric_cardioversion'::text            AS table_name,
    'start_sedation'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(start_sedation)::text        AS min_value,
    MAX(start_sedation)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_sedation IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_sedation IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_electric_cardioversion

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_icarus'::text            AS table_name,
    'date_time_authorization'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(date_time_authorization)::text        AS min_value,
    MAX(date_time_authorization)::text        AS max_value,
    COUNT(*) FILTER (WHERE date_time_authorization IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE date_time_authorization IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_icarus

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_icarus'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_icarus

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_icarus'::text            AS table_name,
    'intervention_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(intervention_date_time)::text        AS min_value,
    MAX(intervention_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE intervention_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE intervention_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_icarus

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_icarus'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_icarus

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_intubation'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_intubation

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_intubation'::text            AS table_name,
    'intervention_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(intervention_date_time)::text        AS min_value,
    MAX(intervention_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE intervention_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE intervention_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_intubation

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_intubation'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_intubation

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_thorax_drain'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_thorax_drain

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_thorax_drain'::text            AS table_name,
    'end_sedation'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(end_sedation)::text        AS min_value,
    MAX(end_sedation)::text        AS max_value,
    COUNT(*) FILTER (WHERE end_sedation IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_sedation IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_thorax_drain

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_thorax_drain'::text            AS table_name,
    'intervention_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(intervention_date_time)::text        AS min_value,
    MAX(intervention_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE intervention_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE intervention_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_thorax_drain

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_thorax_drain'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_thorax_drain

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_thorax_drain'::text            AS table_name,
    'start_procedure'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(start_procedure)::text        AS min_value,
    MAX(start_procedure)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_procedure IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_procedure IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_thorax_drain

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_thorax_drain'::text            AS table_name,
    'start_sedation'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(start_sedation)::text        AS min_value,
    MAX(start_sedation)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_sedation IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_sedation IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_thorax_drain

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_tracheostomy'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_tracheostomy

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_tracheostomy'::text            AS table_name,
    'intervention_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(intervention_date_time)::text        AS min_value,
    MAX(intervention_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE intervention_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE intervention_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_tracheostomy

  UNION ALL

  SELECT
    'amc_core.ic_procedure_note_tracheostomy'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ic_procedure_note_tracheostomy

  UNION ALL

  SELECT
    'amc_core.imaging_study_order'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.imaging_study_order

  UNION ALL

  SELECT
    'amc_core.imaging_study_order'::text            AS table_name,
    'end_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(end_date)::text        AS min_value,
    MAX(end_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE end_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.imaging_study_order

  UNION ALL

  SELECT
    'amc_core.imaging_study_order'::text            AS table_name,
    'end_moment'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(end_moment)::text        AS min_value,
    MAX(end_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE end_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.imaging_study_order

  UNION ALL

  SELECT
    'amc_core.imaging_study_order'::text            AS table_name,
    'end_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(end_time)::text        AS min_value,
    MAX(end_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE end_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.imaging_study_order

  UNION ALL

  SELECT
    'amc_core.imaging_study_order'::text            AS table_name,
    'final_report_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(final_report_date_time)::text        AS min_value,
    MAX(final_report_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE final_report_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE final_report_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.imaging_study_order

  UNION ALL

  SELECT
    'amc_core.imaging_study_order'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.imaging_study_order

  UNION ALL

  SELECT
    'amc_core.imaging_study_order'::text            AS table_name,
    'start_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(start_date)::text        AS min_value,
    MAX(start_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.imaging_study_order

  UNION ALL

  SELECT
    'amc_core.imaging_study_order'::text            AS table_name,
    'start_moment'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(start_moment)::text        AS min_value,
    MAX(start_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.imaging_study_order

  UNION ALL

  SELECT
    'amc_core.imaging_study_order'::text            AS table_name,
    'start_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(start_time)::text        AS min_value,
    MAX(start_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.imaging_study_order

  UNION ALL

  SELECT
    'amc_core.lab_result'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.lab_result

  UNION ALL

  SELECT
    'amc_core.lab_result'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.lab_result

  UNION ALL

  SELECT
    'amc_core.lab_result'::text            AS table_name,
    'material_decrease_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(material_decrease_date)::text        AS min_value,
    MAX(material_decrease_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE material_decrease_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE material_decrease_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.lab_result

  UNION ALL

  SELECT
    'amc_core.lab_result'::text            AS table_name,
    'material_decrease_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(material_decrease_date_time)::text        AS min_value,
    MAX(material_decrease_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE material_decrease_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE material_decrease_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.lab_result

  UNION ALL

  SELECT
    'amc_core.lab_result'::text            AS table_name,
    'material_decrease_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(material_decrease_time)::text        AS min_value,
    MAX(material_decrease_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE material_decrease_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE material_decrease_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.lab_result

  UNION ALL

  SELECT
    'amc_core.lab_result'::text            AS table_name,
    'result_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(result_date)::text        AS min_value,
    MAX(result_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE result_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE result_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.lab_result

  UNION ALL

  SELECT
    'amc_core.lab_result'::text            AS table_name,
    'result_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(result_date_time)::text        AS min_value,
    MAX(result_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE result_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE result_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.lab_result

  UNION ALL

  SELECT
    'amc_core.lab_result'::text            AS table_name,
    'result_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(result_time)::text        AS min_value,
    MAX(result_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE result_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE result_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.lab_result

  UNION ALL

  SELECT
    'amc_core.measurement_blood_pressure'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_blood_pressure

  UNION ALL

  SELECT
    'amc_core.measurement_blood_pressure'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_blood_pressure

  UNION ALL

  SELECT
    'amc_core.measurement_blood_pressure'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_blood_pressure

  UNION ALL

  SELECT
    'amc_core.measurement_blood_pressure'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_blood_pressure

  UNION ALL

  SELECT
    'amc_core.measurement_blood_pressure'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_blood_pressure

  UNION ALL

  SELECT
    'amc_core.measurement_blood_pressure_average'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_blood_pressure_average

  UNION ALL

  SELECT
    'amc_core.measurement_blood_pressure_average'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_blood_pressure_average

  UNION ALL

  SELECT
    'amc_core.measurement_blood_pressure_average'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_blood_pressure_average

  UNION ALL

  SELECT
    'amc_core.measurement_blood_pressure_average'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_blood_pressure_average

  UNION ALL

  SELECT
    'amc_core.measurement_blood_pressure_average'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_blood_pressure_average

  UNION ALL

  SELECT
    'amc_core.measurement_bmi'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_bmi

  UNION ALL

  SELECT
    'amc_core.measurement_bmi'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_bmi

  UNION ALL

  SELECT
    'amc_core.measurement_bmi'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_bmi

  UNION ALL

  SELECT
    'amc_core.measurement_bmi'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_bmi

  UNION ALL

  SELECT
    'amc_core.measurement_bmi'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_bmi

  UNION ALL

  SELECT
    'amc_core.measurement_chadsvasc_score'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_chadsvasc_score

  UNION ALL

  SELECT
    'amc_core.measurement_chadsvasc_score'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_chadsvasc_score

  UNION ALL

  SELECT
    'amc_core.measurement_chadsvasc_score'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_chadsvasc_score

  UNION ALL

  SELECT
    'amc_core.measurement_chadsvasc_score'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_chadsvasc_score

  UNION ALL

  SELECT
    'amc_core.measurement_chadsvasc_score'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_chadsvasc_score

  UNION ALL

  SELECT
    'amc_core.measurement_diurese'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_diurese

  UNION ALL

  SELECT
    'amc_core.measurement_diurese'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_diurese

  UNION ALL

  SELECT
    'amc_core.measurement_diurese'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_diurese

  UNION ALL

  SELECT
    'amc_core.measurement_diurese'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_diurese

  UNION ALL

  SELECT
    'amc_core.measurement_diurese'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_diurese

  UNION ALL

  SELECT
    'amc_core.measurement_doss_score'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_doss_score

  UNION ALL

  SELECT
    'amc_core.measurement_doss_score'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_doss_score

  UNION ALL

  SELECT
    'amc_core.measurement_doss_score'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_doss_score

  UNION ALL

  SELECT
    'amc_core.measurement_doss_score'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_doss_score

  UNION ALL

  SELECT
    'amc_core.measurement_doss_score'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_doss_score

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_assessment_diuresis'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_assessment_diuresis

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_assessment_diuresis'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_assessment_diuresis

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_assessment_diuresis'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_assessment_diuresis

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_assessment_diuresis'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_assessment_diuresis

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_assessment_diuresis'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_assessment_diuresis

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_assessment_emesis'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_assessment_emesis

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_assessment_emesis'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_assessment_emesis

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_assessment_emesis'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_assessment_emesis

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_assessment_emesis'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_assessment_emesis

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_assessment_emesis'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_assessment_emesis

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_assessment_feces'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_assessment_feces

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_assessment_feces'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_assessment_feces

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_assessment_feces'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_assessment_feces

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_assessment_feces'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_assessment_feces

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_assessment_feces'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_assessment_feces

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_out'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_out

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_out'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_out

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_out'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_out

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_out'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_out

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_out'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_out

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_stomach_retention'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_stomach_retention

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_stomach_retention'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_stomach_retention

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_stomach_retention'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_stomach_retention

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_stomach_retention'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_stomach_retention

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_balance_stomach_retention'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_balance_stomach_retention

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_in'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_in

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_in'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_in

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_in'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_in

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_in'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_in

  UNION ALL

  SELECT
    'amc_core.measurement_fluid_in'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_fluid_in

  UNION ALL

  SELECT
    'amc_core.measurement_heart_frequency'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_heart_frequency

  UNION ALL

  SELECT
    'amc_core.measurement_heart_frequency'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_heart_frequency

  UNION ALL

  SELECT
    'amc_core.measurement_heart_frequency'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_heart_frequency

  UNION ALL

  SELECT
    'amc_core.measurement_heart_frequency'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_heart_frequency

  UNION ALL

  SELECT
    'amc_core.measurement_heart_frequency'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_heart_frequency

  UNION ALL

  SELECT
    'amc_core.measurement_height'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_height

  UNION ALL

  SELECT
    'amc_core.measurement_height'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_height

  UNION ALL

  SELECT
    'amc_core.measurement_height'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_height

  UNION ALL

  SELECT
    'amc_core.measurement_height'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_height

  UNION ALL

  SELECT
    'amc_core.measurement_height'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_height

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_cntv_medication'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_cntv_medication

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_cntv_medication'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_cntv_medication

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_cntv_medication'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_cntv_medication

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_cntv_medication'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_cntv_medication

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_cntv_medication'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_cntv_medication

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_cnvt_settings'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_cnvt_settings

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_cnvt_settings'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_cnvt_settings

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_cnvt_settings'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_cnvt_settings

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_cnvt_settings'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_cnvt_settings

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_cnvt_settings'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_cnvt_settings

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_hemodialysis'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_hemodialysis

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_hemodialysis'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_hemodialysis

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_hemodialysis'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_hemodialysis

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_hemodialysis'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_hemodialysis

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_hemodialysis'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_hemodialysis

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_peritoneal_dialysis'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_peritoneal_dialysis

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_peritoneal_dialysis'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_peritoneal_dialysis

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_peritoneal_dialysis'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_peritoneal_dialysis

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_peritoneal_dialysis'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_peritoneal_dialysis

  UNION ALL

  SELECT
    'amc_core.measurement_nephrology_peritoneal_dialysis'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_nephrology_peritoneal_dialysis

  UNION ALL

  SELECT
    'amc_core.measurement_o2_saturation'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_o2_saturation

  UNION ALL

  SELECT
    'amc_core.measurement_o2_saturation'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_o2_saturation

  UNION ALL

  SELECT
    'amc_core.measurement_o2_saturation'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_o2_saturation

  UNION ALL

  SELECT
    'amc_core.measurement_o2_saturation'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_o2_saturation

  UNION ALL

  SELECT
    'amc_core.measurement_o2_saturation'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_o2_saturation

  UNION ALL

  SELECT
    'amc_core.measurement_snaq_score'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_snaq_score

  UNION ALL

  SELECT
    'amc_core.measurement_snaq_score'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_snaq_score

  UNION ALL

  SELECT
    'amc_core.measurement_snaq_score'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_snaq_score

  UNION ALL

  SELECT
    'amc_core.measurement_snaq_score'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_snaq_score

  UNION ALL

  SELECT
    'amc_core.measurement_snaq_score'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_snaq_score

  UNION ALL

  SELECT
    'amc_core.measurement_vital_signs_data'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_vital_signs_data

  UNION ALL

  SELECT
    'amc_core.measurement_vital_signs_data'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_vital_signs_data

  UNION ALL

  SELECT
    'amc_core.measurement_vital_signs_data'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_vital_signs_data

  UNION ALL

  SELECT
    'amc_core.measurement_vital_signs_data'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_vital_signs_data

  UNION ALL

  SELECT
    'amc_core.measurement_vital_signs_data'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_vital_signs_data

  UNION ALL

  SELECT
    'amc_core.measurement_weight'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_weight

  UNION ALL

  SELECT
    'amc_core.measurement_weight'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_weight

  UNION ALL

  SELECT
    'amc_core.measurement_weight'::text            AS table_name,
    'measurement_moment'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(measurement_moment)::text        AS min_value,
    MAX(measurement_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE measurement_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE measurement_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_weight

  UNION ALL

  SELECT
    'amc_core.measurement_weight'::text            AS table_name,
    'meet_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(meet_date)::text        AS min_value,
    MAX(meet_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_weight

  UNION ALL

  SELECT
    'amc_core.measurement_weight'::text            AS table_name,
    'meet_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(meet_time)::text        AS min_value,
    MAX(meet_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE meet_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE meet_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.measurement_weight

  UNION ALL

  SELECT
    'amc_core.medical_diagnosis'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medical_diagnosis

  UNION ALL

  SELECT
    'amc_core.medical_diagnosis'::text            AS table_name,
    'diagnosis_contact_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(diagnosis_contact_date)::text        AS min_value,
    MAX(diagnosis_contact_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE diagnosis_contact_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE diagnosis_contact_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medical_diagnosis

  UNION ALL

  SELECT
    'amc_core.medical_diagnosis'::text            AS table_name,
    'diagnosis_registration_moment'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(diagnosis_registration_moment)::text        AS min_value,
    MAX(diagnosis_registration_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE diagnosis_registration_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE diagnosis_registration_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medical_diagnosis

  UNION ALL

  SELECT
    'amc_core.medical_diagnosis'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medical_diagnosis

  UNION ALL

  SELECT
    'amc_core.medical_history'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medical_history

  UNION ALL

  SELECT
    'amc_core.medical_history'::text            AS table_name,
    'indication_determination_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(indication_determination_date)::text        AS min_value,
    MAX(indication_determination_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE indication_determination_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE indication_determination_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medical_history

  UNION ALL

  SELECT
    'amc_core.medical_history'::text            AS table_name,
    'indication_determination_date_raw'::text           AS column_name,
    'text'::text        AS declared_type,
    MIN(indication_determination_date_raw)::text        AS min_value,
    MAX(indication_determination_date_raw)::text        AS max_value,
    COUNT(*) FILTER (WHERE indication_determination_date_raw IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE indication_determination_date_raw IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medical_history

  UNION ALL

  SELECT
    'amc_core.medical_history'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medical_history

  UNION ALL

  SELECT
    'amc_core.medical_history'::text            AS table_name,
    'registration_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(registration_date)::text        AS min_value,
    MAX(registration_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE registration_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE registration_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medical_history

  UNION ALL

  SELECT
    'amc_core.medication_administration'::text            AS table_name,
    'administration_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(administration_date)::text        AS min_value,
    MAX(administration_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE administration_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE administration_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_administration

  UNION ALL

  SELECT
    'amc_core.medication_administration'::text            AS table_name,
    'administration_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(administration_date_time)::text        AS min_value,
    MAX(administration_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE administration_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE administration_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_administration

  UNION ALL

  SELECT
    'amc_core.medication_administration'::text            AS table_name,
    'administration_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(administration_time)::text        AS min_value,
    MAX(administration_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE administration_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE administration_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_administration

  UNION ALL

  SELECT
    'amc_core.medication_administration'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_administration

  UNION ALL

  SELECT
    'amc_core.medication_administration'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_administration

  UNION ALL

  SELECT
    'amc_core.medication_atc'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_atc

  UNION ALL

  SELECT
    'amc_core.medication_atc'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_atc

  UNION ALL

  SELECT
    'amc_core.medication_prescription'::text            AS table_name,
    'corrected_stop_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(corrected_stop_date)::text        AS min_value,
    MAX(corrected_stop_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE corrected_stop_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE corrected_stop_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_prescription

  UNION ALL

  SELECT
    'amc_core.medication_prescription'::text            AS table_name,
    'corrected_stop_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(corrected_stop_date_time)::text        AS min_value,
    MAX(corrected_stop_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE corrected_stop_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE corrected_stop_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_prescription

  UNION ALL

  SELECT
    'amc_core.medication_prescription'::text            AS table_name,
    'corrected_stop_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(corrected_stop_time)::text        AS min_value,
    MAX(corrected_stop_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE corrected_stop_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE corrected_stop_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_prescription

  UNION ALL

  SELECT
    'amc_core.medication_prescription'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_prescription

  UNION ALL

  SELECT
    'amc_core.medication_prescription'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_prescription

  UNION ALL

  SELECT
    'amc_core.medication_prescription'::text            AS table_name,
    'prescription_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(prescription_date)::text        AS min_value,
    MAX(prescription_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE prescription_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE prescription_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_prescription

  UNION ALL

  SELECT
    'amc_core.medication_prescription'::text            AS table_name,
    'prescription_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(prescription_date_time)::text        AS min_value,
    MAX(prescription_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE prescription_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE prescription_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_prescription

  UNION ALL

  SELECT
    'amc_core.medication_prescription'::text            AS table_name,
    'prescription_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(prescription_time)::text        AS min_value,
    MAX(prescription_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE prescription_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE prescription_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_prescription

  UNION ALL

  SELECT
    'amc_core.medication_prescription'::text            AS table_name,
    'start_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(start_date)::text        AS min_value,
    MAX(start_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_prescription

  UNION ALL

  SELECT
    'amc_core.medication_prescription'::text            AS table_name,
    'start_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(start_date_time)::text        AS min_value,
    MAX(start_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_prescription

  UNION ALL

  SELECT
    'amc_core.medication_prescription'::text            AS table_name,
    'start_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(start_time)::text        AS min_value,
    MAX(start_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_prescription

  UNION ALL

  SELECT
    'amc_core.medication_prescription'::text            AS table_name,
    'stop_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(stop_date)::text        AS min_value,
    MAX(stop_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE stop_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE stop_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_prescription

  UNION ALL

  SELECT
    'amc_core.medication_prescription'::text            AS table_name,
    'stop_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(stop_date_time)::text        AS min_value,
    MAX(stop_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE stop_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE stop_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_prescription

  UNION ALL

  SELECT
    'amc_core.medication_prescription'::text            AS table_name,
    'stop_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(stop_time)::text        AS min_value,
    MAX(stop_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE stop_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE stop_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.medication_prescription

  UNION ALL

  SELECT
    'amc_core.ok_procedure_performed'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ok_procedure_performed

  UNION ALL

  SELECT
    'amc_core.ok_procedure_performed'::text            AS table_name,
    'intervention_executed_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(intervention_executed_date)::text        AS min_value,
    MAX(intervention_executed_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE intervention_executed_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE intervention_executed_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ok_procedure_performed

  UNION ALL

  SELECT
    'amc_core.ok_procedure_performed'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ok_procedure_performed

  UNION ALL

  SELECT
    'amc_core.ok_procedure_performed'::text            AS table_name,
    'session_start_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(session_start_date)::text        AS min_value,
    MAX(session_start_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE session_start_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE session_start_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ok_procedure_performed

  UNION ALL

  SELECT
    'amc_core.ok_procedure_performed'::text            AS table_name,
    'session_start_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(session_start_date_time)::text        AS min_value,
    MAX(session_start_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE session_start_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE session_start_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ok_procedure_performed

  UNION ALL

  SELECT
    'amc_core.ok_procedure_planned'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ok_procedure_planned

  UNION ALL

  SELECT
    'amc_core.ok_procedure_planned'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ok_procedure_planned

  UNION ALL

  SELECT
    'amc_core.ok_procedure_planned'::text            AS table_name,
    'session_planned_start_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(session_planned_start_date)::text        AS min_value,
    MAX(session_planned_start_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE session_planned_start_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE session_planned_start_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.ok_procedure_planned

  UNION ALL

  SELECT
    'amc_core.patient_appointment'::text            AS table_name,
    'appointment_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(appointment_date)::text        AS min_value,
    MAX(appointment_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE appointment_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE appointment_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment

  UNION ALL

  SELECT
    'amc_core.patient_appointment'::text            AS table_name,
    'appointment_end_moment'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(appointment_end_moment)::text        AS min_value,
    MAX(appointment_end_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE appointment_end_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE appointment_end_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment

  UNION ALL

  SELECT
    'amc_core.patient_appointment'::text            AS table_name,
    'appointment_made_at_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(appointment_made_at_date_time)::text        AS min_value,
    MAX(appointment_made_at_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE appointment_made_at_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE appointment_made_at_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment

  UNION ALL

  SELECT
    'amc_core.patient_appointment'::text            AS table_name,
    'appointment_start_moment'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(appointment_start_moment)::text        AS min_value,
    MAX(appointment_start_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE appointment_start_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE appointment_start_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment

  UNION ALL

  SELECT
    'amc_core.patient_appointment'::text            AS table_name,
    'appointment_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(appointment_time)::text        AS min_value,
    MAX(appointment_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE appointment_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE appointment_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment

  UNION ALL

  SELECT
    'amc_core.patient_appointment'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment

  UNION ALL

  SELECT
    'amc_core.patient_appointment'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment

  UNION ALL

  SELECT
    'amc_core.patient_appointment'::text            AS table_name,
    'order_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(order_date)::text        AS min_value,
    MAX(order_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE order_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment

  UNION ALL

  SELECT
    'amc_core.patient_appointment'::text            AS table_name,
    'order_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(order_time)::text        AS min_value,
    MAX(order_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE order_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE order_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment

  UNION ALL

  SELECT
    'amc_core.patient_appointment_line'::text            AS table_name,
    'appointment_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(appointment_date)::text        AS min_value,
    MAX(appointment_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE appointment_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE appointment_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment_line

  UNION ALL

  SELECT
    'amc_core.patient_appointment_line'::text            AS table_name,
    'appointment_end_moment'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(appointment_end_moment)::text        AS min_value,
    MAX(appointment_end_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE appointment_end_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE appointment_end_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment_line

  UNION ALL

  SELECT
    'amc_core.patient_appointment_line'::text            AS table_name,
    'appointment_made_at_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(appointment_made_at_date_time)::text        AS min_value,
    MAX(appointment_made_at_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE appointment_made_at_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE appointment_made_at_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment_line

  UNION ALL

  SELECT
    'amc_core.patient_appointment_line'::text            AS table_name,
    'appointment_start_moment'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(appointment_start_moment)::text        AS min_value,
    MAX(appointment_start_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE appointment_start_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE appointment_start_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment_line

  UNION ALL

  SELECT
    'amc_core.patient_appointment_line'::text            AS table_name,
    'appointment_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(appointment_time)::text        AS min_value,
    MAX(appointment_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE appointment_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE appointment_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment_line

  UNION ALL

  SELECT
    'amc_core.patient_appointment_line'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment_line

  UNION ALL

  SELECT
    'amc_core.patient_appointment_line'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment_line

  UNION ALL

  SELECT
    'amc_core.patient_appointment_line'::text            AS table_name,
    'order_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(order_date)::text        AS min_value,
    MAX(order_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE order_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment_line

  UNION ALL

  SELECT
    'amc_core.patient_appointment_line'::text            AS table_name,
    'order_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(order_time)::text        AS min_value,
    MAX(order_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE order_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE order_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_appointment_line

  UNION ALL

  SELECT
    'amc_core.patient_contact'::text            AS table_name,
    'abnormal_date'::text           AS column_name,
    'int'::text        AS declared_type,
    MIN(abnormal_date)::text        AS min_value,
    MAX(abnormal_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE abnormal_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE abnormal_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_contact'::text            AS table_name,
    'cancellation_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(cancellation_date)::text        AS min_value,
    MAX(cancellation_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE cancellation_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE cancellation_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_contact'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_contact'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_contact'::text            AS table_name,
    'patient_contact_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(patient_contact_date)::text        AS min_value,
    MAX(patient_contact_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE patient_contact_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE patient_contact_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_contact'::text            AS table_name,
    'patient_contact_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(patient_contact_date_time)::text        AS min_value,
    MAX(patient_contact_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE patient_contact_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE patient_contact_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_contact'::text            AS table_name,
    'patient_contact_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(patient_contact_time)::text        AS min_value,
    MAX(patient_contact_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE patient_contact_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE patient_contact_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_not_traceable'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_not_traceable

  UNION ALL

  SELECT
    'amc_core.patient_not_traceable'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_not_traceable

  UNION ALL

  SELECT
    'amc_core.patient_note_contains_sensitive_information'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_note_contains_sensitive_information

  UNION ALL

  SELECT
    'amc_core.patient_note_contains_sensitive_information'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_note_contains_sensitive_information

  UNION ALL

  SELECT
    'amc_core.patient_note_contains_sensitive_information'::text            AS table_name,
    'last_changed_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(last_changed_date)::text        AS min_value,
    MAX(last_changed_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE last_changed_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE last_changed_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_note_contains_sensitive_information

  UNION ALL

  SELECT
    'amc_core.patient_note_contains_sensitive_information'::text            AS table_name,
    'note_made_at_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(note_made_at_time)::text        AS min_value,
    MAX(note_made_at_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE note_made_at_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE note_made_at_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_note_contains_sensitive_information

  UNION ALL

  SELECT
    'amc_core.patient_note_contains_sensitive_information'::text            AS table_name,
    'note_made_on_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(note_made_on_date)::text        AS min_value,
    MAX(note_made_on_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE note_made_on_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE note_made_on_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_note_contains_sensitive_information

  UNION ALL

  SELECT
    'amc_core.patient_note_patient_contact'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_note_patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_note_patient_contact'::text            AS table_name,
    'entry_instant_local_dttm'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(entry_instant_local_dttm)::text        AS min_value,
    MAX(entry_instant_local_dttm)::text        AS max_value,
    COUNT(*) FILTER (WHERE entry_instant_local_dttm IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE entry_instant_local_dttm IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_note_patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_note_patient_contact'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_note_patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_note_patient_contact'::text            AS table_name,
    'note_file_time_local_dttm'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(note_file_time_local_dttm)::text        AS min_value,
    MAX(note_file_time_local_dttm)::text        AS max_value,
    COUNT(*) FILTER (WHERE note_file_time_local_dttm IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE note_file_time_local_dttm IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_note_patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_note_patient_contact'::text            AS table_name,
    'note_made_at_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(note_made_at_date_time)::text        AS min_value,
    MAX(note_made_at_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE note_made_at_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE note_made_at_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_note_patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_note_patient_contact'::text            AS table_name,
    'note_made_at_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(note_made_at_time)::text        AS min_value,
    MAX(note_made_at_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE note_made_at_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE note_made_at_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_note_patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_note_patient_contact'::text            AS table_name,
    'note_made_on_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(note_made_on_date)::text        AS min_value,
    MAX(note_made_on_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE note_made_on_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE note_made_on_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_note_patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_note_patient_contact'::text            AS table_name,
    'patient_contact_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(patient_contact_date_time)::text        AS min_value,
    MAX(patient_contact_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE patient_contact_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE patient_contact_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_note_patient_contact

  UNION ALL

  SELECT
    'amc_core.patient_questionnaire'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_questionnaire

  UNION ALL

  SELECT
    'amc_core.patient_questionnaire'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_questionnaire

  UNION ALL

  SELECT
    'amc_core.patient_questionnaire'::text            AS table_name,
    'reply_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(reply_date)::text        AS min_value,
    MAX(reply_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE reply_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE reply_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_questionnaire

  UNION ALL

  SELECT
    'amc_core.patient_questionnaire'::text            AS table_name,
    'reply_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(reply_date_time)::text        AS min_value,
    MAX(reply_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE reply_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE reply_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_questionnaire

  UNION ALL

  SELECT
    'amc_core.patient_questionnaire'::text            AS table_name,
    'reply_time'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(reply_time)::text        AS min_value,
    MAX(reply_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE reply_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE reply_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_questionnaire

  UNION ALL

  SELECT
    'amc_core.patient_social'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_social

  UNION ALL

  SELECT
    'amc_core.patient_social'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.patient_social

  UNION ALL

  SELECT
    'amc_core.problem_list'::text            AS table_name,
    'close_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(close_date)::text        AS min_value,
    MAX(close_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE close_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE close_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.problem_list

  UNION ALL

  SELECT
    'amc_core.problem_list'::text            AS table_name,
    'corrected_close_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(corrected_close_date)::text        AS min_value,
    MAX(corrected_close_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE corrected_close_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE corrected_close_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.problem_list

  UNION ALL

  SELECT
    'amc_core.problem_list'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.problem_list

  UNION ALL

  SELECT
    'amc_core.problem_list'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.problem_list

  UNION ALL

  SELECT
    'amc_core.problem_list'::text            AS table_name,
    'observation_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(observation_date)::text        AS min_value,
    MAX(observation_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE observation_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE observation_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.problem_list

  UNION ALL

  SELECT
    'amc_core.problem_list'::text            AS table_name,
    'patient_contact_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(patient_contact_date)::text        AS min_value,
    MAX(patient_contact_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE patient_contact_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE patient_contact_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.problem_list

  UNION ALL

  SELECT
    'amc_core.problem_list'::text            AS table_name,
    'patient_contact_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(patient_contact_date_time)::text        AS min_value,
    MAX(patient_contact_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE patient_contact_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE patient_contact_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.problem_list

  UNION ALL

  SELECT
    'amc_core.problem_list'::text            AS table_name,
    'registration_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(registration_date)::text        AS min_value,
    MAX(registration_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE registration_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE registration_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.problem_list

  UNION ALL

  SELECT
    'amc_core.procedures'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.procedures

  UNION ALL

  SELECT
    'amc_core.procedures'::text            AS table_name,
    'intervention_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(intervention_date)::text        AS min_value,
    MAX(intervention_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE intervention_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE intervention_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.procedures

  UNION ALL

  SELECT
    'amc_core.procedures'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.procedures

  UNION ALL

  SELECT
    'amc_core.seh_trajectory'::text            AS table_name,
    'corrected_seh_departure_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(corrected_seh_departure_date)::text        AS min_value,
    MAX(corrected_seh_departure_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE corrected_seh_departure_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE corrected_seh_departure_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.seh_trajectory

  UNION ALL

  SELECT
    'amc_core.seh_trajectory'::text            AS table_name,
    'corrected_seh_departure_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(corrected_seh_departure_date_time)::text        AS min_value,
    MAX(corrected_seh_departure_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE corrected_seh_departure_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE corrected_seh_departure_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.seh_trajectory

  UNION ALL

  SELECT
    'amc_core.seh_trajectory'::text            AS table_name,
    'corrected_seh_departure_moment'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(corrected_seh_departure_moment)::text        AS min_value,
    MAX(corrected_seh_departure_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE corrected_seh_departure_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE corrected_seh_departure_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.seh_trajectory

  UNION ALL

  SELECT
    'amc_core.seh_trajectory'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.seh_trajectory

  UNION ALL

  SELECT
    'amc_core.seh_trajectory'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.seh_trajectory

  UNION ALL

  SELECT
    'amc_core.seh_trajectory'::text            AS table_name,
    'patient_arrived_at_seh_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(patient_arrived_at_seh_date_time)::text        AS min_value,
    MAX(patient_arrived_at_seh_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE patient_arrived_at_seh_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE patient_arrived_at_seh_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.seh_trajectory

  UNION ALL

  SELECT
    'amc_core.seh_trajectory'::text            AS table_name,
    'seh_admission_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(seh_admission_date)::text        AS min_value,
    MAX(seh_admission_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE seh_admission_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE seh_admission_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.seh_trajectory

  UNION ALL

  SELECT
    'amc_core.seh_trajectory'::text            AS table_name,
    'seh_admission_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(seh_admission_date_time)::text        AS min_value,
    MAX(seh_admission_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE seh_admission_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE seh_admission_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.seh_trajectory

  UNION ALL

  SELECT
    'amc_core.seh_trajectory'::text            AS table_name,
    'seh_admission_moment'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(seh_admission_moment)::text        AS min_value,
    MAX(seh_admission_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE seh_admission_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE seh_admission_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.seh_trajectory

  UNION ALL

  SELECT
    'amc_core.seh_trajectory'::text            AS table_name,
    'seh_departure_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(seh_departure_date)::text        AS min_value,
    MAX(seh_departure_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE seh_departure_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE seh_departure_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.seh_trajectory

  UNION ALL

  SELECT
    'amc_core.seh_trajectory'::text            AS table_name,
    'seh_departure_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(seh_departure_date_time)::text        AS min_value,
    MAX(seh_departure_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE seh_departure_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE seh_departure_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.seh_trajectory

  UNION ALL

  SELECT
    'amc_core.seh_trajectory'::text            AS table_name,
    'seh_departure_moment'::text           AS column_name,
    'time'::text        AS declared_type,
    MIN(seh_departure_moment)::text        AS min_value,
    MAX(seh_departure_moment)::text        AS max_value,
    COUNT(*) FILTER (WHERE seh_departure_moment IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE seh_departure_moment IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.seh_trajectory

  UNION ALL

  SELECT
    'amc_core.seh_trajectory'::text            AS table_name,
    'urgent_contact_created_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(urgent_contact_created_date_time)::text        AS min_value,
    MAX(urgent_contact_created_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE urgent_contact_created_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE urgent_contact_created_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.seh_trajectory

  UNION ALL

  SELECT
    'amc_core.surgery_history'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.surgery_history

  UNION ALL

  SELECT
    'amc_core.surgery_history'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.surgery_history

  UNION ALL

  SELECT
    'amc_core.surgery_history'::text            AS table_name,
    'procedure_end_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(procedure_end_date)::text        AS min_value,
    MAX(procedure_end_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE procedure_end_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE procedure_end_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.surgery_history

  UNION ALL

  SELECT
    'amc_core.surgery_history'::text            AS table_name,
    'procedure_start_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(procedure_start_date)::text        AS min_value,
    MAX(procedure_start_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE procedure_start_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE procedure_start_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.surgery_history

  UNION ALL

  SELECT
    'amc_core.surgery_history'::text            AS table_name,
    'registration_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(registration_date)::text        AS min_value,
    MAX(registration_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE registration_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE registration_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.surgery_history

  UNION ALL

  SELECT
    'amc_core.tobacco_use'::text            AS table_name,
    'dcm_refreshed_date_time'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(dcm_refreshed_date_time)::text        AS min_value,
    MAX(dcm_refreshed_date_time)::text        AS max_value,
    COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE dcm_refreshed_date_time IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.tobacco_use

  UNION ALL

  SELECT
    'amc_core.tobacco_use'::text            AS table_name,
    'issue_dt'::text           AS column_name,
    'timestamptz'::text        AS declared_type,
    MIN(issue_dt)::text        AS min_value,
    MAX(issue_dt)::text        AS max_value,
    COUNT(*) FILTER (WHERE issue_dt IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE issue_dt IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.tobacco_use

  UNION ALL

  SELECT
    'amc_core.tobacco_use'::text            AS table_name,
    'registration_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(registration_date)::text        AS min_value,
    MAX(registration_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE registration_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE registration_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.tobacco_use

  UNION ALL

  SELECT
    'amc_core.tobacco_use'::text            AS table_name,
    'start_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(start_date)::text        AS min_value,
    MAX(start_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE start_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.tobacco_use

  UNION ALL

  SELECT
    'amc_core.tobacco_use'::text            AS table_name,
    'stop_date'::text           AS column_name,
    'date'::text        AS declared_type,
    MIN(stop_date)::text        AS min_value,
    MAX(stop_date)::text        AS max_value,
    COUNT(*) FILTER (WHERE stop_date IS NULL) AS null_count,
    COUNT(*)                   AS total_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE stop_date IS NULL)
      / NULLIF(COUNT(*), 0), 2
    )                          AS pct_null
  FROM amc_core.tobacco_use

) AS date_column_quality_checks
ORDER BY table_name, column_name;
