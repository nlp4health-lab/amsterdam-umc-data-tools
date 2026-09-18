----------------------------------------------------------------------------------------------------------------
ALTER TABLE amc_core.medication_prescription
ADD COLUMN IF NOT EXISTS ongoing_medication boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS corrected_stop_date date,
ADD COLUMN IF NOT EXISTS corrected_stop_time time,
ADD COLUMN IF NOT EXISTS corrected_stop_date_time timestamptz;

UPDATE amc_core.medication_prescription
SET
    ongoing_medication = CASE
        WHEN EXTRACT(YEAR FROM stop_date) > 2026 THEN true
        ELSE false
    END,
    corrected_stop_date = CASE
        WHEN EXTRACT(YEAR FROM stop_date) > 2026 THEN NULL
        ELSE stop_date
    END,
    corrected_stop_time = CASE
        WHEN EXTRACT(YEAR FROM stop_date) > 2026 THEN NULL
        ELSE stop_time
    END,
    corrected_stop_date_time = CASE
        WHEN EXTRACT(YEAR FROM stop_date) > 2026 THEN NULL
        ELSE stop_date_time
    END;
