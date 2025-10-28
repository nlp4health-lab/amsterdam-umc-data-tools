-- =============================================================================
--  create_views.sql
--  Description:
--    Defines reusable SQL views built on top of the amc_notes table.
--    Each view represents a derived or summarized subset of the notes data.
-- =============================================================================

-- 1. View: v_last_note_per_patient
--    Purpose:
--      Returns the most recent note for each patient (subject_id),
--      based on date_note. If multiple notes share the same date,
--      the note with the highest note_id is selected.
-------------------------------

CREATE OR REPLACE VIEW v_last_note_per_patient AS
SELECT DISTINCT ON (subject_id)
    subject_id,
    note_id,
    date_note,
    note_type,
    author_note,
    note_text
FROM amc_notes
WHERE date_note IS NOT NULL
ORDER BY subject_id, date_note DESC, note_id DESC;

-------------------------------
-- Comments

COMMENT ON VIEW v_last_note_per_patient IS
'One note per patient: the most recent note (by date_note, then note_id if ties).';

-------------------------------
-- Validation: (run manually)
-- SELECT COUNT(DISTINCT subject_id) FROM amc_notes;
-- SELECT COUNT(*) FROM v_last_note_per_patient;
-- Both counts should match (excluding null dates).

--------------------------------------------------------------------------------

-- 2.