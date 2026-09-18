----------------------------------------------------------------------------------------------------------------
--abnormal patient contact date. This is a flag to identify patient contacts with an abnormal date. It is defined as a contact with a patient_contact_date that is either before 2000 or after 2027, which are considered implausible years for patient contacts in the dataset.
ALTER TABLE amc_core.patient_contact
ADD COLUMN IF NOT EXISTS abnormal_date boolean DEFAULT false;

UPDATE amc_core.patient_contact
SET abnormal_date =
    CASE
        WHEN patient_contact_date IS NOT NULL
         AND (
              EXTRACT(YEAR FROM patient_contact_date) < 2000
              OR EXTRACT(YEAR FROM patient_contact_date) > 2027
         )
        THEN true
        ELSE false
    END;
