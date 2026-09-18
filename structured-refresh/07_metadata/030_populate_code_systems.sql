-- =====================================================================
-- populate_code_systems.sql
--
-- Populates meta.catalog.has_standardized_codes / code_systems for the
-- objects that carry a real coding standard, per the terminology audit:
--   - ATC (medications):  amc_core.medication_atc + v_medications, 1,983
--     distinct codes / 225 classes. Fields: atc_code, atc_code_niv1-5.
--   - ICD (diagnoses):    medical_diagnosis, medical_history, problem_list.
--     Field: diagnosis_code.
--   - SNOMED (problems):  amc_core.problem_list only. Field: snomed_code.
--   - CBV (labs):         amc_core.lab_result. No LOINC — determination_code
--     is a local Epic lab test code (13,117 distinct codes / 7,698 names),
--     but CBV codes (Dutch hospital billing/statistics standard) are present.
--
-- Run after populate_meta_catalog_unified.fixed.sql (needs matching rows
-- to already exist in meta.catalog).
-- =====================================================================

-- ---------------------------------------------------------------------
-- ATC (medications)
-- ---------------------------------------------------------------------

UPDATE meta.catalog SET
    has_standardized_codes = true,
    code_systems = 'ATC (Anatomical Therapeutic Chemical) — lookup/reference table for the ATC hierarchy. Field: atc_code.'
WHERE schema_name = 'amc_core' AND object_name = 'medication_atc';

UPDATE meta.catalog SET
    has_standardized_codes = true,
    code_systems = 'ATC — atc_code field, ~14% NULL. Join medication_atc for the full ATC hierarchy (atc_code_niv1-5).'
WHERE schema_name = 'amc_core' AND object_name IN ('medication_administration', 'medication_prescription');

UPDATE meta.catalog SET
    has_standardized_codes = true,
    code_systems = 'ATC — 1,983 distinct codes / 225 classes. Fields: atc_code, atc_code_niv1-5.'
WHERE schema_name = 'amc_views' AND object_name IN ('v_medications', 'v_icu_medications');

-- ---------------------------------------------------------------------
-- ICD (diagnoses) and SNOMED (problem list)
-- ---------------------------------------------------------------------

UPDATE meta.catalog SET
    has_standardized_codes = true,
    code_systems = 'ICD — diagnosis_code field (primary diagnosis coding).'
WHERE schema_name = 'amc_core' AND object_name IN ('medical_diagnosis', 'medical_history');

UPDATE meta.catalog SET
    has_standardized_codes = true,
    code_systems = 'ICD (diagnosis_code, diagnose_thesaurus_code) + SNOMED (snomed_code, frequently NULL — fall back to diagnose_thesaurus_code/diagnosis_code).'
WHERE schema_name = 'amc_core' AND object_name = 'problem_list';

UPDATE meta.catalog SET
    has_standardized_codes = true,
    code_systems = 'ICD (from medical_diagnosis) + SNOMED (from problem_list).'
WHERE schema_name = 'amc_views' AND object_name IN ('v_diagnoses_longitudinal', 'v_icu_diagnoses_longitudinal');

UPDATE meta.catalog SET
    has_standardized_codes = true,
    code_systems = 'ICD — diagnosis_code, inherited from the medical_history source only (family_history/surgery_history carry no code system).'
WHERE schema_name = 'amc_views' AND object_name IN ('v_medical_history', 'v_icu_medical_history');

-- ---------------------------------------------------------------------
-- CBV (labs) — explicitly NOT LOINC
-- ---------------------------------------------------------------------

UPDATE meta.catalog SET
    has_standardized_codes = true,
    code_systems = 'CBV (Dutch national standard for lab billing/statistics). No LOINC — determination_code is a local Epic lab test code (13,117 distinct codes, 7,698 distinct names).'
WHERE schema_name = 'amc_core' AND object_name = 'lab_result';

UPDATE meta.catalog SET
    has_standardized_codes = true,
    code_systems = 'CBV — inherited from lab_result. No LOINC.'
WHERE schema_name = 'amc_views' AND object_name IN ('v_labs_long', 'v_icu_labs_long');

-- ---------------------------------------------------------------------
-- Everything else defaults to has_standardized_codes = false (already
-- the column default), so no action needed for the remaining 90 objects.
-- ---------------------------------------------------------------------

-- Sanity check: list what got marked
-- SELECT schema_name, object_name, code_systems FROM meta.catalog WHERE has_standardized_codes ORDER BY 1,2;
