# CaRe-NLP Database

Pipeline and infrastructure for the CaRe-NLP clinical database: raw CSV
exports → translated, cleaned, indexed Postgres database on the Helios
cluster, with data-quality checks and metadata.

The database refreshes as a **full replace**, not an append — patient
pseudo-ids can change between data pulls — so every piece here is built to
be dropped and rebuilt safely and quickly, not migrated incrementally.

## Steps, in order

1. **[`extraction-translation/`](extraction-translation/README.md)** —
   locally (R), once per new data pull, before anything touches the
   cluster. Extracts every source table, translates column/file names
   NL → EN, and prepares the data for upload.
2. **[`structured-refresh/`](structured-refresh/README.md)** — on the
   Helios cluster (bash + SQL only), every data refresh. Loads the
   translated CSVs, cleans and types every column, builds indexes and
   foreign keys, computes quality flags, repairs linkage gaps, and
   publishes the `amc_views` views and `meta` metadata schema used by
   everything downstream.
3. **[`free-text-search/`](free-text-search/README.md)** — on the
   Helios cluster (Python + SQL), independent of the steps above, run
   only when the clinical notes themselves change. Cleans note text,
   extracts note metadata, creates the notes tables, and builds the
   GIN full-text search index.

Steps 1-3 populate the database. The two directories below describe and
report on it, and can be run any time afterward:

- **[`docs/data-dictionary/`](docs/data-dictionary/)** — column-level
  documentation for every table: data type, primary/foreign keys, and a
  short description. Generated output loaded into `meta.data_dictionary` by
  `structured-refresh/07_metadata/070_data_dictionary.sql`.
- **[`analysis/`](analysis/README.md)** — data-quality assessment,
  exploratory/landscape queries, and ICU cohort methodology. Read-only
  reporting, not part of the automated refresh.
