-- =====================================================================
-- cohort_functions.cohort_active_in_range
--
-- Cohort membership: pseudo_ids with an event in any of the given
-- amc_views.v_clinical_timeline domains, active during [date_from,
-- date_to] (inclusive both ends). Returns pseudo_id only -- combine
-- with other cohort_functions.* calls via plain SQL
-- INTERSECT/EXCEPT/UNION.
--
-- domains: event_domain values to include, e.g. ARRAY['stay'] or
--   ARRAY['stay', 'medication', 'lab']. Valid values: stay,
--   appointment, encounter, diagnosis, history, procedure, imaging,
--   medication, measurement, lab, score, fluid_balance, nephrology,
--   note (see v_clinical_timeline's own event_domain literals for the
--   authoritative list -- new domains added there later aren't
--   reflected here automatically).
-- date_from/date_to: both required (no default) -- an unbounded call
--   is just querying v_clinical_timeline directly with no date filter,
--   so there's no useful "unbounded" default to offer here.
--
-- Uses an OVERLAP test, not event_datetime BETWEEN date_from AND
-- date_to: an interval-shaped event (e.g. a 'stay' with a real
-- event_end_datetime) that started before date_from but is still
-- ongoing into the window must still count -- BETWEEN on the start
-- alone would miss it. Point-in-time events (event_end_datetime IS
-- NULL) fall back to comparing event_datetime against itself via
-- COALESCE, so the same test works for both shapes.
--
-- CAVEAT: event_end_datetime IS NULL does not always mean "point in
-- time". For the 'medication' domain it also means "ongoing" --
-- v_medications.stop_datetime comes from corrected_stop_date_time,
-- which is deliberately NULLed for ongoing prescriptions (~0.45%).
-- Such an event is treated here as a point event at its start, so an
-- ongoing medication that began before date_from and ran through the
-- whole window will NOT be returned. The 'stay' domain is unaffected
-- (v_stays excludes ongoing stays outright).
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS cohort_functions;

CREATE OR REPLACE FUNCTION cohort_functions.cohort_active_in_range(
    domains    text[],
    date_from  date,
    date_to    date
) RETURNS TABLE(pseudo_id text)
LANGUAGE sql
STABLE
AS $$
    SELECT DISTINCT t.pseudo_id
    FROM amc_views.v_clinical_timeline t
    WHERE t.event_domain = ANY(domains)
      AND t.event_datetime < (date_to + 1)
      AND COALESCE(t.event_end_datetime, t.event_datetime) >= date_from
$$;

-- Manual verification (run by hand against the live database):
--
-- 1. A same-day event on date_to is included (the boundary fix):
--   -- pick a real date with known activity, e.g. today's data pull's
--   -- most recent loaded date, then:
--   SELECT count(*) FROM cohort_functions.cohort_active_in_range(
--     ARRAY['lab'], '2024-01-01', '2024-01-01');
--   -- compare against:
--   SELECT count(DISTINCT pseudo_id) FROM amc_views.v_clinical_timeline
--     WHERE event_domain = 'lab'
--       AND event_datetime >= '2024-01-01'::timestamptz
--       AND event_datetime <  '2024-01-02'::timestamptz;
--   -- both counts must match
--
-- 2. An ongoing stay that started before the window still counts:
--   SELECT pseudo_id, start_datetime, end_datetime FROM amc_views.v_stays
--     WHERE start_datetime < '2024-01-01' AND end_datetime > '2024-01-31' LIMIT 5;
--   -- then check each pseudo_id appears in:
--   SELECT * FROM cohort_functions.cohort_active_in_range(
--     ARRAY['stay'], '2024-01-01', '2024-01-31');
