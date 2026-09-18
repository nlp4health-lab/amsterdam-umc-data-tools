------------------------------------------------------------------------------------------------------------
--patient_not_traceable
--any quality issue: true if this patient has any quality-flag column set true anywhere
--in this stage (aggregated by pseudo_id across every other 04_quality_flags table).
--
--death_registration is deliberately NOT one of the sources here: patient_not_traceable's
--own death_date_time is the direct source of truth for death timing (see
--docs/superpowers/specs/2026-08-28-repo-reorganization-design.md, "Known content updates"),
--so cross-referencing death_registration for this patient's quality status is obsolete.
--death_registration itself is unaffected -- it stays as a normal core table.
--
--NOTE ON ORDER: unlike every other file in this stage, this one has a real dependency --
--it reads the flag columns every other 04_quality_flags/*.sql file computes, so it is
--numbered to run last (130, after 120_seh_trajectory.sql). Running the whole stage in
--order (or a full ./refresh.sh) is unaffected. Running this table alone, in isolation,
--before the other files have run will not error (every source table/column already
--exists once 02_core_clean has loaded), but will compute has_any_quality_issue against
--whatever flag values happen to exist at that moment -- for an accurate result, run the
--full stage in order.
ALTER TABLE amc_core.patient_not_traceable
ADD COLUMN IF NOT EXISTS has_any_quality_issue boolean DEFAULT false;

WITH flagged_patients AS (
  SELECT pseudo_id FROM amc_core.admission_partial_traject WHERE ongoing_partial_stay
  UNION
  SELECT pseudo_id FROM amc_core.admission_partial_traject WHERE ongoing_admission_traject
  UNION
  SELECT pseudo_id FROM amc_core.admission_traject WHERE ongoing_stay
  UNION
  SELECT pseudo_id FROM amc_core.ecg_measurement WHERE abnormal_decrease_date_time
  UNION
  SELECT pseudo_id FROM amc_core.ecg_measurement_test_feature WHERE abnormal_date_flag
  UNION
  SELECT pseudo_id FROM amc_core.echo_measurement_heart_center_extra_check WHERE examination_date_quality_issue
  UNION
  SELECT pseudo_id FROM amc_core.ic_procedure_note_central_venous_catheter WHERE end_procedure_quality_issue
  UNION
  SELECT pseudo_id FROM amc_core.medication_administration WHERE ongoing_medication_administration
  UNION
  SELECT pseudo_id FROM amc_core.medication_prescription WHERE ongoing_medication
  UNION
  SELECT pseudo_id FROM amc_core.patient_contact WHERE abnormal_date
  UNION
  SELECT pseudo_id FROM amc_core.seh_trajectory WHERE ongoing_seh_stay
)
UPDATE amc_core.patient_not_traceable pnt
SET has_any_quality_issue = true
FROM flagged_patients fp
WHERE pnt.pseudo_id = fp.pseudo_id;
