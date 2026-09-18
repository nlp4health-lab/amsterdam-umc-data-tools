------------------------------------------------------------------------------------------------------------
-- amc_views.v_procedures_billing
-- The general care-activity / DBC billing feed, kept as its own honest view.
-- Useful for billing/coverage cross-checks (e.g. "has this OK session been
-- billed yet") and for the non-procedure care activities (labs, imaging,
-- consults) that live in the same source table but are out of scope for
-- v_procedures. Not intended for clinical procedure analysis on its own --
-- use v_procedures for that.
------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS amc_views.v_procedures_billing;

CREATE VIEW amc_views.v_procedures_billing AS

SELECT
    p.pseudo_id,
    p.patient_contact_id,
    p.intervention_id::text AS procedure_id,
    p.intervention_date::timestamptz AS procedure_datetime,
    p.intervention_code AS procedure_code,
    p.intervention AS procedure_name,
    p.hospital_location,
    p.executive_workplace AS workplace,
    p.executive_specialty AS specialty,
    p.executive_sub_specialty AS subspecialty,
    p.requesting_specialty_abbreviation,
    p.requesting_sub_specialty,
    p.age_in_years_at_moment_of_intervention AS age_at_procedure,
    p.subtraject_id,
    p.ok_session_number,
    p.order_id,
    p.care_activity,
    p.care_profile_class,
    p.source_module,
    CASE
        WHEN p.care_profile_class = 'OPERATIEVE VERRICHTINGEN' THEN TRUE
        ELSE FALSE
    END AS is_operative_class,
    CASE
        WHEN p.care_profile_class = 'OPERATIEVE VERRICHTINGEN'
         AND EXISTS (
             SELECT 1 FROM amc_core.ok_procedure_performed op
             WHERE op.pseudo_id = p.pseudo_id
               AND op.subtraject_id = p.subtraject_id
               AND op.ok_session_number = p.ok_session_number
         )
        THEN 'matched_ok_performed'
        WHEN p.care_profile_class = 'OPERATIEVE VERRICHTINGEN'
         AND EXISTS (
             SELECT 1 FROM amc_core.ok_procedure_planned pp
             WHERE pp.pseudo_id = p.pseudo_id
               AND pp.lowest_subtraject_id = p.subtraject_id
               AND pp.ok_session_number = p.ok_session_number
         )
        THEN 'matched_ok_planned'
        WHEN p.care_profile_class = 'OPERATIEVE VERRICHTINGEN'
        THEN 'unmatched_operative_billing_only'
        ELSE 'non_operative_billing'
    END AS ok_match_status,
    'procedures' AS source_table
FROM amc_core.procedures p;
