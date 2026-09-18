-- patient_contact: indices + FK constraints

CREATE INDEX IF NOT EXISTS idx_core_pcontact_date
  ON amc_core.patient_contact(patient_contact_date);

CREATE INDEX IF NOT EXISTS idx_core_pcontact_specialty
  ON amc_core.patient_contact(specialty);

CREATE INDEX IF NOT EXISTS idx_core_pcontact_type
  ON amc_core.patient_contact(patient_contact_type);

DO $$
DECLARE
  orphans bigint;
BEGIN
  SELECT count(*) INTO orphans
  FROM amc_core.patient_contact t
  WHERE (t.pseudo_id) IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM amc_core.patient_not_traceable p
      WHERE (p.pseudo_id) = (t.pseudo_id)
    );

  IF orphans = 0 THEN
    ALTER TABLE amc_core.patient_contact
      ADD CONSTRAINT fk_patient_contact_patient
      FOREIGN KEY (pseudo_id)
      REFERENCES amc_core.patient_not_traceable(pseudo_id);
  ELSE
    RAISE WARNING 'fk_patient_contact_patient: % orphan row(s) in amc_core.patient_contact.pseudo_id not present in amc_core.patient_not_traceable.pseudo_id — constraint skipped', orphans;
  END IF;
END $$;

