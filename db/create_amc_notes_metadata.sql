-- =============================================================================
--  create_amc_notes_metadata.sql
--  Table: amc_notes_metadata
--  Description:
--    Metadata extracted from cleaned clinical notes (character, word, token counts,
--    and original source file location). Each row corresponds to one note.
-- =============================================================================

CREATE TABLE IF NOT EXISTS amc_notes_metadata (
    note_id         TEXT        PRIMARY KEY,
    subject_id      TEXT        NOT NULL,
    note_type       TEXT,
    char_length     INTEGER,
    word_length     INTEGER,
    token_length    INTEGER,
    source_file     TEXT
);

--------------------------------------------------------------------------------
-- Comments

COMMENT ON TABLE amc_notes_metadata IS 'Metadata for clinical notes including lengths and original file source.';
COMMENT ON COLUMN amc_notes_metadata.note_id IS 'Unique note identifier (matches note_id in amc_notes).';
COMMENT ON COLUMN amc_notes_metadata.subject_id IS 'Patient identifier linked to the note.';
COMMENT ON COLUMN amc_notes_metadata.note_type IS 'Type/category of clinical note.';
COMMENT ON COLUMN amc_notes_metadata.char_length IS 'Number of characters in cleaned note text.';
COMMENT ON COLUMN amc_notes_metadata.word_length IS 'Number of whitespace-separated words in note text.';
COMMENT ON COLUMN amc_notes_metadata.token_length IS 'Number of tokens after model tokenizer encoding (o200k_base).';
COMMENT ON COLUMN amc_notes_metadata.source_file IS 'Raw filename where the note was originally extracted from.';

--------------------------------------------------------------------------------
-- Data copy

-- Example command to load data from CSV file into the table
-- \copy amc_notes_metadata FROM '/processed/metadata/metadata_merged_part_1_01.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------------------------------
-- Constraints

-- Foreign key to main notes table - link to main amc_notes table
ALTER TABLE amc_notes_metadata
   ADD CONSTRAINT fk_metadata_note
   FOREIGN KEY (note_id) 
   REFERENCES amc_notes(note_id);

-- Ensure lengths are non-negative - just a sanity check
ALTER TABLE amc_notes_metadata
  ADD CONSTRAINT chk_lengths_nonneg CHECK (
        char_length >= 0 AND
        word_length >= 0 AND
        token_length >= 0
  );

--------------------------------------------------------------------------------
-- Indexes

-- Index by subject for aggregation
CREATE INDEX IF NOT EXISTS idx_amc_metadata_subject
  ON amc_notes_metadata(subject_id);

-- Index by note_type for filtering
CREATE INDEX IF NOT EXISTS idx_amc_metadata_note_type
  ON amc_notes_metadata(note_type);

--------------------------------------------------------------------------------
