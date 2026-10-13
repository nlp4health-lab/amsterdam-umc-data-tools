-- =====================================================================
-- Data quality check: verifies v_stays/v_icu_stays' stay_los_hours,
-- hospital_los_hours, and died_during_stay columns -- added to surface
-- hospital length-of-stay and in-stay mortality consistently across
-- the general and ICU stays/timeline views. Independent of the other
-- scripts in this folder.
--
-- died_during_stay is computed inside the views themselves (death_date_time
-- -- the sole source of truth for death timing in this repo's views,
-- never death_registration/discharge_location -- falling within each
-- row's own start/end window). Section 1-2 below re-derive the same
-- check directly against amc_core.patient_not_traceable, independent
-- of the view's own logic, so a bug in the view's CASE expression
-- would actually show up as a mismatch here rather than passing
-- trivially. Expect 0 mismatches in both.
--
-- Usage: run in psql / any Postgres client against carenlp_db.
-- =====================================================================

-- 1. v_stays.died_during_stay -- re-derived independently
SELECT
    COUNT(*) AS mismatches
FROM amc_views.v_stays s
JOIN amc_core.patient_not_traceable p
    ON p.pseudo_id = s.pseudo_id
WHERE s.died_during_stay <> (
    p.death_date_time IS NOT NULL
    AND p.death_date_time >= s.start_datetime
    AND p.death_date_time <= s.end_datetime
);

-- 2. v_icu_stays.died_during_stay -- re-derived independently
SELECT
    COUNT(*) AS mismatches
FROM amc_views.v_icu_stays s
JOIN amc_core.patient_not_traceable p
    ON p.pseudo_id = s.pseudo_id
WHERE s.died_during_stay <> (
    p.death_date_time IS NOT NULL
    AND p.death_date_time >= s.icu_start_datetime
    AND p.death_date_time <= s.icu_end_datetime
);

-- 3. died_during_stay rate, by stay_type -- context for how common
-- in-stay mortality is per segment type (expect admission_traject's
-- rate to be the highest -- it's the one that spans the whole
-- hospitalization, where a death is most likely to land)
SELECT
    stay_type,
    COUNT(*) AS total_stays,
    COUNT(*) FILTER (WHERE died_during_stay) AS died_during_stay_count,
    ROUND(100.0 * COUNT(*) FILTER (WHERE died_during_stay) / NULLIF(COUNT(*), 0), 2) AS pct_died_during_stay
FROM amc_views.v_stays
GROUP BY stay_type
ORDER BY pct_died_during_stay DESC NULLS LAST;

-- 4. LOS sanity: a segment's own duration should never exceed the
-- whole hospital admission's duration it belongs to (stay_los_hours
-- <= hospital_los_hours always; equal on the admission_traject branch
-- itself, since that row IS the full admission). Expect 0 violations.
SELECT
    COUNT(*) AS violations
FROM amc_views.v_stays
WHERE stay_los_hours IS NOT NULL
  AND hospital_los_hours IS NOT NULL
  AND stay_los_hours > hospital_los_hours + 0.01; -- small tolerance for float rounding
