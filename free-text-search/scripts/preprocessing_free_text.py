import pandas as pd
from pathlib import Path
import re
import unicodedata

# --------------------------------
# Cleaning and formatting function
# --------------------------------
def clean_and_format(text):
    """
    Clean and lightly structure clinical notes
    """
    if not isinstance(text, str):
        return ""

    # --- Encoding cleanup ---
    # normalize accents and characters
    text = unicodedata.normalize("NFKC", text)
    # replace non-breaking spaces, zero-width, etc.
    text = text.replace("\xa0", " ").replace("\u200b", "")
    # keep only printable characters
    text = ''.join(ch for ch in text if ch.isprintable())

    # --- Remove URLs and emails ---
    text = re.sub(r'https?://\S+|www\.\S+', '', text)
    text = re.sub(r'\S+@\S+\.\S+', '', text)

    # --- Normalization ---
    text = text.replace('\r', ' ')
    text = re.sub(r' {2,}', '\n', text)             # 2 or more spaces to newline (srtuctural breaks)
    text = re.sub(r'\s*[·•∙]\s*', '\n- ', text)     # bullet points to newline
    text = re.sub(r'[ \t]+', ' ', text)             # collapse multiple spaces/tabs
    text = re.sub(r'\n+', '\n', text)               # collapse blank lines
    text = re.sub(r'(?<=\w)\s+:\s*', ': ', text)    # normalize spacing around colons
    text = re.sub(r' *\n *', '\n', text)            # trim spaces around newlines
    text = text.strip()

    return text

# --------------------------------
# Batch procesing
# --------------------------------
path = Path("/mnt/data/AUMC_data/merged/free-text-notes/merged_carenlp_1.csv")
output_path = path.with_name(path.stem + "_cleaned.csv")

chunksize = 2000

with pd.read_csv(path, chunksize=chunksize) as reader:
    for i, chunk in enumerate(reader, start=1):
        try:
            print(f"Processing chunk {i}...")
            chunk['note'] = chunk['note'].apply(clean_and_format)
            
            # Append to output file (write header only for first chunk)
            mode = 'w' if i == 1 else 'a'
            header = (i == 1)
            chunk.to_csv(output_path, mode=mode, header=header, index=False)

        except Exception as e:
            print(f"Error processing chunk {i}: {e}")
            error_path = path.with_name(f"error_chunk_{i}.csv")
            chunk.to_csv(error_path, index=False)
            print(f"Saved error chunk to {error_path}")

print(f"Cleaned notes saved to \n{output_path}")

