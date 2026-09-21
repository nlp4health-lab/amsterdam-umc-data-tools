# extraction-translation

R scripts that extract structured tables and note text from the raw NL
exports and translate table/column names NL → EN (DeepL-assisted,
human-reviewed). Every original ↔ translated pair is preserved in two
mapping CSVs on the local data drive (not in this repo — they're data
artifacts, not code): `mappings/column_mapping_second_pass.csv` (used
by `030`) and `mappings/file_name_mapping.csv` (used by `040`).

Runs **locally**, not on the Helios cluster — R is not part of the cluster
environment. Output CSVs need to land at the path `structured-refresh`
expects as `$CSV_HOST` (see `../structured-refresh/README.md`) before
running `01_raw_load`.

## Run order

Run by hand, in order, reviewing output between steps (this is
deliberately not a single unattended driver — e.g. `040`'s file-name
translation only works if `030` already created and populated the
output folder, and it's worth checking `030`'s output for any
newly-appeared, not-yet-mapped column before continuing).

**Every script has a `SET THIS EACH RUN` path at the top — and they
must agree with each other.** `020`'s `output_dir`, `030`'s `raw_dir`,
and `010`'s `output_dir` should all point at the same run's raw-output
folder; `030`'s `translated_dir`, `040`'s `new_dir`, and `050`'s
`folder` must all be the exact same translated-output folder (`030`
creates it, `040` renames files in it, `050` sweeps it). Mismatched
paths don't error — `050` would just silently sweep zero files and
report "DONE" with nothing done, so double-check before running each
step.

1. **`scripts/010_extract_tables.R`** — connects to the source SQL
   Server DB, extracts every `CaRe_NLP` table in size-capped chunks.
   Always reorders LOB/long-text columns to the end of each table's
   column list (verified safe — a no-op for all but 2 of the 59 real
   tables, and the fix for those 2) to avoid a SQL Server ODBC error;
   one table failing doesn't stop the others. **Edit `output_dir`** to
   a new date-stamped folder before each run, e.g.
   `.../structured_data_21_09_26/`. Writes `<table>_part1.csv`,
   `_part2.csv`, ... (always at least `_part1`, even for a single-chunk
   table).
2. **`scripts/020_extract_table_metadata.R`** — independent of
   extraction, safe to run before or after step 1. **Edit `output_dir`**
   — recommended: the same folder as `010`'s, for this run. Dumps
   `INFORMATION_SCHEMA.COLUMNS` for the whole `CaRe_NLP` schema to
   `CaRe_NLP_table_metadata.csv` — real source-of-truth column types,
   used elsewhere in this repo (`structured-refresh`'s type-safety
   audits) to catch cases where a source column is looser/stricter than
   the pipeline assumes.
3. **`scripts/030_translate_column_names.R`** — reads the raw extracted
   CSVs, writes translated-column-header copies into a new output
   folder (creates it). Uses the mapping CSV's `original`/`translated2`
   columns. **Edit `raw_dir`** to match `010`'s `output_dir` exactly,
   and **edit `translated_dir`** to the new folder this run's
   translated output should land in, e.g.
   `.../structured_data_21_09_26_copy`. Check the console for any
   column the mapping CSV doesn't recognize — see "new column appeared"
   below before continuing.
4. **`scripts/040_translate_file_names.R`** — renames the files already
   sitting in that output folder (from step 3) to their translated
   names, in place. Requires step 3 to have already run. **Edit
   `new_dir`** to match `030`'s `translated_dir` exactly. Matches
   filenames case-insensitively and strips/reattaches the `_partN`
   suffix around the lookup, so multi-part tables rename correctly
   (a file with no `_partN` suffix is skipped, not expected from
   `010`'s output).
5. **`scripts/050_remove_rn_column.R`** — final safety-net sweep over
   the translated folder: strips any leftover `rn` column that survived
   extraction despite `010`'s own stripping. **Edit `folder`** to match
   `030`/`040`'s folder exactly. If the console reports 0 files swept,
   stop — that means `folder` didn't match and nothing above actually
   ran on the data you expect.

Copy the result to wherever `$CSV_HOST` points on the machine that runs
`structured-refresh/refresh.sh`.

### New, not-yet-mapped column appeared (during step 3)

Run the occasional-use `translate_column_names_structured_data.R` (see
below) to extend the mapping CSV, then re-run step 3. Before that
script will run, set your DeepL API key for the session:

```r
Sys.setenv(DEEPL_API_KEY = "<your key>")
```

or add `DEEPL_API_KEY=<your key>` to your `.Renviron` so it's set
automatically. 

## Occasional-use scripts (not part of the routine run order)

- `scripts/translate_column_names_structured_data.R` /
  `translate_file_names_structured_data.R` — the original DeepL-based
  scripts used to build the mapping CSV the first time. Run these again
  only when a new, not-yet-mapped column or file name appears; extend
  the mapping CSV with the result, then re-run the numbered sequence
  above. Both read the DeepL API key from the `DEEPL_API_KEY`
  environment variable.
- `scripts/analysis-columns-structured-tables.R` — column profiling
  used while building/checking the mapping.
- `scripts/rename-columns-files.R` — batch rename driver, ad hoc use.


