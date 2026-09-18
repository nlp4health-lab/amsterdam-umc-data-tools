-- echo_measurement_heart_center_extra_check: indices + FK constraints

CREATE INDEX IF NOT EXISTS idx_core_echo_heart_extra_date
  ON amc_core.echo_measurement_heart_center_extra_check(examination_date);

CREATE INDEX IF NOT EXISTS idx_core_echo_heart_extra_type
  ON amc_core.echo_measurement_heart_center_extra_check(examination_type);

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.echo_measurement_heart_center_extra_check t
  WHERE (t.pseudo_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_not_traceable p
      WHERE (p.pseudo_id) = (t.pseudo_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.echo_measurement_heart_center_extra_check
      ADD CONSTRAINT fk_echo_measurement_heart_extra_patient
      FOREIGN KEY (pseudo_id)
      REFERENCES amc_core.patient_not_traceable(pseudo_id);
  ELSE
    RAISE WARNING 'fk_echo_measurement_heart_extra_patient: % orphan row(s) in amc_core.echo_measurement_heart_center_extra_check.pseudo_id not present in amc_core.patient_not_traceable.pseudo_id — constraint skipped', orphans;
  END IF;
END $$;
