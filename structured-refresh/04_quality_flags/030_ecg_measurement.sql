----------------------------------------------------------------------------------------------------------------
---ecg measurement abnormal decrease date time. This is a flag to identify ECG measurements with an abnormal decrease date time. It is defined as an ECG measurement with a decrease date time that is before the year 2000, which is considered an implausible year for ECG measurements in the dataset.
ALTER TABLE amc_core.ecg_measurement
  ADD COLUMN IF NOT EXISTS abnormal_decrease_date_time boolean DEFAULT false;

UPDATE amc_core.ecg_measurement
SET
  abnormal_decrease_date_time =
    CASE
      WHEN ecg_decrease_date_time IS NOT NULL
       AND EXTRACT(YEAR FROM ecg_decrease_date_time) < 2000
      THEN true
      ELSE false
    END;
