# cohort-functions

Composable SQL functions for building patient cohorts against
`amc_views`/`amc_core` — consumers of the published schema, not part
of building it (same relationship `analysis/` has to
`structured-refresh/`). Run by hand, the same way
`extraction-translation/` and `free-text-search/` are — not wired into
`structured-refresh/refresh.sh`.

Every *selection* function returns `TABLE(pseudo_id text)` — a
membership list, not full row detail. Build a specific cohort by
calling 2-3 selection functions and combining with plain SQL
`INTERSECT` (or `EXCEPT`/`UNION`) — see `examples.sql`. This is
deliberate: a pseudo_id-only result composes with any other selection
function or joins back to whichever view holds the detail you actually
want, without needing a wrapper. `timeline_for_cohort` is the one
exception, by design — see below.

## Functions

- **`functions/010_cohort_by_diagnosis_code.sql`** —
  `cohort_functions.cohort_by_diagnosis_code(pattern, primary_only,
  date_from, date_to)`. Filters `amc_views.v_diagnoses_longitudinal` by
  a SQL `LIKE` pattern on `diagnosis_code` (e.g. `'I50%'` for heart
  failure), optionally restricted to primary/chief diagnoses and/or an
  `observation_date` range.
- **`functions/020_cohort_active_in_range.sql`** —
  `cohort_functions.cohort_active_in_range(domains, date_from,
  date_to)`. Filters `amc_views.v_clinical_timeline` to the given
  `event_domain`s, active (overlapping, not just starting) within one
  date range applied consistently across however many domains/tables
  you name.
- **`functions/030_cohort_by_diagnosis_text.sql`** —
  `cohort_functions.cohort_by_diagnosis_text(term, primary_only,
  date_from, date_to)`. Same as `cohort_by_diagnosis_code`, but
  matches a case-insensitive substring of `diagnosis_description`
  instead of an ICD/SNOMED code pattern — use this when you know the
  clinical term but not the code family.
- **`functions/035_lab_determination_lookup.sql`** — not a cohort
  function itself, a prerequisite `cohort_functions.lab_determination_lookup`
  table that `cohort_by_lab_test` depends on: a small (≤13,117-row)
  mapping of `lab_result.determination_code` to its human-readable
  `determination` text, rebuilt by hand whenever `lab_result`'s content
  changes (not wired into `structured-refresh/refresh.sh`).
- **`functions/040_cohort_by_lab_test.sql`** —
  `cohort_functions.cohort_by_lab_test(term, date_from, date_to)`.
  Matches a case-insensitive substring of the lab test's name against
  `cohort_functions.lab_determination_lookup` (not `amc_core.lab_result`
  directly), then uses the matched `determination_code`s to query
  `lab_result` via its existing index — turning what used to be an
  unindexed scan of all ~168M rows into an indexed lookup.
  `date_from`/`date_to` are now optional (they used to be required,
  back when the date bound was the only thing keeping this function's
  big-table query from scanning unfiltered).
- **`functions/050_timeline_for_cohort.sql`** —
  `cohort_functions.timeline_for_cohort(pseudo_ids, domains,
  date_from, date_to)`. The one function here that takes a
  `pseudo_id[]` *in* and returns full `v_clinical_timeline` rows out,
  not just IDs — use it to see or export what actually happened to a
  cohort you've already built with the other functions. `domains`
  defaults to `NULL` (all domains); `date_from`/`date_to` default to
  `NULL` (unbounded) and use the same overlap logic as
  `cohort_active_in_range` when given. Caveat: calling this with
  `domains` left `NULL` against a large cohort — especially one built
  without a date bound of its own — can scan a large share of
  `lab_result` via the timeline's `lab` domain, the same kind of
  `lab_result`-scale exposure `cohort_by_lab_test` was specifically
  designed to avoid; prefer naming specific `domains` and passing
  `date_from`/`date_to` when the cohort could be large.
- **`functions/060_cohort_by_note_text.sql`** —
  `cohort_functions.cohort_by_note_text(term, date_from, date_to)`. The
  unstructured-data counterpart to the diagnosis/lab functions above —
  matches clinical note content via Postgres full-text search (Dutch
  configuration, word/stem-based, not a literal substring) against
  `amc_core.amc_notes.note_text`, e.g. for a concept that was never
  formally coded. `date_from`/`date_to` are optional (unlike
  `cohort_by_lab_test`) — the existing `idx_amc_notes_fts` GIN index
  already makes an unfiltered search fast. Queries `amc_notes` directly
  rather than `amc_views.v_notes`, and its predicate must match the
  index's own indexed expression — `to_tsvector('dutch',
  coalesce(note_text, ''))`, `coalesce` included — exactly, or Postgres
  silently falls back to a sequential scan across all 38.7M+ rows.

Note on required arguments: passing `NULL` for a required argument
(e.g. `domains`, `date_from`, or `date_to` in
`cohort_active_in_range`) doesn't error — it silently yields an empty
result set, since Postgres comparisons and `= ANY()` against `NULL`
evaluate to `NULL`, which the function's `WHERE` clause treats as "no
match."

Note on date semantics for `diagnosis` rows: `cohort_by_diagnosis_code`
bounds `date_from`/`date_to` against `observation_date`, but
`cohort_active_in_range(ARRAY['diagnosis'], ...)` bounds the *same*
underlying diagnosis rows against a different pair of dates
(`registration_datetime`/`close_date`, per how `v_clinical_timeline`
maps the `diagnosis` domain) — so the two functions are not
interchangeable ways of date-filtering diagnoses, and intersecting them
with the same date range is not a redundant no-op check.

Note on date semantics for `lab` rows: `cohort_by_lab_test` bounds
`date_from`/`date_to` against `lab_result.result_date` (a plain `date`
column), but `cohort_active_in_range`/`timeline_for_cohort`'s `lab`
domain (via `v_clinical_timeline`) uses `result_date_time` instead
(mapped from `v_labs_long`) — so rows with a populated `result_date`
but a `NULL` `result_date_time` won't appear under a `lab`-domain date
filter in the timeline functions, even though they'd match
`cohort_by_lab_test`'s own date bound.

## Setting up

Run all seven files once (or again after a schema change) via
`psqlcarenlp`, from the repo root (so these relative paths resolve) —
in this order, since `040` depends on `035`:

```
\i cohort-functions/functions/010_cohort_by_diagnosis_code.sql
\i cohort-functions/functions/020_cohort_active_in_range.sql
\i cohort-functions/functions/030_cohort_by_diagnosis_text.sql
\i cohort-functions/functions/035_lab_determination_lookup.sql
\i cohort-functions/functions/040_cohort_by_lab_test.sql
\i cohort-functions/functions/050_timeline_for_cohort.sql
\i cohort-functions/functions/060_cohort_by_note_text.sql
```

The six functions are all `CREATE OR REPLACE FUNCTION` — safe to re-run
any time. `035` is a `DROP TABLE` + rebuild, not a function — re-run it
specifically whenever `lab_result`'s content changes (see its own
header comment), not just after a schema change.

## Combining functions

No wrapper needed — plain SQL:

```sql
SELECT pseudo_id FROM cohort_functions.cohort_by_diagnosis_code(
    'I50%', true, '2023-01-01', '2024-01-01'
)
INTERSECT
SELECT pseudo_id FROM cohort_functions.cohort_active_in_range(
    ARRAY['stay'], '2023-01-01', '2024-01-01'
);
```

Note that `INTERSECT`-composing two cohort functions over the same
date range finds patients who independently match both conditions
somewhere in that window — not that the two matching events overlapped
in time. The example above finds patients with an HF diagnosis
somewhere in the year *and* a stay somewhere in the same year, not
necessarily that the stay coincided with the diagnosis.

See `examples.sql` for more, including a full "lab meeting" style
query.

## Adding a new cohort function

For a new *selection* function (the common case): copy the pattern —
one `.sql` file in `functions/`, `CREATE OR REPLACE FUNCTION
cohort_functions.<name>(...) RETURNS TABLE(pseudo_id text)`, filtering
an existing `amc_views` view (or an `amc_core` table directly when the
index situation demands it, as `040_cohort_by_lab_test.sql` does), with
a manual verification query in the file's own header comment (no
automated tests in this repo). Keep it
single-purpose — combine with `INTERSECT` in the calling query rather
than adding parameters to an existing function.

For a *detail* function (taking a built cohort and returning full rows
for it, like `timeline_for_cohort`): same file conventions, but the
function takes a `pseudo_id[]` parameter and `RETURNS TABLE(...)` with
an explicit column list matching the source view's columns exactly —
**never `RETURNS SETOF <view_name>`**. That creates a dependency from
the function to the view's composite row type that blocks the view's
own `DROP VIEW` (no `CASCADE`) in `structured-refresh/06_views`,
aborting the `refresh.sh` run partway through — this is exactly the bug
`050_timeline_for_cohort.sql` shipped with and had to be fixed away
from; see its header comment for the full explanation. Keep the
column list in sync with the source view if it ever changes. There's
only one of these so far — don't build a second one speculatively; the
selection-function pattern above is what most new needs turn out to
be.
