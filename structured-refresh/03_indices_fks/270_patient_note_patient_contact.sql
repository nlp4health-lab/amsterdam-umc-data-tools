-- patient_note_patient_contact: indices + FK constraints

CREATE INDEX IF NOT EXISTS idx_core_pnpc_category
  ON amc_core.patient_note_patient_contact(patient_note_category);

CREATE INDEX IF NOT EXISTS idx_core_pnpc_date
  ON amc_core.patient_note_patient_contact(note_made_on_date);

CREATE INDEX IF NOT EXISTS idx_core_pnpc_pseudo
  ON amc_core.patient_note_patient_contact(pseudo_id);

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.patient_note_patient_contact t
  WHERE (t.pseudo_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_not_traceable p
      WHERE (p.pseudo_id) = (t.pseudo_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.patient_note_patient_contact
      ADD CONSTRAINT fk_pnpc_patient
      FOREIGN KEY (pseudo_id)
      REFERENCES amc_core.patient_not_traceable(pseudo_id);
  ELSE
    RAISE WARNING 'fk_pnpc_patient: % orphan row(s) in amc_core.patient_note_patient_contact.pseudo_id not present in amc_core.patient_not_traceable.pseudo_id — constraint skipped', orphans;
  END IF;
END $$;

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.patient_note_patient_contact t
  WHERE (t.patient_contact_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_appointment p
      WHERE (p.patient_contact_id) = (t.patient_contact_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.patient_note_patient_contact
      ADD CONSTRAINT fk_pnpc_patient_contact
      FOREIGN KEY (patient_contact_id)
      REFERENCES amc_core.patient_appointment(patient_contact_id);
  ELSE
    RAISE WARNING 'fk_pnpc_patient_contact: % orphan row(s) in amc_core.patient_note_patient_contact.patient_contact_id not present in amc_core.patient_appointment.patient_contact_id — constraint skipped', orphans;
  END IF;
END $$;

