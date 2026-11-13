# Troubleshooting

Where to go when something doesn't add up — a question about this
pipeline, access problems, or the source data itself changing shape
underneath it.

## Questions, access requests, anything else — open a ticket

For anything not covered by `docs/instructions/` or this file, open a
ticket with the AmsterdamUMC service desk:

https://amsterdamumc.service-now.com/esc?id=sc_cat_item&sys_id=6edc44311bea4110f2ae6313604bcbc4

## The cluster itself is the problem (not this repo/database)

Hardware, node access, Apptainer/Helios infrastructure issues — as
opposed to anything about this pipeline or `carenlp_db` itself — go to
the **Helios Support** Microsoft Teams group:

https://teams.microsoft.com/l/channel/19%3A2rueGnNHXIKjJhFwmxkEWj0fkSiBY89HSUR7_gE39sc1%40thread.tacv2/General?groupId=80058bd6-c5be-4dc3-8fe5-5391a380b7ee&tenantId=68dfab1a-11bb-4cc6-beb5-28d756984fb6

## A whole new dataset landed (routine data pull, no schema change expected)

Every refresh is a full drop-and-rebuild, not an incremental migration
— pseudo-ids can change between pulls. This is the routine sequence
for a normal new extract; see the next section if something along the
way turns out to be an actual schema change, not just new rows.

1. **`extraction-translation/`** (local, R) — run `010`–`050` in order
   per its own `README.md`, producing a fresh set of translated CSVs.
2. Copy the translated output to `$CSV_HOST` on the cluster (mounted
   read-only at `/csv` inside the Apptainer container).
   If you copied the repo itself fresh too (not just the CSVs), the
   executable bit on the shell scripts often doesn't survive a copy —
   if `./refresh.sh` fails with "Permission denied" rather than an
   actual error from inside it, this is why:
   ```bash
   chmod +x structured-refresh/refresh.sh structured-refresh/tools/*.sh
   ```
3. **Run the full refresh**: `./refresh.sh` (all 7 stages, in order) —
   see `structured-refresh/README.md`'s "Running a refresh" for the
   single-stage/single-table/dry-run variants if you want to go
   step-by-step instead.
4. Once core looks right, run `./refresh.sh drop-raw` to clear the
   transient raw layer — explicit and separate, never automatic.
5. **If this pull also changed the clinical notes themselves**,
   separately re-run `free-text-search/`'s steps — it's independent of
   `structured-refresh` and only needs re-running when notes change,
   not on every structured-data pull.
6. **Re-run `cohort-functions/functions/035_lab_determination_lookup.sql`**
   — `lab_result`'s content just changed, and that lookup table is a
   one-time snapshot, not a live query; it won't pick up new
   `determination_code`s on its own.
7. **Spot-check the quality scripts** in `analysis/quality/`
   (`040`–`070`, all independent of each other) to confirm nothing
   regressed — linkage-repair match rate, numeric raw-fallback rate,
   the quality-flags rollup, and the stay LOS/death consistency check.
8. **Run `structured-refresh/tools/check_metadata_drift.sql`** to
   catch any column that's now undocumented in `meta.catalog`/
   `meta.data_dictionary`.
9.  **Sanity-check the demo**: `demo/README.md`'s own "Before the
    session" note already covers this — confirm section 1's `\gset`
    patient and the fixed search terms (`'hartfalen'`, `'troponine'`)
    still return a reasonable number of results, not zero.
10. If anything above surfaces a genuine data-quality finding (not
    just "there's more data now") — log it in
    `analysis/quality/amc_core_issues_registry.xlsx`.

## A table or column changed shape upstream (RDP)

This pipeline's raw data comes from AmsterdamUMC's RDP (Research Data
Platform) exports. If a `structured-refresh` run suddenly breaks on a
missing/renamed column, or `01_raw_load`'s expected columns stop
matching a new extract, the cause is almost always a change on the RDP
side, not a bug in this repo.

1. **Check the RDP release notes** for everything released between
   your last extraction date and now:
   https://amsterdamumc.sharepoint.com/sites/BI_Producten/SitePages/RDP.aspx
2. **Cross-reference the RDP catalogue** (the live Power BI catalog of
   every RDP table and its columns) to confirm the current shape of
   the table in question:
   https://p1wp10014-bi-rs.prod1.umcinfra.nl/reportspbi/powerbi/Onderzoek/RDP%20catalogus

### Once a real schema change is confirmed: steps to take in this repo

Work through the pipeline stages **in order** — each later stage
assumes the one before it is already correct, so fixing `06_views`
before `02_core_clean` just means re-doing the same fix twice.

1. **Detect it precisely, before the first real refresh against the
   new extract**: run
   `structured-refresh/tools/check_raw_column_drift.py` (needs
   `$CSV_HOST` set, no database needed). It reports CLEAN, REORDER, or
   ADDED/MISSING per table, column by column — REORDER is the
   dangerous one, since `\copy` loads by position and a same-count
   reorder loads silently into the wrong columns instead of erroring.
2. **Find every place in the repo that references the old column/table
   name** — the fastest way to see the real blast radius instead of
   walking every stage blind:
   ```bash
   grep -rln "old_column_name" --include="*.sql" --include="*.R" --include="*.py" .
   ```
3. **`01_raw_load/`** — update the affected table's `CREATE TABLE
   amc_raw.*` column list (add/remove/rename), and its `@COPY_PARTS`
   marker if column order changed.
4. **`02_core_clean/`** — update the matching `amc_core` `CREATE
   TABLE` and the `INSERT ... SELECT` cast/rename expression for that
   column.
5. **`03_indices_fks/`** — check whether any index or `FOREIGN KEY`
   referenced the changed column; rename/rebuild as needed.
6. **`04_quality_flags/`** and **`05_linkage_repair/`** — check
   whether any flag computation or date-range-repair anchor referenced
   it.
7. **`06_views/`** — the biggest blast radius: `amc_views` is the
   published interface everything downstream reads, so grep every
   view file for the old column name and update each one. Remember
   `structured-refresh/06_views/*.sql`'s `DROP VIEW` statements need
   `CASCADE` if anything else depends on that view (see the
   `v_clinical_timeline` dependency chain for the pattern).
8. **Re-run `structured-refresh/refresh.sh`** (or just the affected
   stages) end to end and confirm it completes cleanly.
9. 9. **`07_metadata/`** — once the refresh succeeds, run
   `structured-refresh/tools/check_metadata_drift.sql` to see which
   real `amc_core` columns are now undocumented in
   `meta.data_dictionary`, and update `data_dictionary.csv`
   accordingly. If the change was to a *view* column instead, there's
   no automated check for that — consider by hand whether
   `meta.catalog`'s curated entries in
   `07_metadata/020_populate_catalog_curated.sql` need updating too.
10. **Downstream consumers** — `cohort-functions/` and `analysis/`
    query `amc_views`/`amc_core` directly and won't error until
    actually *called*, not at refresh time. Grep both folders for the
    old column name too, and re-run each affected function/script's
    own manual-verification query (in its file header) to confirm it
    still behaves correctly.
11. If the change reveals a genuine data-quality nuance (not just a
    rename) — log it in `analysis/quality/amc_core_issues_registry.xlsx`,
    same as any other finding.

## Re-extracting raw tables from RDP

The official RDP handbook (Dutch: "RDP Handleiding") covers how to pull
raw tables from RDP itself — the step before anything in
`extraction-translation/` runs:

https://amsterdamumc.sharepoint.com/sites/BI_Producten/Tips%20en%20Tricks/Forms/AllItems.aspx?id=%2Fsites%2FBI%5FProducten%2FTips%20en%20Tricks%2FRDP%20Handleiding%2Epdf&parent=%2Fsites%2FBI%5FProducten%2FTips%20en%20Tricks
