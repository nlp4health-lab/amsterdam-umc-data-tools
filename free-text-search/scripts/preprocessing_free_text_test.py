import pandas as pd
from pathlib import Path
import re
import unicodedata

def clean_and_format(text):
    """
    Clean clinical notes.
    (Encoding, normalization, and structural formatting).
    """
    if not isinstance(text, str):
        return ""

    # ---------------------------
    # Encoding cleanup
    # ---------------------------
    # normalize accents and characters
    text = unicodedata.normalize("NFKC", text)
    # replace non-breaking spaces, zero-width, etc.
    text = text.replace("\xa0", " ").replace("\u200b", "")
    # keep only printable characters
    text = ''.join(ch for ch in text if ch.isprintable())

    # ---------------------------
    # Remove unwanted tokens: URLs and emails
    # ---------------------------
    text = re.sub(r'https?://\S+|www\.\S+', '', text)
    text = re.sub(r'\S+@\S+\.\S+', '', text)

    # ---------------------------
    # Normalization
    # ---------------------------
    text = text.replace('\r', ' ')
    text = re.sub(r' {2,}', '\n', text)             # 2 or more spaces to newline (srtuctural breaks)
    text = re.sub(r'\s*[·•∙]\s*', '\n- ', text)     # bullet points to newline
    text = re.sub(r'[ \t]+', ' ', text)             # collapse multiple spaces/tabs
    text = re.sub(r'\n+', '\n', text)               # collapse blank lines
#    text = re.sub(r' {2,}', ' ', text)              # double to single spaces
    text = re.sub(r'(?<=\w)\s+:\s*', ': ', text)    # normalize spacing around colons
    text = text.strip()

    # ---------------------------
    # Structure
    # ---------------------------
    # Newline before capitalized headers
#    text = re.sub(r'(?<!\n)([A-ZÄÖÜ][A-Za-zÄÖÜäöü\s/]{2,25}:)', r'\n\1', text)

    # Newline before short all-caps abbreviations (CZS:, DIG:, etc.)
#    text = re.sub(r'(?<!\n)([A-Z]{2,6}:)', r'\n\1', text)

    # Newline before dashes (bullets)
#    text = re.sub(r'\s*-\s*', r'\n- ', text)

    # Newline before numbered bullets
#    text = re.sub(r'(\d+[\.\)])\s*', r'\n\1 ', text)

    # Newline before date-like patterns (e.g., 03-01-2023)
#    text = re.sub(r'(?<!\n)(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})', r'\n\1', text)

    # Remove any excessive newlines from additions above
#    text = re.sub(r'\n{2,}', '\n', text)

    return text

path = Path("/mnt/data/AUMC_data/merged/free-text-notes/merged_carenlp_1.csv")

df = pd.read_csv(path, nrows=10)

orignial_note = df.loc[8, "note"]

cleaned_note = clean_and_format(orignial_note)

print("Original Note:\n", orignial_note)
print("\nCleaned Note:\n", cleaned_note)