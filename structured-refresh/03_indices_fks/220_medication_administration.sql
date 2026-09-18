-- medication_administration: indices + FK constraints

CREATE INDEX IF NOT EXISTS idx_core_med_admin_admtraj
  ON amc_core.medication_administration(admission_traject_id);

CREATE INDEX IF NOT EXISTS idx_core_med_admin_atc
  ON amc_core.medication_administration(atc_code);

CREATE INDEX IF NOT EXISTS idx_core_med_admin_date
  ON amc_core.medication_administration(administration_date);

CREATE INDEX IF NOT EXISTS idx_core_med_admin_pseudo
  ON amc_core.medication_administration(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_med_admin_rule_id
  ON amc_core.medication_administration(rule_id);

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.medication_administration t
  WHERE (t.admission_traject_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.admission_traject p
      WHERE (p.admission_traject_id) = (t.admission_traject_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.medication_administration
      ADD CONSTRAINT fk_medadmin_admtraj
      FOREIGN KEY (admission_traject_id)
      REFERENCES amc_core.admission_traject(admission_traject_id);
  ELSE
    RAISE WARNING 'fk_medadmin_admtraj: % orphan row(s) in amc_core.medication_administration.admission_traject_id not present in amc_core.admission_traject.admission_traject_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.medication_administration t
  WHERE (t.atc_code) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.medication_atc p
      WHERE (p.atc_code) = (t.atc_code)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.medication_administration
      ADD CONSTRAINT fk_medadmin_atc
      FOREIGN KEY (atc_code)
      REFERENCES amc_core.medication_atc(atc_code);
  ELSE
    RAISE WARNING 'fk_medadmin_atc: % orphan row(s) in amc_core.medication_administration.atc_code not present in amc_core.medication_atc.atc_code — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.medication_administration t
  WHERE (t.patient_contact_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_appointment p
      WHERE (p.patient_contact_id) = (t.patient_contact_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.medication_administration
      ADD CONSTRAINT fk_medadmin_patient_contact
      FOREIGN KEY (patient_contact_id)
      REFERENCES amc_core.patient_appointment(patient_contact_id);
  ELSE
    RAISE WARNING 'fk_medadmin_patient_contact: % orphan row(s) in amc_core.medication_administration.patient_contact_id not present in amc_core.patient_appointment.patient_contact_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.medication_administration t
  WHERE (t.rule_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.medication_prescription p
      WHERE (p.rule_id) = (t.rule_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.medication_administration
      ADD CONSTRAINT fk_medadmin_rule
      FOREIGN KEY (rule_id)
      REFERENCES amc_core.medication_prescription(rule_id);
  ELSE
    RAISE WARNING 'fk_medadmin_rule: % orphan row(s) in amc_core.medication_administration.rule_id not present in amc_core.medication_prescription.rule_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.medication_administration t
  WHERE (t.pseudo_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_not_traceable p
      WHERE (p.pseudo_id) = (t.pseudo_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.medication_administration
      ADD CONSTRAINT fk_medication_administration_patient
      FOREIGN KEY (pseudo_id)
      REFERENCES amc_core.patient_not_traceable(pseudo_id);
  ELSE
    RAISE WARNING 'fk_medication_administration_patient: % orphan row(s) in amc_core.medication_administration.pseudo_id not present in amc_core.patient_not_traceable.pseudo_id — constraint skipped', orphans;
  END IF;
END $$;

