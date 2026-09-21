library(data.table)
library(httr)

structured_dir <- "G:/divjk/kik/NLP/AUMC_data/structured_data_copy"   # your directory

# Add your DeepL API key via the DEEPL_API_KEY environment variable
DEEPL_KEY <- Sys.getenv("DEEPL_API_KEY")
if (identical(DEEPL_KEY, "")) stop("Set the DEEPL_API_KEY environment variable before running this script.")

files_full <- list.files(structured_dir, full.names = TRUE)
files_base <- basename(files_full)

# strip extension for translation
files_noext <- sub("\\.csv$", "", files_base)

translated_files_raw <- deepl_translate_batched(files_noext, auth_key = DEEPL_KEY)

translated_final <- paste0(translated_files_raw, ".csv")

mapping_files <- data.table(
  original_filename = files_base,
  translated_filename = translated_final
)

fwrite(mapping_files, file.path(structured_dir, "file_name_mapping.csv"))
message("Mapping saved: file_name_mapping.csv")


###### Rename files based on mapping

mapping_files <- fread(file.path(structured_dir, "file_name_mapping.csv"))

for (i in seq_len(nrow(mapping_files))) {
  old <- file.path(structured_dir, mapping_files$original_filename[i])
  new <- file.path(structured_dir, mapping_files$translated_filename[i])
  file.rename(old, new)
}

