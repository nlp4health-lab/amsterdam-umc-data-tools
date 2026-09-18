------------------------------------------------------------------------------------------------------------
-- amc_views.v_procedures
-- Genuine clinical procedure events only, sourced from systems of record
-- purpose-built for procedure documentation (OK scheduling, IC bedside notes).
-- Does NOT include amc_core.procedures (the general billing/DBC feed) except
-- for a narrow recovery branch capturing minor/outpatient procedures that
-- never go through OK scheduling and have no other source of truth.
--
-- ok_procedure_performed/ok_procedure_planned have no real patient_contact_id
-- -- patient_contact_id and probable_partial_traject_id below are
-- 05_linkage_repair's probable_contact_id/probable_partial_traject_id for
-- those two branches; every other branch has a real patient_contact_id and
-- NULL::text for probable_partial_traject_id.
------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS amc_views.v_procedures CASCADE;

CREATE VIEW amc_views.v_procedures AS

-- ok procedures performed (primary OR source — more complete/current than
-- its mirror in amc_core.procedures)
SELECT
    op.pseudo_id,
    op.probable_contact_id AS patient_contact_id,
    op.probable_partial_traject_id,
    NULL::text AS admission_traject_id,
    'ok_procedure_performed:' || op.ok_procedure_performed_id::text AS procedure_row_id,
    op.ok_procedure_performed_id::text AS procedure_id,
    'ok_performed' AS procedure_source,
    op.session_start_date_time AS procedure_datetime,
    NULL::timestamptz AS procedure_end_datetime,
    NULL::text AS procedure_code,
    op.intervention AS procedure_name,
    NULL::text AS procedure_status,
    NULL::text AS complications,
    NULL::text AS complications_discussed,
    op.hospital_location,
    NULL::text AS workplace,
    op.session_ok_specialty AS specialty,
    op.chief_operator_panel_subspecialty AS subspecialty,
    op.session_specialism AS requesting_specialty_abbreviation,
    NULL::text AS requesting_sub_specialty,
    op.age_in_years_at_moment_of_session AS age_at_procedure,
    op.subtraject_id,
    op.ok_session_number,
    op.laterality,
    op.is_chief_intervention,
    NULL::text AS ok_anesthesia_type,
    NULL::text AS order_id,
    op.care_activity,
    NULL::text AS care_profile_class,
    NULL::text AS source_module,
    'ok_procedure_performed' AS source_table
FROM amc_core.ok_procedure_performed op

UNION ALL

-- ok procedures planned (scheduling intent; includes plans never executed —
-- see v_procedures_billing for what was actually billed)
SELECT
    pp.pseudo_id,
    pp.probable_contact_id AS patient_contact_id,
    pp.probable_partial_traject_id,
    NULL::text AS admission_traject_id,
    'ok_procedure_planned:' || pp.ok_procedure_planned_id::text AS procedure_row_id,
    pp.ok_procedure_planned_id::text AS procedure_id,
    'ok_planned' AS procedure_source,
    pp.session_planned_start_date::timestamptz AS procedure_datetime,
    NULL::timestamptz AS procedure_end_datetime,
    pp.intervention_code AS procedure_code,
    pp.intervention AS procedure_name,
    pp.session_ok_plan_status AS procedure_status,
    NULL::text AS complications,
    NULL::text AS complications_discussed,
    pp.hospital_location,
    NULL::text AS workplace,
    pp.session_ok_specialty AS specialty,
    pp.chief_operator_panel_subspecialty AS subspecialty,
    pp.session_specialism AS requesting_specialty_abbreviation,
    pp.session_subspecialty AS requesting_sub_specialty,
    pp.age_in_years_at_moment_of_session AS age_at_procedure,
    pp.lowest_subtraject_id AS subtraject_id,
    pp.ok_session_number,
    pp.laterality,
    NULL::text AS is_chief_intervention,
    pp.ok_anesthesia_type,
    NULL::text AS order_id,
    NULL::text AS care_activity,
    NULL::text AS care_profile_class,
    NULL::text AS source_module,
    'ok_procedure_planned' AS source_table
FROM amc_core.ok_procedure_planned pp

UNION ALL

-- ic bronchoscopy
SELECT
    b.pseudo_id,
    b.patient_contact_id,
    NULL::text AS probable_partial_traject_id,
    NULL::text AS admission_traject_id,
    'ic_procedure_note_bronchoscopy:' || b.order_id::text AS procedure_row_id,
    b.order_id::text AS procedure_id,
    'ic_bronchoscopy' AS procedure_source,
    b.intervention_date_time AS procedure_datetime,
    NULL::timestamptz AS procedure_end_datetime,
    NULL::text AS procedure_code,
    b.intervention_name AS procedure_name,
    NULL::text AS procedure_status,
    b.complications,
    b.complications_discussed,
    b.hospital_location,
    NULL::text AS workplace,
    NULL::text AS specialty,
    NULL::text AS subspecialty,
    NULL::text AS requesting_specialty_abbreviation,
    NULL::text AS requesting_sub_specialty,
    NULL::numeric AS age_at_procedure,
    NULL::text AS subtraject_id,
    NULL::text AS ok_session_number,
    NULL::text AS laterality,
    NULL::text AS is_chief_intervention,
    NULL::text AS ok_anesthesia_type,
    b.order_id,
    NULL::text AS care_activity,
    NULL::text AS care_profile_class,
    NULL::text AS source_module,
    'ic_procedure_note_bronchoscopy' AS source_table
FROM amc_core.ic_procedure_note_bronchoscopy b

UNION ALL

-- ic icarus
SELECT
    ic.pseudo_id,
    ic.patient_contact_id,
    NULL::text AS probable_partial_traject_id,
    NULL::text AS admission_traject_id,
    'ic_procedure_note_icarus:' || ic.order_id::text AS procedure_row_id,
    ic.order_id::text AS procedure_id,
    'ic_icarus' AS procedure_source,
    ic.intervention_date_time AS procedure_datetime,
    NULL::timestamptz AS procedure_end_datetime,
    NULL::text AS procedure_code,
    ic.intervention_name AS procedure_name,
    NULL::text AS procedure_status,
    NULL::text AS complications,
    ic.complications_discussed,
    ic.hospital_location,
    NULL::text AS workplace,
    NULL::text AS specialty,
    NULL::text AS subspecialty,
    NULL::text AS requesting_specialty_abbreviation,
    NULL::text AS requesting_sub_specialty,
    NULL::numeric AS age_at_procedure,
    NULL::text AS subtraject_id,
    NULL::text AS ok_session_number,
    NULL::text AS laterality,
    NULL::text AS is_chief_intervention,
    NULL::text AS ok_anesthesia_type,
    ic.order_id,
    NULL::text AS care_activity,
    NULL::text AS care_profile_class,
    NULL::text AS source_module,
    'ic_procedure_note_icarus' AS source_table
FROM amc_core.ic_procedure_note_icarus ic

UNION ALL

-- ic intubation
SELECT
    it.pseudo_id,
    it.patient_contact_id,
    NULL::text AS probable_partial_traject_id,
    NULL::text AS admission_traject_id,
    'ic_procedure_note_intubation:' || it.order_id::text AS procedure_row_id,
    it.order_id::text AS procedure_id,
    'ic_intubation' AS procedure_source,
    it.intervention_date_time AS procedure_datetime,
    NULL::timestamptz AS procedure_end_datetime,
    NULL::text AS procedure_code,
    it.intervention_name AS procedure_name,
    NULL::text AS procedure_status,
    NULL::text AS complications,
    it.complications_discussed,
    it.hospital_location,
    NULL::text AS workplace,
    NULL::text AS specialty,
    NULL::text AS subspecialty,
    NULL::text AS requesting_specialty_abbreviation,
    NULL::text AS requesting_sub_specialty,
    NULL::numeric AS age_at_procedure,
    NULL::text AS subtraject_id,
    NULL::text AS ok_session_number,
    NULL::text AS laterality,
    NULL::text AS is_chief_intervention,
    NULL::text AS ok_anesthesia_type,
    it.order_id,
    NULL::text AS care_activity,
    NULL::text AS care_profile_class,
    NULL::text AS source_module,
    'ic_procedure_note_intubation' AS source_table
FROM amc_core.ic_procedure_note_intubation it

UNION ALL

-- ic tracheostomy
SELECT
    tr.pseudo_id,
    tr.patient_contact_id,
    NULL::text AS probable_partial_traject_id,
    NULL::text AS admission_traject_id,
    'ic_procedure_note_tracheostomy:' || tr.order_id::text AS procedure_row_id,
    tr.order_id::text AS procedure_id,
    'ic_tracheostomy' AS procedure_source,
    tr.intervention_date_time AS procedure_datetime,
    NULL::timestamptz AS procedure_end_datetime,
    NULL::text AS procedure_code,
    tr.intervention_name AS procedure_name,
    NULL::text AS procedure_status,
    tr.complications,
    tr.complications_discussed,
    tr.hospital_location,
    NULL::text AS workplace,
    NULL::text AS specialty,
    NULL::text AS subspecialty,
    NULL::text AS requesting_specialty_abbreviation,
    NULL::text AS requesting_sub_specialty,
    NULL::numeric AS age_at_procedure,
    NULL::text AS subtraject_id,
    NULL::text AS ok_session_number,
    NULL::text AS laterality,
    NULL::text AS is_chief_intervention,
    NULL::text AS ok_anesthesia_type,
    tr.order_id,
    NULL::text AS care_activity,
    NULL::text AS care_profile_class,
    NULL::text AS source_module,
    'ic_procedure_note_tracheostomy' AS source_table
FROM amc_core.ic_procedure_note_tracheostomy tr

UNION ALL

-- ic thorax drain
SELECT
    td.pseudo_id,
    td.patient_contact_id,
    NULL::text AS probable_partial_traject_id,
    NULL::text AS admission_traject_id,
    'ic_procedure_note_thorax_drain:' || td.order_id::text AS procedure_row_id,
    td.order_id::text AS procedure_id,
    'ic_thorax_drain' AS procedure_source,
    td.intervention_date_time AS procedure_datetime,
    NULL::timestamptz AS procedure_end_datetime,
    NULL::text AS procedure_code,
    td.intervention_name AS procedure_name,
    NULL::text AS procedure_status,
    td.complications,
    td.complications_discussed,
    td.hospital_location,
    NULL::text AS workplace,
    NULL::text AS specialty,
    NULL::text AS subspecialty,
    NULL::text AS requesting_specialty_abbreviation,
    NULL::text AS requesting_sub_specialty,
    NULL::numeric AS age_at_procedure,
    NULL::text AS subtraject_id,
    NULL::text AS ok_session_number,
    NULL::text AS laterality,
    NULL::text AS is_chief_intervention,
    NULL::text AS ok_anesthesia_type,
    td.order_id,
    NULL::text AS care_activity,
    NULL::text AS care_profile_class,
    NULL::text AS source_module,
    'ic_procedure_note_thorax_drain' AS source_table
FROM amc_core.ic_procedure_note_thorax_drain td

UNION ALL

-- ic central venous catheter
SELECT
    cv.pseudo_id,
    cv.patient_contact_id,
    NULL::text AS probable_partial_traject_id,
    NULL::text AS admission_traject_id,
    'ic_procedure_note_central_venous_catheter:' || cv.order_id::text AS procedure_row_id,
    cv.order_id::text AS procedure_id,
    'ic_central_venous_catheter' AS procedure_source,
    cv.intervention_date_time AS procedure_datetime,
    NULL::timestamptz AS procedure_end_datetime,
    NULL::text AS procedure_code,
    cv.intervention_name AS procedure_name,
    NULL::text AS procedure_status,
    cv.complications,
    cv.complications_discussed,
    cv.hospital_location,
    NULL::text AS workplace,
    NULL::text AS specialty,
    NULL::text AS subspecialty,
    NULL::text AS requesting_specialty_abbreviation,
    NULL::text AS requesting_sub_specialty,
    NULL::numeric AS age_at_procedure,
    NULL::text AS subtraject_id,
    NULL::text AS ok_session_number,
    NULL::text AS laterality,
    NULL::text AS is_chief_intervention,
    NULL::text AS ok_anesthesia_type,
    cv.order_id,
    NULL::text AS care_activity,
    NULL::text AS care_profile_class,
    NULL::text AS source_module,
    'ic_procedure_note_central_venous_catheter' AS source_table
FROM amc_core.ic_procedure_note_central_venous_catheter cv

UNION ALL

-- ic electric cardioversion
SELECT
    ec.pseudo_id,
    ec.patient_contact_id,
    NULL::text AS probable_partial_traject_id,
    NULL::text AS admission_traject_id,
    'ic_procedure_note_electric_cardioversion:' || ec.order_id::text AS procedure_row_id,
    ec.order_id::text AS procedure_id,
    'ic_electric_cardioversion' AS procedure_source,
    ec.intervention_date_time AS procedure_datetime,
    ec.end_procedure AS procedure_end_datetime,
    NULL::text AS procedure_code,
    ec.intervention_name AS procedure_name,
    NULL::text AS procedure_status,
    ec.complications,
    ec.complications_discussed,
    ec.hospital_location,
    NULL::text AS workplace,
    NULL::text AS specialty,
    NULL::text AS subspecialty,
    NULL::text AS requesting_specialty_abbreviation,
    NULL::text AS requesting_sub_specialty,
    NULL::numeric AS age_at_procedure,
    NULL::text AS subtraject_id,
    NULL::text AS ok_session_number,
    NULL::text AS laterality,
    NULL::text AS is_chief_intervention,
    NULL::text AS ok_anesthesia_type,
    ec.order_id,
    NULL::text AS care_activity,
    NULL::text AS care_profile_class,
    NULL::text AS source_module,
    'ic_procedure_note_electric_cardioversion' AS source_table
FROM amc_core.ic_procedure_note_electric_cardioversion ec

UNION ALL

-- ── recovery branch
-- amc_core.procedures rows classified as OPERATIEVE VERRICHTINGEN that have
-- NO matching session in ok_procedure_performed or ok_procedure_planned.
-- This recovers the genuine long tail of minor/bedside/outpatient procedures
-- (punch biopsies, wound excisions, manual placenta removal, etc.) that
-- never went through OK scheduling and have no other source of truth.
-- Confirmed ~338k of 615k OPERATIEVE VERRICHTINGEN rows
-- are unmatched to either OK table -this branch captures those.
-- dropped ok_session_number from both NOT EXISTS conditions entirely
-- since the OK tables always have it populated and procedures often doesn't,
-- matching on subtraject_id alone is actually the more reliable and inclusive exclusion check
SELECT
    p.pseudo_id,
    p.patient_contact_id,
    NULL::text AS probable_partial_traject_id,
    NULL::text AS admission_traject_id,
    'procedures:' || p.intervention_id::text AS procedure_row_id,
    p.intervention_id::text AS procedure_id,
    'general_procedure_unmatched' AS procedure_source,
    p.intervention_date::timestamptz AS procedure_datetime,
    NULL::timestamptz AS procedure_end_datetime,
    p.intervention_code AS procedure_code,
    p.intervention AS procedure_name,
    NULL::text AS procedure_status,
    NULL::text AS complications,
    NULL::text AS complications_discussed,
    p.hospital_location,
    p.executive_workplace AS workplace,
    p.executive_specialty AS specialty,
    p.executive_sub_specialty AS subspecialty,
    p.requesting_specialty_abbreviation,
    p.requesting_sub_specialty,
    p.age_in_years_at_moment_of_intervention AS age_at_procedure,
    p.subtraject_id,
    p.ok_session_number,
    NULL::text AS laterality,
    NULL::text AS is_chief_intervention,
    NULL::text AS ok_anesthesia_type,
    p.order_id,
    p.care_activity,
    p.care_profile_class,
    p.source_module,
    'procedures' AS source_table
FROM amc_core.procedures p
WHERE p.care_profile_class = 'OPERATIEVE VERRICHTINGEN'
  AND NOT EXISTS (
      SELECT 1 FROM amc_core.ok_procedure_performed op
      WHERE op.pseudo_id = p.pseudo_id
        AND op.subtraject_id = p.subtraject_id
  )
  AND NOT EXISTS (
      SELECT 1 FROM amc_core.ok_procedure_planned pp
      WHERE pp.pseudo_id = p.pseudo_id
        AND pp.lowest_subtraject_id = p.subtraject_id
  );
