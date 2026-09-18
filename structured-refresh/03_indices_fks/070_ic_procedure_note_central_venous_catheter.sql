-- ic_procedure_note_central_venous_catheter: indices + FK constraints

CREATE INDEX IF NOT EXISTS idx_core_cvc_pseudo
  ON amc_core.ic_procedure_note_central_venous_catheter(pseudo_id);

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.ic_procedure_note_central_venous_catheter t
  WHERE (t.pseudo_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_not_traceable p
      WHERE (p.pseudo_id) = (t.pseudo_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.ic_procedure_note_central_venous_catheter
      ADD CONSTRAINT fk_cvc_patient
      FOREIGN KEY (pseudo_id)
      REFERENCES amc_core.patient_not_traceable(pseudo_id);
  ELSE
    RAISE WARNING 'fk_cvc_patient: % orphan row(s) in amc_core.ic_procedure_note_central_venous_catheter.pseudo_id not present in amc_core.patient_not_traceable.pseudo_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.ic_procedure_note_central_venous_catheter t
  WHERE (t.patient_contact_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_appointment p
      WHERE (p.patient_contact_id) = (t.patient_contact_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.ic_procedure_note_central_venous_catheter
      ADD CONSTRAINT fk_cvc_patient_contact
      FOREIGN KEY (patient_contact_id)
      REFERENCES amc_core.patient_appointment(patient_contact_id);
  ELSE
    RAISE WARNING 'fk_cvc_patient_contact: % orphan row(s) in amc_core.ic_procedure_note_central_venous_catheter.patient_contact_id not present in amc_core.patient_appointment.patient_contact_id — constraint skipped', orphans;
  END IF;
END $$;

