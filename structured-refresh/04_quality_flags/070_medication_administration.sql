---------------------------------------------------------------------------------------------------------------
--medication ongoing administration. This is a flag to identify medication administrations that are ongoing at the moment of data extraction, which can be relevant for quality checks and analyses. It is defined as a medication administration with a corrected administration date in the future (after the data extraction date).

ALTER TABLE amc_core.medication_administration
  ADD COLUMN IF NOT EXISTS corrected_administration_date date,
  ADD COLUMN IF NOT EXISTS corrected_administration_date_time timestamptz,
  ADD COLUMN IF NOT EXISTS ongoing_medication_administration boolean DEFAULT false;

UPDATE amc_core.medication_administration
SET
  corrected_administration_date =
    CASE
      WHEN administration_date IS NOT NULL
       AND EXTRACT(YEAR FROM administration_date) <= 2025
      THEN administration_date
      ELSE NULL
    END,

  corrected_administration_date_time =
    CASE
      WHEN administration_date_time IS NOT NULL
       AND EXTRACT(YEAR FROM administration_date_time) <= 2025
      THEN administration_date_time
      ELSE NULL
    END,

  ongoing_medication_administration =
    CASE
      WHEN administration_date IS NOT NULL
       AND EXTRACT(YEAR FROM administration_date) > 2025
      THEN true
      ELSE false
    END;
