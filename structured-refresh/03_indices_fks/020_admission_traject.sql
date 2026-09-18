-- admission_traject: indices + FK constraints

CREATE INDEX IF NOT EXISTS idx_core_admtraj_admission_date
  ON amc_core.admission_traject(admission_date);

CREATE INDEX IF NOT EXISTS idx_core_admtraj_admission_moment
  ON amc_core.admission_traject(admission_moment);

CREATE INDEX IF NOT EXISTS idx_core_admtraj_discharge_date
  ON amc_core.admission_traject(discharge_date);

CREATE INDEX IF NOT EXISTS idx_core_admtraj_pseudo_date
  ON amc_core.admission_traject(pseudo_id, admission_date);

CREATE INDEX IF NOT EXISTS idx_core_admtraj_specialty
  ON amc_core.admission_traject(admission_specialty);

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.admission_traject t
  WHERE (t.pseudo_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_not_traceable p
      WHERE (p.pseudo_id) = (t.pseudo_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.admission_traject
      ADD CONSTRAINT fk_admission_traject_patient
      FOREIGN KEY (pseudo_id)
      REFERENCES amc_core.patient_not_traceable(pseudo_id);
  ELSE
    RAISE WARNING 'fk_admission_traject_patient: % orphan row(s) in amc_core.admission_traject.pseudo_id not present in amc_core.patient_not_traceable.pseudo_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.admission_traject t
  WHERE (t.patient_contact_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_appointment p
      WHERE (p.patient_contact_id) = (t.patient_contact_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.admission_traject
      ADD CONSTRAINT fk_admtraj_patient_contact
      FOREIGN KEY (patient_contact_id)
      REFERENCES amc_core.patient_appointment(patient_contact_id);
  ELSE
    RAISE WARNING 'fk_admtraj_patient_contact: % orphan row(s) in amc_core.admission_traject.patient_contact_id not present in amc_core.patient_appointment.patient_contact_id — constraint skipped', orphans;
  END IF;
END $$;

