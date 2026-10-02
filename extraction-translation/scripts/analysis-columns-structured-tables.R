# ============================================
# Scan CSV headers in a folder (dedupe *_partN)
# Output: dataset_name, source_file, column_name
# ============================================

# Install if needed:
# install.packages("data.table")

library(data.table)

# connection_config.R is gitignored -- copy connection_config.R.example
# to create your own (see README.md).
source("connection_config.R")

# ---- CONFIG ----
folder <- file.path(data_root, "structured_data_translated")
out_csv <- file.path(folder, "csv_columns_index.csv")

# ---- HELPERS ----
# dataset key: remove _part<number> before .csv (case-insensitive)
dataset_key <- function(path) {
  fn <- basename(path)
  sub("(?i)_part[0-9]+(?=\\.csv$)", "", fn, perl = TRUE)
}

# part number (NA if not a part file)
part_number <- function(path) {
  fn <- basename(path)
  m <- regexec("(?i)_part([0-9]+)\\.csv$", fn, perl = TRUE)
  reg <- regmatches(fn, m)[[1]]
  if (length(reg) == 2) as.integer(reg[2]) else NA_integer_
}

# read just the header names (no data)
get_colnames <- function(path) {
  # fread(nrows=0) reads only header
  names(fread(path, nrows = 0, showProgress = FALSE))
}

# ---- MAIN ----
files <- list.files(folder, pattern = "\\.csv$", full.names = TRUE)

if (length(files) == 0) {
  stop("No .csv files found in: ", folder)
}

dt_files <- data.table(
  path = files,
  file = basename(files)
)
dt_files[, dataset := dataset_key(path)]
dt_files[, part := part_number(path)]

# Choose ONE representative file per dataset:
# Prefer part1 if it exists; otherwise choose the smallest part number; otherwise any non-part file
setorder(dt_files, dataset, is.na(part), part)  # non-part first? (is.na(part)=TRUE sorts last by default)
# Better explicit preference: part1 -> other parts -> non-part
dt_files[, pref := fifelse(!is.na(part) & part == 1L, 0L,
                           fifelse(!is.na(part), 1L, 2L))]
setorder(dt_files, dataset, pref, part, file)

dt_pick <- dt_files[, .SD[1], by = dataset]  # one file per dataset

# Extract columns
result_list <- lapply(seq_len(nrow(dt_pick)), function(i) {
  p <- dt_pick$path[i]
  ds <- dt_pick$dataset[i]
  f <- dt_pick$file[i]
  
  cols <- tryCatch(get_colnames(p), error = function(e) {
    warning("Failed reading header for: ", f, " | ", conditionMessage(e))
    character(0)
  })
  
  if (length(cols) == 0) {
    data.table(dataset_name = ds, source_file = f, column_name = NA_character_)
  } else {
    data.table(dataset_name = ds, source_file = f, column_name = cols)
  }
})

out <- rbindlist(result_list, use.names = TRUE, fill = TRUE)
fwrite(out, out_csv)

cat("Wrote:", out_csv, "\n")
cat("Datasets indexed:", uniqueN(out$dataset_name), "\n")
