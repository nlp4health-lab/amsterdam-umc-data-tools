------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_icu_clinical_timeline;

CREATE VIEW amc_views.v_icu_clinical_timeline AS

-- ICU stays: admission (interval row, event_end_datetime still carries
-- the discharge moment for duration/overlap calculations)
SELECT
    s.pseudo_id::text,
    NULL::text AS original_patient_contact_id,
    s.patient_contact_id::text AS icu_patient_contact_id,
    s.icu_stay_id::text,
    s.admission_traject_id::text,
    s.icu_start_datetime,
    s.icu_end_datetime,
    s.icu_los_hours,
    s.icu_start_datetime::timestamptz AS event_datetime,
    s.icu_end_datetime::timestamptz AS event_end_datetime,
    'icu_stay'::text AS event_domain,
    'icu_stay'::text AS event_type,
    'admission'::text AS event_subtype,
    s.icu_stay_id::text AS event_id,
    s.workplace::text AS event_label,
    NULL::numeric AS value_numeric,
    NULL::text AS value_text,
    NULL::text AS unit,
    s.hospital_location::text,
    s.workplace::text,
    s.specialty::text,
    s.subspecialty::text,
    'v_icu_stays'::text AS source_view,
    s.icu_stay_id::text AS source_record_id,
    'icu_stay'::text AS icu_match_type
FROM amc_views.v_icu_stays s

UNION ALL

-- ICU stays: discharge (this ICU segment is the last one in its
-- admission_traject -- next stop is out of the hospital) or transfer_out
-- (another admission_partial_traject segment, ICU or not, starts at/after
-- this one ends, under the same admission_traject -- the patient moved
-- wards, didn't leave). v_icu_stays already excludes ongoing partial
-- stays, so icu_end_datetime is expected to be non-null here; guarded
-- anyway.
SELECT
    s.pseudo_id::text,
    NULL::text AS original_patient_contact_id,
    s.patient_contact_id::text AS icu_patient_contact_id,
    s.icu_stay_id::text,
    s.admission_traject_id::text,
    s.icu_start_datetime,
    s.icu_end_datetime,
    s.icu_los_hours,
    s.icu_end_datetime::timestamptz AS event_datetime,
    NULL::timestamptz AS event_end_datetime,
    'icu_stay'::text AS event_domain,
    'icu_stay'::text AS event_type,
    CASE WHEN EXISTS (
        SELECT 1 FROM amc_core.admission_partial_traject next_apt
        WHERE next_apt.admission_traject_id = s.admission_traject_id
          AND next_apt.admission_partial_traject_id <> s.icu_stay_id
          AND next_apt.start_date_time >= s.icu_end_datetime
          AND NOT COALESCE(next_apt.ongoing_partial_stay, false)
    ) THEN 'transfer_out' ELSE 'discharge' END::text AS event_subtype,
    s.icu_stay_id::text || ':discharge' AS event_id,
    s.workplace::text || CASE WHEN EXISTS (
        SELECT 1 FROM amc_core.admission_partial_traject next_apt
        WHERE next_apt.admission_traject_id = s.admission_traject_id
          AND next_apt.admission_partial_traject_id <> s.icu_stay_id
          AND next_apt.start_date_time >= s.icu_end_datetime
          AND NOT COALESCE(next_apt.ongoing_partial_stay, false)
    ) THEN ' transfer out' ELSE ' discharge' END AS event_label,
    NULL::numeric AS value_numeric,
    NULL::text AS value_text,
    NULL::text AS unit,
    s.hospital_location::text,
    s.workplace::text,
    s.specialty::text,
    s.subspecialty::text,
    'v_icu_stays'::text AS source_view,
    s.icu_stay_id::text AS source_record_id,
    'icu_stay'::text AS icu_match_type
FROM amc_views.v_icu_stays s
WHERE s.icu_end_datetime IS NOT NULL

UNION ALL

-- ICU procedures
SELECT
    p.pseudo_id::text,
    p.original_patient_contact_id::text,
    p.icu_patient_contact_id::text,
    p.icu_stay_id::text,
    p.admission_traject_id::text,
    p.icu_start_datetime,
    p.icu_end_datetime,
    p.icu_los_hours,
    p.procedure_datetime::timestamptz,
    p.procedure_end_datetime::timestamptz,
    'procedure'::text,
    p.procedure_source::text,
    p.procedure_status::text,
    p.procedure_row_id::text,
    p.procedure_name::text,
    NULL::numeric,
    p.procedure_code::text,
    NULL::text,
    p.hospital_location::text,
    p.workplace::text,
    p.specialty::text,
    p.subspecialty::text,
    'v_icu_procedures'::text,
    p.procedure_id::text,
    p.icu_match_type::text
FROM amc_views.v_icu_procedures p

UNION ALL

-- ICU vital signs
SELECT
    v.pseudo_id::text,
    v.original_patient_contact_id::text,
    v.icu_patient_contact_id::text,
    v.icu_stay_id::text,
    v.admission_traject_id::text,
    v.icu_start_datetime,
    v.icu_end_datetime,
    v.icu_los_hours,
    v.measurement_datetime::timestamptz,
    NULL::timestamptz,
    'measurement'::text,
    v.measurement_domain::text,
    v.measurement_name::text,
    NULL::text,
    v.measurement_name::text,
    v.value_numeric::numeric,
    v.value_text::text,
    v.unit::text,
    v.hospital_location::text,
    NULL::text,
    NULL::text,
    NULL::text,
    'v_icu_vital_signs_long'::text,
    NULL::text,
    v.icu_match_type::text
FROM amc_views.v_icu_vital_signs_long v

UNION ALL

-- ICU labs
SELECT
    l.pseudo_id::text,
    l.original_patient_contact_id::text,
    l.patient_contact_id::text,
    l.icu_stay_id::text,
    l.admission_traject_id::text,
    l.icu_start_datetime,
    l.icu_end_datetime,
    l.icu_los_hours,
    l.measurement_datetime::timestamptz,
    NULL::timestamptz,
    'lab'::text,
    l.measurement_domain::text,
    l.measurement_name::text,
    l.source_record_id::text,
    l.measurement_name::text,
    l.value_numeric::numeric,
    l.value_text::text,
    l.unit::text,
    NULL::text,
    l.requesting_workplace::text,
    NULL::text,
    NULL::text,
    'v_icu_labs_long'::text,
    l.source_record_id::text,
    l.icu_match_type::text
FROM amc_views.v_icu_labs_long l

UNION ALL

-- ICU scores
SELECT
    sc.pseudo_id::text,
    sc.original_patient_contact_id::text,
    sc.icu_patient_contact_id::text,
    sc.icu_stay_id::text,
    sc.admission_traject_id::text,
    sc.icu_start_datetime,
    sc.icu_end_datetime,
    sc.icu_los_hours,
    sc.score_datetime::timestamptz,
    NULL::timestamptz,
    'score'::text,
    sc.score_name::text,
    sc.source_column::text,
    NULL::text,
    sc.score_name::text,
    sc.score_value::numeric,
    sc.score_category::text,
    NULL::text,
    sc.hospital_location::text,
    NULL::text,
    NULL::text,
    NULL::text,
    'v_icu_scores'::text,
    NULL::text,
    sc.icu_match_type::text
FROM amc_views.v_icu_scores sc

UNION ALL

-- ICU fluid balance
SELECT
    f.pseudo_id::text,
    f.original_patient_contact_id::text,
    f.icu_patient_contact_id::text,
    f.icu_stay_id::text,
    f.admission_traject_id::text,
    f.icu_start_datetime,
    f.icu_end_datetime,
    f.icu_los_hours,
    f.measurement_datetime::timestamptz,
    NULL::timestamptz,
    'fluid_balance'::text,
    f.fluid_direction::text,
    f.measurement_name::text,
    NULL::text,
    f.measurement_name::text,
    f.value_numeric::numeric,
    f.value_text::text,
    f.unit::text,
    f.hospital_location::text,
    NULL::text,
    NULL::text,
    NULL::text,
    'v_icu_fluid_balance_long'::text,
    NULL::text,
    f.icu_match_type::text
FROM amc_views.v_icu_fluid_balance_long f

UNION ALL

-- ICU nephrology
SELECT
    n.pseudo_id::text,
    n.original_patient_contact_id::text,
    n.icu_patient_contact_id::text,
    n.icu_stay_id::text,
    n.admission_traject_id::text,
    n.icu_start_datetime,
    n.icu_end_datetime,
    n.icu_los_hours,
    n.treatment_datetime::timestamptz,
    NULL::timestamptz,
    'nephrology'::text,
    n.nephrology_modality::text,
    n.treatment_measure::text,
    NULL::text,
    n.treatment_measure::text,
    n.value_numeric::numeric,
    n.value_text::text,
    n.unit::text,
    n.hospital_location::text,
    NULL::text,
    NULL::text,
    NULL::text,
    'v_icu_nephrology_treatments'::text,
    NULL::text,
    n.icu_match_type::text
FROM amc_views.v_icu_nephrology_treatments n

UNION ALL

-- ICU notes
SELECT
    nt.pseudo_id::text,
    nt.original_patient_contact_id::text,
    nt.icu_patient_contact_id::text,
    nt.icu_stay_id::text,
    nt.admission_traject_id::text,
    nt.icu_start_datetime,
    nt.icu_end_datetime,
    nt.icu_los_hours,
    nt.corrected_note_datetime::timestamptz,
    NULL::timestamptz,
    'note'::text,
    nt.patient_note_category::text,
    nt.note_status::text,
    nt.patient_note_id::text,
    nt.patient_note_category::text,
    NULL::numeric,
    NULL::text,
    NULL::text,
    nt.hospital_location::text,
    NULL::text,
    nt.healthcare_provider_specialty::text,
    nt.healthcare_provider_sub_specialty::text,
    'v_icu_notes'::text,
    nt.patient_note_id::text,
    nt.icu_match_type::text
FROM amc_views.v_icu_notes nt;
