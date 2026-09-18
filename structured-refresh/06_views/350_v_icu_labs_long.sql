DROP VIEW IF EXISTS amc_views.v_icu_labs_long;

CREATE VIEW amc_views.v_icu_labs_long AS

-- Joins on lab_result.probable_partial_traject_id (05_linkage_repair), which
-- is the same admission_partial_traject match this view used to recompute
-- independently via a date-range predicate -- using the id directly is more
-- precise (an exact assignment, not "any ICU window this timestamp happens
-- to fall inside") and lets Postgres use the index on that column instead
-- of scanning by date range.
SELECT
    l.pseudo_id,

    NULL::text AS original_patient_contact_id,
    icu.patient_contact_id AS patient_contact_id,

    icu.icu_stay_id,
    icu.admission_traject_id,
    icu.icu_start_datetime,
    icu.icu_end_datetime,
    icu.icu_los_hours,

    l.source_record_id,
    l.measurement_datetime,
    l.measurement_domain,
    l.measurement_name,
    l.measurement_code,
    l.value_numeric,
    l.value_text,
    l.unit,
    l.normalvalue_below,
    l.normalvalue_upper_limit,
    l.material_type,
    l.sampling_location,
    l.requesting_workplace,
    l.source_table,

    'probable_partial_traject_id_match' AS icu_match_type

FROM amc_views.v_labs_long l

JOIN amc_views.v_icu_stays icu
    ON icu.icu_stay_id = l.probable_partial_traject_id;
