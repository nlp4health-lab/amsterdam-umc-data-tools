-- admission_partial_traject: indices + FK constraints

CREATE INDEX IF NOT EXISTS idx_core_admpart_start_date
  ON amc_core.admission_partial_traject(start_date);

CREATE INDEX IF NOT EXISTS idx_core_admpart_start_datetime
  ON amc_core.admission_partial_traject(start_date_time);

CREATE INDEX IF NOT EXISTS idx_core_admpart_traj_date
  ON amc_core.admission_partial_traject(admission_traject_id, start_date);

CREATE INDEX IF NOT EXISTS idx_core_admpart_workplace
  ON amc_core.admission_partial_traject(workplace);

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.admission_partial_traject t
  WHERE (t.pseudo_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_not_traceable p
      WHERE (p.pseudo_id) = (t.pseudo_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.admission_partial_traject
      ADD CONSTRAINT fk_admission_partial_traject_patient
      FOREIGN KEY (pseudo_id)
      REFERENCES amc_core.patient_not_traceable(pseudo_id);
  ELSE
    RAISE WARNING 'fk_admission_partial_traject_patient: % orphan row(s) in amc_core.admission_partial_traject.pseudo_id not present in amc_core.patient_not_traceable.pseudo_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.admission_partial_traject t
  WHERE (t.admission_traject_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.admission_traject p
      WHERE (p.admission_traject_id) = (t.admission_traject_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.admission_partial_traject
      ADD CONSTRAINT fk_admparttraj_admtraj
      FOREIGN KEY (admission_traject_id)
      REFERENCES amc_core.admission_traject(admission_traject_id);
  ELSE
    RAISE WARNING 'fk_admparttraj_admtraj: % orphan row(s) in amc_core.admission_partial_traject.admission_traject_id not present in amc_core.admission_traject.admission_traject_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.admission_partial_traject t
  WHERE (t.patient_contact_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_appointment p
      WHERE (p.patient_contact_id) = (t.patient_contact_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.admission_partial_traject
      ADD CONSTRAINT fk_admparttraj_patient_contact
      FOREIGN KEY (patient_contact_id)
      REFERENCES amc_core.patient_appointment(patient_contact_id);
  ELSE
    RAISE WARNING 'fk_admparttraj_patient_contact: % orphan row(s) in amc_core.admission_partial_traject.patient_contact_id not present in amc_core.patient_appointment.patient_contact_id — constraint skipped', orphans;
  END IF;
END $$;

