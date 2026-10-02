-- =====================================================================
-- cohort_functions.timeline_for_cohort
--
-- Detail for an already-built cohort: given a list of pseudo_ids
-- (from any cohort_functions.* selection function, or any other
-- source), returns the matching amc_views.v_clinical_timeline rows --
-- full detail, not just pseudo_id. This is the "cohort detail"
-- function the original cohort-functions design deferred; unlike
-- every other function in this folder, it takes a pseudo_id[] as
-- INPUT rather than producing one as output.
--
-- pseudo_ids: required. Filters WHERE pseudo_id = ANY(pseudo_ids).
-- domains: optional, NULL (the default) means all domains -- unlike
--   cohort_active_in_range, where domains has no default because an
--   unbounded call there is just querying the view directly; here,
--   "give me everything for this cohort" is itself a common request,
--   so NULL earns its keep as a real default. When given, filters
--   event_domain = ANY(domains).
-- date_from/date_to: optional, NULL on either side leaves that bound
--   off. When given, uses the same overlap test as
--   cohort_active_in_range (020_cohort_active_in_range.sql) and for
--   the same reason: an interval-shaped event that only partially
--   overlaps the window must still count.
--
-- Caveat: calling this with domains left NULL (all domains) against a
-- large cohort -- especially one built without a date bound of its
-- own -- can scan a large share of lab_result via the timeline's lab
-- domain, the same kind of lab_result-scale exposure
-- cohort_by_lab_test (040_cohort_by_lab_test.sql) was specifically
-- designed to avoid. Prefer naming specific domains and passing
-- date_from/date_to when the cohort could be large.
--
-- Return type: this function declares RETURNS TABLE(...) with an
-- explicit column list below, rather than RETURNS SETOF
-- amc_views.v_clinical_timeline. RETURNS SETOF <view> would make
-- Postgres record a blocking dependency from this function to the
-- view's composite row type; once that dependency exists, the
-- unqualified `DROP VIEW IF EXISTS amc_views.v_clinical_timeline;` in
-- structured-refresh/06_views/280_v_clinical_timeline.sql (no CASCADE)
-- would fail with "cannot drop view ... other objects depend on it",
-- aborting structured-refresh/refresh.sh's 06_views stage partway
-- through and leaving every view
-- numbered after 280 unrebuilt. RETURNS TABLE with an explicit column
-- list still reads FROM the view (a normal, non-blocking dependency)
-- but does not share its row type, so no such dependency is created.
--
-- Example, combining with an existing selection function and
-- exporting the result:
--   \copy (
--     SELECT * FROM cohort_functions.timeline_for_cohort(
--       ARRAY(SELECT pseudo_id FROM cohort_functions.cohort_by_diagnosis_code('I50%', true)),
--       ARRAY['stay', 'lab'],
--       '2023-01-01', '2024-01-01'
--     )
--   ) TO 'cohort_timeline.csv' WITH (FORMAT csv, HEADER true)
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS cohort_functions;

CREATE OR REPLACE FUNCTION cohort_functions.timeline_for_cohort(
    pseudo_ids  text[],
    domains     text[] DEFAULT NULL,
    date_from   date    DEFAULT NULL,
    date_to     date    DEFAULT NULL
) RETURNS TABLE(
    -- Column list below must be kept in sync with
    -- structured-refresh/06_views/280_v_clinical_timeline.sql's own
    -- column list if that view ever changes.
    pseudo_id            text,
    patient_contact_id   text,
    event_datetime       timestamptz,
    event_end_datetime   timestamptz,
    event_domain         text,
    event_type           text,
    event_subtype        text,
    event_id             text,
    event_label          text,
    value_numeric        numeric,
    value_text           text,
    unit                 text,
    hospital_location    text,
    workplace            text,
    specialty            text,
    subspecialty         text,
    source_view          text,
    source_record_id     text
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        t.pseudo_id, t.patient_contact_id, t.event_datetime, t.event_end_datetime,
        t.event_domain, t.event_type, t.event_subtype, t.event_id, t.event_label,
        t.value_numeric, t.value_text, t.unit, t.hospital_location, t.workplace,
        t.specialty, t.subspecialty, t.source_view, t.source_record_id
    FROM amc_views.v_clinical_timeline t
    WHERE t.pseudo_id = ANY(pseudo_ids)
      AND (domains IS NULL OR t.event_domain = ANY(domains))
      AND (date_to IS NULL OR t.event_datetime < (date_to + 1))
      AND (date_from IS NULL OR COALESCE(t.event_end_datetime, t.event_datetime) >= date_from)
$$;

