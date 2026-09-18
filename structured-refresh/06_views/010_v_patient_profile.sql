CREATE SCHEMA IF NOT EXISTS amc_views;

------------------------------------------------------------------------------------------------------------
-- amc_views.v_patient_profile
-- death_date_time (on patient_not_traceable itself) is the direct source
-- of truth for death timing -- death_registration is deliberately not
-- joined here (see docs/superpowers/specs/2026-08-28-repo-reorganization-design.md,
-- "06_views" stage status, death-data content update).
------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW amc_views.v_patient_profile AS
WITH latest_tobacco AS (
  SELECT DISTINCT ON (pseudo_id)
    pseudo_id,
    registration_date AS latest_tobacco_registration_date,
    status_tobacco_use AS latest_tobacco_status,
    is_current_smoker,
    is_former_smoker,
    type_tobacco_use,
    quantity_packages_per_day,
    tobacco_use_years
  FROM amc_core.tobacco_use
  ORDER BY pseudo_id, registration_date DESC NULLS LAST
)

SELECT
  p.pseudo_id,
  p.year_of_birth,
  p.gender,
  p.death_date_time,
  p.is_deceased,
  p.is_objection_patient,
  p.objection_research_recruitment,
  ps.marital_status,
  ps.education_level,
  lt.latest_tobacco_registration_date,
  lt.latest_tobacco_status,
  lt.is_current_smoker,
  lt.is_former_smoker,
  lt.type_tobacco_use,
  lt.quantity_packages_per_day,
  lt.tobacco_use_years
FROM amc_core.patient_not_traceable p
LEFT JOIN amc_core.patient_social ps
  ON ps.pseudo_id = p.pseudo_id
LEFT JOIN latest_tobacco lt
  ON lt.pseudo_id = p.pseudo_id;
