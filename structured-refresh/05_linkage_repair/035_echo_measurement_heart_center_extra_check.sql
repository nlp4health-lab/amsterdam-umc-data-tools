-- echo_measurement_heart_center_extra_check (anchor: examination_date)
-- Ported from the retired echo_measurement_heart's own linkage-repair logic
-- (archive/030_echo_measurement_heart_linkage.sql) when that table was
-- retired in favor of this one (2026-09-11 extract). Logic is unchanged;
-- only the table name differs -- every column referenced here (pseudo_id,
-- examination_date, examination_date_quality_issue) exists on this table
-- under the same name.
--
-- examination_date_quality_issue is a boolean column (04_quality_flags),
-- so this checks NOT COALESCE(..., false), not the old "= 0" integer form.
-- Requires 04_quality_flags to have already run: reads
-- admission_partial_traject.corrected_end_date_time and the
-- examination_date_quality_issue boolean quality-flag column above, both
-- added by that stage, not 02_core_clean.
ALTER TABLE amc_core.echo_measurement_heart_center_extra_check
    ADD COLUMN IF NOT EXISTS probable_contact_id text,
    ADD COLUMN IF NOT EXISTS probable_partial_traject_id text;

UPDATE amc_core.echo_measurement_heart_center_extra_check AS eh
SET (probable_contact_id, probable_partial_traject_id) = (
    SELECT apt.patient_contact_id, apt.admission_partial_traject_id
    FROM amc_core.admission_partial_traject AS apt
    WHERE apt.pseudo_id = eh.pseudo_id
      -- NOTE: examination_date is a `date` column (no time-of-day), so it's
      -- implicitly promoted to local midnight for this comparison. An echo
      -- performed later the same day a patient was admitted can therefore
      -- fail the >= start_date_time check and be attributed to an earlier
      -- stay segment (or left unmatched) instead of the correct one. This
      -- is inherited from the original script, not a regression -- flagged
      -- here as a known limitation, not something to silently fix.
      AND eh.examination_date >= apt.start_date_time
      AND (
            apt.corrected_end_date_time IS NULL
            OR eh.examination_date <= apt.corrected_end_date_time
          )
    ORDER BY apt.start_date_time DESC
    LIMIT 1
)
WHERE eh.probable_contact_id IS NULL
  AND eh.examination_date IS NOT NULL
  AND NOT COALESCE(eh.examination_date_quality_issue, false);

CREATE INDEX IF NOT EXISTS idx_echo_measurement_heart_extra_probable_contact_id
    ON amc_core.echo_measurement_heart_center_extra_check (probable_contact_id);
CREATE INDEX IF NOT EXISTS idx_echo_measurement_heart_extra_probable_partial_traject_id
    ON amc_core.echo_measurement_heart_center_extra_check (probable_partial_traject_id);
