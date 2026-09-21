###############################################################
# CONFIG
###############################################################

library(data.table)

# SET THIS EACH RUN -- must match 010's output_dir for this run
# (the folder holding the raw extracted CSVs to translate).
raw_dir <- "G:/divjk/kik/NLP/AUMC_data/structured_data_SET_DATE_HERE"

# SET THIS EACH RUN -- new folder this script creates and populates.
# 040 and 050 both operate on this same folder afterward -- keep all
# three in sync.
translated_dir <- "G:/divjk/kik/NLP/AUMC_data/structured_data_SET_DATE_HERE_copy"

mapping_file <- "G:/divjk/kik/NLP/AUMC_data/mappings/column_mapping_second_pass.csv"

if (!dir.exists(translated_dir)) {
  dir.create(translated_dir, recursive = TRUE)
}

###############################################################
# LOAD MAPPING
###############################################################

message("Loading mapping file: ", mapping_file)

mapping <- fread(mapping_file, header = FALSE)

# First row actually contains the real column names
setnames(mapping, as.character(unlist(mapping[1, ])))
mapping <- mapping[-1]

# Remove empty extra columns if present
mapping <- mapping[, !names(mapping) %in% c("", NA), with = FALSE]

message("Columns found in mapping file: ", paste(names(mapping), collapse = ", "))

required_cols <- c("original", "translated2")
missing_cols <- setdiff(required_cols, names(mapping))

if (length(missing_cols) > 0) {
  stop(
    "Mapping file is missing required columns: ",
    paste(missing_cols, collapse = ", "),
    "\nActual columns found: ",
    paste(names(mapping), collapse = ", ")
  )
}

# Remove empty rows / missing mappings
mapping <- mapping[
  !is.na(original) & original != "" &
    !is.na(translated2) & translated2 != ""
]

# Build named vector: original -> translated2
name_map <- setNames(mapping$translated2, mapping$original)

###############################################################
# FIND FILES
###############################################################

files <- list.files(raw_dir, full.names = TRUE, pattern = "\\.csv$")

if (length(files) == 0) {
  stop("No CSV files found in: ", raw_dir)
}

message("Found ", length(files), " CSV files.")

###############################################################
# RENAME COLUMNS AND WRITE COPIES
###############################################################

for (f in files) {
  message("Processing: ", basename(f))
  
  dt <- fread(f)
  old_names <- names(dt)
  
  mapped_vals <- name_map[old_names]
  
  new_names <- ifelse(!is.na(mapped_vals) & mapped_vals != "", mapped_vals, old_names)
  
  unmapped <- old_names[is.na(mapped_vals) | mapped_vals == ""]
  if (length(unmapped) > 0) {
    message("  Unmapped columns kept as-is: ", paste(unmapped, collapse = ", "))
  }
  
  setnames(dt, old_names, new_names)
  
  out_file <- file.path(translated_dir, basename(f))
  fwrite(dt, out_file)
  
  message("  -> Written to: ", out_file)
}

message("Done.")
