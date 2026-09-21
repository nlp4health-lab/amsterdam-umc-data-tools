###################################################################################
# metadata_extraction.py
#
# Script to generate metadata (char, word, token length, etc.) from processed notes.
# Reads each CSV file in streaming mode to avoid memory overload.
#
# TEST mode: processes a single row for inspection.
# FULL mode: processes all CSV files inside the input directory.
#
# To run (with optional custom dirs):
#   NOTES_PROCESSED_DIR="dir" NOTES_METADATA_DIR="dir" python metadata_extraction.py
###################################################################################

import csv
import sys
from pathlib import Path
import tiktoken
import os

# --------------------------------
# 1. CSV configuration
# --------------------------------
# Increase CSV field size limit to handle large notes
csv.field_size_limit(sys.maxsize)

# --------------------------------
# 2. Script settings
# --------------------------------
TEST = True
TEST_FILE = "merged_part_1_01.csv"
TEST_ROW = 1   

# --------------------------------
# 3. Tokenizer setup
# --------------------------------
enc = tiktoken.get_encoding("o200k_base") # used in gpt 4o, gpt 5

def count_tokens(text: str) -> int:
    """Return number of tokens in text using the selected tokenizer."""
    if not isinstance(text, str) or not text.strip():
        return 0
    try:
        return len(enc.encode(text))
    except Exception:
        return 0


def process_row(row: dict, source_name: str) -> dict:
    """Compute metadata for a single note row.

    Reads extraction_and_cleaning.py's output columns (pseudo_id,
    patient_note_id, patient_note_category -- amc_notes's current
    schema). Writes amc_notes_metadata's own columns (subject_id,
    note_id, note_type), which were never renamed -- see
    free-text-search/README.md.
    """
    text = row.get("note_text", "") or ""
    return {
        "subject_id": row.get("pseudo_id", ""),
        "note_id": row.get("patient_note_id", ""),
        "note_type": row.get("patient_note_category", ""),
        "char_length": len(text),
        "word_length": len(text.split()),
        "token_length": count_tokens(text),
        "source_file": source_name,
    }


def compute_metadata_streaming(file_path: Path):
    """Process a full CSV file line by line and write metadata to output."""
    print(f"Processing {file_path.name} (streaming mode)")

    output_file = output_folder / f"metadata_{file_path.stem}.csv"

    with open(file_path, "r", encoding="utf-8", errors="replace") as f_in, \
         open(output_file, "w", newline="", encoding="utf-8") as f_out:

        reader = csv.DictReader(f_in)
        fieldnames = ["subject_id", "note_id", "note_type", "char_length",
                      "word_length", "token_length", "source_file"]
        writer = csv.DictWriter(f_out, fieldnames=fieldnames)
        writer.writeheader()

        for i, row in enumerate(reader):
            meta = process_row(row, file_path.name)
            writer.writerow(meta)

            # Progress feedback every 50k rows
            if i % 50000 == 0 and i > 0:
                print(f"  → {i:,} notes processed...")

    print(f" ---- Done: {output_file.name}")

# --------------------------------
# 4. Run main
# --------------------------------
if __name__ == "__main__":

    # Resolve folders from environment or fallback to defaults
    input_folder = Path(os.getenv("NOTES_PROCESSED_DIR", "data/processed"))
    output_folder = Path(os.getenv("NOTES_METADATA_DIR", "data/metadata"))
    output_folder.mkdir(parents=True, exist_ok=True)

    if TEST:
        print(" ---- TEST MODE: processing a single note")

        test_file = input_folder / TEST_FILE

        with open(test_file, "r", encoding="utf-8", errors="replace") as f:
            reader = csv.DictReader(f)

            for i, row in enumerate(reader):
                if i == TEST_ROW:
                    meta = process_row(row, test_file.name)
                    print("\n--- Sample Metadata Output ---")
                    print(meta)
                    print("\n ---- TEST complete.")
                    break
            else:
                print(f" ---- Row {TEST_ROW} not found in {TEST_FILE}")

    else:
        all_files = sorted(input_folder.glob("*.csv"))
        print(f"Found {len(all_files)} files in {input_folder}")

        for file_path in all_files:
            compute_metadata_streaming(file_path, output_folder)

        print("\n ---- Metadata generation complete for all files.")