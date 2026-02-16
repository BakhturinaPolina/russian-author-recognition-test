# Data

Canonical dataset for Russian ART (Author Recognition Test) and PISA reading comprehension.

## Core ART pretest (merged)

**ART_pretest_merged_EN.xlsx** — **Core dataset**: merge of two exports, all text in English.

- **Participants:** 1,835 (800 from `ART_prestest_responses.xlsx` + 1,035 from `pretest_dataset_ART_only_EN.xlsx`).
- **Columns:** 5 demographics + 214 ART items + 1 `source` column (`ART_prestest_responses` | `pretest_EN`).
- **Structure:** Row 0 = English labels, row 1 = item codes, rows 2+ = data. Last 9 items are NaN for the 800-participant block (that export had 205 items only).
- **Produced by:** `scripts/merge_and_translate_art.py` (translates Russian to English like `translate_art_dataset.py`).

**author_lists/** — Reference lists for ART items: `real_authors.xls` (real authors + code), `not_real_authors.xls` (foils + code). Use for scoring and mapping item codes to names.

## Layout

```
data/
├── raw/          # Unprocessed source files (DO NOT EDIT)
│   ├── ART_pretest_merged_EN.xlsx   # Core merged pretest (see above)
│   ├── pretest_dataset_ART_only_EN.xlsx
│   ├── author_lists/ # Real vs foil item reference
│   │   ├── real_authors.xls
│   │   └── not_real_authors.xls
│   ├── adults/       # Adults (age > 18)
│   │   ├── adults_dataset1_ART.csv
│   │   ├── adults_dataset1_PISA.csv
│   │   ├── adults_dataset2_ART.csv
│   │   └── adults_dataset2_PISA.csv
│   ├── children/     # Children (age ≤ 18)
│   │   ├── children_dataset1_ART.csv
│   │   ├── children_dataset1_PISA.csv
│   │   ├── children_dataset2_ART.csv
│   │   └── children_dataset2_PISA.csv
│   └── no_birthdate/ # Participants with no birth date
│       ├── no_birthdate_dataset1_ART.csv
│       ├── no_birthdate_dataset1_PISA.csv
│       ├── no_birthdate_dataset2_ART.csv
│       └── no_birthdate_dataset2_PISA.csv
└── processed/    # Derived outputs (scripts may write here)
    └── art_cleaned/   # Cleaned ART pretest (from scripts/data_prep/art_data_prep.ipynb)
        ├── ART_pretest_merged_EN_cleaned.csv
        ├── item_metadata.csv
        └── excluded_items.csv
```

## Source

- **ART_pretest_merged_EN.xlsx** — Core ART pretest: merged 800 + 1,035 participants, all content in English (see above).
- **pretest_dataset_ART_only_EN.xlsx** — Original 1,035-participant ART pretest, English labels (authors + foils).
- **\*_ART.csv** — ART binary responses (same study as OUT_next_version_of_firt_one).
- **\*_PISA.csv** — PISA reading comprehension (Molnár play excerpt, open-ended questions).

## Usage in Python

```python
import pandas as pd

# ART (adults, dataset 1)
art = pd.read_csv("data/raw/adults/adults_dataset1_ART.csv")

# PISA (adults, dataset 1)
pisa = pd.read_csv("data/raw/adults/adults_dataset1_PISA.csv")

# Children or no_birthdate: data/raw/children/..., data/raw/no_birthdate/...

# Core merged pretest (recommended)
pretest = pd.read_excel("data/raw/ART_pretest_merged_EN.xlsx", header=None)
# Row 0 = labels, row 1 = codes, rows 2+ = data (1,835 rows). Last column = source.

# Original 1,035-participant pretest only
# pretest = pd.read_excel("data/raw/pretest_dataset_ART_only_EN.xlsx")

# Author lists (real vs foils) for scoring
# real = pd.read_excel("data/raw/author_lists/real_authors.xls", header=None)
# foils = pd.read_excel("data/raw/author_lists/not_real_authors.xls", header=None)
```

## Linking

Match participants across ART and PISA by the nickname column (e.g. "ПОМОГИТЕ!!!11111..." in raw CSVs).
