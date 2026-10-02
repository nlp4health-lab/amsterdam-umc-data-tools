# free-text-search

Independent pipeline for the ~38.7M clinical notes: cleaning/preprocessing,
metadata extraction, table creation, and the GIN full-text search index.
The only part of this repo that uses Python.

Independent of `structured-refresh` — notes don't need reprocessing on
every structured-data refresh, only when the notes themselves change.
Run by hand, in order, same as `extraction-translation/` — not part of
`structured-refresh/refresh.sh`.


## Run order

1. **`scripts/010_extraction_and_cleaning.py`** — parses raw
   tab-separated note files, cleans the text, writes CSVs matching
   `amc_notes`'s current columns (`pseudo_id`, `patient_note_id`,
   `date_note`, `patient_note_category`, `caregiver_type`, `note_text`).
   Edit `input_folder`/`output_folder` at the bottom before running.
2. **`scripts/020_create_amc_notes_table.sql`** — creates
   `amc_core.amc_notes` (if it doesn't already exist) plus its btree
   indexes. Includes the `\copy` command to load step 1's output.
3. **`scripts/030_metadata_extraction.py`** — reads the CSVs from step 1
   (streaming, to handle the file sizes), computes char/word/token
   length per note, writes metadata CSVs using `amc_notes_metadata`'s
   own (unrenamed) column names. Edit `NOTES_PROCESSED_DIR`/
   `NOTES_METADATA_DIR` env vars, or use the defaults
   (`data/processed`, `data/metadata`). Defaults to `TEST = True`
   (processes one row) — set `False` for a full run.
4. **`scripts/040_create_amc_notes_metadata_table.sql`** — creates
   `amc_core.amc_notes_metadata` plus its FK to `amc_notes` and its
   btree indexes. Includes the `\copy` command to load step 3's output.
5. **`scripts/050_create_fts_index.sql`** — builds the GIN full-text
   index on `amc_notes.note_text` (Dutch text-search config). Only
   depends on step 2's data being loaded — independent of steps 3/4.
   Uses `CONCURRENTLY`, so it's safe to run without locking the table,
   but takes a while over ~38.7M rows.




