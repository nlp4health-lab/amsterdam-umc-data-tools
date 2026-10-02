library(DBI)
library(odbc)
library(data.table)

# connection_config.R is gitignored -- copy connection_config.R.example
# to create your own (see README.md).
source("connection_config.R")

# -----------------------------
# Connect to SQL Server
# -----------------------------
con <- dbConnect(
  odbc(),
  Driver = "SQL Server",
  Server = sql_server_host,
  Database = sql_server_db,
  Trusted_connection = "yes",
  timeout = 60,
  Port = 1433
)

tables <- dbListTables(con, schema = "CaRe_NLP")
tables

# -----------------------------
# Function: Chunked table export
#
# Always orders LOB/long-text columns (text, ntext, image, xml, or
# unbounded varchar/nvarchar/varbinary) to the end of the SELECT list.
# This avoids SQL Server's ODBC "Invalid Descriptor Index" error, which
# occurs when a LOB column appears before other columns in this kind of
# paginated ROW_NUMBER() query. Verified safe: for a table with no LOB
# columns, or whose LOB columns already sit last, this ordering is
# identical to the table's natural column order -- confirmed against
# CaRe_NLP_table_metadata.csv (see
# docs/superpowers/specs/2026-09-18-extraction-translation-pipeline-design.md),
# where it only changes anything for 2 of 59 tables (the two that
# previously needed the separate extract-problematic-tables.R retry).
# -----------------------------
save_table_in_chunks <- function(
    con,
    table,
    chunk_size = 3000000,
    out_dir,
    max_file_size_gb = 4
) {
  message("\n===== Processing table: ", table, " =====")

  file_index <- 1
  current_file <- file.path(out_dir, paste0(table, "_part", file_index, ".csv"))

  # Remove previously generated files for this table
  old_files <- list.files(
    out_dir,
    pattern = paste0("^", table, "_part[0-9]+\\.csv$"),
    full.names = TRUE
  )
  if (length(old_files) > 0) {
    file.remove(old_files)
  }

  # Total row count
  count_query <- paste0("SELECT COUNT(*) AS n FROM [CaRe_NLP].[", table, "]")
  total_rows <- dbGetQuery(con, count_query)$n
  message("Total rows: ", total_rows)

  # Column metadata -- identify LOB columns to move to the end
  column_query <- paste0(
    "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, ORDINAL_POSITION ",
    "FROM INFORMATION_SCHEMA.COLUMNS ",
    "WHERE TABLE_SCHEMA = 'CaRe_NLP' AND TABLE_NAME = '", table, "' ",
    "ORDER BY ORDINAL_POSITION"
  )
  column_info <- dbGetQuery(con, column_query)

  lob_cols <- column_info[
    column_info$DATA_TYPE %in% c("text", "ntext", "image", "xml") |
      (column_info$DATA_TYPE %in% c("varchar", "nvarchar", "varbinary") &
         column_info$CHARACTER_MAXIMUM_LENGTH == -1),
    "COLUMN_NAME"
  ]
  other_cols <- setdiff(column_info$COLUMN_NAME, lob_cols)

  if (length(lob_cols) > 0) {
    message("Long/LOB columns moved to end: ", paste(lob_cols, collapse = ", "))
  } else {
    message("No long/LOB columns detected.")
  }

  ordered_cols <- c(other_cols, lob_cols)
  col_sql <- paste(sprintf("[%s]", ordered_cols), collapse = ", ")

  # Chunked download
  starts <- seq(1, total_rows, by = chunk_size)
  for (start in starts) {
    end <- min(start + chunk_size - 1, total_rows)
    message("  -> Fetching rows ", start, " to ", end)

    chunk_query <- paste0(
      "SELECT ", col_sql, " ",
      "FROM (",
      "  SELECT ", col_sql, ", ",
      "         ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS row_num_for_chunk ",
      "  FROM [CaRe_NLP].[", table, "]",
      ") AS t ",
      "WHERE t.row_num_for_chunk BETWEEN ", start, " AND ", end
    )

    chunk <- dbGetQuery(con, chunk_query)
    if (nrow(chunk) == 0) {
      message("  (no more rows)")
      break
    }

    # row_num_for_chunk is never in col_sql, so it never reaches R -- but
    # strip a leftover 'rn' column defensively too, in case the source
    # table itself ever has a real column under that literal name.
    if ("rn" %in% names(chunk)) {
      chunk[, rn := NULL]
    }

    if (file.exists(current_file)) {
      size_gb <- file.size(current_file) / (1024^3)
      if (size_gb >= max_file_size_gb) {
        file_index <- file_index + 1
        current_file <- file.path(out_dir, paste0(table, "_part", file_index, ".csv"))
        message("----- File reached ", round(size_gb, 2), " GB, starting new file: ", current_file)
      }
    }

    fwrite(chunk, current_file, append = file.exists(current_file))
  }

  message("----- DONE: Saved ", file_index, " files in ", out_dir)
}

# -----------------------------
# Download ALL CaRe_NLP tables
# -----------------------------
# SET THIS EACH RUN -- date-stamp the folder for this extract, matching
# the convention the prior scripts used (e.g. structured_data_27_08_26).
output_dir <- file.path(data_root, "structured_data_SET_DATE_HERE/")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

message("Found ", length(tables), " tables.")

failed_tables <- character(0)

for (i in seq_along(tables)) {
  table <- tables[i]

  message(
    "\n\n############################################",
    "\nTABLE ", i, " / ", length(tables), ": ", table,
    "\n############################################"
  )

  tryCatch(
    {
      save_table_in_chunks(
        con = con,
        table = table,
        chunk_size = 3000000,
        out_dir = output_dir,
        max_file_size_gb = 4
      )
    },
    error = function(e) {
      message("\n!!! ERROR downloading ", table, ": ", conditionMessage(e))
      failed_tables[[length(failed_tables) + 1]] <<- table
    }
  )
}

message("\n===== ALL TABLES FINISHED =====")
if (length(failed_tables) > 0) {
  message("Tables that failed: ", paste(failed_tables, collapse = ", "))
} else {
  message("All tables extracted successfully.")
}

dbDisconnect(con)
