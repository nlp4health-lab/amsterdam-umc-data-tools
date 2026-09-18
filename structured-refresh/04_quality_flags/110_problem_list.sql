---------------------------------------------------------------------------------------------------------------
ALTER TABLE amc_core.problem_list
ADD COLUMN IF NOT EXISTS corrected_close_date date;

UPDATE amc_core.problem_list
SET corrected_close_date =
    CASE
        WHEN patient_problem_status = 'Actief' THEN NULL
        ELSE close_date
    END;
