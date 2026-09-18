-- lab_result: indices + FK constraints

CREATE INDEX IF NOT EXISTS idx_core_lab_code_date
  ON amc_core.lab_result(determination_code, result_date);

CREATE INDEX IF NOT EXISTS idx_core_lab_determination_code
  ON amc_core.lab_result(determination_code);

CREATE INDEX IF NOT EXISTS idx_core_lab_pseudo_code_date
  ON amc_core.lab_result(pseudo_id, determination_code, result_date);

CREATE INDEX IF NOT EXISTS idx_core_lab_result_date
  ON amc_core.lab_result(result_date);

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.lab_result t
  WHERE (t.pseudo_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_not_traceable p
      WHERE (p.pseudo_id) = (t.pseudo_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.lab_result
      ADD CONSTRAINT fk_lab_result_patient
      FOREIGN KEY (pseudo_id)
      REFERENCES amc_core.patient_not_traceable(pseudo_id);
  ELSE
    RAISE WARNING 'fk_lab_result_patient: % orphan row(s) in amc_core.lab_result.pseudo_id not present in amc_core.patient_not_traceable.pseudo_id — constraint skipped', orphans;
  END IF;
END $$;

