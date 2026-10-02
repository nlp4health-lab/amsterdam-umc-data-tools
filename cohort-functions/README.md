# cohort-functions

Composable SQL functions for building patient cohorts against
`amc_views`/`amc_core` — using the published schema, not part
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
- **`functions/040_cohort_by_lab_test.sql`** —
  `cohort_functions.cohort_by_lab_test(term, date_from, date_to)`.
  Matches a case-insensitive substring of the lab test's name
  (`determination`) in `amc_core.lab_result`. `date_from`/`date_to`
  are required here (unlike the diagnosis functions) — `lab_result` is
  ~168M rows with no index on `determination`, so the date bound keeps
  the query planner able to narrow via the existing date index first.
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

Note on required arguments: passing `NULL` for a required argument
(e.g. `domains`, `date_from`, or `date_to` in
`cohort_active_in_range`, or `date_from`/`date_to` in
`cohort_by_lab_test`) doesn't error — it silently yields an empty
result set, since Postgres comparisons and `= ANY()` against `NULL`
evaluate to `NULL`, which the function's `WHERE` clause treats as "no
match."

Note on date semantics for `diagnosis` rows: `cohort_by_diagnosis_code`
bounds `date_from`/`date_to` against `observation_date`, but
`cohort_active_in_range(ARRAY['diagnosis'], ...)` bounds the *same*
underlying diagnosis rows against a different pair of dates
(`registration_datetime`/`close_date`, per how `v_clinical_timeline`
maps the `diagnosis` domain)

Note on date semantics for `lab` rows: `cohort_by_lab_test` bounds
`date_from`/`date_to` against `lab_result.result_date` (a plain `date`
column), but `cohort_active_in_range`/`timeline_for_cohort`'s `lab`
domain (via `v_clinical_timeline`) uses `result_date_time` instead
(mapped from `v_labs_long`) — so rows with a populated `result_date`
but a `NULL` `result_date_time` won't appear under a `lab`-domain date
filter in the timeline functions, even though they'd match
`cohort_by_lab_test`'s own date bound.

## Setting up

Run all five function files once (or again after a schema change) via
`psqlcarenlp`, from the repo root (so these relative paths resolve):

```
\i cohort-functions/functions/010_cohort_by_diagnosis_code.sql
\i cohort-functions/functions/020_cohort_active_in_range.sql
\i cohort-functions/functions/030_cohort_by_diagnosis_text.sql
\i cohort-functions/functions/040_cohort_by_lab_test.sql
\i cohort-functions/functions/050_timeline_for_cohort.sql
```

All five are `CREATE OR REPLACE FUNCTION` — safe to re-run any time.

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

