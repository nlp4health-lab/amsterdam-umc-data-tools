library(DBI)
library(odbc)
library(data.table)

# ============================================================
# CONNECT TO SQL SERVER
# ============================================================

con <- dbConnect(
  odbc(),
  Driver = "SQL Server",
  Server = "p1wp10012-bi-us.prod1.umcinfra.nl",
  Database = "Uitgifte",
  Trusted_connection = "yes",
  timeout = 60,
  Port = 1433
)


# ============================================================
# OUTPUT DIRECTORY
# ============================================================

# SET THIS EACH RUN -- recommended: the same folder as 010's
# output_dir for this run, so extraction output and metadata live
# together.
output_dir <- paste0(
  "G:/divjk/kik/NLP/AUMC_data/",
  "structured_data_SET_DATE_HERE/"
)

dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# ============================================================
# GET METADATA FOR ALL CaRe_NLP TABLES
# ============================================================

metadata_query <- "
SELECT
    TABLE_SCHEMA AS table_schema,
    TABLE_NAME AS table_name,
    ORDINAL_POSITION AS column_order,
    COLUMN_NAME AS column_name,
    DATA_TYPE AS data_type,
    CHARACTER_MAXIMUM_LENGTH AS character_maximum_length,
    NUMERIC_PRECISION AS numeric_precision,
    NUMERIC_SCALE AS numeric_scale,
    DATETIME_PRECISION AS datetime_precision,
    IS_NULLABLE AS is_nullable,
    COLUMN_DEFAULT AS column_default
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'CaRe_NLP'
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;
"

metadata <- dbGetQuery(
  con,
  metadata_query
)

metadata <- as.data.table(metadata)


# ============================================================
# SAVE METADATA
# ============================================================

metadata_file <- file.path(
  output_dir,
  "CaRe_NLP_table_metadata.csv"
)

fwrite(
  metadata,
  metadata_file
)

message(
  "Metadata saved to:\n",
  metadata_file
)

message(
  "Tables: ",
  uniqueN(metadata$table_name)
)

message(
  "Total columns: ",
  nrow(metadata)
)


# ============================================================
# OPTIONAL: TABLE-LEVEL SUMMARY
# ============================================================

table_summary <- metadata[
  ,
  .(
    number_of_columns = .N
  ),
  by = .(
    table_schema,
    table_name
  )
]

summary_file <- file.path(
  output_dir,
  "CaRe_NLP_table_summary.csv"
)

fwrite(
  table_summary,
  summary_file
)

message(
  "\nTable summary saved to:\n",
  summary_file
)


# ============================================================
# CLOSE CONNECTION
# ============================================================

dbDisconnect(con)