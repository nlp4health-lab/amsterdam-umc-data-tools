library(data.table)

# connection_config.R is gitignored -- copy connection_config.R.example
# to create your own (see README.md).
source("connection_config.R")

# SET THIS EACH RUN -- must match 030's translated_dir exactly
# (renames the files 030 already created there, in place).
new_dir <- file.path(data_root, "structured_data_SET_DATE_HERE_copy")
mapping_file <- file.path(data_root, "mappings/file_name_mapping.csv")

mapping_files <- fread(mapping_file)

# Build a case-insensitive mapping:
# lowercase(original_filename) -> translated_filename
file_map <- setNames(
  mapping_files$translated_filename,
  tolower(mapping_files$original_filename)
)

files_full <- list.files(
  new_dir,
  full.names = TRUE,
  pattern = "\\.csv$",
  ignore.case = TRUE
)

files_base <- basename(files_full)

for (i in seq_along(files_full)) {

  old_full <- files_full[i]
  old_base <- files_base[i]

  # -----------------------------------
  # Extract _partX from current filename
  #
  # 010_extract_tables.R always writes chunked output as
  # <table>_part1.csv, _part2.csv, etc. -- every file here is
  # expected to carry a _partX suffix.
  # -----------------------------------
  part_match <- regmatches(
    old_base,
    regexpr("_part[0-9]+(?=\\.csv$)", old_base, perl = TRUE, ignore.case = TRUE)
  )

  if (length(part_match) == 0 || !nzchar(part_match)) {
    message("No _partX found in: ", old_base, " -> skipping")
    next
  }

  # -----------------------------------
  # Remove _partX for mapping lookup
  #
  # Example:
  # CaRe_NLP_AdverseEvent_part1.csv
  # -> CaRe_NLP_AdverseEvent.csv
  # -----------------------------------
  lookup_base <- sub(
    "_part[0-9]+(?=\\.csv$)",
    "",
    old_base,
    perl = TRUE,
    ignore.case = TRUE
  )

  # Case-insensitive lookup
  lookup_key <- tolower(lookup_base)

  new_base <- file_map[lookup_key]

  if (is.na(new_base) || !nzchar(new_base)) {
    message(
      "No mapping found for: ", old_base,
      " | searched as: ", lookup_base,
      " -> skipping"
    )
    next
  }

  # -----------------------------------
  # Remove any existing _partX from the
  # translated filename, just in case
  # -----------------------------------
  translated_base <- sub(
    "_part[0-9]+(?=\\.csv$)",
    "",
    new_base,
    perl = TRUE,
    ignore.case = TRUE
  )

  # -----------------------------------
  # Add the current file's _partX
  #
  # Example:
  # adverse_event.csv
  # -> adverse_event_part1.csv
  # -----------------------------------
  new_base <- sub(
    "\\.csv$",
    paste0(part_match, ".csv"),
    translated_base,
    ignore.case = TRUE
  )

  new_full <- file.path(new_dir, new_base)

  # -----------------------------------
  # Rename
  # -----------------------------------
  ok <- file.rename(old_full, new_full)

  if (ok) {
    message(
      "Renamed: ", old_base,
      " -> ", new_base
    )
  } else {
    warning(
      "Failed to rename: ", old_base,
      " -> ", new_base
    )
  }
}
