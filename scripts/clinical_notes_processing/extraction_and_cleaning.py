###################################################################################
#extraction_and_cleaning.py
# Script to extract and clean clinical notes from raw files
# Outputs cleaned notes into CSV files, splitting by size if needed
# to run:
#RAW_NOTES_DIR="dir" PROCESSED_NOTES_DIR="dir" python extraction_and_cleaning.py
###################################################################################
import re
import pandas as pd
from pathlib import Path
import unicodedata
import os

# --------------------------------
# 1. Cleaning function
# --------------------------------
def clean_and_format(text):
    """Basic cleanup and formatting of clinical notes."""
    if not isinstance(text, str):
        return ""

    # encoding cleanup
    text = unicodedata.normalize("NFKC", text)
    text = text.replace("\xa0", " ").replace("\u200b", "")
    text = ''.join(ch for ch in text if ch.isprintable())

    # remove URLs or emails
    text = re.sub(r'https?://\S+|www\.\S+|\S+@\S+\.\S+', '', text)

    # structure formatting
    text = text.replace('\r', ' ')
    text = re.sub(r'[ \t]{2,}', '\n', text)                 # long spaces to line breaks (to recover structure)
    text = re.sub(r'(?<![\w\)])\s*[*·•∙]\s*', '\n- ', text) # bullet points to newline
    text = re.sub(r'[ \t]+', ' ', text)                     # multiple spaces to single space
    text = re.sub(r'\n{2,}', '\n', text)                    # multiple line breaks to single
    text = re.sub(r'(?<=\w)\s+:\s*', ': ', text)            # normalize space around colon
    text = re.sub(r' *\n *', '\n', text)                    # trim spaces around line breaks
    return text.strip()

# --------------------------------
# 2. Parser for each raw file
# --------------------------------
def parse_notes_file(file_path):
    """Parse one raw notes file and return cleaned DataFrame."""
    notes = []
    with open(file_path, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            fields = line.strip().split("\t", 5)
            # expected fields: subject_id, note_id, timestamp, note_type, [author], note_text
            # not all notes have author field
            # the order of author and note_text may vary
            if len(fields) == 5:
                subj, note_id, ts, note_type, note = fields
                author = ""
            elif len(fields) == 6:
                subj, note_id, ts, note_type, fifth, sixth = fields
                # detect if author comes after note
                if (
                    (fifth.startswith('"') and fifth.endswith('"') and not (sixth.startswith('"') and sixth.endswith('"')))
                    or (len(sixth) < 80 and len(sixth.split()) <= 6 and len(re.findall(r'[.:;!?]', sixth)) < 1)
                ):
                    note, author = fifth, sixth
                else:
                    author, note = fifth, sixth
            else:
                continue

            notes.append({
                "subject_id": subj,
                "note_id": note_id,
                "timestamp": ts,
                "note_type": note_type.rstrip("|"),
                "author_note": author,
                "note_text": clean_and_format(note)
            })

    df = pd.DataFrame(notes)
    df["date_note"] = pd.to_datetime(df["timestamp"], errors="coerce").dt.date
    print(f"{file_path.name}: parsed {len(notes)} notes")
    return df[["subject_id", "note_id", "date_note", "note_type", "author_note", "note_text"]]


# --------------------------------
# 3. Batch processing across all files
# --------------------------------
def process_folder(folder_path, output_dir, start_idx=0, end_idx=None, split_after_gb=4.5):
    """Process all files in folder_path, merge them into large CSVs
    saved in output_dir, and start a new file once the current
    merged CSV exceeds split_after_gb."""

    folder = Path(folder_path)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    files = sorted(folder.glob("*.csv"))
    if end_idx:
        files = files[start_idx:end_idx]
    else:
        files = files[start_idx:]

    print(f"Found {len(files)} files in {folder_path}")
    print([f.name for f in files[:5]])  # show first few

    total_size = 0
    part = 1
    output_file = output_dir / f"{Path(folder_path).stem}_{part:02d}.csv"
    mode = "w"
    header = True

    for i, fpath in enumerate(files, start=1):
        print(f"Processing file {i}/{len(files)}: {fpath.name}")
        df = parse_notes_file(fpath)

        file_name = fpath.stem
        part = 1
        output_file = output_dir / f"{file_name}_{part:02d}.csv"

        # save first part
        df.to_csv(output_file, mode=mode, header=header, index=False)
        mode, header = "a", False  # append mode after first write
        
        # check file size and rotate if above limit
        total_size = output_file.stat().st_size / (1024 ** 3)
        if total_size >= split_after_gb and i < len(files):
            print(f"--> Reached {total_size:.2f} GB, starting new part...")
            part += 1
            output_file = output_dir / f"{Path(folder_path).stem}_{part:02d}.csv"
            mode, header = "w", True
            total_size = 0

        del df

    print("\n Finished processing all files.")
    print(f"Parts saved in: {output_dir}")

# --------------------------------
# 4. Run main
# --------------------------------
if __name__ == "__main__":

    input_folder = Path(os.getenv("RAW_NOTES_DIR", "data/raw"))
    output_folder = Path(os.getenv("PROCESSED_NOTES_DIR", "data/processed"))

    process_folder(input_folder, output_folder, start_idx=0, end_idx=None, split_after_gb=4.5)
    #process_folder(input_folder, output_folder, start_idx=0, end_idx=5, split_after_gb=0.1) #test run
