#!/usr/bin/env bash
# refresh.sh — run the structured-refresh pipeline, in full or in part.
#
# Usage:
#   ./refresh.sh                          # everything, all stages, in order
#   ./refresh.sh <stage>                  # one whole stage, all tables
#   ./refresh.sh <stage> <table> [...]    # one or more tables within a stage
#   ./refresh.sh --dry-run [<stage> [<table>...]]   # print plan, run nothing
#   ./refresh.sh drop-raw                 # explicit, separate — never automatic
#
# <stage> is a directory name under structured-refresh/, e.g. 02_core_clean.
# Connects the same way as the `psqlcarenlp` alias (see README.md); set
# $SIF, $PGDATA_HOST, and $CSV_HOST as documented there. REFRESH_PSQL_CMD
# overrides the psql invocation entirely — used by tools/test_refresh.sh.
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
STAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$LOG_DIR/refresh_${STAMP}.log"

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
  shift
fi

STAGE="${1:-}"
[[ $# -gt 0 ]] && shift
TABLES=("$@")

if [[ "$DRY_RUN" -ne 1 ]] && [[ -z "${REFRESH_PSQL_CMD:-}" ]] && [[ -z "${SIF:-}" || -z "${PGDATA_HOST:-}" ]]; then
  echo "SIF and PGDATA_HOST must be set — see README.md" >&2
  exit 1
fi

# expand_copy_parts — a raw-load file may contain a single line:
#   -- @COPY_PARTS: table_name [csv_prefix]
# in place of a hardcoded \copy block, so the number of CSV parts loaded
# always matches what's actually on disk instead of a count baked in at
# migration time. table_name is the amc_raw.<table_name> load target;
# csv_prefix (optional, defaults to table_name) is the CSV filename
# prefix to glob for — needed for the handful of tables where the CSV
# filename doesn't match the table name exactly (a capitalization
# difference, an old/renamed source filename, etc.). Globs $CSV_HOST (the
# real host path bind-mounted to /csv) for csv_prefix_part[0-9]*.csv,
# sorts numerically, and writes an expanded copy of the file with that
# one marker line replaced by a \copy line per part plus a matching
# amc_meta.raw_load_log INSERT. Prints the path to run (the original
# file, unchanged, if it has no marker).
expand_copy_parts() {
  local file="$1"
  if ! grep -q '^-- @COPY_PARTS:' "$file"; then
    printf '%s' "$file"
    return 0
  fi

  if [[ -z "${CSV_HOST:-}" ]]; then
    echo "ERROR: $file has an @COPY_PARTS marker but CSV_HOST is not set" >&2
    return 1
  fi

  local marker_rest table_name csv_prefix
  marker_rest="$(sed -n 's/^-- @COPY_PARTS:[[:space:]]*//p' "$file" | head -1)"
  table_name="$(awk '{print $1}' <<<"$marker_rest")"
  csv_prefix="$(awk '{print $2}' <<<"$marker_rest")"
  [[ -z "$csv_prefix" ]] && csv_prefix="$table_name"

  # Glob broadly (any _part suffix), then keep only names that are
  # exactly <csv_prefix>_part<digits>.csv — a plain _part[0-9]*.csv glob
  # would still admit "partial" or "part1_OLD"-style stragglers, since
  # the trailing * matches any characters, not just more digits.
  local -a part_files=()
  local f bn
  for f in "$CSV_HOST"/"${csv_prefix}"_part*.csv; do
    [[ -e "$f" ]] || continue
    bn="$(basename "$f")"
    if [[ "$bn" =~ ^${csv_prefix}_part[0-9]+\.csv$ ]]; then
      part_files+=("$bn")
    fi
  done

  if [[ ${#part_files[@]} -eq 0 ]]; then
    echo "ERROR: no CSV parts found for '$table_name' (csv prefix '$csv_prefix') — expected $CSV_HOST/${csv_prefix}_part<N>.csv" >&2
    return 1
  fi

  local -a sorted_files=()
  local sf
  while IFS= read -r sf; do
    sorted_files+=("$sf")
  done < <(printf '%s\n' "${part_files[@]}" | sort -V)
  part_files=("${sorted_files[@]}")

  local out
  out="$(mktemp)"
  local n=${#part_files[@]}
  local last_file="${part_files[$((n - 1))]}"
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "-- @COPY_PARTS:"* ]]; then
      local pf
      for pf in "${part_files[@]}"; do
        printf "\\\\copy amc_raw.%s FROM '/csv/%s' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '\"', ESCAPE '\"');\n" "$table_name" "$pf"
      done
      printf '\n'
      printf 'INSERT INTO amc_meta.raw_load_log(table_name, csv_file, notes)\n'
      printf "VALUES ('%s', '%d file(s): %s..%s', '%d-part load, auto-detected at refresh time');\n" \
        "$table_name" "$n" "${part_files[0]}" "$last_file" "$n"
    else
      printf '%s\n' "$line"
    fi
  done < "$file" > "$out"

  printf '%s' "$out"
}

psql_run() {
  local file="$1"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    if grep -q '^-- @COPY_PARTS:' "$file" 2>/dev/null; then
      echo "[dry-run] would run: $file (contains @COPY_PARTS marker; part count resolved at run time)"
    else
      echo "[dry-run] would run: $file"
    fi
    return 0
  fi

  local run_file="$file"
  local tmp_created=0
  if grep -q '^-- @COPY_PARTS:' "$file" 2>/dev/null; then
    run_file="$(expand_copy_parts "$file")" || return 1
    tmp_created=1
  fi

  if [[ "$tmp_created" -eq 1 ]]; then
    echo "==> $file (expanded @COPY_PARTS -> $run_file)" | tee -a "$LOG_FILE"
  else
    echo "==> $file" | tee -a "$LOG_FILE"
  fi
  ${REFRESH_PSQL_CMD:-apptainer exec -B "${PGDATA_HOST}:/var/lib/postgresql/data" -B "${CSV_HOST}:/csv" "$SIF" psql -h /tmp -U postgres -d carenlp_db -v ON_ERROR_STOP=1} -f "$run_file" 2>&1 | tee -a "$LOG_FILE"

  if [[ "$tmp_created" -eq 1 ]]; then
    rm -f "$run_file"
  fi
}

run_stage_dir() {
  local dir="$1"; shift
  local wanted=("$@")
  local f base name matched w any_matched=0
  for f in "$dir"/*.sql; do
    [[ -e "$f" ]] || continue
    base="$(basename "$f" .sql)"
    name="${base#*_}"
    if [[ ${#wanted[@]} -eq 0 ]]; then
      psql_run "$f"
    else
      matched=0
      for w in "${wanted[@]}"; do
        [[ "$name" == "$w" ]] && matched=1
      done
      if [[ "$matched" -eq 1 ]]; then
        any_matched=1
        psql_run "$f"
      fi
    fi
  done
  if [[ ${#wanted[@]} -gt 0 ]] && [[ "$any_matched" -eq 0 ]]; then
    echo "WARNING: no files in $dir matched requested table(s): ${wanted[*]}" >&2
    return 1
  fi
  return 0
}

mkdir -p "$LOG_DIR"

if [[ "$STAGE" == "drop-raw" ]]; then
  echo "This will DROP SCHEMA amc_raw CASCADE on carenlp_db -- irreversible without re-running 01_raw_load."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] would prompt for confirmation, then run: DROP SCHEMA IF EXISTS amc_raw CASCADE;"
    exit 0
  fi
  read -r -p "Type 'drop raw' to confirm: " confirm
  if [[ "$confirm" != "drop raw" ]]; then
    echo "Aborted."
    exit 1
  fi
  tmp_sql="$(mktemp)"
  echo "DROP SCHEMA IF EXISTS amc_raw CASCADE;" > "$tmp_sql"
  psql_run "$tmp_sql"
  rm -f "$tmp_sql"
  exit 0
fi

if [[ -z "$STAGE" ]]; then
  for dir in "$SCRIPT_DIR"/[0-9][0-9]_*/; do
    [[ -d "$dir" ]] || continue
    run_stage_dir "${dir%/}"
  done
else
  if [[ ! -d "$SCRIPT_DIR/$STAGE" ]]; then
    echo "Unknown stage: $STAGE" >&2
    exit 1
  fi
  run_stage_dir "$SCRIPT_DIR/$STAGE" "${TABLES[@]}"
fi
