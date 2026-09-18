------------------------------------------------------------------------------------------------------------
-- amc_views.v_last_note_per_patient
-- Most recent clinical note per patient (by date_note, then patient_note_id
-- as a tiebreak). Migrated from the untracked, unfinished create_views.sql
-- draft -- rewritten against amc_notes' current column names (that draft
-- was written against an older amc_notes schema: subject_id/note_id/
-- note_type/author_note, since renamed to pseudo_id/patient_note_id/
-- patient_note_category/caregiver_type -- see amc_views.v_notes, which
-- already uses the current names).
------------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS amc_views.v_last_note_per_patient;

CREATE VIEW amc_views.v_last_note_per_patient AS
SELECT DISTINCT ON (pseudo_id)
    pseudo_id,
    patient_note_id,
    date_note,
    patient_note_category,
    caregiver_type,
    note_text
FROM amc_core.amc_notes
WHERE date_note IS NOT NULL
ORDER BY pseudo_id, date_note DESC, patient_note_id DESC;

COMMENT ON VIEW amc_views.v_last_note_per_patient IS
'One note per patient: the most recent note (by date_note, then patient_note_id if ties).';
