###############################################################
# CONFIG
###############################################################

library(data.table)
library(deeplr)

# connection_config.R is gitignored -- copy connection_config.R.example
# to create your own (see README.md).
source("connection_config.R")

# Paths (edit these)
raw_dir       <- file.path(data_root, "structured_data")
translated_dir <- file.path(data_root, "structured_data_copy")

# Make sure output folder exists
if (!dir.exists(translated_dir)) dir.create(translated_dir)

# Add your DeepL API key via the DEEPL_API_KEY environment variable
DEEPL_KEY <- Sys.getenv("DEEPL_API_KEY")
if (identical(DEEPL_KEY, "")) stop("Set the DEEPL_API_KEY environment variable before running this script.")

###############################################################
# STEP 1 — Extract column names from all CSVs
###############################################################

message("STEP 1: Extracting all column names...")

files <- list.files(raw_dir, full.names = TRUE, pattern = "\\.csv$")
all_cols <- unique(unlist(
  lapply(files, function(f) names(fread(f, nrows = 1)))
))

length(all_cols)
head(all_cols)


###############################################################
# STEP 2 — Split CamelCase, PascalCase, and underscores
###############################################################

split_words <- function(x) {
  x <- gsub("_", " ", x)
  x <- gsub("([a-z])([A-Z])", "\\1 \\2", x)
  x <- gsub("([A-Z]+)([A-Z][a-z])", "\\1 \\2", x)
  unlist(strsplit(x, " "))
}

word_lists <- lapply(all_cols, split_words)
unique_words <- unique(tolower(unlist(word_lists)))

message("Found ", length(unique_words), " unique word components.")


###############################################################
# STEP 3 — DeepL translation via REST API
###############################################################

deepl_translate_batched <- function(text_vector, batch_size = 50, target_lang = "EN", source_lang = "NL", auth_key) {
  url <- "https://api-free.deepl.com/v2/translate"
  results <- character(length(text_vector))
  names(results) <- text_vector
  
  batches <- split(text_vector, ceiling(seq_along(text_vector) / batch_size))
  
  for (i in seq_along(batches)) {
    batch <- batches[[i]]
    
    resp <- POST(
      url = url,
      body = c(
        list(
          auth_key = auth_key,
          source_lang = source_lang,
          target_lang = target_lang
        ),
        setNames(as.list(batch), rep("text", length(batch)))
      ),
      encode = "form"
    )
    
    out <- content(resp)
    
    if (!is.null(out$error)) {
      warning("DeepL error in batch ", i, ": ", out$error$message)
      results[batch] <- batch
      next
    }
    
    # Ensure translations exist
    if ("translations" %in% names(out)) {
      translated_batch <- sapply(out$translations, function(x) x$text)
      names(translated_batch) <- batch
      results[batch] <- translated_batch
    } else {
      warning("Unexpected response in batch ", i, ", keeping originals.")
      results[batch] <- batch
    }
    
    Sys.sleep(0.4)  # avoid rate limit
  }
  
  return(results)
}



message("STEP 3: Translating word components via DeepL...")

translated_words <- deepl_translate(unique_words, auth_key = DEEPL_KEY)


warnings()

# normalize
translated_words_clean <- gsub(" ", "_", tolower(translated_words))
translated_words_clean <- gsub("[^a-z0-9_]", "", translated_words_clean)

# dictionary: Dutch → English
word_dict <- setNames(translated_words_clean, unique_words)

head(word_dict)


###############################################################
# STEP 4 — Reconstruct full English column names
###############################################################

message("STEP 4: Reconstructing final English column names...")

reconstruct_name <- function(col_name) {
  parts <- split_words(col_name)
  parts_low <- tolower(parts)
  translated_parts <- word_dict[parts_low]
  
  # fallback for untranslated words (e.g., acronyms)
  translated_parts[is.na(translated_parts)] <- parts_low[is.na(translated_parts)]
  
  paste(translated_parts, collapse = "_")
}

translated_cols <- sapply(all_cols, reconstruct_name)

mapping <- data.table(
  original = all_cols,
  translated = translated_cols
)

fwrite(mapping, file.path(translated_dir, "column_mapping.csv"))
message("Column mapping saved.")

###############################################################
# STEP X — Second-stage translation of whole snake_case names
###############################################################

message("STEP X: Second-stage translation of whole translated names...")

# Remove underscores temporarily because DeepL doesn't like them
#clean_for_translation <- function(x) {
#  gsub("_", " ", x)
#}

# Prepare vector
#to_retranslate <- sapply(mapping$translated, clean_for_translation)

# Translate (batched)
translated2_raw <- deepl_translate_batched(mapping$translated, auth_key = DEEPL_KEY)

# Reintroduce snake_case
#translated2_clean <- gsub(" ", "_", tolower(translated2_raw))
#translated2_clean <- gsub("[^a-z0-9_]", "", translated2_clean)

# Add to mapping
mapping[, translated2 := translated2_raw]

# Save new mapping
fwrite(mapping, file.path(translated_dir, "column_mapping_second_pass.csv"))
message("Second-stage mapping saved.")

###############################################################
# STEP 6 — Apply new column names to all CSVs
###############################################################

message("STEP 6: Applying translations to all CSV files...")

mapping <- fread(file.path(translated_dir, "column_mapping_second_pass.csv"))

files <- list.files(translated_dir, full.names = TRUE, pattern = "\\.csv$")

for (f in files) {
  message("Processing: ", basename(f))
  
  dt <- fread(f)
  old <- names(dt)
  
  new <- sapply(old, function(x) {
    match <- mapping[original == x]
    if (nrow(match) == 1) match$translated2 else x   # or match$final column name
  })
  
  setnames(dt, old, new)
  
  fwrite(dt, f)   # overwrite the same file
  message(" → Updated: ", f)
}

message("ALL DONE! Final English column names applied in-place in translated_dir.")
