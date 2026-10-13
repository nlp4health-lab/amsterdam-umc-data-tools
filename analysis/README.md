# analysis

Read-only reporting and exploratory SQL — zero `ALTER`/`UPDATE`
statements anywhere in here. Run manually/occasionally against
`carenlp_db`, not part of the routine `structured-refresh` pipeline.
Persistent quality-flag *columns* live in
`../structured-refresh/04_quality_flags/` instead — these scripts
report on the data, they don't change it.

Three subfolders, by purpose:

## `quality/` — data-quality assessment

Seven scripts. The first three form one workflow, run in this order,
each narrowing in on the last one's findings; the fourth through
seventh are each independent:

1. **`010_survey_all_date_columns.sql`** — exhaustive MIN/MAX/NULL-rate
   survey of every date/timestamp-like column (331 columns across 59
   tables, per `date_columns.csv`). One row per (table, column) pair.
2. Review that output by hand and flag whatever looks implausible.
   Recorded in `date_column_quality_results_1.csv` — the `Comment`
   column marks which ones warrant a closer look.
3. **`020_deep_check_flagged_dates.sql`** — for exactly the 19 columns
   flagged in step 2, computes `% before 2000` / `% after 2027` per
   column. Results in `flagged_date_range_results.csv`.
4. **`030_full_audit_report.sql`** — the broader, presentation-ready
   report: patient traceability, abnormal dates, orphaned contact_ids,
   NULL rates, duplicate events, medication/prescription chain orphans,
   note-linkage gaps, cross-table date consistency. Runs independently
   of steps 1-3. Findings feed `amc_core_issues_registry.xlsx`, the
   running registry of known data-quality issues.
5. **`040_linkage_repair_match_rate.sql`** — how well
   `structured-refresh/05_linkage_repair`'s date-range inference
   actually worked, per table: eligible rows (a non-null anchor date,
   and not already flagged with an implausible one), matched vs.
   unmatched among those, as percentages. Independent of steps 1-3.
   Not fast on `lab_result` (~168M rows, no index on the anchor-date
   columns) — an audit script, not for a live demo.
6. **`050_numeric_raw_fallback_rate.sql`** — how often the `_raw` text
   sibling columns from the type-safety audit actually get used: for
   each of 47 numeric/int columns (across 15 tables), what fraction of
   rows where the source had *something* failed to parse as a number
   (vs. a normally-empty field, which isn't counted). Independent of
   the others.
7. **`060_quality_flags_summary.sql`** — rollup of every boolean
   quality-flag column `structured-refresh/04_quality_flags` computes
   (11 per-row flags across 10 tables, e.g. `ongoing_stay`,
   `abnormal_date`, plus the patient-level aggregate
   `has_any_quality_issue`), with flagged-row counts and percentages —
   previously only visible by reading all 11 files individually.
   Independent of the others.
8. **`070_stay_los_death_consistency_check.sql`** — verifies
   `v_stays`/`v_icu_stays`'s `stay_los_hours`/`hospital_los_hours`/
   `died_during_stay` columns: re-derives `died_during_stay`
   independently against `patient_not_traceable.death_date_time`
   (rather than trusting the view's own logic), reports the
   died-during-stay rate by `stay_type`, and checks that a segment's
   own duration never exceeds its parent admission's. Independent of
   the others.

**Known discrepancy, not unified:** `020` uses a fixed `2027` cutoff
for "too far in the future," while `030` uses a relative
`CURRENT_DATE + 10 years` for the same kind of check. Both are
intentional, hand-tuned per their own script's context.

**How to run** (connect first, see `../docs/instructions/access-instructions.md`):
```bash
psqlcarenlp
```
```
\i analysis/quality/010_survey_all_date_columns.sql
\i analysis/quality/020_deep_check_flagged_dates.sql
```
```bash
sed 's|/tmp/amc_dq|/your/output/path|g' analysis/quality/030_full_audit_report.sql > dq_run.sql
```
then inside psql: `\i dq_run.sql`
```
\i analysis/quality/040_linkage_repair_match_rate.sql
\i analysis/quality/050_numeric_raw_fallback_rate.sql
\i analysis/quality/060_quality_flags_summary.sql
\i analysis/quality/070_stay_los_death_consistency_check.sql
```

## `exploratory/` — understand the data landscape

- **`landscape_analysis.sql`** / **`landscape_analysis_batch.sql`** —
  the same 67 queries across 18 sections (coding systems, demographics,
  admissions, ICU, mortality, ED, diagnoses, meds, labs, vitals, fluid
  balance, procedures, imaging, notes volume, data quality/completeness,
  cohort-building templates). `landscape_analysis.sql` runs interactively
  (paste into any client); `landscape_analysis_batch.sql` is the same
  queries wrapped for automated psql `\o` output — one CSV per section,
  useful for a full unattended run. Keep both: different use, same content.
- **`presentation_prep_queries.sql`** — scale/orientation numbers,
  architecture credibility, domain inventory, an ICU deep dive, and
  known limitations — organized by slide section, for filling in a
  specific presentation's numbers.

## `icu/` — ICU cohort methodology

- **`icu_cohort_analysis.sql`** — ICU cohort definition (`workplace`
  ILIKE the intensive-care wards) and patient traceability stats.
- **`contact_id_coverage.sql`** — for ICU patients specifically, checks
  whether `patient_contact_id` is a usable secondary join key across
  tables (vs. falling back to pseudo_id + date-window joins).
