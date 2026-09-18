-- measurement_fluid_balance_stomach_retention: indices + FK constraints

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.measurement_fluid_balance_stomach_retention t
  WHERE (t.patient_contact_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_appointment p
      WHERE (p.patient_contact_id) = (t.patient_contact_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.measurement_fluid_balance_stomach_retention
      ADD CONSTRAINT fk_fluid_stomach_patient_contact
      FOREIGN KEY (patient_contact_id)
      REFERENCES amc_core.patient_appointment(patient_contact_id);
  ELSE
    RAISE WARNING 'fk_fluid_stomach_patient_contact: % orphan row(s) in amc_core.measurement_fluid_balance_stomach_retention.patient_contact_id not present in amc_core.patient_appointment.patient_contact_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.measurement_fluid_balance_stomach_retention t
  WHERE (t.pseudo_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_not_traceable p
      WHERE (p.pseudo_id) = (t.pseudo_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.measurement_fluid_balance_stomach_retention
      ADD CONSTRAINT fk_stomach_retention_patient
      FOREIGN KEY (pseudo_id)
      REFERENCES amc_core.patient_not_traceable(pseudo_id);
  ELSE
    RAISE WARNING 'fk_stomach_retention_patient: % orphan row(s) in amc_core.measurement_fluid_balance_stomach_retention.pseudo_id not present in amc_core.patient_not_traceable.pseudo_id — constraint skipped', orphans;
  END IF;
END $$;

