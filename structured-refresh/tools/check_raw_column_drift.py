#!/usr/bin/env python3
"""
check_raw_column_drift.py

Read-only report: compares each real CSV's header row against the
column list declared in its structured-refresh/01_raw_load/*.sql file,
column by column, by position.

This is the raw-layer sibling to check_metadata_drift.sql, which only
covers amc_core/amc_views columns vs. meta.catalog/meta.data_dictionary
documentation. Neither of those catches drift *before* it reaches the
database -- if a source extract adds, drops, renames, or reorders a raw
CSV column, \\copy (used with no explicit column list throughout this
repo) loads purely by position. A dropped column usually fails loudly
(Postgres errors on a column-count mismatch). A same-count REORDER does
not -- it loads silently into the wrong columns. This script is the only
thing in the repo that checks for that specific case.

Needs no database connection and no Apptainer container -- it only reads
CSV files and this repo's own .sql files, so it can run anywhere the CSV
directory is reachable (including outside the cluster, if the CSVs are
mirrored somewhere else).

For each 01_raw_load/*.sql file (except 000_init.sql, which has no
\\copy at all):
  - reads its `-- @COPY_PARTS: table_name [csv_prefix]` marker to find
    the table name (amc_raw.<table_name>, what \\copy loads into) and
    the real CSV filename prefix to look for (csv_prefix, defaulting to
    table_name if the marker has no second field -- same default
    refresh.sh itself uses)
  - reads <csv_prefix>_part1.csv's header line (part1 specifically,
    since every real part of a table shares one column layout)
  - extracts the file's CREATE TABLE amc_raw.<table_name> column list,
    in declared order
  - reports one of: CLEAN (identical), REORDER (same column set, but at
    least one position differs -- the dangerous, otherwise-undetected
    case), or ADDED/MISSING (column sets differ)

A table with no CSV present under $CSV_HOST is skipped with a note, not
an error -- this script is meant to run safely against a partial/scratch
CSV directory too (e.g. a small-slice test copy), not just a full extract.

Usage:
  CSV_HOST=/path/to/real/csvs python3 structured-refresh/tools/check_raw_column_drift.py

Run this manually whenever a new extract lands, before the first real
refresh against it -- NOT part of the automatic refresh cycle (lives in
tools/, not in 01_raw_load/, specifically so refresh.sh never picks it
up as a stage file).
"""
import csv
import os
import re
import sys
import glob

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RAW_LOAD_DIR = os.path.join(REPO_ROOT, "structured-refresh", "01_raw_load")

MARKER_RE = re.compile(r'^-- @COPY_PARTS:[ \t]*(\S+)(?:[ \t]+(\S+))?[ \t]*$', re.MULTILINE)
CREATE_TABLE_RE = re.compile(r'CREATE TABLE amc_raw\.(\w+)\s*\((.*?)\n\);', re.DOTALL)
COLUMN_LINE_RE = re.compile(r'^\s*(\w+)\s+TEXT,?\s*$', re.MULTILINE)


def sql_columns_for_file(path):
    with open(path) as f:
        text = f.read()
    m = CREATE_TABLE_RE.search(text)
    if not m:
        return None, None, None
    table_name = m.group(1)
    cols = COLUMN_LINE_RE.findall(m.group(2))
    marker_m = MARKER_RE.search(text)
    csv_prefix = table_name
    if marker_m:
        csv_prefix = marker_m.group(2) or marker_m.group(1)
    return table_name, csv_prefix, cols


def real_header(csv_host, csv_prefix):
    path = os.path.join(csv_host, f"{csv_prefix}_part1.csv")
    if not os.path.exists(path):
        return None, path
    # utf-8-sig strips a leading BOM if present (harmless no-op if not) --
    # common on Windows-exported CSVs, and would otherwise silently
    # corrupt the first column's name (e.g. '﻿pseudo_id').
    with open(path, newline='', encoding='utf-8-sig') as f:
        reader = csv.reader(f)
        try:
            header = next(reader)
        except StopIteration:
            return [], path
    return [h.strip() for h in header], path


def main():
    csv_host = os.environ.get("CSV_HOST")
    if not csv_host:
        print("ERROR: CSV_HOST must be set (same env var refresh.sh uses)", file=sys.stderr)
        sys.exit(1)
    if not os.path.isdir(csv_host):
        print(f"ERROR: CSV_HOST directory not found: {csv_host}", file=sys.stderr)
        sys.exit(1)

    clean, reorder, mismatch, skipped = [], [], [], []

    for path in sorted(glob.glob(os.path.join(RAW_LOAD_DIR, "*.sql"))):
        if os.path.basename(path) == "000_init.sql":
            continue
        table_name, csv_prefix, sql_cols = sql_columns_for_file(path)
        if table_name is None:
            continue

        real_cols, csv_path = real_header(csv_host, csv_prefix)
        if real_cols is None:
            skipped.append((table_name, csv_path))
            continue

        if real_cols == sql_cols:
            clean.append(table_name)
            continue

        real_set, sql_set = set(real_cols), set(sql_cols)
        added = sorted(real_set - sql_set)
        missing = sorted(sql_set - real_set)

        if not added and not missing:
            # Same column set, different order -- the dangerous case.
            diffs = [
                (i + 1, sql_cols[i], real_cols[i])
                for i in range(len(sql_cols))
                if sql_cols[i] != real_cols[i]
            ]
            reorder.append((table_name, csv_path, diffs))
        else:
            mismatch.append((table_name, csv_path, added, missing))

    print(f"Checked against CSV_HOST={csv_host}\n")

    if reorder:
        print(f"=== REORDER -- same columns, different position (SILENT RISK) -- {len(reorder)} ===")
        for table_name, csv_path, diffs in reorder:
            print(f"\n  {table_name}  ({csv_path})")
            for pos, sql_col, real_col in diffs:
                print(f"    pos {pos}: SQL expects '{sql_col}'  |  CSV actually has '{real_col}'")
        print()

    if mismatch:
        print(f"=== ADDED/MISSING -- column sets differ -- {len(mismatch)} ===")
        for table_name, csv_path, added, missing in mismatch:
            print(f"\n  {table_name}  ({csv_path})")
            if missing:
                print(f"    MISSING (SQL has it, CSV doesn't): {missing}")
            if added:
                print(f"    ADDED (CSV has it, SQL doesn't):   {added}")
        print()

    if skipped:
        print(f"=== SKIPPED -- no CSV found under CSV_HOST -- {len(skipped)} ===")
        for table_name, csv_path in skipped:
            print(f"  {table_name}  (expected {csv_path})")
        print()

    print(f"=== CLEAN -- {len(clean)} ===")
    for table_name in clean:
        print(f"  {table_name}")

    print(f"\nSummary: {len(clean)} clean, {len(reorder)} reorder, "
          f"{len(mismatch)} added/missing, {len(skipped)} skipped (no CSV present).")

    if reorder or mismatch:
        sys.exit(1)


if __name__ == "__main__":
    main()
