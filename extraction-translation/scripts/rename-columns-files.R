###############################################################
# COPY + RENAME FILES + RENAME COLUMNS (USING translated2)
###############################################################

library(data.table)
library(tools)

###############################################################
# CONFIG — edit these paths
###############################################################

# connection_config.R is gitignored -- copy connection_config.R.example
# to create your own (see README.md).
source("connection_config.R")

# Source folder with the original structured CSVs
src_dir <- file.path(data_root, "structured_data")

# Destination folder (will be created; must NOT already contain your source files)
dst_dir <- file.path(data_root, "structured_data_translated")

# Mappings
col_map_path  <- file.path(data_root, "mappings/column_mapping_second_pass.csv")
file_map_path <- file.path(data_root, "mappings/file_name_mapping.csv")

# If TRUE: overwrite existing files in dst_dir
overwrite <- TRUE

###############################################################
# Helpers
###############################################################

ensure_dir <- function(path) {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)
}

# Make safe filenames (optional but recommended)
sanitize_filename <- function(x) {
  x <- gsub("[<>:\"/\\\\|?*]", "_", x)   # Windows-illegal characters
  x <- gsub("\\s+", "_", x)
  x <- gsub("_+", "_", x)
  x
}

###############################################################
# STEP 1 — Load mappings
###############################################################

message("Loading mappings...")

col_map <- fread(col_map_path)
stopifnot(all(c("original", "translated2") %in% names(col_map)))

# build column rename dictionary: original_col -> translated2
col_dict <- setNames(col_map$translated2, col_map$original)

file_map <- fread(file_map_path)
stopifnot(all(c("original_filename", "translated_filename") %in% names(file_map)))

# build file rename dictionary: original_filename -> translated_filename
# (we’ll sanitize translated filenames just in case)
file_map[, translated_filename := sanitize_filename(translated_filename)]
file_dict <- setNames(file_map$translated_filename, file_map$original_filename)

###############################################################
# STEP 2 — Create destination folder and copy everything
###############################################################

message("Copying folder to destination...")

if (dir.exists(dst_dir) && !overwrite) {
  stop("Destination folder already exists and overwrite = FALSE: ", dst_dir)
}
ensure_dir(dst_dir)

# Copy recursively (keeps subfolder structure)
all_paths <- list.files(src_dir, full.names = TRUE, recursive = TRUE, include.dirs = TRUE)

# Create destination subfolders first
src_dirs <- all_paths[file.info(all_paths)$isdir]
if (length(src_dirs) > 0) {
  for (d in src_dirs) {
    rel <- substring(d, nchar(src_dir) + 2)           # relative path
    ensure_dir(file.path(dst_dir, rel))
  }
}

# Copy files
src_files <- all_paths[!file.info(all_paths)$isdir]
if (length(src_files) > 0) {
  for (f in src_files) {
    rel <- substring(f, nchar(src_dir) + 2)
    out <- file.path(dst_dir, rel)
    dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
    ok <- file.copy(f, out, overwrite = overwrite, copy.mode = TRUE, copy.date = TRUE)
    if (!ok) warning("Failed to copy: ", f)
  }
}

message("Copy complete: ", dst_dir)

###############################################################
# STEP 3 — Rename CSV files according to file_name_mapping.csv
###############################################################

message("Renaming files based on file mapping...")

dst_csvs <- list.files(dst_dir, full.names = TRUE, recursive = TRUE, pattern = "\\.csv$", ignore.case = TRUE)

# Skip mapping files if they happen to be in the folder
skip_names <- c("column_mapping_second_pass.csv", "file_name_mapping.csv")
dst_csvs <- dst_csvs[!(basename(dst_csvs) %in% skip_names)]

# Rename only the basename if it appears in mapping; keep same folder
rename_log <- data.table(
  old_path = character(),
  new_path = character(),
  action   = character()
)

for (p in dst_csvs) {
  b <- basename(p)
  if (!is.na(file_dict[b])) {
    new_base <- file_dict[b]
    # Preserve extension if your mapping omitted it
    if (file_ext(new_base) == "") {
      new_base <- paste0(new_base, ".", file_ext(b))
    }
    new_path <- file.path(dirname(p), new_base)
    
    if (file.exists(new_path) && !overwrite) {
      rename_log <- rbind(rename_log, data.table(old_path = p, new_path = new_path, action = "SKIP_EXISTS"))
      next
    }
    
    ok <- file.rename(p, new_path)
    if (!ok) {
      rename_log <- rbind(rename_log, data.table(old_path = p, new_path = new_path, action = "FAILED"))
    } else {
      rename_log <- rbind(rename_log, data.table(old_path = p, new_path = new_path, action = "RENAMED"))
    }
  } else {
    rename_log <- rbind(rename_log, data.table(old_path = p, new_path = p, action = "NO_MAPPING"))
  }
}

fwrite(rename_log, file.path(dst_dir, "file_rename_log.csv"))
message("File rename done. Log saved to file_rename_log.csv")

###############################################################
# STEP 4 — Rename columns inside each CSV using translated2
###############################################################

message("Renaming columns inside CSVs...")

# refresh list after renaming
dst_csvs2 <- list.files(dst_dir, full.names = TRUE, recursive = TRUE, pattern = "\\.csv$", ignore.case = TRUE)
dst_csvs2 <- dst_csvs2[!(basename(dst_csvs2) %in% c(skip_names, "file_rename_log.csv"))]

col_log <- data.table(
  file = character(),
  renamed_cols = integer(),
  total_cols = integer()
)

for (f in dst_csvs2) {
  message("Processing: ", f)
  
  dt <- fread(f, showProgress = FALSE)
  old <- names(dt)
  
  # apply mapping original -> translated2; fallback to original if not found
  new <- vapply(old, function(x) {
    y <- col_dict[[x]]
    if (!is.null(y) && !is.na(y) && nzchar(y)) y else x
  }, character(1))
  
  # If duplicates happen after renaming, make them unique to avoid fwrite errors
  if (any(duplicated(new))) {
    new <- make.names(new, unique = TRUE)
  }
  
  setnames(dt, old, new)
  fwrite(dt, f)
  
  col_log <- rbind(col_log, data.table(
    file = f,
    renamed_cols = sum(old != new),
    total_cols = length(old)
  ))
}

fwrite(col_log, file.path(dst_dir, "column_rename_log.csv"))
message("Column rename done. Log saved to column_rename_log.csv")

message("ALL DONE")
