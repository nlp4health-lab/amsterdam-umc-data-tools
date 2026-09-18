-- ecg_measurement_test_feature: indices + FK constraints

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.ecg_measurement_test_feature t
  WHERE (t.pseudo_id, t.ecg_measurement_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.ecg_measurement p
      WHERE (p.pseudo_id, p.ecg_measurement_id) = (t.pseudo_id, t.ecg_measurement_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.ecg_measurement_test_feature
      ADD CONSTRAINT fk_ecg_feature_ecg_measurement
      FOREIGN KEY (pseudo_id, ecg_measurement_id)
      REFERENCES amc_core.ecg_measurement(pseudo_id, ecg_measurement_id);
  ELSE
    RAISE WARNING 'fk_ecg_feature_ecg_measurement: % orphan row(s) in amc_core.ecg_measurement_test_feature.pseudo_id, ecg_measurement_id not present in amc_core.ecg_measurement.pseudo_id, ecg_measurement_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.ecg_measurement_test_feature t
  WHERE (t.pseudo_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_not_traceable p
      WHERE (p.pseudo_id) = (t.pseudo_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.ecg_measurement_test_feature
      ADD CONSTRAINT fk_ecg_feature_patient
      FOREIGN KEY (pseudo_id)
      REFERENCES amc_core.patient_not_traceable(pseudo_id);
  ELSE
    RAISE WARNING 'fk_ecg_feature_patient: % orphan row(s) in amc_core.ecg_measurement_test_feature.pseudo_id not present in amc_core.patient_not_traceable.pseudo_id — constraint skipped', orphans;
  END IF;
END $$;

