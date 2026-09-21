-- =============================================================================
--  040_create_amc_notes_metadata_table.sql
--  Table: amc_core.amc_notes_metadata
--  Description:
--    Metadata extracted from cleaned clinical notes (character, word, token counts,
--    and original source file location). Each row corresponds to one note.
--
--  Reflects the table's current live schema (confirmed via \d+ against
--  carenlp_db, 2026-09-21) -- unlike amc_notes, this table's columns
--  (note_id, subject_id, note_type) were never renamed, even though
--  030_metadata_extraction.py's input now comes from amc_notes's renamed
--  columns (patient_note_id, pseudo_id, patient_note_category).
-- =============================================================================

CREATE TABLE IF NOT EXISTS amc_core.amc_notes_metadata (
    note_id         TEXT        NOT NULL PRIMARY KEY,
    subject_id      TEXT        NOT NULL,
    note_type       TEXT,
    char_length     INTEGER,
    word_length     INTEGER,
    token_length    INTEGER,
    source_file     TEXT
);

--------------------------------------------------------------------------------
-- Comments

COMMENT ON TABLE amc_core.amc_notes_metadata IS 'Metadata for clinical notes including lengths and original file source.';
COMMENT ON COLUMN amc_core.amc_notes_metadata.note_id IS 'Note identifier (matches amc_notes.patient_note_id).';
COMMENT ON COLUMN amc_core.amc_notes_metadata.subject_id IS 'Patient identifier linked to the note.';
COMMENT ON COLUMN amc_core.amc_notes_metadata.note_type IS 'Type/category of clinical note.';
COMMENT ON COLUMN amc_core.amc_notes_metadata.char_length IS 'Number of characters in cleaned note text.';
COMMENT ON COLUMN amc_core.amc_notes_metadata.word_length IS 'Number of whitespace-separated words in note text.';
COMMENT ON COLUMN amc_core.amc_notes_metadata.token_length IS 'Number of tokens after model tokenizer encoding (o200k_base).';
COMMENT ON COLUMN amc_core.amc_notes_metadata.source_file IS 'Raw filename where the note was originally extracted from.';

--------------------------------------------------------------------------------
-- Data copy

-- Example command to load data from a CSV produced by 030_metadata_extraction.py:
-- \copy amc_core.amc_notes_metadata FROM '/path/to/metadata/metadata_merged_part_1_01.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------------------------------
-- Constraints

-- Cross-referencing differently-named columns is fine in Postgres: this
-- table's note_id maps to amc_notes's patient_note_id (its current name).
ALTER TABLE amc_core.amc_notes_metadata
   ADD CONSTRAINT fk_metadata_note
   FOREIGN KEY (note_id)
   REFERENCES amc_core.amc_notes(patient_note_id);

--------------------------------------------------------------------------------
-- Indexes

CREATE INDEX IF NOT EXISTS idx_amc_metadata_subject
  ON amc_core.amc_notes_metadata(subject_id);

CREATE INDEX IF NOT EXISTS idx_amc_metadata_note_type
  ON amc_core.amc_notes_metadata(note_type);
