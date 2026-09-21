-- =============================================================================
-- AMC CORE — EXPLORATORY ANALYSIS  (psql output version)
-- =============================================================================
-- HOW TO RUN (from inside psql):
--
--   1. Create output directory on the server:
--        \! mkdir -p /your/path/amc_results
--
--   2. Set your output base path — edit the line below:
--        \set outdir '/your/path/amc_results'
--
--   3. Run this file:
--        \i /your/path/amc_core_exploratory_analysis_psql.sql
--
--   4. Detach from tmux (Ctrl+B D) — it keeps running.
--      Results land in /your/path/amc_results/ as individual CSV files.
--      A run.log file records timing and progress.
-- =============================================================================

-- ── Global psql settings ─────────────────────────────────────────────────────
\pset format csv
\pset tuples_only off
\pset footer on
\timing on
\set ON_ERROR_CONTINUE on

-- ── IMPORTANT: Customise your output path before running ─────────────────────
-- Change BOTH occurrences of /tmp/amc_results below to your preferred path:
--   (1) The \set outdir line
--   (2) The \! mkdir -p line
--   (3) The \o /tmp/amc_results/run.log lines
--
-- Quick way: from your shell BEFORE entering psql, run:
--   sed 's|/tmp/amc_results|/your/actual/path|g' \
--       amc_core_exploratory_analysis_psql.sql > amc_run.sql
-- Then from inside psql:
--   \i /path/to/amc_run.sql
--
-- Requires psql >= 9.3 for \set variable interpolation in \o paths.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Edit this path to match your server ──────────────────────────────────────
\set outdir '/tmp/amc_results'

-- ── Create output directory ───────────────────────────────────────────────────
\! mkdir -p /tmp/amc_results

-- ── Start log ────────────────────────────────────────────────────────────────
\o /tmp/amc_results/run.log
\echo '============================================================'
\echo 'AMC Core Exploratory Analysis'
\echo '============================================================'
\echo ''
\! echo "Started: $(date)"
\o

-- =============================================================================
-- AMC CORE — COMPREHENSIVE EXPLORATORY ANALYSIS QUERIES
-- =============================================================================
-- Purpose : Understand the data landscape before building research cohorts.
--           Each query is self-contained and annotated so that non-technical
--           stakeholders can follow what is being measured and why it matters.
-- Schema  : amc_core
-- Audience: Data analysts, clinicians, slide-deck authors
-- Note    : All queries use LEFT JOINs where coverage may be incomplete.
--           Replace 'amc_core' with your local schema alias if needed.
-- =============================================================================


-- =============================================================================
-- SECTION 0 — STANDARD CODING SYSTEMS IN THIS DATASET
-- =============================================================================
-- Before running analysis it is important to know which internationally
-- recognised coding standards are present. This determines which external
-- reference ontologies or terminologies can be linked to the data.
--
-- CODING SYSTEMS FOUND IN AMC CORE:
--
--  System        | Column(s)                          | Table(s)
--  --------------|------------------------------------|-----------------------------------------
--  ATC           | atc_code, atc_code_niv1..5         | medication_atc (lookup), medication_prescription, medication_administration
--                |                                    | → 5-level hierarchy (anatomical → chemical substance)
--  SNOMED-CT     | snomed_code                        | problem_list
--                |                                    | → Only present on problem_list; not on diagnosis tables
--  Diagnose      | diagnose_thesaurus_code            | problem_list
--  Thesaurus     |                                    | → Dutch clinical thesaurus code; often maps to ICD
--  ICD-like      | diagnosis_code, diagnosis_category | medical_diagnosis, medical_history, problem_list
--                |                                    | → Format not guaranteed ICD-10; verify with your EPR team
--  DBC           | dbc_diagnosis                      | ok_procedure_performed, ok_procedure_planned
--                |                                    | → Dutch hospital billing code (Diagnose Behandeling Combinatie)
--  Intervention  | intervention_code                  | procedures, ok_procedure_performed, ok_procedure_planned
--                |                                    | → Dutch procedure classification (CBV/DHD)
--  SEH Triage    | seh_triagecode                     | seh_trajectory
--                |                                    | → Manchester Triage System (MTS) or local equivalent
--  Lab LOINC-    | determination_code, determination  | lab_result
--  like codes    |                                    | → Locally defined; map to LOINC manually if needed
--  ECG codes     | test_code, test_type_code          | ecg_measurement, ecg_measurement_test_feature
--  ATC hierarchy:
--    atc_code_niv1 = Anatomical main group    (e.g., C = Cardiovascular)
--    atc_code_niv2 = Therapeutic subgroup     (e.g., C09 = Agents acting on RAAS)
--    atc_code_niv3 = Pharmacological subgroup
--    atc_code_niv4 = Chemical subgroup
--    atc_code_niv5 = Chemical substance (leaf)
-- =============================================================================


-- =============================================================================
-- SECTION 1 — DATASET OVERVIEW
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [01/61] 1.1 Row counts per table — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[01] Running: 1.1 Row counts per table'
\o :outdir/01_1_1_row_counts_per_table.csv
-- 1.1  Row counts per table
-- Gives a quick sense of data volume and which domains are richest.
-- Large row counts indicate high-frequency measurements or longitudinal data.
-- ----------------------------------------------------------------------------
SELECT 'patient_not_traceable'                   AS table_name, COUNT(*) AS row_count FROM amc_core.patient_not_traceable
UNION ALL SELECT 'patient_contact',              COUNT(*) FROM amc_core.patient_contact
UNION ALL SELECT 'patient_social',               COUNT(*) FROM amc_core.patient_social
UNION ALL SELECT 'admission_traject',            COUNT(*) FROM amc_core.admission_traject
UNION ALL SELECT 'admission_partial_traject',    COUNT(*) FROM amc_core.admission_partial_traject
UNION ALL SELECT 'seh_trajectory',               COUNT(*) FROM amc_core.seh_trajectory
UNION ALL SELECT 'death_registration',           COUNT(*) FROM amc_core.death_registration
UNION ALL SELECT 'medical_diagnosis',            COUNT(*) FROM amc_core.medical_diagnosis
UNION ALL SELECT 'medical_history',              COUNT(*) FROM amc_core.medical_history
UNION ALL SELECT 'problem_list',                 COUNT(*) FROM amc_core.problem_list
UNION ALL SELECT 'medication_prescription',      COUNT(*) FROM amc_core.medication_prescription
UNION ALL SELECT 'medication_administration',    COUNT(*) FROM amc_core.medication_administration
UNION ALL SELECT 'procedures',                   COUNT(*) FROM amc_core.procedures
UNION ALL SELECT 'ok_procedure_performed',       COUNT(*) FROM amc_core.ok_procedure_performed
UNION ALL SELECT 'imaging_study_order',          COUNT(*) FROM amc_core.imaging_study_order
UNION ALL SELECT 'lab_result',                   COUNT(*) FROM amc_core.lab_result
UNION ALL SELECT 'ecg_measurement',              COUNT(*) FROM amc_core.ecg_measurement
UNION ALL SELECT 'echo_measurement_heart',       COUNT(*) FROM amc_core.echo_measurement_heart
UNION ALL SELECT 'measurement_blood_pressure',   COUNT(*) FROM amc_core.measurement_blood_pressure
UNION ALL SELECT 'measurement_vital_signs_data', COUNT(*) FROM amc_core.measurement_vital_signs_data
UNION ALL SELECT 'patient_note_patient_contact', COUNT(*) FROM amc_core.patient_note_patient_contact
UNION ALL SELECT 'adverse_event',                COUNT(*) FROM amc_core.adverse_event
UNION ALL SELECT 'tobacco_use',                  COUNT(*) FROM amc_core.tobacco_use
UNION ALL SELECT 'family_history',               COUNT(*) FROM amc_core.family_history
UNION ALL SELECT 'surgery_history',              COUNT(*) FROM amc_core.surgery_history
ORDER BY row_count DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [02/61] 1.2 Unique patients per domain — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[02] Running: 1.2 Unique patients per domain'
\o :outdir/02_1_2_unique_patients_per_domain.csv
-- 1.2  Unique patients per domain
-- Critical sanity check: how many distinct patients are represented in each
-- data domain? Discrepancies reveal whether data is complete or selective.
-- ----------------------------------------------------------------------------
SELECT 'patient_not_traceable'                   AS domain, COUNT(DISTINCT pseudo_id) AS unique_patients FROM amc_core.patient_not_traceable
UNION ALL SELECT 'patient_contact',              COUNT(DISTINCT pseudo_id) FROM amc_core.patient_contact
UNION ALL SELECT 'admission_traject',            COUNT(DISTINCT pseudo_id) FROM amc_core.admission_traject
UNION ALL SELECT 'seh_trajectory',               COUNT(DISTINCT pseudo_id) FROM amc_core.seh_trajectory
UNION ALL SELECT 'medical_diagnosis',            COUNT(DISTINCT pseudo_id) FROM amc_core.medical_diagnosis
UNION ALL SELECT 'medication_prescription',      COUNT(DISTINCT pseudo_id) FROM amc_core.medication_prescription
UNION ALL SELECT 'lab_result',                   COUNT(DISTINCT pseudo_id) FROM amc_core.lab_result
UNION ALL SELECT 'ecg_measurement',              COUNT(DISTINCT pseudo_id) FROM amc_core.ecg_measurement
UNION ALL SELECT 'death_registration',           COUNT(DISTINCT pseudo_id) FROM amc_core.death_registration
ORDER BY unique_patients DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [03/61] 1.3 Data time range per key table — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[03] Running: 1.3 Data time range per key table'
\o :outdir/03_1_3_data_time_range_per_key_table.csv
-- 1.3  Data time range per key table
-- Shows the earliest and latest event dates. Essential for understanding the
-- observation window and identifying data completeness issues at edges.
-- ----------------------------------------------------------------------------
SELECT 'patient_contact'     AS source, MIN(patient_contact_date) AS earliest, MAX(patient_contact_date) AS latest FROM amc_core.patient_contact
UNION ALL SELECT 'admission_traject',   MIN(admission_date),     MAX(admission_date)   FROM amc_core.admission_traject
UNION ALL SELECT 'death_registration',  MIN(meet_date),          MAX(meet_date)        FROM amc_core.death_registration
UNION ALL SELECT 'lab_result',          MIN(result_date),        MAX(result_date)      FROM amc_core.lab_result
UNION ALL SELECT 'medication_prescription', MIN(prescription_date), MAX(prescription_date) FROM amc_core.medication_prescription
UNION ALL SELECT 'medical_diagnosis',   MIN(diagnosis_contact_date), MAX(diagnosis_contact_date) FROM amc_core.medical_diagnosis
UNION ALL SELECT 'imaging_study_order', MIN(start_date),         MAX(start_date)       FROM amc_core.imaging_study_order
ORDER BY source;


-- =============================================================================
-- SECTION 2 — PATIENT DEMOGRAPHICS
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [04/61] 2.1 Age distribution at time of first contact — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[04] Running: 2.1 Age distribution at time of first contact'
\o :outdir/04_2_1_age_distribution_at_time_of_first_contact.csv
-- 2.1  Age distribution at time of first contact
-- Birth year is available; age is approximated as current_year - year_of_birth.
-- Distribution into bands helps understand which age groups are best represented.
-- ----------------------------------------------------------------------------
SELECT
    CASE
        WHEN (EXTRACT(YEAR FROM CURRENT_DATE) - year_of_birth) < 18  THEN '0-17'
        WHEN (EXTRACT(YEAR FROM CURRENT_DATE) - year_of_birth) < 40  THEN '18-39'
        WHEN (EXTRACT(YEAR FROM CURRENT_DATE) - year_of_birth) < 60  THEN '40-59'
        WHEN (EXTRACT(YEAR FROM CURRENT_DATE) - year_of_birth) < 75  THEN '60-74'
        WHEN (EXTRACT(YEAR FROM CURRENT_DATE) - year_of_birth) < 85  THEN '75-84'
        ELSE '85+'
    END                        AS age_band,
    COUNT(*)                   AS n_patients,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM amc_core.patient_not_traceable
WHERE year_of_birth IS NOT NULL
GROUP BY age_band
ORDER BY age_band;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [05/61] 2.2 Sex distribution — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[05] Running: 2.2 Sex distribution'
\o :outdir/05_2_2_sex_distribution.csv
-- 2.2  Sex distribution
-- Basic demographic split. Note: 'gender' field — check local value labels.
-- ----------------------------------------------------------------------------
SELECT
    gender,
    COUNT(*)                   AS n_patients,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM amc_core.patient_not_traceable
GROUP BY gender
ORDER BY n_patients DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [06/61] 2.3 Deceased vs alive — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[06] Running: 2.3 Deceased vs alive'
\o :outdir/06_2_3_deceased_vs_alive.csv
-- 2.3  Deceased vs alive
-- Useful for mortality studies and for flagging patients who should be excluded
-- from analyses requiring ongoing follow-up.
-- ----------------------------------------------------------------------------
SELECT
    is_deceased,
    COUNT(*)                   AS n_patients,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM amc_core.patient_not_traceable
GROUP BY is_deceased;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [07/61] 2.4 Year of death distribution (deceased patients only) — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[07] Running: 2.4 Year of death distribution (deceased patients only)'
\o :outdir/07_2_4_year_of_death_distribution_deceased_patients_only.csv
-- 2.4  Year of death distribution (deceased patients only)
-- Shows mortality trend over time. Spikes may indicate data refresh cycles
-- or real clinical events (e.g., pandemic years).
-- ----------------------------------------------------------------------------
SELECT
    year_of_death,
    COUNT(*)                   AS deaths
FROM amc_core.patient_not_traceable
WHERE is_deceased = 'J'          -- adjust value label if needed ('Y','1','true')
  AND year_of_death IS NOT NULL
GROUP BY year_of_death
ORDER BY year_of_death;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [08/61] 2.5 Marital status and education level distribution — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[08] Running: 2.5 Marital status and education level distribution'
\o :outdir/08_2_5_marital_status_and_education_level_distribution.csv
-- 2.5  Marital status and education level distribution
-- Social determinants of health. Useful for cohort characterisation tables.
-- From patient_social — not all patients will have this record.
-- ----------------------------------------------------------------------------
SELECT
    ps.marital_status,
    ps.education_level,
    COUNT(*)                   AS n
FROM amc_core.patient_social ps
GROUP BY ps.marital_status, ps.education_level
ORDER BY n DESC;


-- =============================================================================
-- SECTION 3 — HOSPITAL CONTACTS AND ENCOUNTER VOLUME
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [09/61] 3.1 Contact volume by year and contact type — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[09] Running: 3.1 Contact volume by year and contact type'
\o :outdir/09_3_1_contact_volume_by_year_and_contact_type.csv
-- 3.1  Contact volume by year and contact type
-- Shows activity trends over time and the mix of outpatient vs inpatient vs
-- emergency contacts. Large year-over-year jumps may indicate ETL scope changes.
-- ----------------------------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM pc.patient_contact_date)::int AS contact_year,
    pc.patient_contact_type,
    COUNT(*)                   AS n_contacts,
    COUNT(DISTINCT pc.pseudo_id) AS unique_patients
FROM amc_core.patient_contact pc
WHERE pc.patient_contact_date IS NOT NULL
GROUP BY contact_year, pc.patient_contact_type
ORDER BY contact_year DESC, n_contacts DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [10/61] 3.2 Contacts per patient — distribution — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[10] Running: 3.2 Contacts per patient — distribution'
\o :outdir/10_3_2_contacts_per_patient_distribution.csv
-- 3.2  Contacts per patient — distribution
-- Reveals how longitudinal the dataset is. Patients with 1 contact are likely
-- one-off encounters; patients with many contacts are long-term users.
-- ----------------------------------------------------------------------------
WITH contacts_per_patient AS (
    SELECT pseudo_id, COUNT(*) AS n_contacts
    FROM amc_core.patient_contact
    GROUP BY pseudo_id
)
SELECT
    CASE
        WHEN n_contacts = 1  THEN '1'
        WHEN n_contacts <= 5 THEN '2-5'
        WHEN n_contacts <= 10 THEN '6-10'
        WHEN n_contacts <= 25 THEN '11-25'
        WHEN n_contacts <= 50 THEN '26-50'
        ELSE '51+'
    END AS contacts_band,
    COUNT(*) AS n_patients,
    ROUND(AVG(n_contacts), 1) AS avg_contacts_in_band
FROM contacts_per_patient
GROUP BY contacts_band
ORDER BY MIN(n_contacts);


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [11/61] 3.3 Top 20 specialties by contact volume — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[11] Running: 3.3 Top 20 specialties by contact volume'
\o :outdir/11_3_3_top_20_specialties_by_contact_volume.csv
-- 3.3  Top 20 specialties by contact volume
-- Which specialties generate the most encounters? Useful for scoping cohorts
-- to specific clinical areas (e.g., cardiology, oncology, ICU).
-- ----------------------------------------------------------------------------
SELECT
    pc.specialty,
    COUNT(*)                   AS n_contacts,
    COUNT(DISTINCT pc.pseudo_id) AS unique_patients
FROM amc_core.patient_contact pc
WHERE pc.specialty IS NOT NULL
GROUP BY pc.specialty
ORDER BY n_contacts DESC
LIMIT 20;


-- =============================================================================
-- SECTION 4 — HOSPITAL ADMISSIONS (TRAJECTEN)
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [12/61] 4.1 Annual admission volume — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[12] Running: 4.1 Annual admission volume'
\o :outdir/12_4_1_annual_admission_volume.csv
-- 4.1  Annual admission volume
-- Trend in inpatient admissions over time. Useful to set the observation window
-- for cohort studies and identify periods of high/low data completeness.
-- ----------------------------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM admission_date)::int AS admission_year,
    COUNT(*)                   AS n_admissions,
    COUNT(DISTINCT pseudo_id)  AS unique_patients
FROM amc_core.admission_traject
WHERE admission_date IS NOT NULL
GROUP BY admission_year
ORDER BY admission_year DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [13/61] 4.2 Hospital length of stay — descriptive statistics — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[13] Running: 4.2 Hospital length of stay — descriptive statistics'
\o :outdir/13_4_2_hospital_length_of_stay_descriptive_statistics.csv
-- 4.2  Hospital length of stay — descriptive statistics
-- Length of stay (LOS) is a key quality and resource metric.
-- Computed as discharge_date - admission_date (in days).
-- Negative or zero values indicate data issues and should be inspected.
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)                                                    AS n_admissions,
    ROUND(AVG(discharge_date - admission_date), 1)              AS mean_los_days,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY (discharge_date - admission_date)) AS p25_los,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY (discharge_date - admission_date)) AS median_los,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY (discharge_date - admission_date)) AS p75_los,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY (discharge_date - admission_date)) AS p90_los,
    MAX(discharge_date - admission_date)                        AS max_los_days,
    COUNT(*) FILTER (WHERE discharge_date < admission_date)     AS data_issue_negative_los,
    COUNT(*) FILTER (WHERE discharge_date IS NULL)              AS missing_discharge_date
FROM amc_core.admission_traject;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [14/61] 4.3 LOS distribution by admission type — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[14] Running: 4.3 LOS distribution by admission type'
\o :outdir/14_4_3_los_distribution_by_admission_type.csv
-- 4.3  LOS distribution by admission type
-- Elective vs emergency admissions differ markedly in LOS. This breakdown
-- feeds into case-mix adjustment and cohort stratification.
-- ----------------------------------------------------------------------------
SELECT
    admission_type,
    COUNT(*)                                                    AS n,
    ROUND(AVG(discharge_date - admission_date), 1)              AS mean_los_days,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY (discharge_date - admission_date)) AS median_los
FROM amc_core.admission_traject
WHERE admission_date IS NOT NULL AND discharge_date IS NOT NULL
GROUP BY admission_type
ORDER BY n DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [15/61] 4.4 Admission origin and discharge destination mix — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[15] Running: 4.4 Admission origin and discharge destination mix'
\o :outdir/15_4_4_admission_origin_and_discharge_destination_mix.csv
-- 4.4  Admission origin and discharge destination mix
-- Where do patients come from (home, ED, transfer) and where do they go?
-- Together these describe acuity and post-discharge care pathways.
-- ----------------------------------------------------------------------------
SELECT
    admission_origin,
    discharge_method,
    COUNT(*)                   AS n_admissions
FROM amc_core.admission_traject
GROUP BY admission_origin, discharge_method
ORDER BY n_admissions DESC
LIMIT 30;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [16/61] 4.5 Admissions via SEH (emergency department) vs elective — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[16] Running: 4.5 Admissions via SEH (emergency department) vs elective'
\o :outdir/16_4_5_admissions_via_seh_emergency_department_vs_electiv.csv
-- 4.5  Admissions via SEH (emergency department) vs elective
-- is_admission_start_seh and admission_via_seh flag emergency entry.
-- This split is fundamental for emergency vs elective cohort separation.
-- ----------------------------------------------------------------------------
SELECT
    is_admission_elective,
    admission_via_seh,
    COUNT(*)                   AS n_admissions,
    COUNT(DISTINCT pseudo_id)  AS unique_patients,
    ROUND(AVG(discharge_date - admission_date), 1) AS mean_los_days
FROM amc_core.admission_traject
GROUP BY is_admission_elective, admission_via_seh
ORDER BY n_admissions DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [17/61] 4.6 Partial traject (ward) transitions per admission — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[17] Running: 4.6 Partial traject (ward) transitions per admission'
\o :outdir/17_4_6_partial_traject_ward_transitions_per_admission.csv
-- 4.6  Partial traject (ward) transitions per admission
-- Each row in admission_partial_traject is a ward stay within an admission.
-- Many partial trajects per admission indicate complex, multi-ward patients.
-- ----------------------------------------------------------------------------
WITH partial_counts AS (
    SELECT
        admission_traject_id,
        COUNT(*) AS n_partial_trajects
    FROM amc_core.admission_partial_traject
    GROUP BY admission_traject_id
)
SELECT
    CASE
        WHEN n_partial_trajects = 1 THEN '1 ward'
        WHEN n_partial_trajects = 2 THEN '2 wards'
        WHEN n_partial_trajects <= 5 THEN '3-5 wards'
        ELSE '6+ wards'
    END AS ward_transitions,
    COUNT(*)   AS n_admissions,
    ROUND(AVG(n_partial_trajects), 1) AS avg_n_partial
FROM partial_counts
GROUP BY ward_transitions
ORDER BY MIN(n_partial_trajects);


-- =============================================================================
-- SECTION 5 — ICU (INTENSIVE CARE UNIT) ANALYSIS
-- =============================================================================
-- ICU is identified by workplace or specialty containing keywords:
-- 'icu', 'intensive', 'ic ', 'intensive care', 'intens'
-- These filters should be validated against local EPR workplace taxonomy.
-- Adjust ILIKE patterns if your hospital uses different naming conventions.
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [18/61] 5.1 ICU partial traject stays — volume and LOS — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[18] Running: 5.1 ICU partial traject stays — volume and LOS'
\o :outdir/18_5_1_icu_partial_traject_stays_volume_and_los.csv
-- 5.1  ICU partial traject stays — volume and LOS
-- Identifies all ward-level stays that occurred in an ICU.
-- Length of stay in ICU is a strong severity and resource-use proxy.
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)                                                    AS n_icu_stays,
    COUNT(DISTINCT pseudo_id)                                   AS unique_icu_patients,
    ROUND(AVG(EXTRACT(EPOCH FROM (end_date_time - start_date_time))/86400), 1) AS mean_icu_los_days,
    PERCENTILE_CONT(0.50) WITHIN GROUP
        (ORDER BY EXTRACT(EPOCH FROM (end_date_time - start_date_time))/86400)  AS median_icu_los_days,
    PERCENTILE_CONT(0.90) WITHIN GROUP
        (ORDER BY EXTRACT(EPOCH FROM (end_date_time - start_date_time))/86400)  AS p90_icu_los_days,
    MAX(EXTRACT(EPOCH FROM (end_date_time - start_date_time))/86400)::int       AS max_icu_los_days
FROM amc_core.admission_partial_traject
WHERE (
       LOWER(workplace) LIKE '%icu%'
    OR LOWER(workplace) LIKE '%intensive%'
    OR LOWER(workplace) LIKE '%intens%'
    OR LOWER(specialty) LIKE '%intensive%'
    OR LOWER(specialty) LIKE '%intens%'
)
AND start_date_time IS NOT NULL AND end_date_time IS NOT NULL;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [19/61] 5.2 ICU patient characteristics — age, sex, mortality — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[19] Running: 5.2 ICU patient characteristics — age, sex, mortality'
\o :outdir/19_5_2_icu_patient_characteristics_age_sex_mortality.csv
-- 5.2  ICU patient characteristics — age, sex, mortality
-- Who are the ICU patients? Join back to patient demographics and death.
-- ICU mortality (death_registration or is_deceased) is a key outcome.
-- ----------------------------------------------------------------------------
WITH icu_patients AS (
    SELECT DISTINCT pseudo_id
    FROM amc_core.admission_partial_traject
    WHERE (
           LOWER(workplace) LIKE '%icu%'
        OR LOWER(workplace) LIKE '%intensive%'
        OR LOWER(specialty) LIKE '%intensive%'
    )
),
icu_deaths AS (
    SELECT DISTINCT dr.pseudo_id
    FROM amc_core.death_registration dr
    INNER JOIN icu_patients ip ON dr.pseudo_id = ip.pseudo_id
)
SELECT
    COUNT(DISTINCT ip.pseudo_id)                               AS n_icu_patients,
    ROUND(AVG(EXTRACT(YEAR FROM CURRENT_DATE) - p.year_of_birth), 1) AS mean_age,
    COUNT(*) FILTER (WHERE p.gender = 'M')                     AS n_male,
    COUNT(*) FILTER (WHERE p.gender = 'V')                     AS n_female,  -- adjust M/V/F labels
    COUNT(DISTINCT id_.pseudo_id)                              AS n_deceased,
    ROUND(100.0 * COUNT(DISTINCT id_.pseudo_id) / COUNT(DISTINCT ip.pseudo_id), 1) AS mortality_pct
FROM icu_patients ip
LEFT JOIN amc_core.patient_not_traceable p  ON ip.pseudo_id = p.pseudo_id
LEFT JOIN icu_deaths                   id_  ON ip.pseudo_id = id_.pseudo_id;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [20/61] 5.3 IC procedure notes volume — interventions performed in ICU — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[20] Running: 5.3 IC procedure notes volume — interventions performed in ICU'
\o :outdir/20_5_3_ic_procedure_notes_volume_interventions_performed_.csv
-- 5.3  IC procedure notes volume — interventions performed in ICU
-- These tables document specific ICU procedures. Their volume indicates how
-- frequently invasive procedures are needed and recorded.
-- Each table = one procedure type. Counts help scope procedure-specific cohorts.
-- ----------------------------------------------------------------------------
SELECT 'bronchoscopy'           AS procedure_type, COUNT(*) AS n, COUNT(DISTINCT pseudo_id) AS unique_pts
FROM amc_core.ic_procedure_note_bronchoscopy
UNION ALL SELECT 'icarus (US)',  COUNT(*), COUNT(DISTINCT pseudo_id) FROM amc_core.ic_procedure_note_icarus
UNION ALL SELECT 'intubation',   COUNT(*), COUNT(DISTINCT pseudo_id) FROM amc_core.ic_procedure_note_intubation
UNION ALL SELECT 'tracheostomy', COUNT(*), COUNT(DISTINCT pseudo_id) FROM amc_core.ic_procedure_note_tracheostomy
UNION ALL SELECT 'thorax_drain', COUNT(*), COUNT(DISTINCT pseudo_id) FROM amc_core.ic_procedure_note_thorax_drain
UNION ALL SELECT 'central_venous_catheter', COUNT(*), COUNT(DISTINCT pseudo_id) FROM amc_core.ic_procedure_note_central_venous_catheter
UNION ALL SELECT 'electric_cardioversion',  COUNT(*), COUNT(DISTINCT pseudo_id) FROM amc_core.ic_procedure_note_electric_cardioversion
ORDER BY n DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [21/61] 5.4 ICU admissions trend by year — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[21] Running: 5.4 ICU admissions trend by year'
\o :outdir/21_5_4_icu_admissions_trend_by_year.csv
-- 5.4  ICU admissions trend by year
-- Annual ICU patient count. Compare to overall admission trends (4.1) to see
-- if ICU proportion is growing, stable, or artifact of data refresh cycles.
-- ----------------------------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM apt.start_date)::int AS year,
    COUNT(DISTINCT apt.pseudo_id)          AS unique_icu_patients,
    COUNT(*)                               AS icu_ward_stays
FROM amc_core.admission_partial_traject apt
WHERE (
       LOWER(apt.workplace) LIKE '%icu%'
    OR LOWER(apt.workplace) LIKE '%intensive%'
)
AND apt.start_date IS NOT NULL
GROUP BY year
ORDER BY year DESC;


-- =============================================================================
-- SECTION 6 — MORTALITY
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [22/61] 6.1 Overall mortality rate in the dataset — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[22] Running: 6.1 Overall mortality rate in the dataset'
\o :outdir/22_6_1_overall_mortality_rate_in_the_dataset.csv
-- 6.1  Overall mortality rate in the dataset
-- Proportion of all known patients who have a death registration.
-- Compare is_deceased flag vs death_registration row — they should align.
-- ----------------------------------------------------------------------------
SELECT
    COUNT(DISTINCT p.pseudo_id)                                       AS total_patients,
    COUNT(DISTINCT dr.pseudo_id)                                      AS patients_with_death_record,
    COUNT(DISTINCT p.pseudo_id) FILTER (WHERE p.is_deceased = 'J')   AS patients_flagged_deceased,
    ROUND(100.0 * COUNT(DISTINCT dr.pseudo_id)
          / NULLIF(COUNT(DISTINCT p.pseudo_id), 0), 2)                AS death_record_rate_pct
FROM amc_core.patient_not_traceable p
LEFT JOIN amc_core.death_registration dr ON p.pseudo_id = dr.pseudo_id;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [23/61] 6.2 In-hospital mortality by department of death — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[23] Running: 6.2 In-hospital mortality by department of death'
\o :outdir/23_6_2_in_hospital_mortality_by_department_of_death.csv
-- 6.2  In-hospital mortality by department of death
-- Where do patients die? ICU, general wards, ED? Informs care pathways and
-- end-of-life documentation research. Also flags data quality (unknown dept).
-- ----------------------------------------------------------------------------
SELECT
    department_of_death,
    COUNT(*)                   AS n_deaths,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM amc_core.death_registration
WHERE department_of_death IS NOT NULL
GROUP BY department_of_death
ORDER BY n_deaths DESC
LIMIT 25;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [24/61] 6.3 Mode of death / location flags — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[24] Running: 6.3 Mode of death / location flags'
\o :outdir/24_6_3_mode_of_death_location_flags.csv
-- 6.3  Mode of death / location flags
-- natural_death, autopsy, destination_deceased give extra context.
-- Non-natural deaths may require exclusion in some study designs.
-- ----------------------------------------------------------------------------
SELECT
    natural_death,
    autopsy,
    COUNT(*)                   AS n_deaths
FROM amc_core.death_registration
GROUP BY natural_death, autopsy
ORDER BY n_deaths DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [25/61] 6.4 Mortality after admission — 30-day and in-hospital — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[25] Running: 6.4 Mortality after admission — 30-day and in-hospital'
\o :outdir/25_6_4_mortality_after_admission_30_day_and_in_hospital.csv
-- 6.4  Mortality after admission — 30-day and in-hospital
-- For each admission, check if a death occurred within 30 days.
-- This is a standard hospital quality metric.
-- Note: death_registration date used as death date proxy.
-- ----------------------------------------------------------------------------
WITH admissions_with_death AS (
    SELECT
        at_.pseudo_id,
        at_.admission_traject_id,
        at_.admission_date,
        at_.discharge_date,
        MIN(dr.meet_date)   AS death_date
    FROM amc_core.admission_traject at_
    LEFT JOIN amc_core.death_registration dr ON at_.pseudo_id = dr.pseudo_id
    WHERE at_.admission_date IS NOT NULL
    GROUP BY at_.pseudo_id, at_.admission_traject_id, at_.admission_date, at_.discharge_date
)
SELECT
    COUNT(*)                                                        AS total_admissions,
    COUNT(*) FILTER (WHERE death_date BETWEEN admission_date AND discharge_date)
                                                                    AS in_hospital_deaths,
    COUNT(*) FILTER (WHERE death_date BETWEEN admission_date AND admission_date + INTERVAL '30 days')
                                                                    AS deaths_within_30_days,
    ROUND(100.0 * COUNT(*) FILTER (WHERE death_date BETWEEN admission_date AND discharge_date)
          / NULLIF(COUNT(*), 0), 2)                                 AS in_hospital_mortality_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE death_date BETWEEN admission_date AND admission_date + INTERVAL '30 days')
          / NULLIF(COUNT(*), 0), 2)                                 AS mortality_30d_pct
FROM admissions_with_death;


-- =============================================================================
-- SECTION 7 — EMERGENCY DEPARTMENT (SEH)
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [26/61] 7.1 SEH visit volume and arrival mode distribution — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[26] Running: 7.1 SEH visit volume and arrival mode distribution'
\o :outdir/26_7_1_seh_visit_volume_and_arrival_mode_distribution.csv
-- 7.1  SEH visit volume and arrival mode distribution
-- SEH = Spoed Eisende Hulp (Dutch ED). Volume and arrival mode (ambulance,
-- self-referral, GP referral) characterise the ED population.
-- ----------------------------------------------------------------------------
SELECT
    seh_arrival_mode_group,
    seh_presentation_type,
    COUNT(*)                   AS n_visits,
    COUNT(DISTINCT pseudo_id)  AS unique_patients
FROM amc_core.seh_trajectory
GROUP BY seh_arrival_mode_group, seh_presentation_type
ORDER BY n_visits DESC
LIMIT 20;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [27/61] 7.2 SEH triage code distribution — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[27] Running: 7.2 SEH triage code distribution'
\o :outdir/27_7_2_seh_triage_code_distribution.csv
-- 7.2  SEH triage code distribution
-- Triage code reflects urgency (1=immediate to 5=non-urgent in MTS).
-- High proportion of codes 1-2 indicates a critically ill ED population.
-- ----------------------------------------------------------------------------
SELECT
    seh_triagecode,
    COUNT(*)                   AS n_visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM amc_core.seh_trajectory
WHERE seh_triagecode IS NOT NULL
GROUP BY seh_triagecode
ORDER BY seh_triagecode;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [28/61] 7.3 SEH ED length of stay — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[28] Running: 7.3 SEH ED length of stay'
\o :outdir/28_7_3_seh_ed_length_of_stay.csv
-- 7.3  SEH ED length of stay
-- Time from arrival to departure (seh_admission_date_time to seh_departure_date_time).
-- Long ED stays may indicate boarding (no inpatient bed available).
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)                                                                    AS n_visits,
    ROUND(AVG(EXTRACT(EPOCH FROM
        (seh_departure_date_time - seh_admission_date_time))/3600), 1)          AS mean_ed_los_hours,
    PERCENTILE_CONT(0.50) WITHIN GROUP
        (ORDER BY EXTRACT(EPOCH FROM (seh_departure_date_time - seh_admission_date_time))/3600)
                                                                                AS median_ed_los_hours,
    PERCENTILE_CONT(0.90) WITHIN GROUP
        (ORDER BY EXTRACT(EPOCH FROM (seh_departure_date_time - seh_admission_date_time))/3600)
                                                                                AS p90_ed_los_hours,
    COUNT(*) FILTER (WHERE destination_after_seh ILIKE '%opname%'
                        OR destination_after_seh ILIKE '%admit%')               AS admitted_from_ed
FROM amc_core.seh_trajectory
WHERE seh_admission_date_time IS NOT NULL
  AND seh_departure_date_time IS NOT NULL
  AND seh_departure_date_time > seh_admission_date_time;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [29/61] 7.4 SEH destination after ED visit — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[29] Running: 7.4 SEH destination after ED visit'
\o :outdir/29_7_4_seh_destination_after_ed_visit.csv
-- 7.4  SEH destination after ED visit
-- Where do ED patients go? Admitted, discharged home, transferred?
-- Admission rate from ED is a key acuity indicator.
-- ----------------------------------------------------------------------------
SELECT
    destination_after_seh,
    COUNT(*)                   AS n_visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM amc_core.seh_trajectory
WHERE destination_after_seh IS NOT NULL
GROUP BY destination_after_seh
ORDER BY n_visits DESC;


-- =============================================================================
-- SECTION 8 — DIAGNOSES AND CLINICAL CODING
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [30/61] 8.1 Top 30 diagnosis codes (medical_diagnosis) — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[30] Running: 8.1 Top 30 diagnosis codes (medical_diagnosis)'
\o :outdir/30_8_1_top_30_diagnosis_codes_medical_diagnosis.csv
-- 8.1  Top 30 diagnosis codes (medical_diagnosis)
-- Most frequent primary diagnoses across all contacts.
-- Use diagnosis_category to understand clinical domains represented.
-- Cross-reference with ICD-10 browser if diagnosis_code format is confirmed ICD.
-- ----------------------------------------------------------------------------
SELECT
    diagnosis_code,
    diagnosis_description,
    diagnosis_category,
    COUNT(*)                   AS n_records,
    COUNT(DISTINCT pseudo_id)  AS unique_patients
FROM amc_core.medical_diagnosis
WHERE diagnosis_code IS NOT NULL
GROUP BY diagnosis_code, diagnosis_description, diagnosis_category
ORDER BY n_records DESC
LIMIT 30;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [31/61] 8.2 Diagnosis category distribution — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[31] Running: 8.2 Diagnosis category distribution'
\o :outdir/31_8_2_diagnosis_category_distribution.csv
-- 8.2  Diagnosis category distribution
-- Aggregates codes into clinical categories. Useful for high-level slides
-- showing what patient populations the dataset covers.
-- ----------------------------------------------------------------------------
SELECT
    diagnosis_category,
    COUNT(*)                   AS n_records,
    COUNT(DISTINCT pseudo_id)  AS unique_patients
FROM amc_core.medical_diagnosis
WHERE diagnosis_category IS NOT NULL
GROUP BY diagnosis_category
ORDER BY n_records DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [32/61] 8.3 Problem list — SNOMED codes coverage — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[32] Running: 8.3 Problem list — SNOMED codes coverage'
\o :outdir/32_8_3_problem_list_snomed_codes_coverage.csv
-- 8.3  Problem list — SNOMED codes coverage
-- How many problem list entries have SNOMED codes vs only free text?
-- SNOMED coverage is key for semantic interoperability.
-- Tables with SNOMED: problem_list (snomed_code)
-- Tables with Diagnose Thesaurus: problem_list (diagnose_thesaurus_code)
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)                                            AS total_problem_entries,
    COUNT(*) FILTER (WHERE snomed_code IS NOT NULL
                       AND snomed_code <> '')           AS with_snomed_code,
    COUNT(*) FILTER (WHERE diagnose_thesaurus_code IS NOT NULL
                       AND diagnose_thesaurus_code <> '') AS with_thesaurus_code,
    COUNT(*) FILTER (WHERE diagnosis_code IS NOT NULL
                       AND diagnosis_code <> '')        AS with_diagnosis_code,
    ROUND(100.0 * COUNT(*) FILTER (WHERE snomed_code IS NOT NULL AND snomed_code <> '')
          / NULLIF(COUNT(*), 0), 1)                     AS snomed_coverage_pct
FROM amc_core.problem_list;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [33/61] 8.4 Top 20 SNOMED codes in problem list — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[33] Running: 8.4 Top 20 SNOMED codes in problem list'
\o :outdir/33_8_4_top_20_snomed_codes_in_problem_list.csv
-- 8.4  Top 20 SNOMED codes in problem list
-- The most common chronic problems and active conditions.
-- SNOMED codes can be looked up at browser.ihtsdotools.org
-- ----------------------------------------------------------------------------
SELECT
    snomed_code,
    problem_description,
    COUNT(*)                   AS n_entries,
    COUNT(DISTINCT pseudo_id)  AS unique_patients
FROM amc_core.problem_list
WHERE snomed_code IS NOT NULL AND snomed_code <> ''
GROUP BY snomed_code, problem_description
ORDER BY n_entries DESC
LIMIT 20;


-- =============================================================================
-- SECTION 9 — MEDICATIONS
-- =============================================================================
-- ATC coding is the international standard for medication classification.
-- The medication_atc lookup table provides the full 5-level hierarchy.
-- All queries join through atc_code for enrichment.
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [34/61] 9.1 ATC coverage in prescriptions — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[34] Running: 9.1 ATC coverage in prescriptions'
\o :outdir/34_9_1_atc_coverage_in_prescriptions.csv
-- 9.1  ATC coverage in prescriptions
-- What proportion of prescriptions have an ATC code?
-- ATC-coded prescriptions can be linked to medication_atc for enrichment.
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)                                            AS total_prescriptions,
    COUNT(*) FILTER (WHERE atc_code IS NOT NULL
                       AND atc_code <> '')              AS with_atc_code,
    COUNT(DISTINCT pseudo_id)                           AS unique_patients,
    COUNT(DISTINCT atc_code)                            AS unique_atc_codes,
    ROUND(100.0 * COUNT(*) FILTER (WHERE atc_code IS NOT NULL AND atc_code <> '')
          / NULLIF(COUNT(*), 0), 1)                     AS atc_coverage_pct
FROM amc_core.medication_prescription;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [35/61] 9.2 Top 20 prescribed ATC level-1 drug classes — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[35] Running: 9.2 Top 20 prescribed ATC level-1 drug classes'
\o :outdir/35_9_2_top_20_prescribed_atc_level_1_drug_classes.csv
-- 9.2  Top 20 prescribed ATC level-1 drug classes
-- ATC level 1 = anatomical main group (e.g., C=cardiovascular, N=nervous system)
-- This slide-ready breakdown shows which body systems the dataset covers best.
-- ----------------------------------------------------------------------------
SELECT
    atc.atc_code_niv1,
    atc.atc_name_niv1,
    COUNT(mp.rule_id)          AS n_prescriptions,
    COUNT(DISTINCT mp.pseudo_id) AS unique_patients
FROM amc_core.medication_prescription mp
INNER JOIN amc_core.medication_atc atc ON mp.atc_code = atc.atc_code
WHERE atc.atc_code_niv1 IS NOT NULL
GROUP BY atc.atc_code_niv1, atc.atc_name_niv1
ORDER BY n_prescriptions DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [36/61] 9.3 Top 30 most prescribed individual substances (ATC level 5) — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[36] Running: 9.3 Top 30 most prescribed individual substances (ATC level 5)'
\o :outdir/36_9_3_top_30_most_prescribed_individual_substances_atc_l.csv
-- 9.3  Top 30 most prescribed individual substances (ATC level 5)
-- Leaf-level ATC code = specific chemical substance (e.g., metoprolol).
-- Useful for medication-specific cohorts and safety analyses.
-- ----------------------------------------------------------------------------
SELECT
    atc.atc_code,
    atc.atc_name,
    atc.atc_code_niv2,
    atc.atc_name_niv2,
    COUNT(mp.rule_id)          AS n_prescriptions,
    COUNT(DISTINCT mp.pseudo_id) AS unique_patients
FROM amc_core.medication_prescription mp
INNER JOIN amc_core.medication_atc atc ON mp.atc_code = atc.atc_code
GROUP BY atc.atc_code, atc.atc_name, atc.atc_code_niv2, atc.atc_name_niv2
ORDER BY n_prescriptions DESC
LIMIT 30;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [37/61] 9.4 Administration vs prescription — coverage check — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[37] Running: 9.4 Administration vs prescription — coverage check'
\o :outdir/37_9_4_administration_vs_prescription_coverage_check.csv
-- 9.4  Administration vs prescription — coverage check
-- What proportion of prescriptions have administration records?
-- Gaps indicate paper administration, partial ETL, or ICU drip records.
-- ----------------------------------------------------------------------------
SELECT
    COUNT(DISTINCT mp.rule_id)                                  AS unique_prescriptions,
    COUNT(DISTINCT ma.rule_id)                                  AS prescriptions_with_admin,
    ROUND(100.0 * COUNT(DISTINCT ma.rule_id)
          / NULLIF(COUNT(DISTINCT mp.rule_id), 0), 1)           AS admin_coverage_pct
FROM amc_core.medication_prescription mp
LEFT JOIN amc_core.medication_administration ma ON mp.rule_id = ma.rule_id;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [38/61] 9.5 Medication administration route distribution — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[38] Running: 9.5 Medication administration route distribution'
\o :outdir/38_9_5_medication_administration_route_distribution.csv
-- 9.5  Medication administration route distribution
-- Route (oral, IV, subcutaneous, etc.) matters for pharmacokinetic studies
-- and for identifying IV-only ICU medications.
-- ----------------------------------------------------------------------------
SELECT
    administration_route,
    COUNT(*)                   AS n_administrations,
    COUNT(DISTINCT pseudo_id)  AS unique_patients
FROM amc_core.medication_administration
WHERE administration_route IS NOT NULL
GROUP BY administration_route
ORDER BY n_administrations DESC;


-- =============================================================================
-- SECTION 10 — LABORATORY RESULTS
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [39/61] 10.1 Lab result volume and material type distribution — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[39] Running: 10.1 Lab result volume and material type distribution'
\o :outdir/39_10_1_lab_result_volume_and_material_type_distribution.csv
-- 10.1  Lab result volume and material type distribution
-- How many lab results are there, and from what sample types (blood, urine)?
-- material_type determines which assays are applicable.
-- determination_code is a local code; LOINC mapping is recommended if available.
-- ----------------------------------------------------------------------------
SELECT
    material_type,
    COUNT(*)                   AS n_results,
    COUNT(DISTINCT pseudo_id)  AS unique_patients,
    COUNT(DISTINCT determination_code) AS unique_tests
FROM amc_core.lab_result
WHERE material_type IS NOT NULL
GROUP BY material_type
ORDER BY n_results DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [40/61] 10.2 Top 30 most frequently ordered lab tests — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[40] Running: 10.2 Top 30 most frequently ordered lab tests'
\o :outdir/40_10_2_top_30_most_frequently_ordered_lab_tests.csv
-- 10.2  Top 30 most frequently ordered lab tests
-- determination_code + determination = the test identifier and its name.
-- Frequent tests (Hb, CRP, creatinine) confirm dataset richness for
-- common biomarker-based cohort definitions.
-- ----------------------------------------------------------------------------
SELECT
    determination_code,
    determination,
    COUNT(*)                   AS n_results,
    COUNT(DISTINCT pseudo_id)  AS unique_patients,
    ROUND(AVG(result_numeric), 2) AS mean_value,
    MIN(result_unit)           AS unit   -- unit should be constant per code
FROM amc_core.lab_result
WHERE determination_code IS NOT NULL
GROUP BY determination_code, determination
ORDER BY n_results DESC
LIMIT 30;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [41/61] 10.3 Missing numeric results — completeness check — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[41] Running: 10.3 Missing numeric results — completeness check'
\o :outdir/41_10_3_missing_numeric_results_completeness_check.csv
-- 10.3  Missing numeric results — completeness check
-- Some results are categorical (e.g., "positive") and won't have a numeric
-- value. This check quantifies how much of the numeric field is usable.
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)                                            AS total_results,
    COUNT(*) FILTER (WHERE result_numeric IS NOT NULL)  AS numeric_results,
    COUNT(*) FILTER (WHERE result_text IS NOT NULL
                       AND result_numeric IS NULL)      AS text_only_results,
    ROUND(100.0 * COUNT(*) FILTER (WHERE result_numeric IS NOT NULL)
          / NULLIF(COUNT(*), 0), 1)                     AS numeric_coverage_pct
FROM amc_core.lab_result;


-- =============================================================================
-- SECTION 11 — VITAL SIGNS AND MEASUREMENTS
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [42/61] 11.1 Measurement coverage per patient — how many patients have vitals? — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[42] Running: 11.1 Measurement coverage per patient — how many patients have vitals?'
\o :outdir/42_11_1_measurement_coverage_per_patient_how_many_patients.csv
-- 11.1  Measurement coverage per patient — how many patients have vitals?
-- Not all patients will have structured vital sign records (e.g., outpatients
-- may only have blood pressure taken in GP records, not here).
-- ----------------------------------------------------------------------------
SELECT 'blood_pressure'       AS measurement, COUNT(DISTINCT pseudo_id) AS unique_patients, COUNT(*) AS total_records FROM amc_core.measurement_blood_pressure
UNION ALL SELECT 'blood_pressure_avg',         COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_blood_pressure_average
UNION ALL SELECT 'heart_frequency',            COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_heart_frequency
UNION ALL SELECT 'o2_saturation',              COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_o2_saturation
UNION ALL SELECT 'height',                     COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_height
UNION ALL SELECT 'weight',                     COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_weight
UNION ALL SELECT 'bmi',                        COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_bmi
UNION ALL SELECT 'diurese',                    COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_diurese
UNION ALL SELECT 'chadsvasc_score',            COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_chadsvasc_score
UNION ALL SELECT 'doss_score',                 COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_doss_score
UNION ALL SELECT 'snaq_score',                 COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_snaq_score
UNION ALL SELECT 'vital_signs_combined',       COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_vital_signs_data
ORDER BY total_records DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [43/61] 11.2 Blood pressure summary statistics — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[43] Running: 11.2 Blood pressure summary statistics'
\o :outdir/43_11_2_blood_pressure_summary_statistics.csv
-- 11.2  Blood pressure summary statistics
-- Systolic and diastolic distribution across the dataset.
-- Wide IQR is expected (measurements across healthy and critically ill patients).
-- Outliers below 40 or above 250 mmHg systolic are likely data errors.
-- ----------------------------------------------------------------------------
SELECT
    ROUND(AVG(systolic_blood_pressure_value), 1)   AS mean_systolic,
    ROUND(AVG(diastolic_blood_pressure_value), 1)  AS mean_diastolic,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY systolic_blood_pressure_value) AS median_systolic,
    PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY systolic_blood_pressure_value) AS p10_systolic,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY systolic_blood_pressure_value) AS p90_systolic,
    COUNT(*) FILTER (WHERE systolic_blood_pressure_value < 40
                        OR systolic_blood_pressure_value > 280) AS potential_outliers
FROM amc_core.measurement_blood_pressure
WHERE systolic_blood_pressure_value IS NOT NULL;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [44/61] 11.3 BMI distribution — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[44] Running: 11.3 BMI distribution'
\o :outdir/44_11_3_bmi_distribution.csv
-- 11.3  BMI distribution
-- Key covariate for almost all clinical cohort studies.
-- WHO categories provided as a reference.
-- ----------------------------------------------------------------------------
SELECT
    CASE
        WHEN bmi < 18.5 THEN 'Underweight (<18.5)'
        WHEN bmi < 25   THEN 'Normal (18.5-24.9)'
        WHEN bmi < 30   THEN 'Overweight (25-29.9)'
        WHEN bmi < 35   THEN 'Obese class I (30-34.9)'
        WHEN bmi < 40   THEN 'Obese class II (35-39.9)'
        ELSE                 'Obese class III (≥40)'
    END AS bmi_category,
    COUNT(DISTINCT pseudo_id) AS unique_patients,
    COUNT(*)                  AS n_measurements
FROM amc_core.measurement_bmi
WHERE bmi IS NOT NULL AND bmi > 10 AND bmi < 80   -- exclude clear errors
GROUP BY bmi_category
ORDER BY MIN(bmi);


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [45/61] 11.4 CHA₂DS₂-VASc score distribution — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[45] Running: 11.4 CHA₂DS₂-VASc score distribution'
\o :outdir/45_11_4_cha_ds_vasc_score_distribution.csv
-- 11.4  CHA₂DS₂-VASc score distribution
-- Stroke risk score for atrial fibrillation patients.
-- Score ≥2 (men) or ≥3 (women) = anticoagulation recommended.
-- ----------------------------------------------------------------------------
SELECT
    chadsvasc_score::int AS chadsvasc_score,
    COUNT(*)             AS n_measurements,
    COUNT(DISTINCT pseudo_id) AS unique_patients
FROM amc_core.measurement_chadsvasc_score
WHERE chadsvasc_score IS NOT NULL
GROUP BY chadsvasc_score
ORDER BY chadsvasc_score;


-- =============================================================================
-- SECTION 12 — FLUID BALANCE AND NEPHROLOGY (ICU-SPECIFIC)
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [46/61] 12.1 Fluid measurement table coverage — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[46] Running: 12.1 Fluid measurement table coverage'
\o :outdir/46_12_1_fluid_measurement_table_coverage.csv
-- 12.1  Fluid measurement table coverage
-- These tables are typically only populated for ICU/high-dependency patients.
-- Coverage gives an idea of how many patients had structured fluid monitoring.
-- ----------------------------------------------------------------------------
SELECT 'fluid_assessment_diuresis'          AS domain, COUNT(DISTINCT pseudo_id) AS pts, COUNT(*) AS records FROM amc_core.measurement_fluid_assessment_diuresis
UNION ALL SELECT 'fluid_balance_emesis',     COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_fluid_balance_assessment_emesis
UNION ALL SELECT 'fluid_balance_feces',      COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_fluid_balance_assessment_feces
UNION ALL SELECT 'fluid_balance_out',        COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_fluid_balance_out
UNION ALL SELECT 'fluid_balance_stomach',    COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_fluid_balance_stomach_retention
UNION ALL SELECT 'fluid_in',                 COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_fluid_in
UNION ALL SELECT 'nephrology_cntv_med',      COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_nephrology_cntv_medication
UNION ALL SELECT 'nephrology_cnvt_settings', COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_nephrology_cnvt_settings
UNION ALL SELECT 'nephrology_hemodialysis',  COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_nephrology_hemodialysis
UNION ALL SELECT 'nephrology_peritoneal_dialysis', COUNT(DISTINCT pseudo_id), COUNT(*) FROM amc_core.measurement_nephrology_peritoneal_dialysis
ORDER BY pts DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [47/61] 12.2 Dialysis patients — prevalence and treatment type — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[47] Running: 12.2 Dialysis patients — prevalence and treatment type'
\o :outdir/47_12_2_dialysis_patients_prevalence_and_treatment_type.csv
-- 12.2  Dialysis patients — prevalence and treatment type
-- Kidney replacement therapy (KRT) is a critical outcome in ICU cohorts.
-- Hemo vs peritoneal dialysis may differ in patient profile and outcomes.
-- ----------------------------------------------------------------------------
WITH dialysis_patients AS (
    SELECT pseudo_id, 'hemodialysis' AS treatment_type FROM amc_core.measurement_nephrology_hemodialysis
    UNION
    SELECT pseudo_id, 'peritoneal'   FROM amc_core.measurement_nephrology_peritoneal_dialysis
    UNION
    SELECT pseudo_id, 'cnvt'         FROM amc_core.measurement_nephrology_cnvt_settings  -- continuous veno-venous therapy
)
SELECT
    treatment_type,
    COUNT(DISTINCT pseudo_id) AS unique_patients
FROM dialysis_patients
GROUP BY treatment_type
ORDER BY unique_patients DESC;


-- =============================================================================
-- SECTION 13 — SURGICAL PROCEDURES AND OR
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [48/61] 13.1 Procedure volume by specialty — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[48] Running: 13.1 Procedure volume by specialty'
\o :outdir/48_13_1_procedure_volume_by_specialty.csv
-- 13.1  Procedure volume by specialty
-- DBC / intervention_code are Dutch billing/procedure codes.
-- Top specialties by number of procedures indicates surgical scope.
-- ----------------------------------------------------------------------------
SELECT
    executive_specialty,
    COUNT(*)                   AS n_procedures,
    COUNT(DISTINCT pseudo_id)  AS unique_patients
FROM amc_core.procedures
WHERE executive_specialty IS NOT NULL
GROUP BY executive_specialty
ORDER BY n_procedures DESC
LIMIT 20;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [49/61] 13.2 OR sessions — performed vs planned ratio — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[49] Running: 13.2 OR sessions — performed vs planned ratio'
\o :outdir/49_13_2_or_sessions_performed_vs_planned_ratio.csv
-- 13.2  OR sessions — performed vs planned ratio
-- A high planned/performed ratio may indicate cancellations.
-- ok_session_number links performed and planned records.
-- ----------------------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM amc_core.ok_procedure_performed) AS performed,
    (SELECT COUNT(*) FROM amc_core.ok_procedure_planned)   AS planned,
    (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.ok_procedure_performed) AS unique_pts_performed,
    (SELECT COUNT(DISTINCT pseudo_id) FROM amc_core.ok_procedure_planned)   AS unique_pts_planned;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [50/61] 13.3 Top OR procedures by DBC diagnosis — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[50] Running: 13.3 Top OR procedures by DBC diagnosis'
\o :outdir/50_13_3_top_or_procedures_by_dbc_diagnosis.csv
-- 13.3  Top OR procedures by DBC diagnosis
-- DBC (Diagnose Behandeling Combinatie) is the Dutch hospital episode system.
-- Each DBC links a diagnosis to a treatment trajectory and its billing code.
-- Top DBC diagnoses reveal which surgical conditions dominate.
-- ----------------------------------------------------------------------------
SELECT
    dbc_diagnosis,
    COUNT(*)                   AS n_sessions,
    COUNT(DISTINCT pseudo_id)  AS unique_patients
FROM amc_core.ok_procedure_performed
WHERE dbc_diagnosis IS NOT NULL
GROUP BY dbc_diagnosis
ORDER BY n_sessions DESC
LIMIT 20;


-- =============================================================================
-- SECTION 14 — IMAGING AND ECG
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [51/61] 14.1 Imaging study order volume and status — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[51] Running: 14.1 Imaging study order volume and status'
\o :outdir/51_14_1_imaging_study_order_volume_and_status.csv
-- 14.1  Imaging study order volume and status
-- Cancelled vs completed studies. Imaging is essential for many diagnostic
-- cohorts (e.g., chest CT for pneumonia, echo for heart failure).
-- ----------------------------------------------------------------------------
SELECT
    imaging_study_status,
    COUNT(*)                   AS n_orders,
    COUNT(DISTINCT pseudo_id)  AS unique_patients
FROM amc_core.imaging_study_order
GROUP BY imaging_study_status
ORDER BY n_orders DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [52/61] 14.2 ECG measurement volume and types — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[52] Running: 14.2 ECG measurement volume and types'
\o :outdir/52_14_2_ecg_measurement_volume_and_types.csv
-- 14.2  ECG measurement volume and types
-- ECGs are valuable for arrhythmia and cardiac event studies.
-- test_type distinguishes resting ECG, exercise test, Holter, etc.
-- ----------------------------------------------------------------------------
SELECT
    test_type,
    COUNT(*)                   AS n_ecgs,
    COUNT(DISTINCT pseudo_id)  AS unique_patients
FROM amc_core.ecg_measurement
WHERE test_type IS NOT NULL
GROUP BY test_type
ORDER BY n_ecgs DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [53/61] 14.3 Echo measurement heart — examination type and volume — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[53] Running: 14.3 Echo measurement heart — examination type and volume'
\o :outdir/53_14_3_echo_measurement_heart_examination_type_and_volume.csv
-- 14.3  Echo measurement heart — examination type and volume
-- Transthoracic (TTE) vs transoesophageal (TOE) vs stress echo etc.
-- Patients with echo records are a natural cohort for cardiac research.
-- ----------------------------------------------------------------------------
SELECT
    examination_type,
    COUNT(*)                   AS n_echos,
    COUNT(DISTINCT pseudo_id)  AS unique_patients,
    ROUND(AVG(heart_rate), 1)  AS mean_heart_rate_bpm
FROM amc_core.echo_measurement_heart
WHERE examination_type IS NOT NULL
GROUP BY examination_type
ORDER BY n_echos DESC;


-- =============================================================================
-- SECTION 15 — CLINICAL NOTES VOLUME
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [54/61] 15.1 Note volume by category and status — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[54] Running: 15.1 Note volume by category and status'
\o :outdir/54_15_1_note_volume_by_category_and_status.csv
-- 15.1  Note volume by category and status
-- Structured note metadata available even without NLP on note text.
-- patient_note_category shows documentation type (progress note, discharge letter, etc.)
-- is_confidential flags notes that may need special access controls for research.
-- ----------------------------------------------------------------------------
SELECT
    patient_note_category,
    note_status,
    COUNT(*)                   AS n_notes,
    COUNT(DISTINCT pseudo_id)  AS unique_patients,
    COUNT(*) FILTER (WHERE is_confidential = 'J') AS confidential_notes
FROM amc_core.patient_note_patient_contact
GROUP BY patient_note_category, note_status
ORDER BY n_notes DESC
LIMIT 20;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [55/61] 15.2 Notes per patient distribution — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[55] Running: 15.2 Notes per patient distribution'
\o :outdir/55_15_2_notes_per_patient_distribution.csv
-- 15.2  Notes per patient distribution
-- Patients with many notes are likely long-term or complex.
-- Very low note counts may mean data is selective (e.g., only discharge letters).
-- ----------------------------------------------------------------------------
WITH notes_per_patient AS (
    SELECT pseudo_id, COUNT(*) AS n_notes
    FROM amc_core.patient_note_patient_contact
    GROUP BY pseudo_id
)
SELECT
    CASE
        WHEN n_notes = 1    THEN '1'
        WHEN n_notes <= 5   THEN '2-5'
        WHEN n_notes <= 20  THEN '6-20'
        WHEN n_notes <= 50  THEN '21-50'
        WHEN n_notes <= 100 THEN '51-100'
        ELSE '101+'
    END               AS notes_band,
    COUNT(*)          AS n_patients
FROM notes_per_patient
GROUP BY notes_band
ORDER BY MIN(n_notes);


-- =============================================================================
-- SECTION 16 — DATA QUALITY AND COMPLETENESS
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [56/61] 16.1 Key field null rates in critical tables — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[56] Running: 16.1 Key field null rates in critical tables'
\o :outdir/56_16_1_key_field_null_rates_in_critical_tables.csv
-- 16.1  Key field null rates in critical tables
-- NULL rates in anchor fields (pseudo_id, patient_contact_id) indicate
-- data quality issues that may need exclusion criteria in cohort definitions.
-- ----------------------------------------------------------------------------
SELECT
    'admission_traject'        AS tbl,
    'patient_contact_id'       AS field,
    COUNT(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = '') AS null_or_empty,
    COUNT(*)                   AS total,
    ROUND(100.0 * COUNT(*) FILTER (WHERE patient_contact_id IS NULL OR patient_contact_id = '')
          / NULLIF(COUNT(*), 0), 1) AS null_pct
FROM amc_core.admission_traject
UNION ALL
SELECT 'admission_traject', 'discharge_date',
    COUNT(*) FILTER (WHERE discharge_date IS NULL), COUNT(*),
    ROUND(100.0 * COUNT(*) FILTER (WHERE discharge_date IS NULL) / NULLIF(COUNT(*),0), 1)
FROM amc_core.admission_traject
UNION ALL
SELECT 'lab_result', 'result_numeric',
    COUNT(*) FILTER (WHERE result_numeric IS NULL), COUNT(*),
    ROUND(100.0 * COUNT(*) FILTER (WHERE result_numeric IS NULL) / NULLIF(COUNT(*),0), 1)
FROM amc_core.lab_result
UNION ALL
SELECT 'medical_diagnosis', 'diagnosis_code',
    COUNT(*) FILTER (WHERE diagnosis_code IS NULL OR diagnosis_code = ''), COUNT(*),
    ROUND(100.0 * COUNT(*) FILTER (WHERE diagnosis_code IS NULL OR diagnosis_code = '')
          / NULLIF(COUNT(*),0), 1)
FROM amc_core.medical_diagnosis
UNION ALL
SELECT 'medication_prescription', 'atc_code',
    COUNT(*) FILTER (WHERE atc_code IS NULL OR atc_code = ''), COUNT(*),
    ROUND(100.0 * COUNT(*) FILTER (WHERE atc_code IS NULL OR atc_code = '')
          / NULLIF(COUNT(*),0), 1)
FROM amc_core.medication_prescription
UNION ALL
SELECT 'patient_not_traceable', 'year_of_birth',
    COUNT(*) FILTER (WHERE year_of_birth IS NULL), COUNT(*),
    ROUND(100.0 * COUNT(*) FILTER (WHERE year_of_birth IS NULL) / NULLIF(COUNT(*),0), 1)
FROM amc_core.patient_not_traceable
UNION ALL
SELECT 'patient_not_traceable', 'gender',
    COUNT(*) FILTER (WHERE gender IS NULL OR gender = ''), COUNT(*),
    ROUND(100.0 * COUNT(*) FILTER (WHERE gender IS NULL OR gender = '')
          / NULLIF(COUNT(*),0), 1)
FROM amc_core.patient_not_traceable
ORDER BY null_pct DESC;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [57/61] 16.2 Patients in patient_not_traceable not found in any event table — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[57] Running: 16.2 Patients in patient_not_traceable not found in any event table'
\o :outdir/57_16_2_patients_in_patient_not_traceable_not_found_in_any.csv
-- 16.2  Patients in patient_not_traceable not found in any event table
-- These "ghost" patients have a master record but no associated clinical data.
-- They may be from research registrations, anonymisation artefacts, or ETL gaps.
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS patients_with_no_events
FROM amc_core.patient_not_traceable p
WHERE NOT EXISTS (SELECT 1 FROM amc_core.patient_contact      pc ON pc.pseudo_id = p.pseudo_id)
  AND NOT EXISTS (SELECT 1 FROM amc_core.admission_traject    at_ WHERE at_.pseudo_id = p.pseudo_id)
  AND NOT EXISTS (SELECT 1 FROM amc_core.lab_result           lr  WHERE lr.pseudo_id  = p.pseudo_id);


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [58/61] 16.3 Duplicate detection — patients with multiple death registrations — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[58] Running: 16.3 Duplicate detection — patients with multiple death registrations'
\o :outdir/58_16_3_duplicate_detection_patients_with_multiple_death_r.csv
-- 16.3  Duplicate detection — patients with multiple death registrations
-- Each patient should have at most one death. Multiples suggest ETL issues
-- or data from multiple source systems with different event identifiers.
-- ----------------------------------------------------------------------------
SELECT
    pseudo_id,
    COUNT(*) AS n_death_records
FROM amc_core.death_registration
GROUP BY pseudo_id
HAVING COUNT(*) > 1
ORDER BY n_death_records DESC;


-- =============================================================================
-- SECTION 17 — COHORT BUILDING EXAMPLE TEMPLATES
-- =============================================================================

-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [59/61] 17.1 Template: admitted adult patients with at least one ICU stay — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[59] Running: 17.1 Template: admitted adult patients with at least one ICU stay'
\o :outdir/59_17_1_template_admitted_adult_patients_with_at_least_one.csv
-- 17.1  Template: admitted adult patients with at least one ICU stay
-- Starting point for ICU cohort studies. Extend with diagnosis, medication,
-- or lab filters for specific research questions.
-- ----------------------------------------------------------------------------
SELECT DISTINCT
    at_.pseudo_id,
    p.year_of_birth,
    p.gender,
    at_.admission_traject_id,
    at_.admission_date,
    at_.discharge_date,
    (at_.discharge_date - at_.admission_date)   AS los_days,
    CASE WHEN dr.pseudo_id IS NOT NULL THEN 1 ELSE 0 END AS died
FROM amc_core.admission_traject at_
INNER JOIN amc_core.patient_not_traceable p ON at_.pseudo_id = p.pseudo_id
-- Filter: adults only
WHERE (EXTRACT(YEAR FROM at_.admission_date) - p.year_of_birth) >= 18
-- Filter: at least one ICU partial traject
  AND EXISTS (
        SELECT 1
        FROM amc_core.admission_partial_traject apt
        WHERE apt.admission_traject_id = at_.admission_traject_id
          AND (LOWER(apt.workplace) LIKE '%icu%'
            OR LOWER(apt.workplace) LIKE '%intensive%')
      )
-- Filter: complete admission (no open stays)
  AND at_.discharge_date IS NOT NULL
LEFT JOIN amc_core.death_registration dr ON at_.pseudo_id = dr.pseudo_id
ORDER BY at_.admission_date DESC
LIMIT 100;   -- remove LIMIT for full cohort


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [60/61] 17.2 Template: patients with a specific diagnosis who received a medication — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[60] Running: 17.2 Template: patients with a specific diagnosis who received a medication'
\o :outdir/60_17_2_template_patients_with_a_specific_diagnosis_who_re.csv
-- 17.2  Template: patients with a specific diagnosis who received a medication
-- Example: patients with heart failure (ICD I50) on loop diuretics (ATC C03C)
-- Substitute diagnosis_code and atc_code_niv3 for your research question.
-- ----------------------------------------------------------------------------
SELECT DISTINCT
    md_.pseudo_id,
    p.year_of_birth,
    p.gender,
    md_.diagnosis_code,
    md_.diagnosis_description,
    atc.atc_name_niv3  AS drug_class
FROM amc_core.medical_diagnosis md_
INNER JOIN amc_core.patient_not_traceable p   ON md_.pseudo_id = p.pseudo_id
INNER JOIN amc_core.medication_prescription mp ON md_.pseudo_id = mp.pseudo_id
INNER JOIN amc_core.medication_atc atc         ON mp.atc_code   = atc.atc_code
WHERE md_.diagnosis_code LIKE 'I50%'       -- Heart failure — adjust to your code format
  AND atc.atc_code_niv3 = 'C03C'          -- Loop diuretics (furosemide etc.)
LIMIT 100;


-- ----------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
\! echo "  [61/61] 17.3 Template: tobacco smokers with lung-related diagnoses — $(date +%H:%M:%S)" >> /tmp/amc_results/run.log
\echo '[61] Running: 17.3 Template: tobacco smokers with lung-related diagnoses'
\o :outdir/61_17_3_template_tobacco_smokers_with_lung_related_diagnos.csv
-- 17.3  Template: tobacco smokers with lung-related diagnoses
-- Tobacco use table flags current and former smokers.
-- Cross with diagnosis for respiratory cohort selection.
-- ----------------------------------------------------------------------------
SELECT DISTINCT
    tu.pseudo_id,
    tu.status_tobacco_use,
    tu.type_tobacco_use,
    tu.is_current_smoker,
    tu.is_former_smoker,
    tu.quantity_packages_per_day,
    md_.diagnosis_code,
    md_.diagnosis_description
FROM amc_core.tobacco_use tu
INNER JOIN amc_core.medical_diagnosis md_ ON tu.pseudo_id = md_.pseudo_id
WHERE (tu.is_current_smoker = 'J' OR tu.is_former_smoker = 'J')
  AND md_.diagnosis_code LIKE 'J%'   -- Respiratory chapter (ICD J00-J99)
LIMIT 100;

-- ── Close any open output file ───────────────────────────────────────────────
\o

-- ── Final log entry ───────────────────────────────────────────────────────────
\o /tmp/amc_results/run.log
\! echo ""
\! echo "Finished: $(date)"
\! echo "All CSVs written to /tmp/amc_results/"
\! ls -lh /tmp/amc_results/*.csv 2>/dev/null | awk '{print $5, $9}'
\o

\echo ''
\echo '✓ Analysis complete. Check /tmp/amc_results/'
\timing off
