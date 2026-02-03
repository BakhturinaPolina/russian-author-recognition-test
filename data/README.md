# Data

Canonical dataset for Russian ART (Author Recognition Test) and PISA reading comprehension.

## Layout

```
data/
├── raw/          # Unprocessed source files (DO NOT EDIT)
│   ├── pretest_dataset_ART_only_EN.xlsx
│   ├── adults_dataset1_ART.csv
│   ├── adults_dataset1_PISA.csv
│   ├── adults_dataset2_ART.csv
│   ├── adults_dataset2_PISA.csv
│   ├── children_dataset1_ART.csv
│   ├── children_dataset1_PISA.csv
│   ├── children_dataset2_ART.csv
│   ├── children_dataset2_PISA.csv
│   ├── no_birthdate_dataset1_ART.csv
│   ├── no_birthdate_dataset1_PISA.csv
│   ├── no_birthdate_dataset2_ART.csv
│   └── no_birthdate_dataset2_PISA.csv
└── processed/    # Derived outputs (scripts may write here)
```

## Source

- **pretest_dataset_ART_only_EN.xlsx** — Main ART pretest, English labels (authors + foils, explicit labels).
- **\*_ART.csv** — ART binary responses (same study as OUT_next_version_of_firt_one).
- **\*_PISA.csv** — PISA reading comprehension (Molnár play excerpt, open-ended questions).

## Usage in Python

```python
import pandas as pd

# ART (adults, dataset 1)
art = pd.read_csv("data/raw/adults_dataset1_ART.csv")

# PISA (adults, dataset 1)
pisa = pd.read_csv("data/raw/adults_dataset1_PISA.csv")

# Pretest (Castano, English labels)
pretest = pd.read_excel("data/raw/pretest_dataset_ART_only_EN.xlsx")
```

## Linking

Match participants across ART and PISA by the nickname column (e.g. "ПОМОГИТЕ!!!11111..." in raw CSVs).
