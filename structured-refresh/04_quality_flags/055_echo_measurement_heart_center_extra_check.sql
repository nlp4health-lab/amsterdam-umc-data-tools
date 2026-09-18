----------------------------------------------------------------------------------------------------------------
---echo measurement heart (center extra check) examination date quality issue. Same flag echo_measurement_heart
---itself used to carry, ported here when echo_measurement_heart was retired in favor of this table (2026-09-11
---extract: echo_measurement_heart's CSV is gone from the source, echo_measurement_heart_center_extra_check is
---now the sole echo-heart table). It is defined as an echo measurement with an examination date in the year
---1991, which is considered an implausible year for echo measurements in the dataset.
--
-- Numbered 055 (between the retired 050 slot and 060) specifically so this
-- runs BEFORE 130_patient_not_traceable.sql, which reads this column.
ALTER TABLE amc_core.echo_measurement_heart_center_extra_check
  ADD COLUMN IF NOT EXISTS examination_date_quality_issue boolean DEFAULT false;

UPDATE amc_core.echo_measurement_heart_center_extra_check
SET
  examination_date_quality_issue =
    CASE
      WHEN examination_date IS NOT NULL
       AND EXTRACT(YEAR FROM examination_date) = 1991
      THEN true
      ELSE false
    END;
