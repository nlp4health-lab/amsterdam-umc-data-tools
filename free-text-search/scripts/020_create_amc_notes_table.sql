-- =============================================================================
--  020_create_amc_notes_table.sql
--  Table: amc_core.amc_notes
--  Description:
--    Cleaned and structured clinical notes parsed from carenlp-dfile raw files.
--    Each row corresponds to one note.
--
--  Reflects the table's current live schema (confirmed via \d+ against
--  carenlp_db, 2026-09-21) -- columns were renamed at some point after
--  the original notes-only build (subject_id -> patient_note_id,
--  note_id -> pseudo_id, note_type -> patient_note_category,
--  author_note -> caregiver_type) to match the rest of amc_core's naming
--  convention once the structured tables were added alongside the notes
--  pipeline. The old composite PRIMARY KEY (subject_id, note_id) and the
--  generated `uid` column are gone -- patient_note_id alone is now the
--  primary key.
-- =============================================================================

CREATE TABLE IF NOT EXISTS amc_core.amc_notes (
    patient_note_id        TEXT    NOT NULL PRIMARY KEY,
    pseudo_id               TEXT    NOT NULL,
    date_note                DATE,
    patient_note_category  TEXT,
    caregiver_type           TEXT,
    note_text                TEXT
);

--------------------------------------------------------------------------------
-- Comments

COMMENT ON TABLE amc_core.amc_notes IS 'Cleaned and structured clinical notes from carenlp-dfiles raw inputs.';
COMMENT ON COLUMN amc_core.amc_notes.patient_note_id IS 'Note identifier.';
COMMENT ON COLUMN amc_core.amc_notes.pseudo_id IS 'Patient identifier.';
COMMENT ON COLUMN amc_core.amc_notes.date_note IS 'Date extracted from timestamp.';
COMMENT ON COLUMN amc_core.amc_notes.patient_note_category IS 'Type of clinical note.';
COMMENT ON COLUMN amc_core.amc_notes.caregiver_type IS 'Note author department or person role (if available).';
COMMENT ON COLUMN amc_core.amc_notes.note_text IS 'Cleaned full text of the note.';

--------------------------------------------------------------------------------
-- Data copy

-- Example command to load data from a CSV produced by 010_extraction_and_cleaning.py:
-- \copy amc_core.amc_notes FROM '/path/to/processed/merged_part_1_01.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------------------------------
-- Indexes

CREATE INDEX IF NOT EXISTS idx_amc_notes_subject
  ON amc_core.amc_notes(pseudo_id);

CREATE INDEX IF NOT EXISTS idx_amc_notes_note_type
  ON amc_core.amc_notes(patient_note_category);

CREATE INDEX IF NOT EXISTS idx_amc_notes_date
  ON amc_core.amc_notes(date_note);

-- The full-text-search GIN index is created separately, after data is
-- loaded -- see 050_create_fts_index.sql.
