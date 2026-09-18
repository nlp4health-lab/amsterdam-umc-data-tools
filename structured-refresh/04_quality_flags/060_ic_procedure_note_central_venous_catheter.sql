---------------------------------------------------------------------------------------------------------------
--end procedure issue (1 row)
ALTER TABLE amc_core.ic_procedure_note_central_venous_catheter
  ADD COLUMN IF NOT EXISTS end_procedure_quality_issue boolean DEFAULT false;

UPDATE amc_core.ic_procedure_note_central_venous_catheter
SET
  end_procedure_quality_issue =
    CASE
      WHEN end_procedure IS NOT NULL
       AND EXTRACT(YEAR FROM end_procedure) > 2025
      THEN true
      ELSE false
    END;
