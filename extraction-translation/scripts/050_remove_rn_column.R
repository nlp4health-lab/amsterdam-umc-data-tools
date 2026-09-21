library(data.table)

# SET THIS EACH RUN -- must match 030/040's translated_dir
# (the same folder 040 already renamed files in).
folder <- "G:/divjk/kik/NLP/AUMC_data/structured_data_SET_DATE_HERE_copy/"

# Find all CSV files
csv_files <- list.files(
  folder,
  pattern = "\\.csv$",
  full.names = TRUE
)

message("Found ", length(csv_files), " CSV files.")

for (i in seq_along(csv_files)) {
  
  file <- csv_files[i]
  
  message(
    "\n[", i, "/", length(csv_files), "] ",
    basename(file)
  )
  
  tryCatch({
    
    # Read CSV
    dt <- fread(file)
    
    # Remove rn only if it exists
    if ("rn" %in% names(dt)) {
      
      message("  → 'rn' found. Removing...")
      
      dt[, rn := NULL]
      
      # Overwrite original file
      fwrite(dt, file)
      
      message("  ✓ Saved without 'rn'")
      
    } else {
      
      message("  → No 'rn' column. Nothing to do.")
      
    }
    
    # Free memory before next potentially large file
    rm(dt)
    gc()
    
  }, error = function(e) {
    
    message(
      "  !!! ERROR: ",
      conditionMessage(e)
    )
    
  })
}

message("\n===== DONE =====")