-- =============================================================================
-- AMC CORE — ICU PATIENT STATISTICS & TRACEABILITY
-- =============================================================================
-- Definition of ICU:
--   admission_partial_traject.workplace ILIKE ANY('%INTENSIVE CARE%','%NICU%','%PICU%')
--   This is the ONLY reliable ICU filter. Do not use admission_traject.admission_specialty
--   or patient_contact.specialty — workplace in partial_traject is the ward-level field.
--
-- JOIN STRATEGY (from known data quality):
--   PRIMARY key: pseudo_id (100% clean, enforced FK everywhere)
--   SECONDARY key: patient_contact_id — use only within tables where confirmed non-orphan
--     (avoid for medical_diagnosis: 36% orphan; avoid for procedures: 46% null)
--   DATE joins: use result_date for lab (not material_decrease_date — 7% pre-2000)
--   ADMISSION window: admission_traject (admission_date, discharge_date) — 0 logical errors
--   ICU window: admission_partial_traject (start_date_time, end_date_time) — 0 logical errors
--
-- TABLE REFERENCE:
--   patient_not_traceable           → master patient registry (pseudo_id PK)
--   patient_social                  → marital status, education (pseudo_id PK)
--   patient_contact                 → every encounter/contact (patient_contact_id PK)
--   admission_traject               → inpatient admission episode (admission_traject_id PK)
--   admission_partial_traject       → ward-level stay within admission (→ workplace for ICU)
--   seh_trajectory                  → ED trajectory (→ admission_traject_id)
--   death_registration              → death record (pseudo_id FK)
--   medical_diagnosis               → diagnoses per contact (diagnosis_code, ICD-like)
--   problem_list                    → active/chronic problems (snomed_code, diagnose_thesaurus_code)
--   medication_prescription         → prescriptions (rule_id PK, atc_code FK → medication_atc)
--   medication_administration       → administered doses (rule_id → prescription, admission_traject_id)
--   medication_atc                  → ATC hierarchy lookup (atc_code PK, 5 levels)
--   procedures                      → interventions (pseudo_id+intervention_id composite PK)
--   ok_procedure_performed          → OR procedures performed (ok_session_number)
--   lab_result                      → lab results (pseudo_id+sample_id+determination_code PK)
--   measurement_vital_signs_data    → combined vitals snapshot (bigserial PK)
--   measurement_blood_pressure      → BP (patient_contact_id+measurement_moment+demand_observation PK)
--   measurement_heart_frequency     → HR (patient_contact_id+measurement_moment+heart_rate PK)
--   measurement_o2_saturation       → SpO2 (patient_contact_id+measurement_moment+o2saturation PK)
--   measurement_height              → height (patient_contact_id+measurement_moment PK)
--   measurement_weight              → weight (patient_contact_id+measurement_moment PK)
--   measurement_bmi                 → BMI (patient_contact_id+measurement_moment+bmi PK)
--   measurement_diurese             → urine output (patient_contact_id+measurement_moment PK)
--   measurement_fluid_in            → fluid intake (measurement_moisture_at_id PK)
--   measurement_fluid_balance_out   → fluid output (measurement_moisture_out_id PK)
--   measurement_fluid_balance_stomach_retention → gastric retention
--   measurement_fluid_assessment_diuresis       → urine assessment
--   measurement_fluid_balance_assessment_emesis → vomiting
--   measurement_fluid_balance_assessment_feces  → stool
--   measurement_nephrology_hemodialysis         → HD sessions
--   measurement_nephrology_peritoneal_dialysis  → PD sessions
--   measurement_nephrology_cnvt_settings        → CVVT/CVVH settings
--   measurement_nephrology_cntv_medication      → citrate/calcium anticoagulation
--   measurement_chadsvasc_score     → CHA2DS2-VASc
--   measurement_doss_score          → delirium (DOS)
--   measurement_snaq_score          → nutritional screening
--   patient_questionnaire           → patient-reported outcomes
--   ecg_measurement                 → ECG with quantitative measures
--   echo_measurement_heart          → echocardiography (lvef_mod, lvef_teich, etc.)
--   patient_note_patient_contact    → note metadata (patient_note_id → amc_notes.note_id)
--   ic_procedure_note_bronchoscopy  → (patient_contact_id+order_id PK)
--   ic_procedure_note_icarus        → lung US (patient_contact_id+order_id PK)
--   ic_procedure_note_intubation    → (order_id PK)
--   ic_procedure_note_tracheostomy  → (order_id PK)
--   ic_procedure_note_thorax_drain  → (order_id PK)
--   ic_procedure_note_central_venous_catheter → CVC (order_id PK)
--   ic_procedure_note_electric_cardioversion  → ECV (order_id PK)
--   imaging_study_order             → radiology orders (imaging_study_order_id bigserial PK)
--   tobacco_use                     → smoking history (note: start_date 99% pre-2000 — treat as categorical)
--   surgery_history                 → surgical history
--   family_history                  → family history
--   adverse_event                   → adverse events / study events
--
-- HOW TO RUN:
--   sed 's|/tmp/amc_icu|/net/beegfs/users/P014993/results-icu|g' icu-cohort-analysis.sql > icu_run.sql
--   \i /net/beegfs/users/P014993/scripts/icu_run.sql
-- =============================================================================

\pset format csv
\pset tuples_only off
\pset footer on
\timing on
\set ON_ERROR_CONTINUE on
\set outdir '/tmp/amc_icu'
\! mkdir -p /tmp/amc_icu

\o /tmp/amc_icu/run.log
\echo '============================================================'
\echo 'AMC Core — ICU Patient Statistics & Traceability'
\echo '============================================================'
\! echo "Started: $(date)"
\o


-- =============================================================================
-- BASE CTE — ICU STAYS
-- Reused in all queries below via a shared definition.
-- Identifies ICU stays at the ward level (admission_partial_traject).
-- Excludes reversed stays (end < start — confirmed 0 in audit, but safe guard kept).
-- =============================================================================
-- NOTE: Because psql doesn't support WITH across separate \o blocks,
-- each query section defines icu_stays inline as a CTE.
-- The ICU definition is always:
--
--   WITH icu_stays AS (
--       SELECT
--           apt.pseudo_id,
--           apt.admission_traject_id,
--           apt.admission_partial_traject_id,
--           apt.workplace,
--           apt.specialty,
--           apt.start_date_time,
--           apt.end_date_time,
--           apt.start_date,
--           apt.end_date,
--           apt.age_in_years_at_moment_admission,
--           at_.admission_date,
--           at_.discharge_date,
--           at_.admission_origin,
--           at_.discharge_method,
--           at_.admission_via_seh,
--           at_.is_admission_elective,
--           EXTRACT(EPOCH FROM (apt.end_date_time - apt.start_date_time))/3600.0 AS icu_los_hours
--       FROM amc_core.admission_partial_traject apt
--       INNER JOIN amc_core.admission_traject at_
--             ON apt.admission_traject_id = at_.admission_traject_id
--       WHERE (
--             apt.workplace ILIKE '%INTENSIVE CARE%'
--          OR apt.workplace ILIKE '%NICU%'
--          OR apt.workplace ILIKE '%PICU%'
--       )
--       AND apt.start_date_time IS NOT NULL
--       AND apt.end_date_time   IS NOT NULL
--       AND apt.end_date_time   > apt.start_date_time   -- guard: no reversed stays
--   )


-- =============================================================================
-- SECTION 0 — ICU DEFINITION VALIDATION
-- Always run first to verify the workplace filter catches the right units.
-- =============================================================================

\! echo "  [0.1] ICU workplace values — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[0.1] Distinct workplace values matching ICU filter — validate before continuing'
\o /tmp/amc_icu/00_icu_workplace_values.csv

SELECT
    workplace,
    COUNT(*)                    AS n_stays,
    COUNT(DISTINCT pseudo_id)   AS unique_patients
FROM amc_core.admission_partial_traject
WHERE (
      workplace ILIKE '%INTENSIVE CARE%'
   OR workplace ILIKE '%NICU%'
   OR workplace ILIKE '%PICU%'
)
GROUP BY workplace
ORDER BY n_stays DESC;

-- Review this output before proceeding.
-- If unexpected workplace names appear, add or remove ILIKE filters.
-- If valid ICU units are missing, extend the WHERE clause.


-- =============================================================================
-- SECTION 1 — ICU COHORT SIZE AND OVERALL VOLUME
-- =============================================================================

\! echo "  [1.1] ICU cohort size — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[1.1] ICU cohort: stay counts, unique patients, unique admissions'
\o /tmp/amc_icu/01_icu_cohort_size.csv

WITH icu_stays AS (
    SELECT
        apt.pseudo_id,
        apt.admission_traject_id,
        apt.admission_partial_traject_id,
        apt.workplace,
        apt.start_date_time,
        apt.end_date_time,
        apt.start_date,
        EXTRACT(EPOCH FROM (apt.end_date_time - apt.start_date_time))/3600.0 AS icu_los_hours
    FROM amc_core.admission_partial_traject apt
    INNER JOIN amc_core.admission_traject at_
          ON apt.admission_traject_id = at_.admission_traject_id
    WHERE (
          apt.workplace ILIKE '%INTENSIVE CARE%'
       OR apt.workplace ILIKE '%NICU%'
       OR apt.workplace ILIKE '%PICU%'
    )
    AND apt.start_date_time IS NOT NULL
    AND apt.end_date_time   > apt.start_date_time
)
SELECT
    COUNT(*)                                              AS total_icu_ward_stays,
    COUNT(DISTINCT pseudo_id)                             AS unique_icu_patients,
    COUNT(DISTINCT admission_traject_id)                  AS unique_icu_admissions,
    -- patients with more than one ICU admission
    COUNT(DISTINCT pseudo_id) FILTER (WHERE pseudo_id IN (
        SELECT pseudo_id FROM icu_stays GROUP BY pseudo_id
        HAVING COUNT(DISTINCT admission_traject_id) > 1
    ))                                                    AS patients_with_multiple_icu_admissions,
    -- ward stays per admission (readmissions within same hospitalisation)
    ROUND(COUNT(*)::numeric /
          NULLIF(COUNT(DISTINCT admission_traject_id), 0), 2) AS avg_icu_stays_per_admission,
    -- by unit type
    COUNT(*) FILTER (WHERE workplace ILIKE '%NICU%')      AS nicu_stays,
    COUNT(*) FILTER (WHERE workplace ILIKE '%PICU%')      AS picu_stays,
    COUNT(*) FILTER (WHERE workplace ILIKE '%INTENSIVE CARE%'
                       AND workplace NOT ILIKE '%NICU%'
                       AND workplace NOT ILIKE '%PICU%')  AS adult_icu_stays
FROM icu_stays;


-- ----------------------------------------------------------------------------
-- 1.2  ICU admissions by year
-- ----------------------------------------------------------------------------
\! echo "  [1.2] ICU volume by year — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[1.2] ICU admission volume by year'
\o /tmp/amc_icu/01_icu_volume_by_year.csv

WITH icu_stays AS (
    SELECT
        apt.pseudo_id,
        apt.admission_traject_id,
        apt.start_date,
        apt.workplace,
        EXTRACT(EPOCH FROM (apt.end_date_time - apt.start_date_time))/3600.0 AS icu_los_hours
    FROM amc_core.admission_partial_traject apt
    WHERE (
          apt.workplace ILIKE '%INTENSIVE CARE%'
       OR apt.workplace ILIKE '%NICU%'
       OR apt.workplace ILIKE '%PICU%'
    )
    AND apt.start_date_time IS NOT NULL
    AND apt.end_date_time   > apt.start_date_time
)
SELECT
    EXTRACT(YEAR FROM start_date)::int  AS icu_year,
    COUNT(*)                            AS icu_ward_stays,
    COUNT(DISTINCT pseudo_id)           AS unique_patients,
    COUNT(DISTINCT admission_traject_id) AS unique_admissions,
    ROUND(AVG(icu_los_hours), 1)        AS avg_icu_los_hours,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY icu_los_hours)::numeric, 1) AS median_icu_los_hours
FROM icu_stays
WHERE start_date >= '2015-01-01'   -- data confirmed clean from 2015
GROUP BY icu_year
ORDER BY icu_year DESC;


-- =============================================================================
-- SECTION 2 — PATIENT DEMOGRAPHICS
-- =============================================================================

\! echo "  [2.1] ICU demographics — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[2.1] ICU patient demographics'
\o /tmp/amc_icu/02_icu_demographics.csv

WITH icu_patients AS (
    SELECT DISTINCT apt.pseudo_id,
           MIN(apt.age_in_years_at_moment_admission) AS age_at_first_icu
    FROM amc_core.admission_partial_traject apt
    WHERE (
          apt.workplace ILIKE '%INTENSIVE CARE%'
       OR apt.workplace ILIKE '%NICU%'
       OR apt.workplace ILIKE '%PICU%'
    )
    AND apt.start_date_time IS NOT NULL
    AND apt.end_date_time > apt.start_date_time
    GROUP BY apt.pseudo_id
)
SELECT
    COUNT(DISTINCT ip.pseudo_id)                                    AS n_icu_patients,
    ROUND(AVG(ip.age_at_first_icu), 1)                             AS mean_age,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ip.age_at_first_icu) AS median_age,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ip.age_at_first_icu) AS p25_age,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ip.age_at_first_icu) AS p75_age,
    MIN(ip.age_at_first_icu)                                       AS min_age,
    MAX(ip.age_at_first_icu)                                       AS max_age,
    -- gender breakdown from master table
    COUNT(*) FILTER (WHERE p.gender = 'M')                         AS n_male,
    COUNT(*) FILTER (WHERE p.gender = 'V')                         AS n_female,
    COUNT(*) FILTER (WHERE p.gender IS NULL OR p.gender = '')      AS n_gender_unknown,
    ROUND(100.0 * COUNT(*) FILTER (WHERE p.gender = 'M')
          / NULLIF(COUNT(*), 0), 1)                                AS pct_male
FROM icu_patients ip
LEFT JOIN amc_core.patient_not_traceable p ON ip.pseudo_id = p.pseudo_id;


-- ----------------------------------------------------------------------------
-- 2.2  Age band distribution
-- ----------------------------------------------------------------------------
\! echo "  [2.2] ICU age bands — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[2.2] ICU age band distribution'
\o /tmp/amc_icu/02_icu_age_bands.csv

WITH icu_patients AS (
    SELECT DISTINCT apt.pseudo_id,
           MIN(apt.age_in_years_at_moment_admission) AS age
    FROM amc_core.admission_partial_traject apt
    WHERE (
          apt.workplace ILIKE '%INTENSIVE CARE%'
       OR apt.workplace ILIKE '%NICU%'
       OR apt.workplace ILIKE '%PICU%'
    )
    AND apt.start_date_time IS NOT NULL
    AND apt.end_date_time > apt.start_date_time
    GROUP BY apt.pseudo_id
)
SELECT
    CASE
        WHEN age < 1   THEN 'neonate (<1y)'
        WHEN age < 18  THEN 'paediatric (1-17y)'
        WHEN age < 40  THEN 'adult 18-39y'
        WHEN age < 60  THEN 'adult 40-59y'
        WHEN age < 75  THEN 'adult 60-74y'
        WHEN age < 85  THEN 'older adult 75-84y'
        ELSE                'oldest old (85+)'
    END                                                     AS age_band,
    COUNT(*)                                                AS n_patients,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)     AS pct
FROM icu_patients
WHERE age IS NOT NULL
GROUP BY age_band
ORDER BY MIN(age);


-- =============================================================================
-- SECTION 3 — ICU LENGTH OF STAY
-- =============================================================================

\! echo "  [3.1] ICU LOS — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[3.1] ICU length of stay (ward-stay level)'
\o /tmp/amc_icu/03_icu_los.csv

WITH icu_stays AS (
    SELECT
        apt.pseudo_id,
        apt.admission_traject_id,
        apt.workplace,
        EXTRACT(EPOCH FROM (apt.end_date_time - apt.start_date_time))/3600.0  AS icu_los_hours,
        EXTRACT(EPOCH FROM (apt.end_date_time - apt.start_date_time))/86400.0 AS icu_los_days
    FROM amc_core.admission_partial_traject apt
    WHERE (
          apt.workplace ILIKE '%INTENSIVE CARE%'
       OR apt.workplace ILIKE '%NICU%'
       OR apt.workplace ILIKE '%PICU%'
    )
    AND apt.start_date_time IS NOT NULL
    AND apt.end_date_time > apt.start_date_time
)
SELECT
    COUNT(*)                                                               AS n_stays,
    -- hours
    ROUND(AVG(icu_los_hours)::numeric, 1)                                  AS mean_icu_los_hours,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY icu_los_hours)::numeric, 1) AS p25_hours,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY icu_los_hours)::numeric, 1) AS median_hours,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY icu_los_hours)::numeric, 1) AS p75_hours,
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY icu_los_hours)::numeric, 1) AS p90_hours,
    -- days
    ROUND(AVG(icu_los_days)::numeric, 1)                                   AS mean_icu_los_days,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY icu_los_days)::numeric, 1)  AS median_days,
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY icu_los_days)::numeric, 1)  AS p90_days,
    ROUND(MAX(icu_los_days)::numeric, 1)                                   AS max_icu_los_days,
    -- short vs long stays
    COUNT(*) FILTER (WHERE icu_los_hours < 24)                             AS stays_under_24h,
    COUNT(*) FILTER (WHERE icu_los_days  BETWEEN 1 AND 3)                  AS stays_1_to_3_days,
    COUNT(*) FILTER (WHERE icu_los_days  BETWEEN 3 AND 7)                  AS stays_3_to_7_days,
    COUNT(*) FILTER (WHERE icu_los_days  > 7)                              AS stays_over_7_days
FROM icu_stays;


-- ----------------------------------------------------------------------------
-- 3.2  Total hospital LOS for ICU admissions vs ICU LOS
-- ----------------------------------------------------------------------------
\! echo "  [3.2] Hospital vs ICU LOS — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[3.2] Hospital LOS vs ICU LOS per admission'
\o /tmp/amc_icu/03_hospital_vs_icu_los.csv

WITH icu_admissions AS (
    SELECT
        at_.admission_traject_id,
        at_.pseudo_id,
        at_.admission_date,
        at_.discharge_date,
        (at_.discharge_date - at_.admission_date)                           AS hospital_los_days,
        SUM(EXTRACT(EPOCH FROM (apt.end_date_time - apt.start_date_time))/86400.0) AS total_icu_days
    FROM amc_core.admission_traject at_
    INNER JOIN amc_core.admission_partial_traject apt
            ON at_.admission_traject_id = apt.admission_traject_id
    WHERE (
          apt.workplace ILIKE '%INTENSIVE CARE%'
       OR apt.workplace ILIKE '%NICU%'
       OR apt.workplace ILIKE '%PICU%'
    )
    AND apt.start_date_time IS NOT NULL
    AND apt.end_date_time   > apt.start_date_time
    AND at_.admission_date  IS NOT NULL
    AND at_.discharge_date  IS NOT NULL
    AND at_.discharge_date  >= at_.admission_date
    AND at_.discharge_date  < CURRENT_DATE + INTERVAL '1 year'
    GROUP BY at_.admission_traject_id, at_.pseudo_id, at_.admission_date, at_.discharge_date
)
SELECT
    COUNT(*)                                                                AS n_admissions,
    -- hospital LOS
    ROUND(AVG(hospital_los_days)::numeric, 1)                              AS mean_hospital_los_days,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY hospital_los_days)::numeric, 1) AS median_hospital_days,
    ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY hospital_los_days)::numeric, 1) AS p90_hospital_days,
    -- ICU LOS
    ROUND(AVG(total_icu_days)::numeric, 1)                                 AS mean_icu_days,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_icu_days)::numeric, 1)    AS median_icu_days,
    ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY total_icu_days)::numeric, 1)    AS p90_icu_days,
    -- ratio
    ROUND(AVG(total_icu_days / NULLIF(hospital_los_days, 0))::numeric, 2)  AS avg_icu_fraction_of_hosp
FROM icu_admissions;


-- =============================================================================
-- SECTION 4 — MORTALITY
-- =============================================================================

\! echo "  [4.1] ICU mortality — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[4.1] ICU patient mortality (death_registration + is_deceased flag)'
\o /tmp/amc_icu/04_icu_mortality.csv

WITH icu_patients AS (
    SELECT DISTINCT apt.pseudo_id
    FROM amc_core.admission_partial_traject apt
    WHERE (
          apt.workplace ILIKE '%INTENSIVE CARE%'
       OR apt.workplace ILIKE '%NICU%'
       OR apt.workplace ILIKE '%PICU%'
    )
    AND apt.start_date_time IS NOT NULL
    AND apt.end_date_time   > apt.start_date_time
),
icu_admissions AS (
    SELECT DISTINCT apt.pseudo_id, apt.admission_traject_id,
           at_.admission_date, at_.discharge_date
    FROM amc_core.admission_partial_traject apt
    INNER JOIN amc_core.admission_traject at_
            ON apt.admission_traject_id = at_.admission_traject_id
    WHERE (
          apt.workplace ILIKE '%INTENSIVE CARE%'
       OR apt.workplace ILIKE '%NICU%'
       OR apt.workplace ILIKE '%PICU%'
    )
    AND apt.start_date_time IS NOT NULL
    AND apt.end_date_time   > apt.start_date_time
)
SELECT
    COUNT(DISTINCT ip.pseudo_id)                                            AS total_icu_patients,
    -- death registration
    COUNT(DISTINCT dr.pseudo_id)                                            AS patients_with_death_record,
    ROUND(100.0 * COUNT(DISTINCT dr.pseudo_id) /
          NULLIF(COUNT(DISTINCT ip.pseudo_id), 0), 2)                       AS death_record_pct,
    -- is_deceased flag
    COUNT(DISTINCT ip.pseudo_id) FILTER (WHERE p.is_deceased = 'J')        AS patients_flagged_deceased,
    -- in-hospital death: death date falls within an admission window
    COUNT(DISTINCT ia.admission_traject_id) FILTER (WHERE
        dr.pseudo_id IS NOT NULL
        AND dr.meet_date BETWEEN ia.admission_date AND ia.discharge_date
    )                                                                       AS in_hospital_deaths,
    -- 30-day mortality
    COUNT(DISTINCT ia.admission_traject_id) FILTER (WHERE
        dr.pseudo_id IS NOT NULL
        AND dr.meet_date BETWEEN ia.admission_date
                             AND ia.admission_date + INTERVAL '30 days'
    )                                                                       AS deaths_within_30_days,
    -- department of death breakdown aggregated
    COUNT(DISTINCT dr.pseudo_id) FILTER (WHERE
        dr.department_of_death ILIKE '%INTENSIVE%'
        OR dr.department_of_death ILIKE '%ICU%'
    )                                                                       AS died_in_icu
FROM icu_patients ip
LEFT JOIN amc_core.patient_not_traceable   p  ON ip.pseudo_id = p.pseudo_id
LEFT JOIN amc_core.death_registration      dr ON ip.pseudo_id = dr.pseudo_id
LEFT JOIN icu_admissions                   ia ON ip.pseudo_id = ia.pseudo_id;


-- ----------------------------------------------------------------------------
-- 4.2  Department of death for ICU patients
-- ----------------------------------------------------------------------------
\! echo "  [4.2] ICU death by department — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[4.2] Department of death for ICU patients'
\o /tmp/amc_icu/04_icu_death_by_department.csv

WITH icu_patients AS (
    SELECT DISTINCT pseudo_id
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date_time IS NOT NULL
    AND end_date_time   > start_date_time
)
SELECT
    dr.department_of_death,
    COUNT(*)                                                                AS n_deaths,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)                     AS pct
FROM amc_core.death_registration dr
INNER JOIN icu_patients ip ON dr.pseudo_id = ip.pseudo_id
WHERE dr.department_of_death IS NOT NULL
GROUP BY dr.department_of_death
ORDER BY n_deaths DESC;


-- =============================================================================
-- SECTION 5 — TRACEABILITY: ICU PATIENTS IN EACH DOMAIN
-- =============================================================================

\! echo "  [5.1] ICU traceability per domain — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[5.1] ICU patient traceability across all clinical domains'
\o /tmp/amc_icu/05_icu_traceability.csv

WITH icu_patients AS (
    SELECT DISTINCT pseudo_id
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date_time IS NOT NULL
    AND end_date_time   > start_date_time
),
total AS (SELECT COUNT(*) AS n FROM icu_patients)
SELECT
    domain,
    n_patients,
    ROUND(100.0 * n_patients / (SELECT n FROM total), 2) AS pct_of_icu_patients
FROM (
    SELECT 'patient_not_traceable (master)'     AS domain, COUNT(DISTINCT ip.pseudo_id) AS n_patients FROM icu_patients ip INNER JOIN amc_core.patient_not_traceable p ON ip.pseudo_id = p.pseudo_id
    UNION ALL SELECT 'patient_contact',           COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.patient_contact          pc WHERE pc.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'lab_result',                COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.lab_result               lr WHERE lr.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'medical_diagnosis',         COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.medical_diagnosis         md WHERE md.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'problem_list',              COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.problem_list              pl WHERE pl.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'medication_prescription',   COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.medication_prescription   mp WHERE mp.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'medication_administration', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.medication_administration  ma WHERE ma.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'patient_note_patient_contact', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.patient_note_patient_contact nn WHERE nn.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'death_registration',        COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.death_registration        dr WHERE dr.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'measurement_blood_pressure', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.measurement_blood_pressure mbp WHERE mbp.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'measurement_heart_frequency', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.measurement_heart_frequency mhf WHERE mhf.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'measurement_o2_saturation', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.measurement_o2_saturation  mo2 WHERE mo2.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'measurement_vital_signs_data', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.measurement_vital_signs_data vs WHERE vs.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'measurement_bmi',           COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.measurement_bmi            bmi WHERE bmi.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'measurement_weight',        COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.measurement_weight         mw  WHERE mw.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'measurement_diurese',       COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.measurement_diurese        md  WHERE md.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'measurement_fluid_in',      COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.measurement_fluid_in       mfi WHERE mfi.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'measurement_fluid_balance_out', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.measurement_fluid_balance_out mfo WHERE mfo.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'measurement_nephrology_hemodialysis', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.measurement_nephrology_hemodialysis nh WHERE nh.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'measurement_nephrology_peritoneal_dialysis', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.measurement_nephrology_peritoneal_dialysis np WHERE np.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'measurement_nephrology_cnvt_settings (CVVT)', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.measurement_nephrology_cnvt_settings nc WHERE nc.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'measurement_doss_score',    COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.measurement_doss_score     ds WHERE ds.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'measurement_chadsvasc_score', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.measurement_chadsvasc_score cv WHERE cv.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'ecg_measurement',           COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.ecg_measurement            ecg WHERE ecg.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'echo_measurement_heart',    COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.echo_measurement_heart     ech WHERE ech.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'procedures',                COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.procedures                  pr  WHERE pr.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'ok_procedure_performed',    COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.ok_procedure_performed      ok  WHERE ok.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'imaging_study_order',       COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.imaging_study_order         iso WHERE iso.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'ic_procedure_note_bronchoscopy', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.ic_procedure_note_bronchoscopy icb WHERE icb.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'ic_procedure_note_intubation',   COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.ic_procedure_note_intubation   ici WHERE ici.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'ic_procedure_note_tracheostomy', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.ic_procedure_note_tracheostomy ict WHERE ict.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'ic_procedure_note_central_venous_catheter', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.ic_procedure_note_central_venous_catheter icc WHERE icc.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'ic_procedure_note_icarus (lung US)', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.ic_procedure_note_icarus icr WHERE icr.pseudo_id = ip.pseudo_id)
    UNION ALL SELECT 'tobacco_use',               COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.tobacco_use                 tu  WHERE tu.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'surgery_history',           COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.surgery_history             sh  WHERE sh.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'adverse_event',             COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.adverse_event               ae  WHERE ae.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'patient_social',            COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.patient_social              ps  WHERE ps.pseudo_id  = ip.pseudo_id)
    UNION ALL SELECT 'seh_trajectory (ED entry)', COUNT(DISTINCT ip.pseudo_id) FROM icu_patients ip WHERE EXISTS (SELECT 1 FROM amc_core.seh_trajectory              st  WHERE st.pseudo_id  = ip.pseudo_id)
) sub
ORDER BY n_patients DESC;


-- =============================================================================
-- SECTION 6 — LAB RESULTS DURING ICU STAY
-- Join: lab_result.pseudo_id = icu_patient AND result_date WITHIN icu stay window
-- Use result_date (reliable) not material_decrease_date (6.95% pre-2000)
-- =============================================================================

\! echo "  [6.1] ICU lab volume — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[6.1] Lab result volume and coverage during ICU stays'
\o /tmp/amc_icu/06_icu_lab_volume.csv

-- Joins on lab_result.probable_partial_traject_id (05_linkage_repair)
-- instead of a date-range predicate -- same fix as amc_views.v_icu_labs_long
-- (structured-refresh/06_views/350_v_icu_labs_long.sql), applied here since
-- this script duplicated the same date-range join independently.
WITH icu_stays AS (
    SELECT
        apt.pseudo_id,
        apt.admission_partial_traject_id
    FROM amc_core.admission_partial_traject apt
    WHERE (
          apt.workplace ILIKE '%INTENSIVE CARE%'
       OR apt.workplace ILIKE '%NICU%'
       OR apt.workplace ILIKE '%PICU%'
    )
)
SELECT
    COUNT(lr.*)                                        AS total_lab_results_during_icu,
    COUNT(DISTINCT lr.pseudo_id)                       AS patients_with_lab_during_icu,
    COUNT(DISTINCT lr.determination_code)              AS unique_test_types,
    ROUND(AVG(lr.result_numeric), 2)                   AS overall_mean_numeric_result,
    COUNT(*) FILTER (WHERE lr.result_numeric IS NULL)  AS text_only_results,
    ROUND(100.0 * COUNT(*) FILTER (WHERE lr.result_numeric IS NULL)
          / NULLIF(COUNT(*), 0), 1)                    AS pct_text_only
FROM amc_core.lab_result lr
INNER JOIN icu_stays ist
        ON lr.probable_partial_traject_id = ist.admission_partial_traject_id;


-- ----------------------------------------------------------------------------
-- 6.2  Top 30 lab tests ordered during ICU stays
-- ----------------------------------------------------------------------------
\! echo "  [6.2] Top ICU lab tests — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[6.2] Top 30 lab tests during ICU stays'
\o /tmp/amc_icu/06_icu_top_lab_tests.csv

WITH icu_stays AS (
    SELECT pseudo_id, admission_partial_traject_id
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
)
SELECT
    lr.determination_code,
    lr.determination,
    lr.material_type,
    COUNT(*)                                            AS n_results,
    COUNT(DISTINCT lr.pseudo_id)                        AS n_patients,
    ROUND(AVG(lr.result_numeric), 2)                    AS mean_value,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
          (ORDER BY lr.result_numeric)::numeric, 2)     AS median_value,
    MIN(lr.result_unit)                                 AS unit
FROM amc_core.lab_result lr
INNER JOIN icu_stays ist
        ON lr.probable_partial_traject_id = ist.admission_partial_traject_id
WHERE lr.determination_code IS NOT NULL
GROUP BY lr.determination_code, lr.determination, lr.material_type
ORDER BY n_results DESC
LIMIT 30;


-- =============================================================================
-- SECTION 7 — VITAL SIGNS DURING ICU
-- Join via pseudo_id + meet_date within ICU stay window
-- =============================================================================

\! echo "  [7.1] ICU vitals coverage — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[7.1] Vital signs coverage during ICU stays'
\o /tmp/amc_icu/07_icu_vitals_coverage.csv

WITH icu_stays AS (
    SELECT pseudo_id, start_date, end_date
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date IS NOT NULL AND end_date >= start_date
),
icu_pts AS (SELECT DISTINCT pseudo_id FROM icu_stays)
SELECT
    'blood_pressure'        AS measurement,
    COUNT(DISTINCT mbp.pseudo_id) AS pts_with_measurement,
    COUNT(*)                AS total_records,
    ROUND(AVG(mbp.systolic_blood_pressure_value), 1)  AS mean_systolic,
    ROUND(AVG(mbp.diastolic_blood_pressure_value), 1) AS mean_diastolic
FROM amc_core.measurement_blood_pressure mbp
INNER JOIN icu_stays ist ON mbp.pseudo_id = ist.pseudo_id
    AND mbp.meet_date BETWEEN ist.start_date AND ist.end_date

UNION ALL
SELECT
    'heart_frequency',
    COUNT(DISTINCT mhf.pseudo_id),
    COUNT(*),
    ROUND(AVG(mhf.heart_rate), 1), NULL
FROM amc_core.measurement_heart_frequency mhf
INNER JOIN icu_stays ist ON mhf.pseudo_id = ist.pseudo_id
    AND mhf.meet_date BETWEEN ist.start_date AND ist.end_date

UNION ALL
SELECT
    'o2_saturation',
    COUNT(DISTINCT mo2.pseudo_id),
    COUNT(*),
    ROUND(AVG(mo2.o2saturation), 1), NULL
FROM amc_core.measurement_o2_saturation mo2
INNER JOIN icu_stays ist ON mo2.pseudo_id = ist.pseudo_id
    AND mo2.meet_date BETWEEN ist.start_date AND ist.end_date

UNION ALL
SELECT
    'diurese',
    COUNT(DISTINCT md.pseudo_id),
    COUNT(*),
    ROUND(AVG(md.diuresis_output), 1), NULL
FROM amc_core.measurement_diurese md
INNER JOIN icu_stays ist ON md.pseudo_id = ist.pseudo_id
    AND md.meet_date BETWEEN ist.start_date AND ist.end_date

UNION ALL
SELECT
    'bmi',
    COUNT(DISTINCT mb.pseudo_id),
    COUNT(*),
    ROUND(AVG(mb.bmi), 1), NULL
FROM amc_core.measurement_bmi mb
INNER JOIN icu_stays ist ON mb.pseudo_id = ist.pseudo_id
    AND mb.meet_date BETWEEN ist.start_date AND ist.end_date;


-- =============================================================================
-- SECTION 8 — MEDICATIONS DURING ICU
-- Join via pseudo_id + administration_date within ICU stay window
-- administration_date more reliable than prescription dates for timing
-- =============================================================================

\! echo "  [8.1] ICU medications ATC level 1 — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[8.1] Drug class distribution during ICU (ATC level 1)'
\o /tmp/amc_icu/08_icu_medications_atc1.csv

WITH icu_stays AS (
    SELECT pseudo_id, start_date, end_date
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date IS NOT NULL AND end_date >= start_date
)
SELECT
    atc.atc_code_niv1,
    atc.atc_name_niv1,
    COUNT(ma.*)                             AS n_administrations,
    COUNT(DISTINCT ma.pseudo_id)            AS n_patients,
    ROUND(100.0 * COUNT(DISTINCT ma.pseudo_id) /
          (SELECT COUNT(DISTINCT pseudo_id) FROM icu_stays), 1) AS pct_of_icu_pts
FROM amc_core.medication_administration ma
INNER JOIN icu_stays ist
        ON ma.pseudo_id = ist.pseudo_id
       AND ma.administration_date BETWEEN ist.start_date AND ist.end_date
LEFT JOIN amc_core.medication_atc atc ON ma.atc_code = atc.atc_code
WHERE atc.atc_code_niv1 IS NOT NULL
GROUP BY atc.atc_code_niv1, atc.atc_name_niv1
ORDER BY n_administrations DESC;


-- ----------------------------------------------------------------------------
-- 8.2  Top 30 specific drugs administered in ICU (ATC level 5 substance)
-- ----------------------------------------------------------------------------
\! echo "  [8.2] ICU top medications substance — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[8.2] Top 30 specific drug substances administered in ICU'
\o /tmp/amc_icu/08_icu_top_drugs.csv

WITH icu_stays AS (
    SELECT pseudo_id, start_date, end_date
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date IS NOT NULL AND end_date >= start_date
)
SELECT
    ma.atc_code,
    atc.atc_name                            AS substance_name,
    atc.atc_name_niv3                       AS pharmacological_class,
    ma.administration_route,
    COUNT(*)                                AS n_administrations,
    COUNT(DISTINCT ma.pseudo_id)            AS n_patients,
    ROUND(AVG(ma.administered_amount), 2)   AS mean_dose,
    MIN(ma.administered_quantity_unit)      AS unit
FROM amc_core.medication_administration ma
INNER JOIN icu_stays ist
        ON ma.pseudo_id = ist.pseudo_id
       AND ma.administration_date BETWEEN ist.start_date AND ist.end_date
LEFT JOIN amc_core.medication_atc atc ON ma.atc_code = atc.atc_code
WHERE ma.atc_code IS NOT NULL
GROUP BY ma.atc_code, atc.atc_name, atc.atc_name_niv3, ma.administration_route
ORDER BY n_administrations DESC
LIMIT 30;


-- =============================================================================
-- SECTION 9 — ICU PROCEDURES
-- =============================================================================

\! echo "  [9.1] IC procedure notes volume — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[9.1] IC procedure note counts for ICU patients'
\o /tmp/amc_icu/09_icu_procedure_notes.csv

WITH icu_patients AS (
    SELECT DISTINCT pseudo_id
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date_time IS NOT NULL AND end_date_time > start_date_time
)
SELECT 'bronchoscopy'            AS procedure_type,
    COUNT(*)                     AS n_procedures,
    COUNT(DISTINCT icb.pseudo_id) AS n_patients
FROM amc_core.ic_procedure_note_bronchoscopy icb
INNER JOIN icu_patients ip ON icb.pseudo_id = ip.pseudo_id

UNION ALL SELECT 'intubation',
    COUNT(*), COUNT(DISTINCT ici.pseudo_id)
FROM amc_core.ic_procedure_note_intubation ici
INNER JOIN icu_patients ip ON ici.pseudo_id = ip.pseudo_id

UNION ALL SELECT 'tracheostomy',
    COUNT(*), COUNT(DISTINCT ict.pseudo_id)
FROM amc_core.ic_procedure_note_tracheostomy ict
INNER JOIN icu_patients ip ON ict.pseudo_id = ip.pseudo_id

UNION ALL SELECT 'thorax_drain',
    COUNT(*), COUNT(DISTINCT itd.pseudo_id)
FROM amc_core.ic_procedure_note_thorax_drain itd
INNER JOIN icu_patients ip ON itd.pseudo_id = ip.pseudo_id

UNION ALL SELECT 'central_venous_catheter',
    COUNT(*), COUNT(DISTINCT icc.pseudo_id)
FROM amc_core.ic_procedure_note_central_venous_catheter icc
INNER JOIN icu_patients ip ON icc.pseudo_id = ip.pseudo_id

UNION ALL SELECT 'electric_cardioversion',
    COUNT(*), COUNT(DISTINCT iec.pseudo_id)
FROM amc_core.ic_procedure_note_electric_cardioversion iec
INNER JOIN icu_patients ip ON iec.pseudo_id = ip.pseudo_id

UNION ALL SELECT 'icarus (lung_us)',
    COUNT(*), COUNT(DISTINCT icr.pseudo_id)
FROM amc_core.ic_procedure_note_icarus icr
INNER JOIN icu_patients ip ON icr.pseudo_id = ip.pseudo_id

ORDER BY n_procedures DESC;


-- =============================================================================
-- SECTION 10 — NEPHROLOGY / RENAL REPLACEMENT THERAPY
-- =============================================================================

\! echo "  [10.1] ICU dialysis — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[10.1] Renal replacement therapy in ICU patients'
\o /tmp/amc_icu/10_icu_dialysis.csv

WITH icu_patients AS (
    SELECT DISTINCT pseudo_id
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date_time IS NOT NULL AND end_date_time > start_date_time
)
SELECT
    total_icu_pts.n                                         AS total_icu_patients,
    hd.n                                                    AS pts_hemodialysis,
    pd.n                                                    AS pts_peritoneal_dialysis,
    cvvt.n                                                  AS pts_cvvt_crrt,
    cm.n                                                    AS pts_citrate_anticoag,
    ROUND(100.0 * hd.n   / NULLIF(total_icu_pts.n, 0), 2) AS pct_hemodialysis,
    ROUND(100.0 * pd.n   / NULLIF(total_icu_pts.n, 0), 2) AS pct_peritoneal,
    ROUND(100.0 * cvvt.n / NULLIF(total_icu_pts.n, 0), 2) AS pct_cvvt
FROM
    (SELECT COUNT(DISTINCT pseudo_id) AS n FROM icu_patients) total_icu_pts,
    (SELECT COUNT(DISTINCT nh.pseudo_id) AS n FROM amc_core.measurement_nephrology_hemodialysis nh INNER JOIN icu_patients ip ON nh.pseudo_id = ip.pseudo_id) hd,
    (SELECT COUNT(DISTINCT np.pseudo_id) AS n FROM amc_core.measurement_nephrology_peritoneal_dialysis np INNER JOIN icu_patients ip ON np.pseudo_id = ip.pseudo_id) pd,
    (SELECT COUNT(DISTINCT nc.pseudo_id) AS n FROM amc_core.measurement_nephrology_cnvt_settings nc INNER JOIN icu_patients ip ON nc.pseudo_id = ip.pseudo_id) cvvt,
    (SELECT COUNT(DISTINCT nm.pseudo_id) AS n FROM amc_core.measurement_nephrology_cntv_medication nm INNER JOIN icu_patients ip ON nm.pseudo_id = ip.pseudo_id) cm;


-- =============================================================================
-- SECTION 11 — DIAGNOSES OF ICU PATIENTS
-- =============================================================================

\! echo "  [11.1] ICU top diagnoses — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[11.1] Top 30 diagnoses for ICU patients'
\o /tmp/amc_icu/11_icu_top_diagnoses.csv

-- NOTE: join via pseudo_id only (medical_diagnosis has 36% orphan contact_id rate)
WITH icu_patients AS (
    SELECT DISTINCT pseudo_id
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date_time IS NOT NULL AND end_date_time > start_date_time
)
SELECT
    md.diagnosis_code,
    md.diagnosis_description,
    md.diagnosis_category,
    md.diagnosis_type,
    COUNT(*)                            AS n_diagnosis_records,
    COUNT(DISTINCT md.pseudo_id)        AS n_patients
FROM amc_core.medical_diagnosis md
INNER JOIN icu_patients ip ON md.pseudo_id = ip.pseudo_id
WHERE md.diagnosis_code IS NOT NULL AND md.diagnosis_code <> ''
GROUP BY md.diagnosis_code, md.diagnosis_description, md.diagnosis_category, md.diagnosis_type
ORDER BY n_patients DESC
LIMIT 30;


-- ----------------------------------------------------------------------------
-- 11.2  Diagnosis category mix for ICU patients
-- ----------------------------------------------------------------------------
\! echo "  [11.2] ICU diagnosis categories — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[11.2] Diagnosis category distribution for ICU patients'
\o /tmp/amc_icu/11_icu_diagnosis_categories.csv

WITH icu_patients AS (
    SELECT DISTINCT pseudo_id
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date_time IS NOT NULL AND end_date_time > start_date_time
)
SELECT
    md.diagnosis_category,
    COUNT(*)                        AS n_records,
    COUNT(DISTINCT md.pseudo_id)    AS n_patients,
    ROUND(100.0 * COUNT(DISTINCT md.pseudo_id) /
          (SELECT COUNT(*) FROM icu_patients), 1) AS pct_of_icu_pts
FROM amc_core.medical_diagnosis md
INNER JOIN icu_patients ip ON md.pseudo_id = ip.pseudo_id
WHERE md.diagnosis_category IS NOT NULL
GROUP BY md.diagnosis_category
ORDER BY n_patients DESC;


-- =============================================================================
-- SECTION 12 — IMAGING AND ECG DURING ICU
-- =============================================================================

\! echo "  [12.1] ICU imaging and ECG — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[12.1] Imaging study orders and ECG measurements for ICU patients'
\o /tmp/amc_icu/12_icu_imaging_ecg.csv

WITH icu_patients AS (
    SELECT DISTINCT pseudo_id
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date_time IS NOT NULL AND end_date_time > start_date_time
),
icu_stays AS (
    SELECT pseudo_id, start_date, end_date
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date IS NOT NULL AND end_date >= start_date
)
SELECT
    'imaging_study_orders'           AS domain,
    COUNT(*)                         AS total_records,
    COUNT(DISTINCT iso.pseudo_id)    AS patients_with_data,
    COUNT(*) FILTER (WHERE iso.imaging_study_status ILIKE '%complet%'
                       OR  iso.imaging_study_status ILIKE '%final%') AS completed_studies,
    NULL::numeric                    AS mean_numeric
FROM amc_core.imaging_study_order iso
INNER JOIN icu_patients ip ON iso.pseudo_id = ip.pseudo_id

UNION ALL
SELECT
    'ecg_measurements',
    COUNT(*),
    COUNT(DISTINCT ecg.pseudo_id),
    NULL,
    ROUND(AVG(ecg.ventricular_rate_at_rest), 1)
FROM amc_core.ecg_measurement ecg
INNER JOIN icu_patients ip ON ecg.pseudo_id = ip.pseudo_id

UNION ALL
SELECT
    'echo_measurements_heart',
    COUNT(*),
    COUNT(DISTINCT ech.pseudo_id),
    NULL,
    ROUND(AVG(ech.lvef_mod), 1)   -- mean LV ejection fraction (biplane)
FROM amc_core.echo_measurement_heart ech
INNER JOIN icu_patients ip ON ech.pseudo_id = ip.pseudo_id;


-- =============================================================================
-- SECTION 13 — NOTES DURING ICU
-- Join: patient_note_patient_contact.pseudo_id + note_made_on_date within ICU window
-- =============================================================================

\! echo "  [13.1] ICU notes — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[13.1] Clinical notes volume and category during ICU stays'
\o /tmp/amc_icu/13_icu_notes.csv

WITH icu_stays AS (
    SELECT pseudo_id, start_date, end_date
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date IS NOT NULL AND end_date >= start_date
    AND start_date >= '2000-01-01'   -- filter out pre-2000 dates (45% abnormal in audit)
)
SELECT
    nn.patient_note_category,
    COUNT(*)                            AS n_notes,
    COUNT(DISTINCT nn.pseudo_id)        AS n_patients,
    COUNT(*) FILTER (WHERE nn.is_confidential = 'J') AS confidential_notes
FROM amc_core.patient_note_patient_contact nn
INNER JOIN icu_stays ist
        ON nn.pseudo_id = ist.pseudo_id
       AND nn.note_made_on_date BETWEEN ist.start_date AND ist.end_date
WHERE nn.note_made_on_date >= '2000-01-01'  -- same filter
  AND nn.note_status NOT IN ('Geannuleerd','Verwijderd')  -- exclude cancelled/deleted
GROUP BY nn.patient_note_category
ORDER BY n_notes DESC;


-- =============================================================================
-- SECTION 14 — DELIRIUM AND NUTRITION SCORES IN ICU
-- =============================================================================

\! echo "  [14.1] ICU DOSS delirium score — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[14.1] DOSS delirium score distribution during ICU'
\o /tmp/amc_icu/14_icu_doss_delirium.csv

WITH icu_stays AS (
    SELECT pseudo_id, start_date, end_date
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date IS NOT NULL AND end_date >= start_date
)
SELECT
    COUNT(*)                                                        AS total_doss_measurements,
    COUNT(DISTINCT ds.pseudo_id)                                    AS patients_with_doss,
    ROUND(AVG(ds.dos_total), 2)                                     AS mean_dos_total,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ds.dos_total)::numeric, 1) AS median_dos,
    -- DOS ≥ 3 = delirium threshold
    COUNT(*) FILTER (WHERE ds.dos_total >= 3)                       AS measurements_with_delirium,
    COUNT(DISTINCT ds.pseudo_id) FILTER (WHERE ds.dos_total >= 3)   AS patients_with_any_delirium,
    ROUND(100.0 * COUNT(DISTINCT ds.pseudo_id) FILTER (WHERE ds.dos_total >= 3) /
          NULLIF(COUNT(DISTINCT ds.pseudo_id), 0), 1)               AS pct_patients_with_delirium
FROM amc_core.measurement_doss_score ds
INNER JOIN icu_stays ist
        ON ds.pseudo_id = ist.pseudo_id
       AND ds.meet_date BETWEEN ist.start_date AND ist.end_date;


-- ----------------------------------------------------------------------------
-- 14.2  SNAQ nutritional screening in ICU
-- ----------------------------------------------------------------------------
\! echo "  [14.2] ICU SNAQ nutrition score — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[14.2] SNAQ nutritional risk score during ICU'
\o /tmp/amc_icu/14_icu_snaq_nutrition.csv

WITH icu_stays AS (
    SELECT pseudo_id, start_date, end_date
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date IS NOT NULL AND end_date >= start_date
)
SELECT
    COUNT(*)                                                AS total_snaq_measurements,
    COUNT(DISTINCT ms.pseudo_id)                            AS patients_with_snaq,
    ROUND(AVG(ms.score), 2)                                 AS mean_snaq_score,
    -- SNAQ ≥ 2 = nutritional risk
    COUNT(DISTINCT ms.pseudo_id) FILTER (WHERE ms.score >= 2) AS patients_at_nutritional_risk,
    ROUND(100.0 * COUNT(DISTINCT ms.pseudo_id) FILTER (WHERE ms.score >= 2) /
          NULLIF(COUNT(DISTINCT ms.pseudo_id), 0), 1)      AS pct_at_risk
FROM amc_core.measurement_snaq_score ms
INNER JOIN icu_stays ist
        ON ms.pseudo_id = ist.pseudo_id
       AND ms.meet_date BETWEEN ist.start_date AND ist.end_date;


-- =============================================================================
-- SECTION 15 — ICU ADMISSION ROUTE (SEH / ELECTIVE / TRANSFER)
-- =============================================================================

\! echo "  [15.1] ICU admission route — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[15.1] ICU admission route and origin'
\o /tmp/amc_icu/15_icu_admission_route.csv

-- One row per ICU admission (not per ward stay)
WITH icu_admissions AS (
    SELECT DISTINCT
        at_.admission_traject_id,
        at_.pseudo_id,
        at_.admission_origin,
        at_.admission_mode,
        at_.admission_via_seh,
        at_.is_admission_elective,
        at_.discharge_method,
        at_.discharge_location,
        at_.admission_specialty
    FROM amc_core.admission_traject at_
    INNER JOIN amc_core.admission_partial_traject apt
            ON at_.admission_traject_id = apt.admission_traject_id
    WHERE (
          apt.workplace ILIKE '%INTENSIVE CARE%'
       OR apt.workplace ILIKE '%NICU%'
       OR apt.workplace ILIKE '%PICU%'
    )
    AND apt.start_date_time IS NOT NULL
    AND apt.end_date_time   > apt.start_date_time
)
SELECT
    admission_origin,
    admission_via_seh,
    is_admission_elective,
    COUNT(*)                        AS n_admissions,
    COUNT(DISTINCT pseudo_id)       AS n_patients,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_icu_admissions
FROM icu_admissions
GROUP BY admission_origin, admission_via_seh, is_admission_elective
ORDER BY n_admissions DESC
LIMIT 25;


-- ----------------------------------------------------------------------------
-- 15.2  SEH → ICU pathway
-- Patients who came through ED before ICU admission
-- ----------------------------------------------------------------------------
\! echo "  [15.2] SEH to ICU pathway — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[15.2] ED (SEH) triage characteristics for patients admitted to ICU'
\o /tmp/amc_icu/15_icu_seh_pathway.csv

WITH icu_admissions AS (
    SELECT DISTINCT at_.admission_traject_id, at_.pseudo_id
    FROM amc_core.admission_traject at_
    INNER JOIN amc_core.admission_partial_traject apt
            ON at_.admission_traject_id = apt.admission_traject_id
    WHERE (
          apt.workplace ILIKE '%INTENSIVE CARE%'
       OR apt.workplace ILIKE '%NICU%'
       OR apt.workplace ILIKE '%PICU%'
    )
    AND apt.start_date_time IS NOT NULL AND apt.end_date_time > apt.start_date_time
)
SELECT
    st.seh_triagecode,
    st.seh_arrival_mode_group,
    COUNT(*)                        AS n_icu_patients_via_seh,
    COUNT(DISTINCT st.pseudo_id)    AS unique_patients,
    ROUND(AVG(st.age_in_years_at_moment_admission), 1) AS mean_age_at_seh
FROM amc_core.seh_trajectory st
INNER JOIN icu_admissions ia
        ON st.admission_traject_id = ia.admission_traject_id
GROUP BY st.seh_triagecode, st.seh_arrival_mode_group
ORDER BY n_icu_patients_via_seh DESC;


-- =============================================================================
-- SECTION 16 — COMORBIDITY PROFILE (PROBLEM LIST + HISTORY)
-- =============================================================================

\! echo "  [16.1] ICU comorbidities — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[16.1] Top chronic problems in ICU patients (problem_list, is_chronic=J)'
\o /tmp/amc_icu/16_icu_chronic_comorbidities.csv

WITH icu_patients AS (
    SELECT DISTINCT pseudo_id
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date_time IS NOT NULL AND end_date_time > start_date_time
)
SELECT
    pl.diagnosis_code,
    pl.problem_description,
    pl.snomed_code,
    pl.diagnosis_category,
    COUNT(DISTINCT pl.pseudo_id)        AS n_patients,
    ROUND(100.0 * COUNT(DISTINCT pl.pseudo_id) /
          (SELECT COUNT(*) FROM icu_patients), 1) AS pct_of_icu_pts
FROM amc_core.problem_list pl
INNER JOIN icu_patients ip ON pl.pseudo_id = ip.pseudo_id
WHERE pl.is_chronic = 'J'
  AND pl.patient_problem_status NOT IN ('Inactief','Verwijderd')
  AND (pl.close_date IS NULL OR pl.close_date > CURRENT_DATE)
  AND pl.diagnosis_code IS NOT NULL
GROUP BY pl.diagnosis_code, pl.problem_description, pl.snomed_code, pl.diagnosis_category
ORDER BY n_patients DESC
LIMIT 30;


-- ----------------------------------------------------------------------------
-- 16.2  Tobacco use in ICU patients
-- NOTE: tobacco_use.start_date is 99% pre-2000 — treat as categorical only
-- ----------------------------------------------------------------------------
\! echo "  [16.2] ICU tobacco use — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[16.2] Tobacco use status for ICU patients (categorical, not date-based)'
\o /tmp/amc_icu/16_icu_tobacco.csv

WITH icu_patients AS (
    SELECT DISTINCT pseudo_id
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date_time IS NOT NULL AND end_date_time > start_date_time
)
SELECT
    COUNT(DISTINCT ip.pseudo_id)                                    AS total_icu_patients,
    COUNT(DISTINCT tu.pseudo_id) FILTER (WHERE tu.is_current_smoker = 'J') AS current_smokers,
    COUNT(DISTINCT tu.pseudo_id) FILTER (WHERE tu.is_former_smoker  = 'J') AS former_smokers,
    COUNT(DISTINCT tu.pseudo_id) FILTER (WHERE tu.is_current_smoker = 'N'
                                            AND tu.is_former_smoker  = 'N') AS never_smokers,
    COUNT(DISTINCT tu.pseudo_id) FILTER (WHERE tu.pseudo_id IS NULL) AS no_tobacco_record,
    ROUND(100.0 * COUNT(DISTINCT tu.pseudo_id) FILTER (WHERE tu.is_current_smoker = 'J')
          / NULLIF(COUNT(DISTINCT ip.pseudo_id), 0), 1)            AS pct_current_smoker
FROM icu_patients ip
LEFT JOIN amc_core.tobacco_use tu ON ip.pseudo_id = tu.pseudo_id;


-- =============================================================================
-- SECTION 17 — FLUID BALANCE SUMMARY IN ICU
-- =============================================================================

\! echo "  [17.1] ICU fluid balance — $(date +%H:%M:%S)" >> /tmp/amc_icu/run.log
\echo '[17.1] Fluid balance measurement coverage during ICU'
\o /tmp/amc_icu/17_icu_fluid_balance.csv

WITH icu_stays AS (
    SELECT pseudo_id, start_date, end_date
    FROM amc_core.admission_partial_traject
    WHERE (
          workplace ILIKE '%INTENSIVE CARE%'
       OR workplace ILIKE '%NICU%'
       OR workplace ILIKE '%PICU%'
    )
    AND start_date IS NOT NULL AND end_date >= start_date
)
SELECT
    'fluid_in'                           AS measure,
    COUNT(*)                             AS n_records,
    COUNT(DISTINCT mfi.pseudo_id)        AS n_patients,
    NULL::numeric                        AS mean_value
FROM amc_core.measurement_fluid_in mfi
INNER JOIN icu_stays ist ON mfi.pseudo_id = ist.pseudo_id
    AND mfi.meet_date BETWEEN ist.start_date AND ist.end_date

UNION ALL
SELECT 'fluid_out',
    COUNT(*), COUNT(DISTINCT mfo.pseudo_id), NULL
FROM amc_core.measurement_fluid_balance_out mfo
INNER JOIN icu_stays ist ON mfo.pseudo_id = ist.pseudo_id
    AND mfo.meet_date BETWEEN ist.start_date AND ist.end_date

UNION ALL
SELECT 'stomach_retention',
    COUNT(*), COUNT(DISTINCT msr.pseudo_id),
    ROUND(AVG(msr.stomach_retention), 1)
FROM amc_core.measurement_fluid_balance_stomach_retention msr
INNER JOIN icu_stays ist ON msr.pseudo_id = ist.pseudo_id
    AND msr.meet_date BETWEEN ist.start_date AND ist.end_date

UNION ALL
SELECT 'diuresis_assessment',
    COUNT(*), COUNT(DISTINCT mfa.pseudo_id), NULL
FROM amc_core.measurement_fluid_assessment_diuresis mfa
INNER JOIN icu_stays ist ON mfa.pseudo_id = ist.pseudo_id
    AND mfa.meet_date BETWEEN ist.start_date AND ist.end_date;


-- =============================================================================
-- CLOSE LOG
-- =============================================================================
\o
\o /tmp/amc_icu/run.log
\! echo ""
\! echo "Finished: $(date)"
\! echo "Output files in /tmp/amc_icu/"
\! ls -lh /tmp/amc_icu/*.csv 2>/dev/null | awk '{print $5, $9}'
\o
\echo ''
\echo 'Done. Start with 00_icu_workplace_values.csv to validate the ICU filter.'
\timing off