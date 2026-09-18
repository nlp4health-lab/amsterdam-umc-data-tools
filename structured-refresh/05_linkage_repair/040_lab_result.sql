-- lab_result (anchor: result_date_time, fallback: material_decrease_date_time)
-- Set-based approach: lab_result is the highest-volume table in this stage
-- (~168M rows), so this computes matches as ONE join (hash/merge, via
-- lab_result_id -- its bigserial PRIMARY KEY) into a staging table, then
-- applies them with a single indexed-PK UPDATE, instead of a per-row
-- correlated subquery like the other 4 files in this stage.
-- Requires 04_quality_flags to have already run: reads
-- admission_partial_traject.corrected_end_date_time, added by that
-- stage, not 02_core_clean.
ALTER TABLE amc_core.lab_result
    ADD COLUMN IF NOT EXISTS probable_contact_id text,
    ADD COLUMN IF NOT EXISTS probable_partial_traject_id text;

ANALYZE amc_core.lab_result;
ANALYZE amc_core.admission_partial_traject;

DROP TABLE IF EXISTS staging_lab_result_contact_match;

CREATE TABLE staging_lab_result_contact_match AS
SELECT DISTINCT ON (lr.lab_result_id)
    lr.lab_result_id,
    apt.patient_contact_id,
    apt.admission_partial_traject_id
FROM amc_core.lab_result lr
JOIN amc_core.admission_partial_traject apt
    ON apt.pseudo_id = lr.pseudo_id
   AND COALESCE(lr.result_date_time, lr.material_decrease_date_time) >= apt.start_date_time
   AND (
         apt.corrected_end_date_time IS NULL
         OR COALESCE(lr.result_date_time, lr.material_decrease_date_time) <= apt.corrected_end_date_time
       )
WHERE lr.probable_contact_id IS NULL
  AND COALESCE(lr.result_date_time, lr.material_decrease_date_time) IS NOT NULL
ORDER BY lr.lab_result_id, apt.start_date_time DESC;

CREATE UNIQUE INDEX ON staging_lab_result_contact_match (lab_result_id);

UPDATE amc_core.lab_result lr
SET probable_contact_id = s.patient_contact_id,
    probable_partial_traject_id = s.admission_partial_traject_id
FROM staging_lab_result_contact_match s
WHERE s.lab_result_id = lr.lab_result_id;

DROP TABLE staging_lab_result_contact_match;

CREATE INDEX IF NOT EXISTS idx_lab_result_probable_contact_id
    ON amc_core.lab_result (probable_contact_id);
CREATE INDEX IF NOT EXISTS idx_lab_result_probable_partial_traject_id
    ON amc_core.lab_result (probable_partial_traject_id);
