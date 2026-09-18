-- ecg_measurement (anchor: ecg_decrease_date_time)
-- Excludes rows already flagged as having an implausible (<2000) date --
-- abnormal_decrease_date_time is a boolean column (04_quality_flags), so
-- this checks NOT COALESCE(..., false), not the old "= 0" integer form.
-- Requires 04_quality_flags to have already run: reads
-- admission_partial_traject.corrected_end_date_time and the
-- abnormal_decrease_date_time boolean quality-flag column referenced
-- above, both added by that stage, not 02_core_clean.
ALTER TABLE amc_core.ecg_measurement
    ADD COLUMN IF NOT EXISTS probable_contact_id text,
    ADD COLUMN IF NOT EXISTS probable_partial_traject_id text;

UPDATE amc_core.ecg_measurement AS em
SET (probable_contact_id, probable_partial_traject_id) = (
    SELECT apt.patient_contact_id, apt.admission_partial_traject_id
    FROM amc_core.admission_partial_traject AS apt
    WHERE apt.pseudo_id = em.pseudo_id
      AND em.ecg_decrease_date_time >= apt.start_date_time
      AND (
            apt.corrected_end_date_time IS NULL
            OR em.ecg_decrease_date_time <= apt.corrected_end_date_time
          )
    ORDER BY apt.start_date_time DESC
    LIMIT 1
)
WHERE em.probable_contact_id IS NULL
  AND em.ecg_decrease_date_time IS NOT NULL
  AND NOT COALESCE(em.abnormal_decrease_date_time, false);

CREATE INDEX IF NOT EXISTS idx_ecg_measurement_probable_contact_id
    ON amc_core.ecg_measurement (probable_contact_id);
CREATE INDEX IF NOT EXISTS idx_ecg_measurement_probable_partial_traject_id
    ON amc_core.ecg_measurement (probable_partial_traject_id);
