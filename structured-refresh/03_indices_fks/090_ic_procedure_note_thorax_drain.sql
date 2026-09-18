-- ic_procedure_note_thorax_drain: indices + FK constraints

CREATE INDEX IF NOT EXISTS idx_core_thorax_pseudo
  ON amc_core.ic_procedure_note_thorax_drain(pseudo_id);

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.ic_procedure_note_thorax_drain t
  WHERE (t.pseudo_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_not_traceable p
      WHERE (p.pseudo_id) = (t.pseudo_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.ic_procedure_note_thorax_drain
      ADD CONSTRAINT fk_thorax_drain_patient
      FOREIGN KEY (pseudo_id)
      REFERENCES amc_core.patient_not_traceable(pseudo_id);
  ELSE
    RAISE WARNING 'fk_thorax_drain_patient: % orphan row(s) in amc_core.ic_procedure_note_thorax_drain.pseudo_id not present in amc_core.patient_not_traceable.pseudo_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.ic_procedure_note_thorax_drain t
  WHERE (t.patient_contact_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_appointment p
      WHERE (p.patient_contact_id) = (t.patient_contact_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.ic_procedure_note_thorax_drain
      ADD CONSTRAINT fk_thoraxdrain_patient_contact
      FOREIGN KEY (patient_contact_id)
      REFERENCES amc_core.patient_appointment(patient_contact_id);
  ELSE
    RAISE WARNING 'fk_thoraxdrain_patient_contact: % orphan row(s) in amc_core.ic_procedure_note_thorax_drain.patient_contact_id not present in amc_core.patient_appointment.patient_contact_id — constraint skipped', orphans;
  END IF;
END $$;

