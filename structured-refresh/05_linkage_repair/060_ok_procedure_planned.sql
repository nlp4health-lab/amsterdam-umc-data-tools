-- ok_procedure_planned (anchor: session_planned_start_date -- date only, no time component)
-- Date-range matching only, same reasoning as ok_procedure_performed above.
-- Requires 04_quality_flags to have already run: reads
-- admission_partial_traject.corrected_end_date_time, added by that
-- stage, not 02_core_clean.
ALTER TABLE amc_core.ok_procedure_planned
    ADD COLUMN IF NOT EXISTS probable_contact_id text,
    ADD COLUMN IF NOT EXISTS probable_partial_traject_id text;

UPDATE amc_core.ok_procedure_planned AS op
SET (probable_contact_id, probable_partial_traject_id) = (
    SELECT apt.patient_contact_id, apt.admission_partial_traject_id
    FROM amc_core.admission_partial_traject AS apt
    WHERE apt.pseudo_id = op.pseudo_id
      -- NOTE: session_planned_start_date is a `date` column (no time-of-day),
      -- so it's implicitly promoted to local midnight for this comparison.
      -- A session planned later the same day a patient was admitted can
      -- therefore fail the >= start_date_time check and be attributed to an
      -- earlier stay segment (or left unmatched) instead of the correct one.
      -- This is inherited from the original script, not a regression --
      -- flagged here as a known limitation, not something to silently fix.
      AND op.session_planned_start_date::timestamptz >= apt.start_date_time
      AND (
            apt.corrected_end_date_time IS NULL
            OR op.session_planned_start_date::timestamptz <= apt.corrected_end_date_time
          )
    ORDER BY apt.start_date_time DESC
    LIMIT 1
)
WHERE op.probable_contact_id IS NULL
  AND op.session_planned_start_date IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_ok_procedure_planned_probable_contact_id
    ON amc_core.ok_procedure_planned (probable_contact_id);
CREATE INDEX IF NOT EXISTS idx_ok_procedure_planned_probable_partial_traject_id
    ON amc_core.ok_procedure_planned (probable_partial_traject_id);
