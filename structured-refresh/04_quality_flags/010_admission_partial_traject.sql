------------------------------------------------------------------------------------------------------------
--ongoing partial admission stay. This is a flag to identify partial stays that are ongoing at the moment of data extraction, which can be relevant for quality checks and analyses. It is defined as a partial stay with a corrected end date in the future (after the data extraction date).

ALTER TABLE amc_core.admission_partial_traject
  ADD COLUMN IF NOT EXISTS corrected_end_date_time timestamptz,
  ADD COLUMN IF NOT EXISTS corrected_end_date date,
  ADD COLUMN IF NOT EXISTS corrected_end_time time,
  ADD COLUMN IF NOT EXISTS ongoing_partial_stay boolean DEFAULT false;

UPDATE amc_core.admission_partial_traject
SET
  corrected_end_date_time =
    CASE
      WHEN end_date_time IS NOT NULL
       AND EXTRACT(YEAR FROM end_date_time) <= 2025
      THEN end_date_time
      ELSE NULL
    END,

  corrected_end_date =
    CASE
      WHEN end_date IS NOT NULL
       AND EXTRACT(YEAR FROM end_date) <= 2025
      THEN end_date
      ELSE NULL
    END,

  corrected_end_time =
    CASE
      WHEN end_date IS NOT NULL
       AND EXTRACT(YEAR FROM end_date) <= 2025
      THEN end_time
      ELSE NULL
    END,

  ongoing_partial_stay =
    CASE
      WHEN end_date IS NOT NULL
       AND EXTRACT(YEAR FROM end_date) > 2025
      THEN true
      ELSE false
    END;

---------------------------------------------------------------------------------------------------------------
--ongoing admission stay (from the admission_partial_traject side). This is a flag to identify partial stays whose parent admission_traject discharge date is in the future (after the data extraction date).

ALTER TABLE amc_core.admission_partial_traject
  ADD COLUMN IF NOT EXISTS corrected_admission_traject_discharge_date_time timestamptz,
  ADD COLUMN IF NOT EXISTS corrected_admission_traject_discharge_date date,
  ADD COLUMN IF NOT EXISTS ongoing_admission_traject boolean DEFAULT false;

UPDATE amc_core.admission_partial_traject
SET
  corrected_admission_traject_discharge_date_time =
    CASE
      WHEN admission_traject_discharge_date_time IS NOT NULL
       AND EXTRACT(YEAR FROM admission_traject_discharge_date_time) <= 2025
      THEN admission_traject_discharge_date_time
      ELSE NULL
    END,

  corrected_admission_traject_discharge_date =
    CASE
      WHEN admission_traject_discharge_date IS NOT NULL
       AND EXTRACT(YEAR FROM admission_traject_discharge_date) <= 2025
      THEN admission_traject_discharge_date
      ELSE NULL
    END,

  ongoing_admission_traject =
    CASE
      WHEN admission_traject_discharge_date IS NOT NULL
       AND EXTRACT(YEAR FROM admission_traject_discharge_date) > 2025
      THEN true
      ELSE false
    END;
