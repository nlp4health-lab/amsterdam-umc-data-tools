---------------------------------------------------------------------------------------------------------------------
--ongoing seh stay. This is a flag to identify seh stays that are ongoing at the moment of data extraction. It is defined as a stay with a corrected departure date in the future (after the data extraction date).
ALTER TABLE amc_core.seh_trajectory
  ADD COLUMN IF NOT EXISTS corrected_seh_departure_date_time timestamptz,
  ADD COLUMN IF NOT EXISTS corrected_seh_departure_date date,
  ADD COLUMN IF NOT EXISTS corrected_seh_departure_moment time,
  ADD COLUMN IF NOT EXISTS ongoing_seh_stay boolean DEFAULT false;

UPDATE amc_core.seh_trajectory
SET
  corrected_seh_departure_date_time =
    CASE
      WHEN seh_departure_date_time IS NOT NULL
       AND EXTRACT(YEAR FROM seh_departure_date_time) <= 2025
      THEN seh_departure_date_time
      ELSE NULL
    END,

  corrected_seh_departure_date =
    CASE
      WHEN seh_departure_date IS NOT NULL
       AND EXTRACT(YEAR FROM seh_departure_date) <= 2025
      THEN seh_departure_date
      ELSE NULL
    END,

  corrected_seh_departure_moment =
    CASE
      WHEN seh_departure_date IS NOT NULL
       AND EXTRACT(YEAR FROM seh_departure_date) <= 2025
      THEN seh_departure_moment
      ELSE NULL
    END,

  ongoing_seh_stay =
    CASE
      WHEN seh_departure_date IS NOT NULL
       AND EXTRACT(YEAR FROM seh_departure_date) > 2025
      THEN true
      ELSE false
    END;
