-- =============================================================================
--  050_create_fts_index.sql
--  Index: amc_core.idx_amc_notes_fts
--  Description:
--    Full-text search (inverted) index on amc_notes.note_text, Dutch
--    text-search configuration. Backs search_notes()-style queries.
--
--  Only depends on amc_notes being loaded (020) -- independent of
--  amc_notes_metadata (040). CONCURRENTLY avoids locking amc_notes
--  against reads/writes while the ~38.7M-row index builds; run outside
--  a transaction block (psql does this by default for a single \i).
-- =============================================================================

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_amc_notes_fts
  ON amc_core.amc_notes
  USING GIN (to_tsvector('dutch', coalesce(note_text, '')));
