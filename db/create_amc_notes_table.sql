-- =============================================================================
--  create_amc_notes.sql
--  Table: amc_notes
--  Description:
--    Cleaned and structured clinical notes parsed from carenlp-dfile raw files.
--    Each row corresponds to one note.
-- =============================================================================

CREATE TABLE IF NOT EXISTS amc_notes (
    subject_id      TEXT        NOT NULL,
    note_id         TEXT        NOT NULL,
    date_note       DATE,
    note_type       TEXT,
    author_note     TEXT,
    note_text       TEXT,
    uid             TEXT        GENERATED ALWAYS AS (subject_id || '_' || note_id) STORED,
    PRIMARY KEY (subject_id, note_id)
);

--------------------------------------------------------------------------------
-- Comments

COMMENT ON TABLE amc_notes IS 'Cleaned and structured clinical notes from carenlp-dfiles raw inputs.';
COMMENT ON COLUMN amc_notes.subject_id IS 'Patient identifier.';
COMMENT ON COLUMN amc_notes.note_id IS 'Note identifier (may repeat across patients).';
COMMENT ON COLUMN amc_notes.uid IS 'Concatenated subject_id and note_id (unique composite identifier).';
COMMENT ON COLUMN amc_notes.date_note IS 'Date extracted from timestamp.';
COMMENT ON COLUMN amc_notes.note_type IS 'Type of clinical note.';
COMMENT ON COLUMN amc_notes.author_note IS 'Note author department or person role (if available).';
COMMENT ON COLUMN amc_notes.note_text IS 'Cleaned full text of the note.';

--------------------------------------------------------------------------------
-- Data copy

-- Example command to load data from CSV file into the table
-- \copy amc_notes FROM '/processed/merged_part_1_01.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------------------------------
-- Constraints

ALTER TABLE amc_notes ADD CONSTRAINT uniq_amc_uid UNIQUE (uid);
ALTER TABLE amc_notes ADD CONSTRAINT chk_amc_date CHECK (date_note <= CURRENT_DATE);

--------------------------------------------------------------------------------
-- Indexes

-- Index by patient (frequent grouping)
CREATE INDEX IF NOT EXISTS idx_amc_notes_subject
  ON amc_notes(subject_id);

-- Index by note type
CREATE INDEX IF NOT EXISTS idx_amc_notes_note_type
  ON amc_notes(note_type);

-- Index by note date
CREATE INDEX IF NOT EXISTS idx_amc_notes_date
  ON amc_notes(date_note);

--------------------------------------------------------------------------------
