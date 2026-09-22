---------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_clinical_timeline;

CREATE VIEW amc_views.v_clinical_timeline AS

-- stays: admission (interval row, event_end_datetime still carries the
-- discharge moment for duration/overlap calculations)
SELECT
    s.pseudo_id::text AS pseudo_id,
    s.patient_contact_id::text AS patient_contact_id,
    s.start_datetime::timestamptz AS event_datetime,
    s.end_datetime::timestamptz AS event_end_datetime,
    'stay'::text AS event_domain,
    s.stay_type::text AS event_type,
    'admission'::text AS event_subtype,
    s.stay_id::text AS event_id,
    s.stay_type::text AS event_label,
    NULL::numeric AS value_numeric,
    NULL::text AS value_text,
    NULL::text AS unit,
    s.hospital_location::text AS hospital_location,
    s.workplace::text AS workplace,
    s.specialty::text AS specialty,
    s.subspecialty::text AS subspecialty,
    'v_stays'::text AS source_view,
    s.stay_id::text AS source_record_id
FROM amc_views.v_stays s

UNION ALL

-- stays: discharge (admission_traject, seh_trajectory) or transfer_out
-- (admission_partial_traject -- a subtraject/ward-segment ending mid-
-- admission is a ward transfer, not a hospital discharge), as its own
-- point-in-time event -- so ordering the timeline by event_datetime
-- surfaces the moment directly, instead of it only being visible as
-- event_end_datetime on the admission row above. v_stays already
-- excludes ongoing/undischarged stays (repo owner's call, for cleaner
-- analyses), so end_datetime is expected to be non-null here; guarded
-- anyway.
SELECT
    s.pseudo_id::text AS pseudo_id,
    s.patient_contact_id::text AS patient_contact_id,
    s.end_datetime::timestamptz AS event_datetime,
    NULL::timestamptz AS event_end_datetime,
    'stay'::text AS event_domain,
    s.stay_type::text AS event_type,
    CASE WHEN s.stay_type = 'admission_partial_traject'
         THEN 'transfer_out' ELSE 'discharge' END::text AS event_subtype,
    s.stay_id::text || ':discharge' AS event_id,
    s.stay_type::text || CASE WHEN s.stay_type = 'admission_partial_traject'
         THEN ' transfer out' ELSE ' discharge' END AS event_label,
    NULL::numeric AS value_numeric,
    NULL::text AS value_text,
    NULL::text AS unit,
    s.hospital_location::text AS hospital_location,
    s.workplace::text AS workplace,
    s.specialty::text AS specialty,
    s.subspecialty::text AS subspecialty,
    'v_stays'::text AS source_view,
    s.stay_id::text AS source_record_id
FROM amc_views.v_stays s
WHERE s.end_datetime IS NOT NULL

UNION ALL

-- appointments
SELECT
    a.pseudo_id::text,
    a.patient_contact_id::text,
    a.appointment_start_moment::timestamptz,
    a.appointment_end_moment::timestamptz,
    'appointment'::text,
    a.appointment_form_level1::text,
    a.appointment_form_level2::text,
    COALESCE(a.appointment_line_id::text, a.appointment_id::text, a.source_record_id::text),
    a.appointment_name::text,
    NULL::numeric,
    a.appointment_status::text,
    NULL::text,
    a.hospital_location::text,
    a.executive_workplace::text,
    a.executive_specialty::text,
    NULL::text,
    'v_appointments'::text,
    a.source_record_id::text
FROM amc_views.v_appointments a

UNION ALL

-- encounters
SELECT
    e.pseudo_id::text,
    e.patient_contact_id::text,
    e.start_datetime::timestamptz,
    e.end_datetime::timestamptz,
    'encounter'::text,
    e.encounter_type::text,
    e.encounter_subtype::text,
    e.source_record_id::text,
    e.status::text,
    NULL::numeric,
    NULL::text,
    NULL::text,
    e.hospital_location::text,
    e.workplace::text,
    e.specialty::text,
    e.subspecialty::text,
    'v_encounters'::text,
    e.source_record_id::text
FROM amc_views.v_encounters e

UNION ALL

-- diagnoses / problems
SELECT
    d.pseudo_id::text,
    d.patient_contact_id::text,
    d.registration_datetime::timestamptz,
    d.close_date::timestamptz,
    'diagnosis'::text,
    d.condition_source::text,
    d.condition_type::text,
    d.condition_id::text,
    d.diagnosis_description::text,
    NULL::numeric,
    COALESCE(d.diagnosis_code::text, d.problem_code::text, d.snomed_code::text),
    NULL::text,
    d.hospital_location::text,
    NULL::text,
    d.specialty::text,
    NULL::text,
    'v_diagnoses_longitudinal'::text,
    d.condition_id::text
FROM amc_views.v_diagnoses_longitudinal d

UNION ALL

-- medical / surgical / family history
SELECT
    h.pseudo_id::text,
    h.patient_contact_id::text,
    h.registration_date::timestamptz,
    h.end_date::timestamptz,
    'history'::text,
    h.history_type::text,
    h.category::text,
    h.history_item_id::text,
    h.description::text,
    NULL::numeric,
    h.code::text,
    NULL::text,
    h.hospital_location::text,
    NULL::text,
    NULL::text,
    NULL::text,
    'v_medical_history'::text,
    h.history_item_id::text
FROM amc_views.v_medical_history h

UNION ALL

-- procedures
SELECT
    p.pseudo_id::text,
    p.patient_contact_id::text,
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
    'v_procedures'::text,
    p.procedure_id::text
FROM amc_views.v_procedures p

UNION ALL

-- imaging study orders
SELECT
    i.pseudo_id::text,
    i.patient_contact_id::text,
    i.imaging_start_datetime::timestamptz,
    i.imaging_end_datetime::timestamptz,
    'imaging'::text,
    i.order_assignment::text,
    i.imaging_study_status::text,
    i.imaging_event_id::text,
    COALESCE(i.order_assignment, i.accession_number)::text,
    NULL::numeric,
    i.is_cancelled::text,
    NULL::text,
    i.hospital_location::text,
    COALESCE(i.executive_workplace, i.requesting_workplace)::text,
    NULL::text,
    NULL::text,
    'v_imaging_study_orders'::text,
    i.imaging_event_id::text
FROM amc_views.v_imaging_study_orders i

UNION ALL

-- medications
SELECT
    m.pseudo_id::text,
    m.patient_contact_id::text,
    m.event_datetime::timestamptz,
    m.stop_datetime::timestamptz AS event_end_datetime,
    'medication'::text AS event_domain,
    m.medication_event_type::text AS event_type,
    m.route::text AS event_subtype,
    m.medication_event_id::text AS event_id,
    COALESCE(
        m.medication_generic_name,
        m.medication_substance_name,
        m.medication_article_name
    )::text AS event_label,
    m.administered_amount::numeric AS value_numeric,
    COALESCE(
        m.status,
        m.medication_frequency_description,
        m.order_description
    )::text AS value_text,
    m.administered_quantity_unit::text AS unit,
    m.hospital_location::text,
    m.workplace::text,
    COALESCE(m.specialty, m.patient_contact_specialty)::text AS specialty,
    m.subspecialty::text,
    'v_medications'::text AS source_view,
    m.medication_event_id::text AS source_record_id
FROM amc_views.v_medications m

UNION ALL

-- vital signs
SELECT
    v.pseudo_id::text,
    v.patient_contact_id::text,
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
    'v_vital_signs_long'::text,
    NULL::text
FROM amc_views.v_vital_signs_long v

UNION ALL

-- labs
SELECT
    l.pseudo_id::text,
    l.patient_contact_id::text,
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
    'v_labs_long'::text,
    l.source_record_id::text
FROM amc_views.v_labs_long l

UNION ALL

-- scores
SELECT
    sc.pseudo_id::text,
    sc.patient_contact_id::text,
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
    'v_scores'::text,
    NULL::text
FROM amc_views.v_scores sc

UNION ALL

-- fluid balance
SELECT
    f.pseudo_id::text,
    f.patient_contact_id::text,
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
    'v_fluid_balance_long'::text,
    NULL::text
FROM amc_views.v_fluid_balance_long f

UNION ALL

-- nephrology treatments
SELECT
    n.pseudo_id::text,
    n.patient_contact_id::text,
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
    'v_nephrology_treatments'::text,
    NULL::text
FROM amc_views.v_nephrology_treatments n

UNION ALL

-- notes metadata / note event
SELECT
    nt.pseudo_id::text,
    nt.patient_contact_id::text,
    nt.note_datetime::timestamptz,
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
    'v_notes'::text,
    nt.patient_note_id::text
FROM amc_views.v_notes nt;
