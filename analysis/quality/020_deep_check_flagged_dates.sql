-- ============================================================================
-- Data quality check: % of rows with implausible dates
-- for the 19 date/timestamp columns flagged with a review comment
-- in date_column_quality_results_1.csv (Comment column not blank).
--
-- For each flagged column:
--   pct_before_2000 = % of rows where the column's year is < 2000
--   pct_after_2027  = % of rows where the column's year is > 2027
-- (NULLs are excluded from both numerator and denominator's "out of range"
--  count, since a NULL date has no year to test; total_count is still all
--  rows in the table for context.)
--
-- Usage: run in psql / any Postgres client against the carenlp_db database.
-- ============================================================================

SELECT * FROM (
  -- flagged comment: to correct
  SELECT
    'amc_core.admission_partial_traject'::text        AS table_name,
    'admission_traject_discharge_date'::text       AS column_name,
    'date'::text    AS declared_type,
    'to correct'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE admission_traject_discharge_date IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE admission_traject_discharge_date IS NOT NULL AND EXTRACT(YEAR FROM admission_traject_discharge_date) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE admission_traject_discharge_date IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE admission_traject_discharge_date IS NOT NULL AND EXTRACT(YEAR FROM admission_traject_discharge_date) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE admission_traject_discharge_date IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.admission_partial_traject

  UNION ALL

  -- flagged comment: corrected
  SELECT
    'amc_core.admission_partial_traject'::text        AS table_name,
    'end_date'::text       AS column_name,
    'date'::text    AS declared_type,
    'corrected'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE end_date IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_date IS NOT NULL AND EXTRACT(YEAR FROM end_date) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE end_date IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_date IS NOT NULL AND EXTRACT(YEAR FROM end_date) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE end_date IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.admission_partial_traject

  UNION ALL

  -- flagged comment: to correct
  SELECT
    'amc_core.admission_traject'::text        AS table_name,
    'discharge_date'::text       AS column_name,
    'date'::text    AS declared_type,
    'to correct'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE discharge_date IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE discharge_date IS NOT NULL AND EXTRACT(YEAR FROM discharge_date) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE discharge_date IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE discharge_date IS NOT NULL AND EXTRACT(YEAR FROM discharge_date) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE discharge_date IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.admission_traject

  UNION ALL

  -- flagged comment: to correct
  SELECT
    'amc_core.death_registration'::text        AS table_name,
    'date_transfer_mortuary'::text       AS column_name,
    'date'::text    AS declared_type,
    'to correct'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE date_transfer_mortuary IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE date_transfer_mortuary IS NOT NULL AND EXTRACT(YEAR FROM date_transfer_mortuary) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE date_transfer_mortuary IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE date_transfer_mortuary IS NOT NULL AND EXTRACT(YEAR FROM date_transfer_mortuary) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE date_transfer_mortuary IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.death_registration

  UNION ALL

  -- flagged comment: what do measurement in the past mean?
  SELECT
    'amc_core.ecg_measurement'::text        AS table_name,
    'ecg_decrease_date'::text       AS column_name,
    'date'::text    AS declared_type,
    'what do measurement in the past mean?'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE ecg_decrease_date IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE ecg_decrease_date IS NOT NULL AND EXTRACT(YEAR FROM ecg_decrease_date) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE ecg_decrease_date IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE ecg_decrease_date IS NOT NULL AND EXTRACT(YEAR FROM ecg_decrease_date) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE ecg_decrease_date IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.ecg_measurement

  UNION ALL

  -- flagged comment: end procedure ongoing? Correct
  SELECT
    'amc_core.ic_procedure_note_central_venous_catheter'::text        AS table_name,
    'end_procedure'::text       AS column_name,
    'timestamptz'::text    AS declared_type,
    'end procedure ongoing? Correct'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE end_procedure IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_procedure IS NOT NULL AND EXTRACT(YEAR FROM end_procedure) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE end_procedure IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_procedure IS NOT NULL AND EXTRACT(YEAR FROM end_procedure) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE end_procedure IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.ic_procedure_note_central_venous_catheter

  UNION ALL

  -- flagged comment: what do past dates mean?
  SELECT
    'amc_core.imaging_study_order'::text        AS table_name,
    'end_date'::text       AS column_name,
    'date'::text    AS declared_type,
    'what do past dates mean?'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE end_date IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_date IS NOT NULL AND EXTRACT(YEAR FROM end_date) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE end_date IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE end_date IS NOT NULL AND EXTRACT(YEAR FROM end_date) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE end_date IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.imaging_study_order

  UNION ALL

  -- flagged comment: to correct
  SELECT
    'amc_core.medication_administration'::text        AS table_name,
    'administration_date'::text       AS column_name,
    'date'::text    AS declared_type,
    'to correct'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE administration_date IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE administration_date IS NOT NULL AND EXTRACT(YEAR FROM administration_date) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE administration_date IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE administration_date IS NOT NULL AND EXTRACT(YEAR FROM administration_date) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE administration_date IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.medication_administration

  UNION ALL

  -- flagged comment: to check
  SELECT
    'amc_core.medication_prescription'::text        AS table_name,
    'corrected_stop_date'::text       AS column_name,
    'date'::text    AS declared_type,
    'to check'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE corrected_stop_date IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE corrected_stop_date IS NOT NULL AND EXTRACT(YEAR FROM corrected_stop_date) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE corrected_stop_date IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE corrected_stop_date IS NOT NULL AND EXTRACT(YEAR FROM corrected_stop_date) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE corrected_stop_date IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.medication_prescription

  UNION ALL

  -- flagged comment: past dates?
  SELECT
    'amc_core.medication_prescription'::text        AS table_name,
    'start_date'::text       AS column_name,
    'date'::text    AS declared_type,
    'past dates?'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE start_date IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_date IS NOT NULL AND EXTRACT(YEAR FROM start_date) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE start_date IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_date IS NOT NULL AND EXTRACT(YEAR FROM start_date) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE start_date IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.medication_prescription

  UNION ALL

  -- flagged comment: future dates can be corrected
  SELECT
    'amc_core.medication_prescription'::text        AS table_name,
    'start_date_time'::text       AS column_name,
    'timestamptz'::text    AS declared_type,
    'future dates can be corrected'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE start_date_time IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_date_time IS NOT NULL AND EXTRACT(YEAR FROM start_date_time) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE start_date_time IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE start_date_time IS NOT NULL AND EXTRACT(YEAR FROM start_date_time) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE start_date_time IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.medication_prescription

  UNION ALL

  -- flagged comment: to correct
  SELECT
    'amc_core.patient_appointment'::text        AS table_name,
    'appointment_start_moment'::text       AS column_name,
    'timestamptz'::text    AS declared_type,
    'to correct'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE appointment_start_moment IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE appointment_start_moment IS NOT NULL AND EXTRACT(YEAR FROM appointment_start_moment) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE appointment_start_moment IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE appointment_start_moment IS NOT NULL AND EXTRACT(YEAR FROM appointment_start_moment) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE appointment_start_moment IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.patient_appointment

  UNION ALL

  -- flagged comment: to correct
  SELECT
    'amc_core.patient_appointment_line'::text        AS table_name,
    'appointment_start_moment'::text       AS column_name,
    'timestamptz'::text    AS declared_type,
    'to correct'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE appointment_start_moment IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE appointment_start_moment IS NOT NULL AND EXTRACT(YEAR FROM appointment_start_moment) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE appointment_start_moment IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE appointment_start_moment IS NOT NULL AND EXTRACT(YEAR FROM appointment_start_moment) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE appointment_start_moment IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.patient_appointment_line

  UNION ALL

  -- flagged comment: how to correct?
  SELECT
    'amc_core.patient_contact'::text        AS table_name,
    'patient_contact_date'::text       AS column_name,
    'date'::text    AS declared_type,
    'how to correct?'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE patient_contact_date IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE patient_contact_date IS NOT NULL AND EXTRACT(YEAR FROM patient_contact_date) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE patient_contact_date IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE patient_contact_date IS NOT NULL AND EXTRACT(YEAR FROM patient_contact_date) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE patient_contact_date IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.patient_contact

  UNION ALL

  -- flagged comment: unreliable
  SELECT
    'amc_core.patient_note_patient_contact'::text        AS table_name,
    'note_made_at_date_time'::text       AS column_name,
    'timestamptz'::text    AS declared_type,
    'unreliable'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE note_made_at_date_time IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE note_made_at_date_time IS NOT NULL AND EXTRACT(YEAR FROM note_made_at_date_time) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE note_made_at_date_time IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE note_made_at_date_time IS NOT NULL AND EXTRACT(YEAR FROM note_made_at_date_time) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE note_made_at_date_time IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.patient_note_patient_contact

  UNION ALL

  -- flagged comment: unreliable
  SELECT
    'amc_core.patient_note_patient_contact'::text        AS table_name,
    'note_made_on_date'::text       AS column_name,
    'date'::text    AS declared_type,
    'unreliable'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE note_made_on_date IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE note_made_on_date IS NOT NULL AND EXTRACT(YEAR FROM note_made_on_date) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE note_made_on_date IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE note_made_on_date IS NOT NULL AND EXTRACT(YEAR FROM note_made_on_date) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE note_made_on_date IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.patient_note_patient_contact

  UNION ALL

  -- flagged comment: unreliable
  SELECT
    'amc_core.patient_note_patient_contact'::text        AS table_name,
    'patient_contact_date_time'::text       AS column_name,
    'timestamptz'::text    AS declared_type,
    'unreliable'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE patient_contact_date_time IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE patient_contact_date_time IS NOT NULL AND EXTRACT(YEAR FROM patient_contact_date_time) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE patient_contact_date_time IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE patient_contact_date_time IS NOT NULL AND EXTRACT(YEAR FROM patient_contact_date_time) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE patient_contact_date_time IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.patient_note_patient_contact

  UNION ALL

  -- flagged comment: past dates?
  SELECT
    'amc_core.problem_list'::text        AS table_name,
    'corrected_close_date'::text       AS column_name,
    'date'::text    AS declared_type,
    'past dates?'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE corrected_close_date IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE corrected_close_date IS NOT NULL AND EXTRACT(YEAR FROM corrected_close_date) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE corrected_close_date IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE corrected_close_date IS NOT NULL AND EXTRACT(YEAR FROM corrected_close_date) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE corrected_close_date IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.problem_list

  UNION ALL

  -- flagged comment: corrected
  SELECT
    'amc_core.seh_trajectory'::text        AS table_name,
    'seh_departure_date'::text       AS column_name,
    'date'::text    AS declared_type,
    'corrected'::text AS review_comment,
    COUNT(*)               AS total_count,
    COUNT(*) FILTER (WHERE seh_departure_date IS NULL) AS null_count,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE seh_departure_date IS NOT NULL AND EXTRACT(YEAR FROM seh_departure_date) < 2000)
      / NULLIF(COUNT(*) FILTER (WHERE seh_departure_date IS NOT NULL), 0), 2
    )                       AS pct_before_2000,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE seh_departure_date IS NOT NULL AND EXTRACT(YEAR FROM seh_departure_date) > 2027)
      / NULLIF(COUNT(*) FILTER (WHERE seh_departure_date IS NOT NULL), 0), 2
    )                       AS pct_after_2027
  FROM amc_core.seh_trajectory

) AS flagged_date_range_checks
ORDER BY table_name, column_name;