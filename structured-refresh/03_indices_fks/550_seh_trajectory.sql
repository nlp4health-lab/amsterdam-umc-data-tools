-- seh_trajectory: indices + FK constraints

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.seh_trajectory t
  WHERE (t.admission_traject_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.admission_traject p
      WHERE (p.admission_traject_id) = (t.admission_traject_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.seh_trajectory
      ADD CONSTRAINT fk_seh_admtraj
      FOREIGN KEY (admission_traject_id)
      REFERENCES amc_core.admission_traject(admission_traject_id);
  ELSE
    RAISE WARNING 'fk_seh_admtraj: % orphan row(s) in amc_core.seh_trajectory.admission_traject_id not present in amc_core.admission_traject.admission_traject_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.seh_trajectory t
  WHERE (t.patient_contact_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_appointment p
      WHERE (p.patient_contact_id) = (t.patient_contact_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.seh_trajectory
      ADD CONSTRAINT fk_seh_patient_contact
      FOREIGN KEY (patient_contact_id)
      REFERENCES amc_core.patient_appointment(patient_contact_id);
  ELSE
    RAISE WARNING 'fk_seh_patient_contact: % orphan row(s) in amc_core.seh_trajectory.patient_contact_id not present in amc_core.patient_appointment.patient_contact_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.seh_trajectory t
  WHERE (t.pseudo_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_not_traceable p
      WHERE (p.pseudo_id) = (t.pseudo_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.seh_trajectory
      ADD CONSTRAINT fk_seh_trajectory_patient
      FOREIGN KEY (pseudo_id)
      REFERENCES amc_core.patient_not_traceable(pseudo_id);
  ELSE
    RAISE WARNING 'fk_seh_trajectory_patient: % orphan row(s) in amc_core.seh_trajectory.pseudo_id not present in amc_core.patient_not_traceable.pseudo_id — constraint skipped', orphans;
  END IF;
END $$;

