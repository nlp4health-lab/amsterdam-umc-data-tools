---------------------------------------------------------------------------------------------------------------
--ongoing admission stay. This is a flag to identify stays that are ongoing at the moment of data extraction, which can be relevant for quality checks and analyses. It is defined as a stay with a corrected discharge date in the future (after the data extraction date).

ALTER TABLE amc_core.admission_traject
  ADD COLUMN IF NOT EXISTS corrected_discharge_moment timestamptz,
  ADD COLUMN IF NOT EXISTS corrected_discharge_date date,
  ADD COLUMN IF NOT EXISTS ongoing_stay boolean DEFAULT false;

UPDATE amc_core.admission_traject
SET
  corrected_discharge_moment =
    CASE
      WHEN discharge_moment IS NOT NULL
       AND EXTRACT(YEAR FROM discharge_moment) <= 2025
      THEN discharge_moment
      ELSE NULL
    END,

  corrected_discharge_date =
    CASE
      WHEN discharge_date IS NOT NULL
       AND EXTRACT(YEAR FROM discharge_date) <= 2025
      THEN discharge_date
      ELSE NULL
    END,

  ongoing_stay =
    CASE
      WHEN discharge_date IS NOT NULL
       AND EXTRACT(YEAR FROM discharge_date) > 2025
      THEN true
      ELSE false
    END;
