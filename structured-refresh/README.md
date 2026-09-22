# structured-refresh

The bash + SQL pipeline that loads, cleans, keys, indexes, flags, and
publishes the CaRe-NLP structured tables on the Helios cluster.

## Cluster access

The PostgreSQL data directory is shared — only one server instance can run
at a time. Users on the same cluster node (check with `hostname`; the
current author's is `hpcloginresearch01.cluster`) can share a running
instance; users on different nodes cannot.

Add to your shell profile:

```bash
export SIF=/net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif
export PGDATA_HOST=/net/beegfs/groups/care-nlp-db/carenlp/pgdata
export CSV_HOST=/net/beegfs/groups/care-nlp-db/carenlp/scripts

alias pgstart='apptainer exec -B ${PGDATA_HOST}:/var/lib/postgresql/data $SIF postgres -D /var/lib/postgresql/data -k /tmp'
alias pgstop='apptainer exec -B ${PGDATA_HOST}:/var/lib/postgresql/data $SIF pg_ctl -D /var/lib/postgresql/data stop -m fast'
alias pgstatus='apptainer exec -B ${PGDATA_HOST}:/var/lib/postgresql/data $SIF pg_ctl -D /var/lib/postgresql/data status'
alias psqlcarenlp='apptainer exec -B ${PGDATA_HOST}:/var/lib/postgresql/data -B ${CSV_HOST}:/csv $SIF psql -h /tmp -U postgres -d carenlp_db'
```

Typical workflow: `pgstatus` → (if not running) `pgstart` → `psqlcarenlp` →
`\q` when done → `pgstop` once nobody else needs the server.

`CSV_HOST` is the shared group `scripts` folder — the same one
`07_metadata`'s CSVs (`data_dictionary.csv`, `name_mapping.csv`) already
live in, not a personal scratch directory. It's where
`extraction-translation/`'s output CSVs need to land (mounted read-only
at `/csv` inside the container) before running `01_raw_load`.

## Refresh model

Every refresh is a full drop-and-rebuild, not an incremental migration —
pseudo-ids can change between data pulls. `01_raw_load` is transient: it
exists only to get the new CSVs into Postgres as untyped text before
`02_core_clean` runs, and gets dropped afterward via `./refresh.sh drop-raw`
(never automatic — run it yourself once you've confirmed core looks right).

## Stages

`01_raw_load` → `02_core_clean` → `03_indices_fks` → `04_quality_flags` →
`05_linkage_repair` → `06_views` → `07_metadata`. Each stage folder holds
one SQL file per table, numbered for order (e.g. `010_lab_result.sql`).
All seven stages this reorg pass covers are migrated:
`01_raw_load` → `02_core_clean` → `03_indices_fks` → `04_quality_flags` →
`05_linkage_repair` → `06_views` → `07_metadata`.

Note: unlike the earlier stages, `05_linkage_repair` depends on
`04_quality_flags` having already run, not just `02_core_clean` — it reads
`admission_partial_traject.corrected_end_date_time` and (for two of its
tables) boolean quality-flag columns, both added by `04_quality_flags`.
Running `05_linkage_repair` alone against a database where only
`02_core_clean` has run will fail with a missing-column error.

Note: refreshing any single table in `02_core_clean`, `04_quality_flags`,
or `05_linkage_repair` should be followed by re-running that table's own
`03_indices_fks` file, the full `03_indices_fks` stage, and the full
`06_views` stage. `02_core_clean`'s `DROP TABLE` statements `CASCADE`, so a
table-level refresh always succeeds — but it silently takes down any view
built on that table and any other table's FK constraint pointing at it.
Re-running `03_indices_fks` and `06_views` in full restores both; both are
guarded, idempotent DDL passes (not full rebuilds), so this is cheap
regardless of which single table actually changed.

Note: `05_linkage_repair/070_analyze_all.sql` runs a blanket `ANALYZE;`
as the last step of the stage — every table's `DROP TABLE` this cycle
wiped its planner statistics along with it, and nothing else re-analyzes
most tables afterward (autovacuum eventually catches up on its own, but
that can take a long time on tables this large). Skipping this step is
easy to miss the cost of: queries joining across many tables — especially
through `06_views`'s widest views, e.g. `v_clinical_timeline`'s 13-way
`UNION ALL` — can select bad plans on stale statistics
(a real incident: a 5,000-row filter join chose a full top-level sort
over the entire ~300M-row unfiltered union instead of pushing the filter
into each branch, because the row estimate was off by 5 orders of
magnitude). If you refresh a single table rather than the full pipeline,
re-running `ANALYZE amc_core.<table>;` for just that table is enough —
you don't need the full blanket `ANALYZE;` again.

## Running a refresh

```bash
./refresh.sh                          # everything, all stages, in order
./refresh.sh 02_core_clean            # one whole stage, all tables
./refresh.sh 02_core_clean lab_result # one table in one stage
./refresh.sh 02_core_clean lab_result patient_contact   # a subset
./refresh.sh --dry-run 02_core_clean  # print what would run, execute nothing
./refresh.sh drop-raw                 # explicit, separate — never automatic
```

Every run writes a timestamped log to `logs/`.

## Maintenance tools

`tools/check_metadata_drift.sql` — not a migration tool, an ongoing one.
`07_metadata` has no automatic column-level drift detection: a column
added upstream after `meta.catalog`/`meta.data_dictionary` were curated
won't appear in either, silently, with no warning. Run this manually
(`psql -f structured-refresh/tools/check_metadata_drift.sql`) whenever you
suspect drift — e.g. right after a schema change, or periodically — to
see which real columns aren't documented anywhere yet. Cheap (metadata-only
joins, no data scans), never runs automatically.

`tools/check_raw_column_drift.py` — the raw-layer sibling: compares each
real CSV's header row directly against its `01_raw_load/*.sql` column
list, position by position. Needs no database connection at all — just
`CSV_HOST` pointed at the real (or a scratch/sliced) CSV directory:
`CSV_HOST=/path/to/csvs python3 structured-refresh/tools/check_raw_column_drift.py`.
Flags three things `check_metadata_drift.sql` can't see (it only looks at
`amc_core`/`amc_views`, after loading): columns added or dropped in a new
extract, and — the one nothing else in this repo checks — same-column-count
reorders, which `\copy`'s positional loading (no explicit column list
anywhere in this repo) would otherwise load silently into the wrong
fields. Run it whenever a new extract lands, before the first real
refresh against it.
