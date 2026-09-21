-- ============================================================================
-- PRESENTATION PREP QUERIES
-- Scale/orientation, architecture credibility, domain inventory, ICU deep
-- dive, and known limitations -- organized by slide section. Run each and
-- fill the numbers directly into slides.
-- ============================================================================


-- ============================================================================
-- SECTION 1: ORIENTATION / SCALE
-- ============================================================================

-- 1.1 Total unique patients in the warehouse
SELECT COUNT(DISTINCT pseudo_id) AS total_patients
FROM amc_core.patient_not_traceable;

-- 1.2 Date range covered
SELECT
    MIN(start_datetime) AS earliest_event,
    MAX(start_datetime) AS latest_event
FROM amc_views.v_clinical_timeline;

-- 1.3 Total encounters / stays
SELECT
    (SELECT COUNT(*) FROM amc_views.v_stays) AS total_stays,
    (SELECT COUNT(*) FROM amc_views.v_encounters) AS total_encounters,
    (SELECT COUNT(*) FROM amc_views.v_appointments WHERE source_table = 'patient_appointment') AS total_appointments;

-- 1.4 Row counts across the whole timeline by domain (the "what's in here" slide)
SELECT event_domain, COUNT(*) AS row_count, COUNT(DISTINCT pseudo_id) AS unique_patients
FROM amc_views.v_clinical_timeline
GROUP BY event_domain
ORDER BY row_count DESC;

-- 1.5 Hospital locations represented (AMC vs VUmc etc.)
SELECT hospital_location, COUNT(*) AS n
FROM amc_views.v_stays
GROUP BY hospital_location
ORDER BY n DESC;


-- ============================================================================
-- SECTION 2: ARCHITECTURE / DATA QUALITY CREDIBILITY
-- ============================================================================

-- 2.1 Before/after row counts for the vital signs dedup (use numbers already
-- gathered today -- see your changelog doc). Just for reference, re-run live:
SELECT measurement_name, COUNT(*) AS row_count
FROM amc_views.v_vital_signs_long
GROUP BY measurement_name
ORDER BY measurement_name;

-- 2.2 v_procedures composition after the redesign
SELECT procedure_source, COUNT(*) AS row_count, COUNT(DISTINCT pseudo_id) AS unique_patients
FROM amc_views.v_procedures
GROUP BY procedure_source
ORDER BY row_count DESC;

-- 2.3 View inventory -- a simple list of all views for an appendix/reference slide
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'amc_views'
ORDER BY table_name;

-- 2.4 View inventory grouped by category, with row counts -- feeds the
-- "what views exist and what's in them" slide. Run this and use the output
-- directly to fill in the schema overview table.
SELECT
    'v_patient_profile' AS view_name, 'Patient / encounter' AS category,
    'One row per patient: demographics, smoking, death registration' AS contains
UNION ALL SELECT 'v_stays', 'Patient / encounter', 'Admissions, partial stays, ED visits -- unified'
UNION ALL SELECT 'v_encounters', 'Patient / encounter', 'All contact types: visits, appointments, admissions, ED'
UNION ALL SELECT 'v_appointments', 'Patient / encounter', 'Scheduled appointments, outpatient'
UNION ALL SELECT 'v_contact_id_registry', 'Patient / encounter', 'Lookup table mapping contact IDs across source tables'
UNION ALL SELECT 'v_medical_history', 'Clinical domain', 'Medical, surgical, family history'
UNION ALL SELECT 'v_diagnoses_longitudinal', 'Clinical domain', 'Diagnoses + problem list, longitudinal'
UNION ALL SELECT 'v_medications', 'Clinical domain', 'Prescriptions + administrations'
UNION ALL SELECT 'v_procedures', 'Clinical domain', 'OK + IC bedside procedures (rebuilt today)'
UNION ALL SELECT 'v_procedures_billing', 'Clinical domain', 'General billing/DBC feed -- coverage cross-check (new today)'
UNION ALL SELECT 'v_vital_signs_long', 'Clinical domain', 'HR, BP, temp, SpO2, height, weight, BMI (deduped today)'
UNION ALL SELECT 'v_labs_long', 'Clinical domain', 'All lab results, long format'
UNION ALL SELECT 'v_scores', 'Clinical domain', 'CHA2DS2-VASc, DOSS, SNAQ clinical scores'
UNION ALL SELECT 'v_fluid_balance_long', 'Clinical domain', 'Fluid in/out, output, stool/urine assessments'
UNION ALL SELECT 'v_nephrology_treatments', 'Clinical domain', 'Hemodialysis, peritoneal dialysis, CVVH'
UNION ALL SELECT 'v_imaging_study_orders', 'Clinical domain', 'Radiology orders + status'
UNION ALL SELECT 'v_ecg_exams', 'Clinical domain', 'ECG metadata'
UNION ALL SELECT 'v_ecg_measurements_long', 'Clinical domain', 'ECG numeric measurements (PR, QRS, QTc...)'
UNION ALL SELECT 'v_echo_heart_exams', 'Clinical domain', 'Echocardiogram metadata'
UNION ALL SELECT 'v_echo_heart_measurements_long', 'Clinical domain', 'Echo numeric measurements by anatomic region'
UNION ALL SELECT 'v_questionnaires_long', 'Clinical domain', 'Patient-reported questionnaire responses'
UNION ALL SELECT 'v_adverse_events', 'Clinical domain', 'Adverse events, research project linkage'
UNION ALL SELECT 'v_notes', 'Clinical domain', 'Clinical notes, full text + metadata'
UNION ALL SELECT 'v_measurements', 'Aggregator', 'Vitals + labs + scores + fluid + nephrology, unified'
UNION ALL SELECT 'v_clinical_timeline', 'Aggregator', 'Every domain, one row per event, patient-level'
UNION ALL SELECT 'v_icu_patient_profile', 'ICU mirror', 'Patient profile, ICU patients only'
UNION ALL SELECT 'v_icu_stays', 'ICU mirror', 'ICU stay boundaries + LOS'
UNION ALL SELECT 'v_icu_*', 'ICU mirror', 'Every domain view above, scoped to ICU stay window (procedures, vitals, labs, scores, fluid balance, nephrology, notes, medications, diagnoses, medical history)'
UNION ALL SELECT 'v_icu_clinical_timeline', 'ICU mirror', 'v_clinical_timeline, ICU-scoped';


-- ============================================================================
-- SECTION 3: DATA INVENTORY BY DOMAIN
-- ============================================================================

-- 3.1 Vitals / labs / meds / procedures / diagnoses / notes -- one summary table
SELECT 'vital_signs' AS domain, COUNT(*) AS rows, COUNT(DISTINCT pseudo_id) AS patients,
       MIN(measurement_datetime)::date AS earliest, MAX(measurement_datetime)::date AS latest
FROM amc_views.v_vital_signs_long

UNION ALL

SELECT 'labs', COUNT(*), COUNT(DISTINCT pseudo_id),
       MIN(measurement_datetime)::date, MAX(measurement_datetime)::date
FROM amc_views.v_labs_long

UNION ALL

SELECT 'medications', COUNT(*), COUNT(DISTINCT pseudo_id),
       MIN(event_datetime)::date, MAX(event_datetime)::date
FROM amc_views.v_medications

UNION ALL

SELECT 'procedures', COUNT(*), COUNT(DISTINCT pseudo_id),
       MIN(procedure_datetime)::date, MAX(procedure_datetime)::date
FROM amc_views.v_procedures

UNION ALL

SELECT 'diagnoses', COUNT(*), COUNT(DISTINCT pseudo_id),
       MIN(registration_datetime)::date, MAX(registration_datetime)::date
FROM amc_views.v_diagnoses_longitudinal

UNION ALL

SELECT 'medical_history', COUNT(*), COUNT(DISTINCT pseudo_id),
       MIN(registration_date)::date, MAX(registration_date)::date
FROM amc_views.v_medical_history

UNION ALL

SELECT 'notes', COUNT(*), COUNT(DISTINCT pseudo_id),
       MIN(note_datetime)::date, MAX(note_datetime)::date
FROM amc_views.v_notes

UNION ALL

SELECT 'scores', COUNT(*), COUNT(DISTINCT pseudo_id),
       MIN(score_datetime)::date, MAX(score_datetime)::date
FROM amc_views.v_scores

UNION ALL

SELECT 'fluid_balance', COUNT(*), COUNT(DISTINCT pseudo_id),
       MIN(measurement_datetime)::date, MAX(measurement_datetime)::date
FROM amc_views.v_fluid_balance_long

ORDER BY rows DESC;

-- 3.2 Notes: how much text data, what categories
SELECT patient_note_category, COUNT(*) AS n, COUNT(DISTINCT pseudo_id) AS patients,
       ROUND(AVG(word_length)) AS avg_words
FROM amc_views.v_notes
GROUP BY patient_note_category
ORDER BY n DESC
LIMIT 15;

-- 3.3 Lab test variety -- how many distinct lab tests exist (gives sense of breadth)
SELECT COUNT(DISTINCT measurement_code) AS distinct_lab_tests,
       COUNT(DISTINCT measurement_name) AS distinct_lab_names
FROM amc_views.v_labs_long;

-- 3.4 Medication coverage -- distinct ATC classes
SELECT COUNT(DISTINCT atc_code) AS distinct_atc_codes,
       COUNT(DISTINCT pharmaceutical_class) AS distinct_pharma_classes
FROM amc_views.v_medications;

-- 3.5 Known data quality gap: mortality
-- Show the actual scope of the problem for the "known limitations" slide
SELECT
    COUNT(*) AS total_patients,
    COUNT(*) FILTER (WHERE is_deceased = 1) AS marked_deceased,
    COUNT(*) FILTER (WHERE is_deceased = 1 AND year_of_death IS NULL) AS deceased_no_year,
    COUNT(*) FILTER (WHERE has_death_registration) AS has_death_registration,
    COUNT(*) FILTER (WHERE is_deceased = 1 AND NOT has_death_registration) AS deceased_but_no_registration
FROM amc_views.v_patient_profile;


-- ============================================================================
-- SECTION 4: ICU DEEP DIVE
-- ============================================================================

-- 4.1 ICU cohort size
SELECT
    COUNT(DISTINCT pseudo_id) AS unique_icu_patients,
    COUNT(*) AS total_icu_stays
FROM amc_views.v_icu_stays;

-- 4.2 ICU length of stay distribution
SELECT
    ROUND(MIN(icu_los_hours) / 24.0, 1) AS min_days,
    ROUND(AVG(icu_los_hours) / 24.0, 1) AS mean_days,
    ROUND(
        PERCENTILE_CONT(0.5) OVER () , 1
    ) AS placeholder -- see windowed version below
FROM amc_views.v_icu_stays;

-- Better LOS distribution using percentiles properly:
SELECT
    ROUND(MIN(icu_los_hours)/24.0, 2) AS min_days,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY icu_los_hours)/24.0, 2) AS p25_days,
    ROUND(PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY icu_los_hours)/24.0, 2) AS median_days,
    ROUND(AVG(icu_los_hours)/24.0, 2) AS mean_days,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY icu_los_hours)/24.0, 2) AS p75_days,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY icu_los_hours)/24.0, 2) AS p95_days,
    ROUND(MAX(icu_los_hours)/24.0, 2) AS max_days
FROM amc_views.v_icu_stays
WHERE icu_los_hours IS NOT NULL AND icu_los_hours >= 0;

-- 4.3 ICU LOS by specialty/workplace -- which ICUs/units are represented
SELECT workplace, specialty, COUNT(*) AS n_stays,
       ROUND(AVG(icu_los_hours)/24.0, 1) AS mean_los_days
FROM amc_views.v_icu_stays
WHERE icu_los_hours IS NOT NULL AND icu_los_hours >= 0
GROUP BY workplace, specialty
ORDER BY n_stays DESC
LIMIT 15;

-- 4.4 Multiple ICU stays per patient (readmissions within the data)
SELECT n_stays, COUNT(*) AS n_patients
FROM (
    SELECT pseudo_id, COUNT(*) AS n_stays
    FROM amc_views.v_icu_stays
    GROUP BY pseudo_id
) t
GROUP BY n_stays
ORDER BY n_stays;

-- 4.5 ICU mortality proxy (CAVEAT: mortality data quality is a known issue --
-- frame this as "here's what we can compute today, here's the caveat")
SELECT
    COUNT(DISTINCT icu.pseudo_id) AS icu_patients,
    COUNT(DISTINCT icu.pseudo_id) FILTER (WHERE p.is_deceased = 1) AS deceased_at_any_point,
    COUNT(DISTINCT icu.pseudo_id) FILTER (
        WHERE p.is_deceased = 1
          AND p.death_registration_moment IS NOT NULL
          AND p.death_registration_moment BETWEEN icu.icu_start_datetime AND icu.icu_end_datetime + interval '2 days'
    ) AS likely_died_during_or_just_after_icu_stay
FROM amc_views.v_icu_stays icu
JOIN amc_views.v_patient_profile p ON p.pseudo_id = icu.pseudo_id;

-- 4.6 ICU data density -- how many measurements/labs per ICU stay on average
-- (useful to show "this is rich enough for time-series work")
SELECT
    ROUND(AVG(n_vitals)) AS avg_vitals_per_stay,
    ROUND(AVG(n_labs)) AS avg_labs_per_stay,
    ROUND(AVG(n_meds)) AS avg_meds_per_stay
FROM (
    SELECT
        icu.icu_stay_id,
        (SELECT COUNT(*) FROM amc_views.v_icu_vital_signs_long v WHERE v.icu_stay_id = icu.icu_stay_id) AS n_vitals,
        (SELECT COUNT(*) FROM amc_views.v_icu_labs_long l WHERE l.icu_stay_id = icu.icu_stay_id) AS n_labs,
        (SELECT COUNT(*) FROM amc_views.v_icu_medications m WHERE m.pseudo_id = icu.pseudo_id) AS n_meds
    FROM amc_views.v_icu_stays icu
    TABLESAMPLE SYSTEM (5)  -- sample 5% of stays for speed; remove if dataset is small enough to run on all
) sub;

-- 4.7 Pick ONE concrete (de-identified) patient for the walkthrough story.
-- Look for someone with a moderate stay (not too short, not an extreme outlier)
-- and reasonably rich data across domains, for a compelling but representative example.
SELECT icu.pseudo_id, icu.icu_stay_id, icu.icu_los_hours/24.0 AS los_days,
       icu.workplace, icu.specialty,
       (SELECT COUNT(*) FROM amc_views.v_icu_vital_signs_long v WHERE v.icu_stay_id = icu.icu_stay_id) AS n_vitals,
       (SELECT COUNT(*) FROM amc_views.v_icu_labs_long l WHERE l.icu_stay_id = icu.icu_stay_id) AS n_labs,
       (SELECT COUNT(*) FROM amc_views.v_icu_procedures pr WHERE pr.icu_stay_id = icu.icu_stay_id) AS n_procedures,
       (SELECT COUNT(*) FROM amc_views.v_icu_notes nt WHERE nt.icu_stay_id = icu.icu_stay_id) AS n_notes
FROM amc_views.v_icu_stays icu
WHERE icu.icu_los_hours BETWEEN 72 AND 168  -- 3-7 day stay, "typical" not extreme
ORDER BY n_vitals DESC, n_labs DESC
LIMIT 10;

-- Once you pick a pseudo_id + icu_stay_id from above, get their full story:
-- (replace :pseudo_id and :icu_stay_id below)

-- 4.8 The chosen patient's full ICU timeline (for the walkthrough slide)
SELECT event_datetime, event_domain, event_type, event_label, value_numeric, value_text, unit
FROM amc_views.v_icu_clinical_timeline
WHERE icu_stay_id = ':icu_stay_id'
ORDER BY event_datetime
LIMIT 50;

-- 4.9 That patient's basic profile (for context on the slide)
SELECT gender, year_of_birth, is_deceased, latest_tobacco_status
FROM amc_views.v_icu_patient_profile
WHERE pseudo_id = ':pseudo_id';

-- 4.10 That patient's vitals over time (good for a simple chart in the slide)
SELECT measurement_datetime, measurement_name, value_numeric, unit
FROM amc_views.v_icu_vital_signs_long
WHERE icu_stay_id = ':icu_stay_id'
  AND measurement_name IN ('heart_rate', 'systolic_blood_pressure', 'oxygen_saturation', 'temperature')
ORDER BY measurement_datetime;


-- ============================================================================
-- SECTION 5: KNOWN LIMITATIONS / IN-PROGRESS WORK
-- ============================================================================

-- 5.1 Domains missing patient_contact_id (the gap you mentioned -- labs,
-- some measurements -- vs what's available in procedures/encounters)
SELECT
    'v_labs_long' AS view_name,
    COUNT(*) AS total_rows,
    COUNT(patient_contact_id) AS rows_with_contact_id,
    ROUND(100.0 * COUNT(patient_contact_id) / COUNT(*), 1) AS pct_with_contact_id
FROM amc_views.v_labs_long

UNION ALL

SELECT 'v_vital_signs_long', COUNT(*), COUNT(patient_contact_id),
       ROUND(100.0 * COUNT(patient_contact_id) / COUNT(*), 1)
FROM amc_views.v_vital_signs_long

UNION ALL

SELECT 'v_procedures', COUNT(*), COUNT(patient_contact_id),
       ROUND(100.0 * COUNT(patient_contact_id) / COUNT(*), 1)
FROM amc_views.v_procedures;

-- 5.2 v_clinical_timeline row counts by source view (to show what needs
-- re-validation after the procedures rework)
SELECT source_view, COUNT(*) AS n
FROM amc_views.v_clinical_timeline
GROUP BY source_view
ORDER BY n DESC;
