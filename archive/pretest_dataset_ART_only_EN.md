# pretest_dataset_ART_only_EN.xlsx — Data Description

## Overview

| Property | Value |
|----------|-------|
| **File** | `data/raw/pretest_dataset_ART_only_EN.xlsx` |
| **Content** | ART (Author Recognition Test) pretest with **English labels** |
| **Origin** | English version of `pretest_dataset_ART_only.xlsx` (Russian labels), produced by `scripts/translate_art_dataset.py` |
| **Sheets** | Single sheet (Sheet1) |
| **Total Participants** | 1,036 |
| **Total ART Items** | 214 (106 real authors + 108 foils) |

This file has the **same layout and data** as the Russian pretest; only **text** (column headers, demographic labels, author/foil names, etc.) is translated to English for readers who do not use Russian.

---

## File Structure

The workbook is read with **no header row** in code (`header=None`), so row 0 is the first data row.

| Column range | Content |
|--------------|---------|
| **0–4** | Demographics: e.g. Submitted (date), age, sex, humanities-related (yes/no), profession/education |
| **5–218** | ART items (214 binary “Is this an author?” items) |

- **Real authors (106):** item label is the author name (e.g. Jules Verne, Agatha Christie). Used for IRT modeling.
- **Foils (108):** item label includes `"fill"` + number (e.g. `fill1`, `fill37`). Used for penalty scoring only, not in the IRT model.

---

## Demographics (Columns 0–4)

Approximate mapping (exact wording is in the file; below is typical meaning):

| Index | Meaning | Notes |
|-------|---------|--------|
| 0 | Submitted / date | Survey submission time |
| 1 | Age | Numeric |
| 2 | Sex | Male / Female (or equivalent) |
| 3 | Humanities-connected | Yes / No (reading, books, literature) |
| 4 | Education / profession | Free text or category |

From the analysis of the Russian source: Age M = 27.5, SD = 9.7; ~67% female, ~33% male; 42 profession categories (e.g. science & education, service, IT).

---

## ART Items (Columns 5–218)

- **Response format:** Binary — participant indicates whether the name is a real author (e.g. 1/0 or Yes/No). Stored in the cell as number or text.
- **Item order:** Same as in the Russian file; column headers in the EN file are the translated author/foil names.
- **Duplicate:** “Ian Fleming” appears twice (columns 70 and 218) — same as in source.

---

## Data Quality (same as source)

1. **Missing:** No participant has complete data on all items; 6 items have >10% missing.
2. **Coding:** Mostly 0/1; some cells may contain text (e.g. “fill1”, “falce”) and need cleaning before numeric/IRT analysis.
3. **Foils:** Identified by the word “fill” plus a number in the column header (e.g. “fill1”, “fill37”).

---

## Usage in Python

```python
import pandas as pd

# Read with no header so row 0 = first row of data
df = pd.read_excel("data/raw/pretest_dataset_ART_only_EN.xlsx", header=None)

# Demographics
demo = df.iloc[:, :5]

# ART response matrix (columns 5–218)
art_matrix = df.iloc[:, 5:219]
```

---

## Relationship to Other Files

| File | Relationship |
|------|--------------|
| `pretest_dataset_ART_only.xlsx` | Russian-label source; same structure and cell values. EN file is its translated copy. |
| `scripts/translate_art_dataset.py` | Script that generates this EN file from the Russian xlsx. |
| `docs/ART_pretest_Castano_analysis.md` | Analysis report for the pretest (Russian file); statistics and interpretation apply to this EN file as well. |

---

## IRT / Analysis Readiness

Same as the Russian pretest:

- Binary responses (after cleaning) and large N (1,036) are suitable for IRT (e.g. Moore & Gordon, 2015).
- Separate real-author vs foil columns; foils for penalty only.
- No PISA or other validation measures are in this file; link to other datasets by participant ID or nickname if needed.

---

*Document describes: `data/raw/pretest_dataset_ART_only_EN.xlsx` only. Structure and stats aligned with `docs/ART_pretest_Castano_analysis.md` and `scripts/translate_art_dataset.py`.*
