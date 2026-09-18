-- ok_procedure_performed (anchor: session_start_date_time, fallback: intervention_executed_date)
-- Date-range matching only -- an earlier version of this logic tried an
-- exact match via subtraject_id first; dropped, because
-- admission_partial_traject_id is a composite value
-- (patient_contact_id||'|'||sequence), not a plain id, so it can't be
-- matched directly against subtraject_id.
-- Requires 04_quality_flags to have already run: reads
-- admission_partial_traject.corrected_end_date_time, added by that
-- stage, not 02_core_clean.
ALTER TABLE amc_core.ok_procedure_performed
    ADD COLUMN IF NOT EXISTS probable_contact_id text,
    ADD COLUMN IF NOT EXISTS probable_partial_traject_id text;

UPDATE amc_core.ok_procedure_performed AS op
SET (probable_contact_id, probable_partial_traject_id) = (
    SELECT apt.patient_contact_id, apt.admission_partial_traject_id
    FROM amc_core.admission_partial_traject AS apt
    WHERE apt.pseudo_id = op.pseudo_id
      -- NOTE: the fallback half of this COALESCE, intervention_executed_date,
      -- is a `date` column (no time-of-day), so when session_start_date_time
      -- is null it's implicitly promoted to local midnight for this
      -- comparison. A procedure performed later the same day a patient was
      -- admitted can therefore fail the >= start_date_time check and be
      -- attributed to an earlier stay segment (or left unmatched) instead of
      -- the correct one. session_start_date_time itself already has
      -- time-of-day and is unaffected. This is inherited from the original
      -- script, not a regression -- flagged here as a known limitation, not
      -- something to silently fix.
      AND COALESCE(op.session_start_date_time, op.intervention_executed_date) >= apt.start_date_time
      AND (
            apt.corrected_end_date_time IS NULL
            OR COALESCE(op.session_start_date_time, op.intervention_executed_date) <= apt.corrected_end_date_time
          )
    ORDER BY apt.start_date_time DESC
    LIMIT 1
)
WHERE op.probable_contact_id IS NULL
  AND COALESCE(op.session_start_date_time, op.intervention_executed_date) IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_ok_procedure_performed_probable_contact_id
    ON amc_core.ok_procedure_performed (probable_contact_id);
CREATE INDEX IF NOT EXISTS idx_ok_procedure_performed_probable_partial_traject_id
    ON amc_core.ok_procedure_performed (probable_partial_traject_id);
