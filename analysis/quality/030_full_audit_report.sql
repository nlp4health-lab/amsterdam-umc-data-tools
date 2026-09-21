-- =============================================================================
-- AMC CORE — DATA QUALITY AUDIT QUERIES
-- =============================================================================
-- Purpose : Systematically identify, quantify, and characterise data quality
--           issues before building research cohorts.
--           Each query produces counts + percentages so results are slide-ready.
-- Issues covered (from meeting notes + schema analysis):
--   A. Patient traceability across tables
--   B. Abnormal dates (past: < 2000, future: > CURRENT_DATE + 10 years)
--   C. contact_ids not found in patient_contact master table
--   D. NULL rates for key fields
--   E. lab_result: bigserial PK issue, null in composite key
--   F. Discharge before admission / negative stays
--   G. Duplicate events per patient
--   H. Medication / prescription chain orphans
--   I. Note linkage gaps
--   J. Cross-table date consistency
--   K. Patients traceable end-to-end (positive quality check)
--
-- HOW TO RUN (from inside psql):
--   sed 's|/tmp/amc_dq|/your/path|g' amc_core_data_quality_audit_psql.sql > dq_run.sql
--   \i /path/to/dq_run.sql
--
-- All results are written to separate CSVs. A run.log tracks timing.
-- =============================================================================

\pset format csv
\pset tuples_only off
\pset footer on
\timing on
\set ON_ERROR_CONTINUE on

-- ── Edit this path ────────────────────────────────────────────────────────────
\set outdir '/tmp/amc_dq'
\! mkdir -p /tmp/amc_dq

\o /tmp/amc_dq/run.log
\echo '============================================================'
\echo 'AMC Core Data Quality Audit'
\echo '============================================================'
\! echo "Started: $(date)"
\o


-- =============================================================================
-- SECTION A — PATIENT TRACEABILITY ACROSS TABLES
-- =============================================================================
-- Key question from notes: "are there patients that can be traced through
-- the tables?" A patient is "traceable" if their pseudo_id appears in
-- multiple key domains. Patients only in one domain may be incomplete.
-- =============================================================================

-- ----------------------------------------------------------------------------
-- A.1  Per-patient domain coverage
-- For each patient, count how many major domains they appear in.
-- Patients with coverage in 0-1 domains are "thin" records — may be
-- registration artefacts, consent-only records, or ETL gaps.
-- ----------------------------------------------------------------------------
\! echo "  [A.1] Patient domain coverage — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[A.1] Patient domain coverage'
\o /tmp/amc_dq/A1_patient_domain_coverage.csv

WITH domain_flags AS (
    SELECT
        p.pseudo_id,
        -- 1 if patient appears in this domain, else 0
        (EXISTS (SELECT 1 FROM amc_core.patient_contact      pc WHERE pc.pseudo_id = p.pseudo_id))::int AS has_contact,
        (EXISTS (SELECT 1 FROM amc_core.admission_traject    at_ WHERE at_.pseudo_id = p.pseudo_id))::int AS has_admission,
        (EXISTS (SELECT 1 FROM amc_core.lab_result           lr  WHERE lr.pseudo_id  = p.pseudo_id))::int AS has_lab,
        (EXISTS (SELECT 1 FROM amc_core.medical_diagnosis    md  WHERE md.pseudo_id  = p.pseudo_id))::int AS has_diagnosis,
        (EXISTS (SELECT 1 FROM amc_core.medication_prescription mp WHERE mp.pseudo_id = p.pseudo_id))::int AS has_medication,
        (EXISTS (SELECT 1 FROM amc_core.patient_note_patient_contact nn WHERE nn.pseudo_id = p.pseudo_id))::int AS has_note,
        (EXISTS (SELECT 1 FROM amc_core.death_registration   dr  WHERE dr.pseudo_id  = p.pseudo_id))::int AS has_death,
        (EXISTS (SELECT 1 FROM amc_core.measurement_vital_signs_data vs WHERE vs.pseudo_id = p.pseudo_id))::int AS has_vitals
    FROM amc_core.patient_not_traceable p
),
coverage AS (
    SELECT
        pseudo_id,
        has_contact + has_admission + has_lab + has_diagnosis +
        has_medication + has_note + has_death + has_vitals AS n_domains,
        has_contact, has_admission, has_lab, has_diagnosis,
        has_medication, has_note, has_death, has_vitals
    FROM domain_flags
)
SELECT
    n_domains,
    COUNT(*)                                                        AS n_patients,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)             AS pct_of_all_patients,
    SUM(has_contact)                                               AS with_contact,
    SUM(has_admission)                                             AS with_admission,
    SUM(has_lab)                                                   AS with_lab,
    SUM(has_diagnosis)                                             AS with_diagnosis,
    SUM(has_medication)                                            AS with_medication,
    SUM(has_note)                                                  AS with_note,
    SUM(has_death)                                                 AS with_death,
    SUM(has_vitals)                                                AS with_vitals
FROM coverage
GROUP BY n_domains
ORDER BY n_domains;


-- ----------------------------------------------------------------------------
-- A.2  Patients with NO data in any event table
-- These "ghost" patients have a master record but no clinical events.
-- Check: registration artefacts? consent-only? ETL gap?
-- ----------------------------------------------------------------------------
\! echo "  [A.2] Ghost patients — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[A.2] Ghost patients (in patient_not_traceable but no events anywhere)'
\o /tmp/amc_dq/A2_ghost_patients.csv

SELECT
    COUNT(*)                                         AS total_patients_master,
    SUM(CASE WHEN
            NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc WHERE pc.pseudo_id = p.pseudo_id)
        AND NOT EXISTS (SELECT 1 FROM amc_core.admission_traject at_ WHERE at_.pseudo_id = p.pseudo_id)
        AND NOT EXISTS (SELECT 1 FROM amc_core.lab_result lr WHERE lr.pseudo_id = p.pseudo_id)
        AND NOT EXISTS (SELECT 1 FROM amc_core.medical_diagnosis md WHERE md.pseudo_id = p.pseudo_id)
        AND NOT EXISTS (SELECT 1 FROM amc_core.medication_prescription mp WHERE mp.pseudo_id = p.pseudo_id)
        AND NOT EXISTS (SELECT 1 FROM amc_core.patient_note_patient_contact nn WHERE nn.pseudo_id = p.pseudo_id)
        THEN 1 ELSE 0 END)                           AS ghost_patients,
    ROUND(100.0 * SUM(CASE WHEN
            NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc WHERE pc.pseudo_id = p.pseudo_id)
        AND NOT EXISTS (SELECT 1 FROM amc_core.admission_traject at_ WHERE at_.pseudo_id = p.pseudo_id)
        AND NOT EXISTS (SELECT 1 FROM amc_core.lab_result lr WHERE lr.pseudo_id = p.pseudo_id)
        AND NOT EXISTS (SELECT 1 FROM amc_core.medical_diagnosis md WHERE md.pseudo_id = p.pseudo_id)
        AND NOT EXISTS (SELECT 1 FROM amc_core.medication_prescription mp WHERE mp.pseudo_id = p.pseudo_id)
        AND NOT EXISTS (SELECT 1 FROM amc_core.patient_note_patient_contact nn WHERE nn.pseudo_id = p.pseudo_id)
        THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS ghost_pct
FROM amc_core.patient_not_traceable p;


-- ----------------------------------------------------------------------------
-- A.3  Full end-to-end traceability — positive check
-- "Fully traceable" = patient has contact + admission + lab + diagnosis + note.
-- These are the richest patients, best candidates for cohort studies.
-- ----------------------------------------------------------------------------
\! echo "  [A.3] Fully traceable patients — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[A.3] Fully traceable patients (contact + admission + lab + diagnosis + note)'
\o /tmp/amc_dq/A3_fully_traceable_patients.csv

SELECT
    COUNT(DISTINCT p.pseudo_id)                      AS total_patients,
    COUNT(DISTINCT p.pseudo_id) FILTER (WHERE
        EXISTS (SELECT 1 FROM amc_core.patient_contact pc WHERE pc.pseudo_id = p.pseudo_id)
    AND EXISTS (SELECT 1 FROM amc_core.admission_traject at_ WHERE at_.pseudo_id = p.pseudo_id)
    AND EXISTS (SELECT 1 FROM amc_core.lab_result lr WHERE lr.pseudo_id = p.pseudo_id)
    AND EXISTS (SELECT 1 FROM amc_core.medical_diagnosis md WHERE md.pseudo_id = p.pseudo_id)
    AND EXISTS (SELECT 1 FROM amc_core.patient_note_patient_contact nn WHERE nn.pseudo_id = p.pseudo_id)
    )                                                AS fully_traceable,
    ROUND(100.0 * COUNT(DISTINCT p.pseudo_id) FILTER (WHERE
        EXISTS (SELECT 1 FROM amc_core.patient_contact pc WHERE pc.pseudo_id = p.pseudo_id)
    AND EXISTS (SELECT 1 FROM amc_core.admission_traject at_ WHERE at_.pseudo_id = p.pseudo_id)
    AND EXISTS (SELECT 1 FROM amc_core.lab_result lr WHERE lr.pseudo_id = p.pseudo_id)
    AND EXISTS (SELECT 1 FROM amc_core.medical_diagnosis md WHERE md.pseudo_id = p.pseudo_id)
    AND EXISTS (SELECT 1 FROM amc_core.patient_note_patient_contact nn WHERE nn.pseudo_id = p.pseudo_id)
    ) / NULLIF(COUNT(DISTINCT p.pseudo_id), 0), 2)  AS fully_traceable_pct
FROM amc_core.patient_not_traceable p;


-- =============================================================================
-- SECTION B — ABNORMAL DATES
-- =============================================================================
-- From notes: "dates from 1900 to 2400 in some tables. maybe randomized."
-- "up to 10 years in the future, that ok, if not, flag as weird."
-- Rule: flag dates < 2000-01-01 OR > CURRENT_DATE + 10 years as abnormal.
-- For planned appointments/future dates, > CURRENT_DATE + 10 years is the flag.
-- =============================================================================

-- ----------------------------------------------------------------------------
-- B.1  Abnormal date summary — all tables with date columns
-- One row per table+column showing: total, past_abnormal, future_abnormal, pct.
-- "Past abnormal" = before 2000-01-01 (clearly pre-digital/data-entry error).
-- "Future abnormal" = more than 10 years from today.
-- ----------------------------------------------------------------------------
\! echo "  [B.1] Abnormal dates summary all tables — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[B.1] Abnormal dates - all tables summary'
\o /tmp/amc_dq/B1_abnormal_dates_summary.csv

SELECT
    table_name,
    date_column,
    total_non_null,
    past_abnormal,
    future_abnormal,
    past_abnormal + future_abnormal                                  AS total_abnormal,
    ROUND(100.0 * past_abnormal  / NULLIF(total_non_null, 0), 2)   AS past_pct,
    ROUND(100.0 * future_abnormal / NULLIF(total_non_null, 0), 2)  AS future_pct,
    ROUND(100.0 * (past_abnormal + future_abnormal) / NULLIF(total_non_null, 0), 2) AS total_abnormal_pct,
    min_date,
    max_date
FROM (

    SELECT 'patient_contact' AS table_name, 'patient_contact_date' AS date_column,
        COUNT(patient_contact_date) AS total_non_null,
        COUNT(*) FILTER (WHERE patient_contact_date < '2000-01-01') AS past_abnormal,
        COUNT(*) FILTER (WHERE patient_contact_date > CURRENT_DATE + INTERVAL '10 years') AS future_abnormal,
        MIN(patient_contact_date) AS min_date, MAX(patient_contact_date) AS max_date
    FROM amc_core.patient_contact

    UNION ALL SELECT 'admission_traject', 'admission_date',
        COUNT(admission_date),
        COUNT(*) FILTER (WHERE admission_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE admission_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(admission_date), MAX(admission_date)
    FROM amc_core.admission_traject

    UNION ALL SELECT 'admission_traject', 'discharge_date',
        COUNT(discharge_date),
        COUNT(*) FILTER (WHERE discharge_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE discharge_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(discharge_date), MAX(discharge_date)
    FROM amc_core.admission_traject

    UNION ALL SELECT 'admission_partial_traject', 'start_date',
        COUNT(start_date),
        COUNT(*) FILTER (WHERE start_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE start_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(start_date), MAX(start_date)
    FROM amc_core.admission_partial_traject

    UNION ALL SELECT 'admission_partial_traject', 'end_date',
        COUNT(end_date),
        COUNT(*) FILTER (WHERE end_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE end_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(end_date), MAX(end_date)
    FROM amc_core.admission_partial_traject

    UNION ALL SELECT 'seh_trajectory', 'seh_admission_date',
        COUNT(seh_admission_date),
        COUNT(*) FILTER (WHERE seh_admission_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE seh_admission_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(seh_admission_date), MAX(seh_admission_date)
    FROM amc_core.seh_trajectory

    UNION ALL SELECT 'seh_trajectory', 'seh_departure_date',
        COUNT(seh_departure_date),
        COUNT(*) FILTER (WHERE seh_departure_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE seh_departure_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(seh_departure_date), MAX(seh_departure_date)
    FROM amc_core.seh_trajectory

    UNION ALL SELECT 'patient_appointment', 'appointment_date',
        COUNT(appointment_date),
        COUNT(*) FILTER (WHERE appointment_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE appointment_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(appointment_date), MAX(appointment_date)
    FROM amc_core.patient_appointment

    UNION ALL SELECT 'patient_appointment_line', 'appointment_date',
        COUNT(appointment_date),
        COUNT(*) FILTER (WHERE appointment_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE appointment_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(appointment_date), MAX(appointment_date)
    FROM amc_core.patient_appointment_line

    UNION ALL SELECT 'death_registration', 'meet_date',
        COUNT(meet_date),
        COUNT(*) FILTER (WHERE meet_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE meet_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(meet_date), MAX(meet_date)
    FROM amc_core.death_registration

    UNION ALL SELECT 'lab_result', 'material_decrease_date',
        COUNT(material_decrease_date),
        COUNT(*) FILTER (WHERE material_decrease_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE material_decrease_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(material_decrease_date), MAX(material_decrease_date)
    FROM amc_core.lab_result

    UNION ALL SELECT 'lab_result', 'result_date',
        COUNT(result_date),
        COUNT(*) FILTER (WHERE result_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE result_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(result_date), MAX(result_date)
    FROM amc_core.lab_result

    UNION ALL SELECT 'medical_diagnosis', 'diagnosis_contact_date',
        COUNT(diagnosis_contact_date),
        COUNT(*) FILTER (WHERE diagnosis_contact_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE diagnosis_contact_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(diagnosis_contact_date), MAX(diagnosis_contact_date)
    FROM amc_core.medical_diagnosis

    UNION ALL SELECT 'medication_prescription', 'prescription_date',
        COUNT(prescription_date),
        COUNT(*) FILTER (WHERE prescription_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE prescription_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(prescription_date), MAX(prescription_date)
    FROM amc_core.medication_prescription

    UNION ALL SELECT 'medication_prescription', 'start_date',
        COUNT(start_date),
        COUNT(*) FILTER (WHERE start_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE start_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(start_date), MAX(start_date)
    FROM amc_core.medication_prescription

    UNION ALL SELECT 'medication_prescription', 'stop_date',
        COUNT(stop_date),
        COUNT(*) FILTER (WHERE stop_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE stop_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(stop_date), MAX(stop_date)
    FROM amc_core.medication_prescription

    UNION ALL SELECT 'medication_administration', 'administration_date',
        COUNT(administration_date),
        COUNT(*) FILTER (WHERE administration_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE administration_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(administration_date), MAX(administration_date)
    FROM amc_core.medication_administration

    UNION ALL SELECT 'procedures', 'intervention_date',
        COUNT(intervention_date),
        COUNT(*) FILTER (WHERE intervention_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE intervention_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(intervention_date), MAX(intervention_date)
    FROM amc_core.procedures

    UNION ALL SELECT 'ok_procedure_performed', 'session_start_date',
        COUNT(session_start_date),
        COUNT(*) FILTER (WHERE session_start_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE session_start_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(session_start_date), MAX(session_start_date)
    FROM amc_core.ok_procedure_performed

    UNION ALL SELECT 'ok_procedure_planned', 'session_planned_start_date',
        COUNT(session_planned_start_date),
        COUNT(*) FILTER (WHERE session_planned_start_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE session_planned_start_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(session_planned_start_date), MAX(session_planned_start_date)
    FROM amc_core.ok_procedure_planned

    UNION ALL SELECT 'imaging_study_order', 'start_date',
        COUNT(start_date),
        COUNT(*) FILTER (WHERE start_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE start_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(start_date), MAX(start_date)
    FROM amc_core.imaging_study_order

    UNION ALL SELECT 'ecg_measurement', 'ecg_decrease_date',
        COUNT(ecg_decrease_date),
        COUNT(*) FILTER (WHERE ecg_decrease_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE ecg_decrease_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(ecg_decrease_date), MAX(ecg_decrease_date)
    FROM amc_core.ecg_measurement

    UNION ALL SELECT 'echo_measurement_heart', 'examination_date',
        COUNT(examination_date),
        COUNT(*) FILTER (WHERE examination_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE examination_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(examination_date), MAX(examination_date)
    FROM amc_core.echo_measurement_heart

    UNION ALL SELECT 'problem_list', 'patient_contact_date',
        COUNT(patient_contact_date),
        COUNT(*) FILTER (WHERE patient_contact_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE patient_contact_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(patient_contact_date), MAX(patient_contact_date)
    FROM amc_core.problem_list

    UNION ALL SELECT 'problem_list', 'observation_date',
        COUNT(observation_date),
        COUNT(*) FILTER (WHERE observation_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE observation_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(observation_date), MAX(observation_date)
    FROM amc_core.problem_list

    UNION ALL SELECT 'problem_list', 'close_date',
        COUNT(close_date),
        COUNT(*) FILTER (WHERE close_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE close_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(close_date), MAX(close_date)
    FROM amc_core.problem_list

    UNION ALL SELECT 'tobacco_use', 'start_date',
        COUNT(start_date),
        COUNT(*) FILTER (WHERE start_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE start_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(start_date), MAX(start_date)
    FROM amc_core.tobacco_use

    UNION ALL SELECT 'surgery_history', 'procedure_start_date',
        COUNT(procedure_start_date),
        COUNT(*) FILTER (WHERE procedure_start_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE procedure_start_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(procedure_start_date), MAX(procedure_start_date)
    FROM amc_core.surgery_history

    UNION ALL SELECT 'measurement_vital_signs_data', 'meet_date',
        COUNT(meet_date),
        COUNT(*) FILTER (WHERE meet_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE meet_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(meet_date), MAX(meet_date)
    FROM amc_core.measurement_vital_signs_data

    UNION ALL SELECT 'measurement_blood_pressure', 'meet_date',
        COUNT(meet_date),
        COUNT(*) FILTER (WHERE meet_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE meet_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(meet_date), MAX(meet_date)
    FROM amc_core.measurement_blood_pressure

    UNION ALL SELECT 'patient_note_patient_contact', 'note_made_on_date',
        COUNT(note_made_on_date),
        COUNT(*) FILTER (WHERE note_made_on_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE note_made_on_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(note_made_on_date), MAX(note_made_on_date)
    FROM amc_core.patient_note_patient_contact

    UNION ALL SELECT 'adverse_event', 'course_date',
        COUNT(course_date),
        COUNT(*) FILTER (WHERE course_date < '2000-01-01'),
        COUNT(*) FILTER (WHERE course_date > CURRENT_DATE + INTERVAL '10 years'),
        MIN(course_date), MAX(course_date)
    FROM amc_core.adverse_event

) sub
ORDER BY total_abnormal_pct DESC NULLS LAST;


-- ----------------------------------------------------------------------------
-- B.2  Patients with abnormal dates — how many patients affected?
-- From notes: "how many patients have this, how much data represents per table"
-- Per table: count affected patients and their share of total patients.
-- ----------------------------------------------------------------------------
\! echo "  [B.2] Patients with abnormal dates per table — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[B.2] Patients affected by abnormal dates per table'
\o /tmp/amc_dq/B2_patients_with_abnormal_dates.csv

SELECT
    source_table,
    date_column,
    abnormal_type,
    n_affected_patients,
    ROUND(100.0 * n_affected_patients /
        (SELECT COUNT(*) FROM amc_core.patient_not_traceable), 2) AS pct_of_all_patients
FROM (
    SELECT 'admission_traject' AS source_table, 'admission_date' AS date_column,
           'past (<2000)' AS abnormal_type,
           COUNT(DISTINCT pseudo_id) AS n_affected_patients
    FROM amc_core.admission_traject WHERE admission_date < '2000-01-01'
    UNION ALL
    SELECT 'admission_traject', 'admission_date', 'future (>today+10y)',
           COUNT(DISTINCT pseudo_id)
    FROM amc_core.admission_traject WHERE admission_date > CURRENT_DATE + INTERVAL '10 years'
    UNION ALL
    SELECT 'admission_traject', 'discharge_date', 'future (>today+10y)',
           COUNT(DISTINCT pseudo_id)
    FROM amc_core.admission_traject WHERE discharge_date > CURRENT_DATE + INTERVAL '10 years'
    UNION ALL
    SELECT 'lab_result', 'result_date', 'past (<2000)',
           COUNT(DISTINCT pseudo_id)
    FROM amc_core.lab_result WHERE result_date < '2000-01-01'
    UNION ALL
    SELECT 'lab_result', 'result_date', 'future (>today+10y)',
           COUNT(DISTINCT pseudo_id)
    FROM amc_core.lab_result WHERE result_date > CURRENT_DATE + INTERVAL '10 years'
    UNION ALL
    SELECT 'medication_prescription', 'stop_date', 'future (>today+10y)',
           COUNT(DISTINCT pseudo_id)
    FROM amc_core.medication_prescription WHERE stop_date > CURRENT_DATE + INTERVAL '10 years'
    UNION ALL
    SELECT 'medication_prescription', 'start_date', 'past (<2000)',
           COUNT(DISTINCT pseudo_id)
    FROM amc_core.medication_prescription WHERE start_date < '2000-01-01'
    UNION ALL
    SELECT 'patient_contact', 'patient_contact_date', 'past (<2000)',
           COUNT(DISTINCT pseudo_id)
    FROM amc_core.patient_contact WHERE patient_contact_date < '2000-01-01'
    UNION ALL
    SELECT 'patient_contact', 'patient_contact_date', 'future (>today+10y)',
           COUNT(DISTINCT pseudo_id)
    FROM amc_core.patient_contact WHERE patient_contact_date > CURRENT_DATE + INTERVAL '10 years'
    UNION ALL
    SELECT 'procedures', 'intervention_date', 'past (<2000)',
           COUNT(DISTINCT pseudo_id)
    FROM amc_core.procedures WHERE intervention_date < '2000-01-01'
    UNION ALL
    SELECT 'procedures', 'intervention_date', 'future (>today+10y)',
           COUNT(DISTINCT pseudo_id)
    FROM amc_core.procedures WHERE intervention_date > CURRENT_DATE + INTERVAL '10 years'
) sub
WHERE n_affected_patients > 0
ORDER BY n_affected_patients DESC;


-- ----------------------------------------------------------------------------
-- B.3  Medication stop_date in 2404 — specific flag from notes
-- Notes mention "2404-07-27 is geplanned? in status".
-- Check medication_prescription for stop_dates > 2100 specifically.
-- These are likely placeholder "no end date" values from the source system.
-- ----------------------------------------------------------------------------
\! echo "  [B.3] Extreme future dates in medication stop_date — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[B.3] Extreme future dates in medication stop_date (year > 2100)'
\o /tmp/amc_dq/B3_extreme_future_medication_stop_dates.csv

SELECT
    EXTRACT(YEAR FROM stop_date)::int  AS stop_year,
    order_status,
    COUNT(*)                           AS n_prescriptions,
    COUNT(DISTINCT pseudo_id)          AS n_patients
FROM amc_core.medication_prescription
WHERE stop_date > '2100-01-01'
GROUP BY stop_year, order_status
ORDER BY stop_year DESC, n_prescriptions DESC;


-- =============================================================================
-- SECTION C — CONTACT_ID NOT IN PATIENT_CONTACT MASTER TABLE
-- =============================================================================
-- From notes: "contact ids missing from master table"
-- "We don't have the table with all contacts — messier than we thought"
-- Key question: is there a PATTERN to orphan contact_ids?
-- Do they share specialty, workplace, contact_type, date range, or table origin?
-- =============================================================================

-- ----------------------------------------------------------------------------
-- C.1  Orphan contact_id volume per table
-- How many records in each child table have a patient_contact_id that does
-- NOT exist in patient_contact? Counts + percentage per table.
-- ----------------------------------------------------------------------------
\! echo "  [C.1] Orphan contact_ids per table — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[C.1] Orphan patient_contact_id per table (not in patient_contact master)'
\o /tmp/amc_dq/C1_orphan_contact_ids_per_table.csv

SELECT
    source_table,
    total_rows,
    rows_with_contact_id,
    orphan_rows,
    orphan_patients,
    ROUND(100.0 * orphan_rows / NULLIF(rows_with_contact_id, 0), 2) AS orphan_row_pct
FROM (
    SELECT 'admission_traject' AS source_table,
        COUNT(*) AS total_rows,
        COUNT(patient_contact_id) AS rows_with_contact_id,
        COUNT(*) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = at_.patient_contact_id)) AS orphan_rows,
        COUNT(DISTINCT pseudo_id) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = at_.patient_contact_id)) AS orphan_patients
    FROM amc_core.admission_traject at_

    UNION ALL
    SELECT 'patient_note_patient_contact',
        COUNT(*), COUNT(patient_contact_id),
        COUNT(*) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = nn.patient_contact_id)),
        COUNT(DISTINCT pseudo_id) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = nn.patient_contact_id))
    FROM amc_core.patient_note_patient_contact nn

    UNION ALL
    SELECT 'patient_appointment',
        COUNT(*), COUNT(patient_contact_id),
        COUNT(*) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = pa.patient_contact_id)),
        COUNT(DISTINCT pseudo_id) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = pa.patient_contact_id))
    FROM amc_core.patient_appointment pa

    UNION ALL
    SELECT 'patient_appointment_line',
        COUNT(*), COUNT(patient_contact_id),
        COUNT(*) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = pal.patient_contact_id)),
        COUNT(DISTINCT pseudo_id) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = pal.patient_contact_id))
    FROM amc_core.patient_appointment_line pal

    UNION ALL
    SELECT 'medical_diagnosis',
        COUNT(*), COUNT(patient_contact_id),
        COUNT(*) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = md.patient_contact_id)),
        COUNT(DISTINCT pseudo_id) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = md.patient_contact_id))
    FROM amc_core.medical_diagnosis md

    UNION ALL
    SELECT 'procedures',
        COUNT(*), COUNT(patient_contact_id),
        COUNT(*) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = pr.patient_contact_id)),
        COUNT(DISTINCT pseudo_id) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = pr.patient_contact_id))
    FROM amc_core.procedures pr

    UNION ALL
    SELECT 'medication_prescription',
        COUNT(*), COUNT(patient_contact_id),
        COUNT(*) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = mp.patient_contact_id)),
        COUNT(DISTINCT pseudo_id) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = mp.patient_contact_id))
    FROM amc_core.medication_prescription mp

    UNION ALL
    SELECT 'seh_trajectory',
        COUNT(*), COUNT(patient_contact_id),
        COUNT(*) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = st.patient_contact_id)),
        COUNT(DISTINCT pseudo_id) FILTER (WHERE patient_contact_id IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                            WHERE pc.patient_contact_id = st.patient_contact_id))
    FROM amc_core.seh_trajectory st

) sub
ORDER BY orphan_row_pct DESC;


-- ----------------------------------------------------------------------------
-- C.2  Pattern analysis — do orphan contact_ids share characteristics?
-- Check admission_traject orphans: do they cluster by specialty, year, type?
-- If orphans are concentrated in a specialty or date range, it's a systematic
-- gap (e.g., a department not in the master table) rather than random noise.
-- ----------------------------------------------------------------------------
\! echo "  [C.2] Orphan contact_id pattern analysis (admission_traject) — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[C.2] Orphan contact_id pattern - admission_traject by specialty and year'
\o /tmp/amc_dq/C2_orphan_contact_pattern_admission.csv

SELECT
    admission_specialty,
    EXTRACT(YEAR FROM admission_date)::int AS admission_year,
    COUNT(*)                               AS orphan_count,
    COUNT(DISTINCT pseudo_id)              AS orphan_patients,
    ROUND(100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (), 2)          AS pct_of_all_orphans
FROM amc_core.admission_traject at_
WHERE patient_contact_id IS NOT NULL
  AND NOT EXISTS (
        SELECT 1 FROM amc_core.patient_contact pc
        WHERE pc.patient_contact_id = at_.patient_contact_id
  )
GROUP BY admission_specialty, admission_year
ORDER BY orphan_count DESC
LIMIT 40;


-- ----------------------------------------------------------------------------
-- C.3  Do orphan contact_ids from different tables overlap?
-- If the same contact_id appears as orphan in multiple tables, it might be
-- a real contact simply missing from the master table (systemic gap).
-- If orphans are unique per table, it's likely a different issue per source.
-- ----------------------------------------------------------------------------
\! echo "  [C.3] Cross-table overlap of orphan contact_ids — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[C.3] Cross-table overlap of orphan contact_ids'
\o /tmp/amc_dq/C3_orphan_contact_cross_table_overlap.csv

WITH orphan_contacts AS (
    SELECT patient_contact_id, 'admission_traject' AS source_table
    FROM amc_core.admission_traject
    WHERE patient_contact_id IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                      WHERE pc.patient_contact_id = admission_traject.patient_contact_id)
    UNION ALL
    SELECT patient_contact_id, 'patient_appointment'
    FROM amc_core.patient_appointment
    WHERE patient_contact_id IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                      WHERE pc.patient_contact_id = patient_appointment.patient_contact_id)
    UNION ALL
    SELECT patient_contact_id, 'medical_diagnosis'
    FROM amc_core.medical_diagnosis
    WHERE patient_contact_id IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                      WHERE pc.patient_contact_id = medical_diagnosis.patient_contact_id)
    UNION ALL
    SELECT patient_contact_id, 'procedures'
    FROM amc_core.procedures
    WHERE patient_contact_id IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                      WHERE pc.patient_contact_id = procedures.patient_contact_id)
)
SELECT
    n_tables_sharing_orphan_id,
    COUNT(DISTINCT patient_contact_id) AS n_distinct_orphan_ids,
    ROUND(100.0 * COUNT(DISTINCT patient_contact_id) /
        SUM(COUNT(DISTINCT patient_contact_id)) OVER (), 2) AS pct
FROM (
    SELECT patient_contact_id, COUNT(DISTINCT source_table) AS n_tables_sharing_orphan_id
    FROM orphan_contacts
    GROUP BY patient_contact_id
) sub
GROUP BY n_tables_sharing_orphan_id
ORDER BY n_tables_sharing_orphan_id DESC;


-- =============================================================================
-- SECTION D — NULL RATES FOR KEY FIELDS
-- =============================================================================
-- Comprehensive NULL audit of all anchor/join fields and key clinical fields.
-- =============================================================================

-- ----------------------------------------------------------------------------
-- D.1  NULL rates — anchor and join fields across all tables
-- NULL in pseudo_id or patient_contact_id breaks traceability.
-- These should be near 0%. Any nulls are data quality flags.
-- ----------------------------------------------------------------------------
\! echo "  [D.1] NULL rates for key join fields — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[D.1] NULL rates for key join/anchor fields'
\o /tmp/amc_dq/D1_null_rates_key_fields.csv

SELECT
    table_name, column_name,
    total_rows, null_count,
    ROUND(100.0 * null_count / NULLIF(total_rows, 0), 2) AS null_pct,
    severity
FROM (
    -- pseudo_id NULLs (should be 0 — enforced FK)
    SELECT 'patient_contact'       AS table_name, 'pseudo_id' AS column_name,
        COUNT(*) AS total_rows, COUNT(*) FILTER (WHERE pseudo_id IS NULL) AS null_count, 'CRITICAL' AS severity
    FROM amc_core.patient_contact
    UNION ALL SELECT 'admission_traject', 'pseudo_id',
        COUNT(*), COUNT(*) FILTER (WHERE pseudo_id IS NULL), 'CRITICAL'
    FROM amc_core.admission_traject
    UNION ALL SELECT 'lab_result', 'pseudo_id',
        COUNT(*), COUNT(*) FILTER (WHERE pseudo_id IS NULL), 'CRITICAL'
    FROM amc_core.lab_result
    UNION ALL SELECT 'medical_diagnosis', 'pseudo_id',
        COUNT(*), COUNT(*) FILTER (WHERE pseudo_id IS NULL), 'CRITICAL'
    FROM amc_core.medical_diagnosis
    UNION ALL SELECT 'medication_prescription', 'pseudo_id',
        COUNT(*), COUNT(*) FILTER (WHERE pseudo_id IS NULL), 'CRITICAL'
    FROM amc_core.medication_prescription
    UNION ALL SELECT 'procedures', 'pseudo_id',
        COUNT(*), COUNT(*) FILTER (WHERE pseudo_id IS NULL), 'CRITICAL'
    FROM amc_core.procedures

    -- patient_contact_id NULLs (expected some — incomplete coverage)
    UNION ALL SELECT 'admission_traject', 'patient_contact_id',
        COUNT(*), COUNT(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = ''), 'HIGH'
    FROM amc_core.admission_traject
    UNION ALL SELECT 'medical_diagnosis', 'patient_contact_id',
        COUNT(*), COUNT(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = ''), 'HIGH'
    FROM amc_core.medical_diagnosis
    UNION ALL SELECT 'medication_prescription', 'patient_contact_id',
        COUNT(*), COUNT(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = ''), 'HIGH'
    FROM amc_core.medication_prescription
    UNION ALL SELECT 'procedures', 'patient_contact_id',
        COUNT(*), COUNT(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = ''), 'HIGH'
    FROM amc_core.procedures
    UNION ALL SELECT 'seh_trajectory', 'patient_contact_id',
        COUNT(*), COUNT(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = ''), 'HIGH'
    FROM amc_core.seh_trajectory

    -- Clinical key fields
    UNION ALL SELECT 'admission_traject', 'admission_date',
        COUNT(*), COUNT(*) FILTER (WHERE admission_date IS NULL), 'HIGH'
    FROM amc_core.admission_traject
    UNION ALL SELECT 'admission_traject', 'discharge_date',
        COUNT(*), COUNT(*) FILTER (WHERE discharge_date IS NULL), 'MEDIUM'
    FROM amc_core.admission_traject
    UNION ALL SELECT 'lab_result', 'result_numeric',
        COUNT(*), COUNT(*) FILTER (WHERE result_numeric IS NULL), 'MEDIUM'
    FROM amc_core.lab_result
    UNION ALL SELECT 'lab_result', 'determination_code',
        COUNT(*), COUNT(*) FILTER (WHERE determination_code IS NULL OR determination_code = ''), 'CRITICAL'
    FROM amc_core.lab_result
    UNION ALL SELECT 'medical_diagnosis', 'diagnosis_code',
        COUNT(*), COUNT(*) FILTER (WHERE diagnosis_code IS NULL OR diagnosis_code = ''), 'HIGH'
    FROM amc_core.medical_diagnosis
    UNION ALL SELECT 'medication_prescription', 'atc_code',
        COUNT(*), COUNT(*) FILTER (WHERE atc_code IS NULL OR atc_code = ''), 'HIGH'
    FROM amc_core.medication_prescription
    UNION ALL SELECT 'medication_administration', 'atc_code',
        COUNT(*), COUNT(*) FILTER (WHERE atc_code IS NULL OR atc_code = ''), 'MEDIUM'
    FROM amc_core.medication_administration
    UNION ALL SELECT 'patient_not_traceable', 'year_of_birth',
        COUNT(*), COUNT(*) FILTER (WHERE year_of_birth IS NULL), 'HIGH'
    FROM amc_core.patient_not_traceable
    UNION ALL SELECT 'patient_not_traceable', 'gender',
        COUNT(*), COUNT(*) FILTER (WHERE gender IS NULL OR gender = ''), 'MEDIUM'
    FROM amc_core.patient_not_traceable
    UNION ALL SELECT 'problem_list', 'snomed_code',
        COUNT(*), COUNT(*) FILTER (WHERE snomed_code IS NULL OR snomed_code = ''), 'MEDIUM'
    FROM amc_core.problem_list
    UNION ALL SELECT 'procedures', 'intervention_code',
        COUNT(*), COUNT(*) FILTER (WHERE intervention_code IS NULL OR intervention_code = ''), 'MEDIUM'
    FROM amc_core.procedures

) sub
ORDER BY severity, null_pct DESC;


-- =============================================================================
-- SECTION E — LAB_RESULT: BIGSERIAL PK AND NULL IN COMPOSITE KEY
-- =============================================================================
-- From notes: "labs still bigserial pk, null part of the pk"
-- The composite PK is (pseudo_id, sample_id, determination_code).
-- If any of these are NULL, the row has no meaningful identity.
-- Also check for duplicate rows on the composite key (bigserial is artificial).
-- =============================================================================

-- ----------------------------------------------------------------------------
-- E.1  NULL in composite PK components of lab_result
-- Any NULL in pseudo_id, sample_id, or determination_code means the row
-- cannot be reliably identified or joined. These rows should be quarantined.
-- ----------------------------------------------------------------------------
\! echo "  [E.1] Lab result composite PK null analysis — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[E.1] Lab result composite PK null/empty analysis'
\o /tmp/amc_dq/E1_lab_result_pk_nulls.csv

SELECT
    COUNT(*)                                                          AS total_lab_rows,
    COUNT(*) FILTER (WHERE pseudo_id IS NULL)                         AS null_pseudo_id,
    COUNT(*) FILTER (WHERE sample_id IS NULL OR sample_id = '')       AS null_sample_id,
    COUNT(*) FILTER (WHERE determination_code IS NULL
                        OR determination_code = '')                   AS null_determination_code,
    COUNT(*) FILTER (WHERE pseudo_id IS NULL
                        OR sample_id IS NULL OR sample_id = ''
                        OR determination_code IS NULL
                        OR determination_code = '')                   AS any_pk_component_null,
    ROUND(100.0 * COUNT(*) FILTER (WHERE pseudo_id IS NULL
                        OR sample_id IS NULL OR sample_id = ''
                        OR determination_code IS NULL
                        OR determination_code = '')
        / NULLIF(COUNT(*), 0), 2)                                     AS pct_with_pk_issue
FROM amc_core.lab_result;


-- ----------------------------------------------------------------------------
-- E.2  Duplicate rows on natural composite key in lab_result
-- Same (pseudo_id, sample_id, determination_code) appearing more than once
-- may indicate the bigserial is masking genuine duplicates from the ETL.
-- Shows how many natural key combinations have > 1 row and with different values.
-- ----------------------------------------------------------------------------
\! echo "  [E.2] Lab result duplicate natural keys — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[E.2] Lab result duplicate natural key combinations'
\o /tmp/amc_dq/E2_lab_result_duplicate_keys.csv

WITH dupe_check AS (
    SELECT
        pseudo_id, sample_id, determination_code,
        COUNT(*)                           AS n_rows,
        COUNT(DISTINCT result_numeric)     AS distinct_numeric_values,
        COUNT(DISTINCT result_text)        AS distinct_text_values,
        COUNT(DISTINCT result_date)        AS distinct_result_dates,
        MIN(result_numeric)                AS min_val,
        MAX(result_numeric)                AS max_val
    FROM amc_core.lab_result
    WHERE pseudo_id IS NOT NULL
      AND sample_id IS NOT NULL AND sample_id <> ''
      AND determination_code IS NOT NULL AND determination_code <> ''
    GROUP BY pseudo_id, sample_id, determination_code
    HAVING COUNT(*) > 1
)
SELECT
    n_rows AS duplicate_count,
    COUNT(*) AS n_natural_keys_with_this_count,
    SUM(CASE WHEN distinct_numeric_values > 1 THEN 1 ELSE 0 END) AS keys_with_different_values,
    SUM(CASE WHEN distinct_numeric_values = 1 THEN 1 ELSE 0 END) AS keys_with_same_value_exact_dupe
FROM dupe_check
GROUP BY n_rows
ORDER BY n_rows;


-- =============================================================================
-- SECTION F — LOGICAL DATE INCONSISTENCIES
-- =============================================================================
-- Discharge before admission, end before start, death before birth, etc.
-- These are clinically impossible and indicate ETL/source system issues.
-- =============================================================================

-- ----------------------------------------------------------------------------
-- F.1  Discharge before admission date
-- Negative LOS is impossible. These admissions must be excluded from any
-- LOS or timing analysis. Quantify per year to see if it's a recent issue.
-- ----------------------------------------------------------------------------
\! echo "  [F.1] Discharge before admission — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[F.1] Admission_traject: discharge_date before admission_date'
\o /tmp/amc_dq/F1_discharge_before_admission.csv

SELECT
    EXTRACT(YEAR FROM admission_date)::int AS admission_year,
    COUNT(*)                               AS n_negative_los,
    COUNT(DISTINCT pseudo_id)              AS n_patients,
    ROUND(AVG(admission_date - discharge_date), 1) AS avg_days_reversed,
    MAX(admission_date - discharge_date)   AS max_days_reversed
FROM amc_core.admission_traject
WHERE discharge_date IS NOT NULL
  AND admission_date IS NOT NULL
  AND discharge_date < admission_date
GROUP BY admission_year
ORDER BY n_negative_los DESC;


-- ----------------------------------------------------------------------------
-- F.2  Ward stay end before start (admission_partial_traject)
-- Each partial traject (ward stay) must end after it begins.
-- ----------------------------------------------------------------------------
\! echo "  [F.2] Partial traject end before start — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[F.2] Admission_partial_traject: end_date before start_date'
\o /tmp/amc_dq/F2_partial_traject_end_before_start.csv

SELECT
    COUNT(*)                              AS n_reversed_stays,
    COUNT(DISTINCT pseudo_id)             AS n_patients,
    ROUND(AVG(EXTRACT(EPOCH FROM (start_date_time - end_date_time))/3600), 1) AS avg_reversal_hours,
    MAX(EXTRACT(EPOCH FROM (start_date_time - end_date_time))/3600)::int AS max_reversal_hours
FROM amc_core.admission_partial_traject
WHERE end_date_time IS NOT NULL
  AND start_date_time IS NOT NULL
  AND end_date_time < start_date_time;


-- ----------------------------------------------------------------------------
-- F.3  Death date before admission date
-- Patient cannot die before they were admitted. Flags cross-table
-- date inconsistency — likely a year error in one of the sources.
-- ----------------------------------------------------------------------------
\! echo "  [F.3] Death before admission — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[F.3] Death registration date before any admission date'
\o /tmp/amc_dq/F3_death_before_admission.csv

SELECT
    COUNT(DISTINCT dr.pseudo_id)          AS patients_death_before_admission,
    ROUND(100.0 * COUNT(DISTINCT dr.pseudo_id) /
        (SELECT COUNT(*) FROM amc_core.death_registration), 2) AS pct_of_deceased
FROM amc_core.death_registration dr
WHERE EXISTS (
    SELECT 1 FROM amc_core.admission_traject at_
    WHERE at_.pseudo_id = dr.pseudo_id
      AND at_.admission_date > dr.meet_date
      AND at_.admission_date IS NOT NULL
);


-- ----------------------------------------------------------------------------
-- F.4  Medication administration before prescription start date
-- Administered before prescribed = impossible in normal workflow.
-- May indicate different medication record from a different contact or system.
-- ----------------------------------------------------------------------------
\! echo "  [F.4] Administration before prescription — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[F.4] Medication administered before prescription start_date'
\o /tmp/amc_dq/F4_admin_before_prescription.csv

SELECT
    COUNT(*)                              AS n_admin_before_rx,
    COUNT(DISTINCT ma.pseudo_id)          AS n_patients,
    ROUND(100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM amc_core.medication_administration
         WHERE rule_id IS NOT NULL), 2)   AS pct_of_linked_administrations
FROM amc_core.medication_administration ma
JOIN amc_core.medication_prescription mp
    ON ma.rule_id = mp.rule_id
WHERE ma.administration_date IS NOT NULL
  AND mp.start_date IS NOT NULL
  AND ma.administration_date < mp.start_date;


-- ----------------------------------------------------------------------------
-- F.5  Lab results with result_date before material collection date
-- Result cannot precede sample collection.
-- ----------------------------------------------------------------------------
\! echo "  [F.5] Lab result date before collection date — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[F.5] Lab result_date before material_decrease_date'
\o /tmp/amc_dq/F5_lab_result_before_collection.csv

SELECT
    COUNT(*)                              AS n_result_before_collection,
    COUNT(DISTINCT pseudo_id)             AS n_patients,
    ROUND(100.0 * COUNT(*) / NULLIF(
        (SELECT COUNT(*) FROM amc_core.lab_result
         WHERE result_date IS NOT NULL AND material_decrease_date IS NOT NULL), 0), 2) AS pct
FROM amc_core.lab_result
WHERE result_date IS NOT NULL
  AND material_decrease_date IS NOT NULL
  AND result_date < material_decrease_date;


-- =============================================================================
-- SECTION G — DUPLICATE EVENTS PER PATIENT
-- =============================================================================

-- ----------------------------------------------------------------------------
-- G.1  Patients with multiple death registrations
-- Should be exactly 1 per deceased patient. Multiples = ETL issue.
-- Show how many registrations and whether death dates agree.
-- ----------------------------------------------------------------------------
\! echo "  [G.1] Multiple death registrations — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[G.1] Patients with multiple death registrations'
\o /tmp/amc_dq/G1_multiple_death_registrations.csv

SELECT
    pseudo_id,
    COUNT(*)                  AS n_death_records,
    COUNT(DISTINCT meet_date) AS distinct_death_dates,
    MIN(meet_date)            AS earliest_date,
    MAX(meet_date)            AS latest_date,
    MAX(meet_date) - MIN(meet_date) AS date_range_days
FROM amc_core.death_registration
GROUP BY pseudo_id
HAVING COUNT(*) > 1
ORDER BY n_death_records DESC
LIMIT 50;


-- ----------------------------------------------------------------------------
-- G.2  Duplicate lab results — same patient, sample, test, but different values
-- These are the genuinely problematic duplicates from E.2.
-- Inspect determination_code distribution among duplicates with different values.
-- ----------------------------------------------------------------------------
\! echo "  [G.2] Lab results with conflicting values — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[G.2] Lab: top determination_codes with conflicting duplicate values'
\o /tmp/amc_dq/G2_lab_conflicting_duplicate_values.csv

SELECT
    determination_code,
    determination,
    COUNT(*) AS n_natural_keys_with_conflict,
    COUNT(DISTINCT pseudo_id) AS n_patients_affected
FROM amc_core.lab_result lr
WHERE (pseudo_id, sample_id, determination_code) IN (
    SELECT pseudo_id, sample_id, determination_code
    FROM amc_core.lab_result
    WHERE pseudo_id IS NOT NULL AND sample_id IS NOT NULL AND determination_code IS NOT NULL
    GROUP BY pseudo_id, sample_id, determination_code
    HAVING COUNT(DISTINCT result_numeric) > 1
)
GROUP BY determination_code, determination
ORDER BY n_natural_keys_with_conflict DESC
LIMIT 30;


-- =============================================================================
-- SECTION H — MEDICATION CHAIN INTEGRITY
-- =============================================================================

-- ----------------------------------------------------------------------------
-- H.1  Prescription amendment chain — orphan previous_prescription_id
-- medication_prescription.previous_prescription_id references rule_id in the
-- same table. Orphan = previous_prescription_id not found in rule_id.
-- Notes: "self-ref — check pending"
-- ----------------------------------------------------------------------------
\! echo "  [H.1] Orphan previous_prescription_id — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[H.1] Medication prescription: orphan previous_prescription_id'
\o /tmp/amc_dq/H1_orphan_previous_prescription.csv

SELECT
    COUNT(*)                              AS total_with_previous_id,
    COUNT(*) FILTER (WHERE prev.rule_id IS NULL) AS orphan_previous_ids,
    ROUND(100.0 * COUNT(*) FILTER (WHERE prev.rule_id IS NULL)
        / NULLIF(COUNT(*), 0), 2)        AS orphan_pct
FROM amc_core.medication_prescription mp
LEFT JOIN amc_core.medication_prescription prev
    ON mp.previous_prescription_id = prev.rule_id
WHERE mp.previous_prescription_id IS NOT NULL
  AND mp.previous_prescription_id <> '';


-- ----------------------------------------------------------------------------
-- H.2  Administration without matching prescription (unlinked rule_id)
-- medication_administration.rule_id should match medication_prescription.rule_id.
-- Unlinked administrations cannot be enriched with ATC hierarchy or dose info.
-- ----------------------------------------------------------------------------
\! echo "  [H.2] Administration without prescription — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[H.2] Medication administration with no matching prescription'
\o /tmp/amc_dq/H2_admin_without_prescription.csv

SELECT
    COUNT(*)                              AS total_administrations,
    COUNT(*) FILTER (WHERE rule_id IS NOT NULL AND rule_id <> '') AS with_rule_id,
    COUNT(*) FILTER (WHERE rule_id IS NOT NULL AND rule_id <> ''
        AND NOT EXISTS (SELECT 1 FROM amc_core.medication_prescription mp
                        WHERE mp.rule_id = ma.rule_id)) AS orphan_rule_ids,
    ROUND(100.0 * COUNT(*) FILTER (WHERE rule_id IS NOT NULL AND rule_id <> ''
        AND NOT EXISTS (SELECT 1 FROM amc_core.medication_prescription mp
                        WHERE mp.rule_id = ma.rule_id))
        / NULLIF(COUNT(*) FILTER (WHERE rule_id IS NOT NULL AND rule_id <> ''), 0), 2) AS orphan_pct
FROM amc_core.medication_administration ma;


-- =============================================================================
-- SECTION I — NOTE LINKAGE GAPS
-- =============================================================================

-- ----------------------------------------------------------------------------
-- I.1  Notes without a matching amc_notes record
-- patient_note_patient_contact.patient_note_id → amc_notes.note_id
-- Orphan note_ids mean the bridge table references non-existent notes.
-- Critical for NLP pipeline: you can't extract text from a missing note.
-- ----------------------------------------------------------------------------
\! echo "  [I.1] Note bridge orphans — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[I.1] patient_note_patient_contact: orphan patient_note_id (no amc_notes record)'
\o /tmp/amc_dq/I1_note_bridge_orphans.csv

SELECT
    COUNT(*)                              AS total_note_contact_rows,
    COUNT(*) FILTER (WHERE patient_note_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM amc_core.amc_notes an
                        WHERE an.note_id = nn.patient_note_id)) AS orphan_note_ids,
    ROUND(100.0 * COUNT(*) FILTER (WHERE patient_note_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM amc_core.amc_notes an
                        WHERE an.note_id = nn.patient_note_id))
        / NULLIF(COUNT(*), 0), 2)        AS orphan_pct
FROM amc_core.patient_note_patient_contact nn;


-- ----------------------------------------------------------------------------
-- I.2  amc_notes with no bridge record (unreferenced notes)
-- Notes in amc_notes not referenced by patient_note_patient_contact have
-- no patient or contact context — they cannot be used for NLP cohort work.
-- ----------------------------------------------------------------------------
\! echo "  [I.2] Unreferenced notes in amc_notes — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[I.2] amc_notes rows with no patient_note_patient_contact reference'
\o /tmp/amc_dq/I2_unreferenced_notes.csv

SELECT
    COUNT(*)                              AS total_amc_notes,
    COUNT(*) FILTER (WHERE NOT EXISTS (
        SELECT 1 FROM amc_core.patient_note_patient_contact nn
        WHERE nn.patient_note_id = an.note_id)) AS unreferenced_notes,
    ROUND(100.0 * COUNT(*) FILTER (WHERE NOT EXISTS (
        SELECT 1 FROM amc_core.patient_note_patient_contact nn
        WHERE nn.patient_note_id = an.note_id))
        / NULLIF(COUNT(*), 0), 2)        AS unreferenced_pct
FROM amc_core.amc_notes an;


-- =============================================================================
-- SECTION J — CROSS-TABLE DATE CONSISTENCY
-- =============================================================================

-- ----------------------------------------------------------------------------
-- J.1  Lab results dated outside of any known admission for that patient
-- For ICU patients, lab results should fall within an admission window.
-- Results far outside all admission windows may be from other episodes or errors.
-- Note: some outpatient labs are expected outside admissions — flag only extremes.
-- ----------------------------------------------------------------------------
\! echo "  [J.1] Lab results outside admission windows — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[J.1] Lab results dated outside any admission window (>30 days outside)'
\o /tmp/amc_dq/J1_lab_outside_admission.csv

WITH admitted_patients AS (
    SELECT DISTINCT pseudo_id FROM amc_core.admission_traject
),
labs_vs_admissions AS (
    SELECT
        lr.pseudo_id,
        lr.result_date,
        (SELECT MAX(at_.discharge_date)
         FROM amc_core.admission_traject at_
         WHERE at_.pseudo_id = lr.pseudo_id
           AND lr.result_date BETWEEN at_.admission_date - 1
                                  AND at_.discharge_date + 30) AS matched_admission_discharge
    FROM amc_core.lab_result lr
    INNER JOIN admitted_patients ap ON lr.pseudo_id = ap.pseudo_id
    WHERE lr.result_date IS NOT NULL
)
SELECT
    COUNT(*)                              AS total_labs_for_admitted_patients,
    COUNT(*) FILTER (WHERE matched_admission_discharge IS NULL) AS labs_outside_any_admission_window,
    ROUND(100.0 * COUNT(*) FILTER (WHERE matched_admission_discharge IS NULL)
        / NULLIF(COUNT(*), 0), 2)        AS pct_outside
FROM labs_vs_admissions;


-- ----------------------------------------------------------------------------
-- J.2  Measurement dates vs patient contact dates consistency
-- Vital signs should be recorded during a known contact.
-- Measurements dated more than 1 day before/after any contact for that patient
-- may indicate date entry errors or data from a different system.
-- ----------------------------------------------------------------------------
\! echo "  [J.2] Vitals outside any contact window — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[J.2] Blood pressure measurements with no patient_contact within 1 day'
\o /tmp/amc_dq/J2_vitals_outside_contact_window.csv

SELECT
    COUNT(*)                              AS total_bp_measurements,
    COUNT(*) FILTER (WHERE NOT EXISTS (
        SELECT 1 FROM amc_core.patient_contact pc
        WHERE pc.pseudo_id = mbp.pseudo_id
          AND mbp.meet_date BETWEEN pc.patient_contact_date - 1
                                AND pc.patient_contact_date + 1
    ))                                   AS measurements_outside_contact_window,
    ROUND(100.0 * COUNT(*) FILTER (WHERE NOT EXISTS (
        SELECT 1 FROM amc_core.patient_contact pc
        WHERE pc.pseudo_id = mbp.pseudo_id
          AND mbp.meet_date BETWEEN pc.patient_contact_date - 1
                                AND pc.patient_contact_date + 1
    )) / NULLIF(COUNT(*), 0), 2)         AS pct_outside
FROM amc_core.measurement_blood_pressure mbp
WHERE meet_date IS NOT NULL;


-- =============================================================================
-- SECTION K — SUMMARY DASHBOARD
-- =============================================================================
-- One-page overview of all issue counts for slide/report use.
-- Each row = one issue category with count, affected patients, and severity.
-- =============================================================================

\! echo "  [K.1] Summary dashboard — $(date +%H:%M:%S)" >> /tmp/amc_dq/run.log
\echo '[K.1] Data quality issue summary dashboard'
\o /tmp/amc_dq/K1_summary_dashboard.csv

SELECT
    issue_category,
    issue_description,
    affected_rows,
    affected_patients,
    ROUND(100.0 * affected_patients /
        NULLIF((SELECT COUNT(*) FROM amc_core.patient_not_traceable), 0), 2) AS pct_of_all_patients,
    severity,
    recommended_action
FROM (VALUES

    ('A - Traceability',
     'Patients with 0 event domain records (ghost patients)',
     NULL::bigint,
     (SELECT COUNT(*) FROM amc_core.patient_not_traceable p
      WHERE NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc WHERE pc.pseudo_id = p.pseudo_id)
        AND NOT EXISTS (SELECT 1 FROM amc_core.admission_traject at_ WHERE at_.pseudo_id = p.pseudo_id)
        AND NOT EXISTS (SELECT 1 FROM amc_core.lab_result lr WHERE lr.pseudo_id = p.pseudo_id)),
     'CRITICAL', 'Exclude from cohorts; investigate ETL source'),

    ('B - Dates',
     'Admission dates before 2000-01-01',
     (SELECT COUNT(*) FROM amc_core.admission_traject WHERE admission_date < '2000-01-01'),
     (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.admission_traject WHERE admission_date < '2000-01-01'),
     'HIGH', 'Flag; verify with source; drop or use admission_date_time instead'),

    ('B - Dates',
     'Discharge dates more than 10y in future',
     (SELECT COUNT(*) FROM amc_core.admission_traject WHERE discharge_date > CURRENT_DATE + INTERVAL '10 years'),
     (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.admission_traject WHERE discharge_date > CURRENT_DATE + INTERVAL '10 years'),
     'HIGH', 'Likely open/ongoing admissions coded with placeholder date'),

    ('B - Dates',
     'Medication stop_date after year 2100 (placeholder)',
     (SELECT COUNT(*) FROM amc_core.medication_prescription WHERE stop_date > '2100-01-01'),
     (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.medication_prescription WHERE stop_date > '2100-01-01'),
     'MEDIUM', 'Treat as "no end date" — exclude stop_date from time-windowed queries'),

    ('C - Orphan IDs',
     'Admission_traject rows with contact_id not in patient_contact',
     (SELECT COUNT(*) FROM amc_core.admission_traject at_
      WHERE patient_contact_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                        WHERE pc.patient_contact_id = at_.patient_contact_id)),
     (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.admission_traject at_
      WHERE patient_contact_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM amc_core.patient_contact pc
                        WHERE pc.patient_contact_id = at_.patient_contact_id)),
     'HIGH', 'Use pseudo_id as fallback join; report pattern to RDP/ICT'),

    ('D - Nulls',
     'Admissions with NULL admission_date',
     (SELECT COUNT(*) FROM amc_core.admission_traject WHERE admission_date IS NULL),
     (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.admission_traject WHERE admission_date IS NULL),
     'HIGH', 'Exclude from LOS and timing analyses'),

    ('D - Nulls',
     'Admissions with NULL discharge_date (open stays)',
     (SELECT COUNT(*) FROM amc_core.admission_traject WHERE discharge_date IS NULL),
     (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.admission_traject WHERE discharge_date IS NULL),
     'MEDIUM', 'Keep but flag; LOS not computable; may be current admissions'),

    ('D - Nulls',
     'Lab results with NULL determination_code',
     (SELECT COUNT(*) FROM amc_core.lab_result WHERE determination_code IS NULL OR determination_code = ''),
     (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.lab_result WHERE determination_code IS NULL OR determination_code = ''),
     'CRITICAL', 'Cannot classify test — exclude from test-specific analyses'),

    ('E - Lab PK',
     'Lab rows with any composite PK component null/empty',
     (SELECT COUNT(*) FROM amc_core.lab_result
      WHERE pseudo_id IS NULL OR sample_id IS NULL OR sample_id = ''
         OR determination_code IS NULL OR determination_code = ''),
     (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.lab_result
      WHERE sample_id IS NULL OR sample_id = ''
         OR determination_code IS NULL OR determination_code = ''),
     'CRITICAL', 'Cannot uniquely identify row — quarantine before analysis'),

    ('F - Logic',
     'Admissions with discharge before admission date',
     (SELECT COUNT(*) FROM amc_core.admission_traject
      WHERE discharge_date IS NOT NULL AND discharge_date < admission_date),
     (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.admission_traject
      WHERE discharge_date IS NOT NULL AND discharge_date < admission_date),
     'CRITICAL', 'Exclude from all LOS calculations'),

    ('F - Logic',
     'Ward stays with end before start (partial_traject)',
     (SELECT COUNT(*) FROM amc_core.admission_partial_traject
      WHERE end_date_time IS NOT NULL AND end_date_time < start_date_time),
     (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.admission_partial_traject
      WHERE end_date_time IS NOT NULL AND end_date_time < start_date_time),
     'HIGH', 'Exclude from ward-level LOS and ICU duration analyses'),

    ('G - Duplicates',
     'Patients with more than 1 death registration',
     (SELECT COUNT(*) FROM (SELECT pseudo_id FROM amc_core.death_registration
                             GROUP BY pseudo_id HAVING COUNT(*) > 1) x),
     (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.death_registration
      GROUP BY pseudo_id HAVING COUNT(*) > 1),
     'HIGH', 'Deduplicate; keep earliest or most complete record'),

    ('H - Med chain',
     'Medication administrations with no matching prescription',
     (SELECT COUNT(*) FROM amc_core.medication_administration ma
      WHERE rule_id IS NOT NULL AND rule_id <> ''
        AND NOT EXISTS (SELECT 1 FROM amc_core.medication_prescription mp
                        WHERE mp.rule_id = ma.rule_id)),
     (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.medication_administration ma
      WHERE rule_id IS NOT NULL AND rule_id <> ''
        AND NOT EXISTS (SELECT 1 FROM amc_core.medication_prescription mp
                        WHERE mp.rule_id = ma.rule_id)),
     'MEDIUM', 'Cannot enrich with ATC hierarchy — flag in output'),

    ('I - Notes',
     'Note bridge rows with orphan patient_note_id (no amc_notes record)',
     (SELECT COUNT(*) FROM amc_core.patient_note_patient_contact nn
      WHERE patient_note_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM amc_core.amc_notes an
                        WHERE an.note_id = nn.patient_note_id)),
     (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.patient_note_patient_contact nn
      WHERE patient_note_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM amc_core.amc_notes an
                        WHERE an.note_id = nn.patient_note_id)),
     'CRITICAL', 'Cannot retrieve note text — exclude from NLP pipeline')

) AS issues(issue_category, issue_description, affected_rows, affected_patients, severity, recommended_action)
ORDER BY severity, affected_patients DESC NULLS LAST;


-- ── Close output and write final log ──────────────────────────────────────────
\o

\o /tmp/amc_dq/run.log
\! echo ""
\! echo "Finished: $(date)"
\! echo "CSVs written to /tmp/amc_dq/"
\! ls -lh /tmp/amc_dq/*.csv 2>/dev/null | awk '{print $5, $9}'
\o

\echo ''
\echo '✓ Data quality audit complete.'
\echo '  Open K1_summary_dashboard.csv first for the overview.'
\timing off
