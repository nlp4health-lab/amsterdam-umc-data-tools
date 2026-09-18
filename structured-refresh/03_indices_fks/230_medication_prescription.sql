-- medication_prescription: indices + FK constraints

CREATE INDEX IF NOT EXISTS idx_core_med_presc_atc
  ON amc_core.medication_prescription(atc_code);

CREATE INDEX IF NOT EXISTS idx_core_med_presc_pseudo
  ON amc_core.medication_prescription(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_core_med_presc_pseudo_atc
  ON amc_core.medication_prescription(pseudo_id, atc_code);

CREATE INDEX IF NOT EXISTS idx_core_med_presc_start_date
  ON amc_core.medication_prescription(start_date);

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.medication_prescription t
  WHERE (t.pseudo_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_not_traceable p
      WHERE (p.pseudo_id) = (t.pseudo_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.medication_prescription
      ADD CONSTRAINT fk_medication_prescription_patient
      FOREIGN KEY (pseudo_id)
      REFERENCES amc_core.patient_not_traceable(pseudo_id);
  ELSE
    RAISE WARNING 'fk_medication_prescription_patient: % orphan row(s) in amc_core.medication_prescription.pseudo_id not present in amc_core.patient_not_traceable.pseudo_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.medication_prescription t
  WHERE (t.previous_prescription_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.medication_prescription p
      WHERE (p.rule_id) = (t.previous_prescription_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.medication_prescription
      ADD CONSTRAINT fk_medication_prescription_previous
      FOREIGN KEY (previous_prescription_id)
      REFERENCES amc_core.medication_prescription(rule_id);
  ELSE
    RAISE WARNING 'fk_medication_prescription_previous: % orphan row(s) in amc_core.medication_prescription.previous_prescription_id not present in amc_core.medication_prescription.rule_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.medication_prescription t
  WHERE (t.atc_code) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.medication_atc p
      WHERE (p.atc_code) = (t.atc_code)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.medication_prescription
      ADD CONSTRAINT fk_medrx_atc
      FOREIGN KEY (atc_code)
      REFERENCES amc_core.medication_atc(atc_code);
  ELSE
    RAISE WARNING 'fk_medrx_atc: % orphan row(s) in amc_core.medication_prescription.atc_code not present in amc_core.medication_atc.atc_code — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.medication_prescription t
  WHERE (t.patient_contact_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_appointment p
      WHERE (p.patient_contact_id) = (t.patient_contact_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.medication_prescription
      ADD CONSTRAINT fk_medrx_patient_contact
      FOREIGN KEY (patient_contact_id)
      REFERENCES amc_core.patient_appointment(patient_contact_id);
  ELSE
    RAISE WARNING 'fk_medrx_patient_contact: % orphan row(s) in amc_core.medication_prescription.patient_contact_id not present in amc_core.patient_appointment.patient_contact_id — constraint skipped', orphans;
  END IF;
END $$;

