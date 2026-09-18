----------------------------------------------------------------------------------------------------------------
---ecg measurement test feature abnormal date flag. This is a flag to identify ECG measurement test features with an abnormal date. It is defined as an ECG measurement test feature with a change date time or decrease date time that is before the year 2000, which is considered an implausible year for ECG measurements in the dataset.
ALTER TABLE amc_core.ecg_measurement_test_feature
  ADD COLUMN IF NOT EXISTS abnormal_date_flag boolean DEFAULT false;

UPDATE amc_core.ecg_measurement_test_feature
SET
  abnormal_date_flag =
    CASE
      WHEN (
        ecg_change_date_time IS NOT NULL
        AND EXTRACT(YEAR FROM ecg_change_date_time) < 2000
      )
      OR (
        ecg_decrease_date_time IS NOT NULL
        AND EXTRACT(YEAR FROM ecg_decrease_date_time) < 2000
      )
      THEN true
      ELSE false
    END;
