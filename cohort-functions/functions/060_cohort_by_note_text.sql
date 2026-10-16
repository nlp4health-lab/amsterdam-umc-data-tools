-- =====================================================================
-- cohort_functions.cohort_by_note_text
--
-- Cohort selection by clinical note content -- the unstructured-data
-- counterpart to cohort_by_diagnosis_code/cohort_by_diagnosis_text
-- (structured). Lets a cohort be built from what's written in notes,
-- not just coded diagnoses/labs -- e.g. a clinical concept that was
-- never formally coded, or a search by the exact word a clinician
-- would use.
--
-- term: required. Matched via Postgres full-text search (Dutch
--   configuration, word/stem-based -- not a literal substring match
--   like cohort_by_diagnosis_text's ILIKE), e.g. 'hartfalen' matches
--   "hartfalen", "Hartfalen", and other inflections, not just an exact
--   substring.
-- date_from/date_to: optional, NULL (the default) on either side
--   leaves that bound unbounded -- unlike cohort_by_lab_test, there's
--   no performance reason to require a date bound here (see below), so
--   this matches cohort_by_diagnosis_text's optional pattern instead.
--
-- Performance: queries amc_core.amc_notes directly (not the
-- amc_views.v_notes view, same choice the demo's own note search
-- makes) so the predicate below matches amc_notes_fts' indexed
-- expression exactly. This is NOT optional -- the index
-- (free-text-search/scripts/050_create_fts_index.sql) is built on
-- to_tsvector('dutch', coalesce(note_text, '')), with the coalesce.
-- Postgres only uses an expression index when the query's predicate is
-- the exact same expression; to_tsvector('dutch', note_text) WITHOUT
-- the coalesce is a different expression and silently falls back to a
-- sequential scan across all 38.7M+ rows -- found while building this
-- function; demo/queries.sql's own note search had the same mismatch,
-- fixed alongside this.
--
-- date_note is unindexed as a text-search companion (idx_amc_notes_date
-- is a plain btree, unrelated to the GIN index above) -- it's applied
-- as a plain filter after the indexed text match, not pushed ahead of
-- it, same as cohort_by_diagnosis_text's date handling.
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS cohort_functions;

CREATE OR REPLACE FUNCTION cohort_functions.cohort_by_note_text(
    term       text,
    date_from  date DEFAULT NULL,
    date_to    date DEFAULT NULL
) RETURNS TABLE(pseudo_id text)
LANGUAGE sql
STABLE
AS $$
    SELECT DISTINCT n.pseudo_id
    FROM amc_core.amc_notes n
    WHERE to_tsvector('dutch', coalesce(n.note_text, '')) @@ plainto_tsquery('dutch', term)
      AND (date_from IS NULL OR n.date_note >= date_from)
      AND (date_to IS NULL OR n.date_note <= date_to)
$$;

-- Manual verification (run by hand against the live database -- no
-- automated test suite in this repo):
--
-- 1. Sanity: result is non-empty for a real clinical term, and every
--    returned pseudo_id really does have a matching note:
--   SELECT count(*) FROM cohort_functions.cohort_by_note_text('hartfalen');
--   SELECT count(*) FROM amc_core.amc_notes
--     WHERE pseudo_id = (SELECT pseudo_id FROM cohort_functions.cohort_by_note_text('hartfalen') LIMIT 1)
--       AND to_tsvector('dutch', coalesce(note_text, '')) @@ plainto_tsquery('dutch', 'hartfalen');
--   -- second count must be > 0
--
-- 2. Confirm the index is actually used (not a sequential scan):
--   EXPLAIN SELECT * FROM cohort_functions.cohort_by_note_text('hartfalen');
--   -- expect "Bitmap Index Scan on idx_amc_notes_fts" (or similar
--   -- index-scan plan) in the output, not "Seq Scan on amc_notes"
--
-- 3. Date bound matches a direct query:
--   SELECT count(*) FROM cohort_functions.cohort_by_note_text('hartfalen', '2024-01-01', '2024-01-31');
--   SELECT count(DISTINCT pseudo_id) FROM amc_core.amc_notes
--     WHERE to_tsvector('dutch', coalesce(note_text, '')) @@ plainto_tsquery('dutch', 'hartfalen')
--       AND date_note >= '2024-01-01' AND date_note <= '2024-01-31';
--   -- both counts must match
--
-- 4. Combine with a structured cohort function -- e.g. heart failure
--    patients whose notes also mention a specific term not captured by
--    the diagnosis code/description alone:
--   SELECT pseudo_id FROM cohort_functions.cohort_by_diagnosis_code('I50%', true)
--   INTERSECT
--   SELECT pseudo_id FROM cohort_functions.cohort_by_note_text('delier');
