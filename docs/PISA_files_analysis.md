# PISA Files Analysis — Version Comparison Report

## Overview

The PISA (Programme for International Student Assessment) reading comprehension data exists in multiple versions across the project. This report identifies the **correct version** for analysis.

---

## Source Files (from `pisa_analysis.ipynb`)

The original data processing notebook used:
```python
AP_file = './PISA/ART+PISA_2.0/CSV/ART_PISA_2.0.csv'  # Combined ART+PISA
P_file = './PISA/PISA_2.0/CSV/PISA_2.0.csv'           # PISA only
```

These source files are **not present** in the current directory structure.

---

## Available PISA Files

### Raw Response Files

| File | N | PISA Questions | Status |
|------|---|----------------|--------|
| `OUT 2/OUT/adults_dataset1_PISA.csv` | 169 | 4 | Older version |
| `OUT 2/OUT/adults_dataset2_PISA.csv` | 149 | 2 | Dataset 2 |
| `OUT_next_version_of_firt_one/OUT/adults_dataset1_PISA.csv` | **196** | 4 | **✓ RECOMMENDED** |
| `OUT_next_version_of_firt_one/OUT/adults_dataset2_PISA.csv` | 188 | 2 | Dataset 2 |

### Scored Data

| File | N | Format | Status |
|------|---|--------|--------|
| `Res_Recalculated_PISA1.csv` | **196** | Score + Points | **✓ RECOMMENDED** |

---

## PISA Questions (4 items)

The PISA reading comprehension task uses an excerpt from Ferenc Molnár's play "Theater — and Nothing But Theater."

1. **Q1:** Что делали герои пьесы непосредственно перед тем, как поднялся занавес?
   - *What were the characters doing just before the curtain rose?*

2. **Q2:** Почему четверть часа, по мнению Турая, – «целая вечность»?
   - *Why does Turay consider fifteen minutes "an eternity"?*

3. **Q3:** Почему Адам больше всех взволнован?
   - *Why is Adam the most excited?*

4. **Q4:** Что хочет сказать Молнар-драматург, начав свою пьесу таким образом?
   - *What is Molnár trying to say by starting his play this way?*

---

## Scoring (from `Res_Recalculated_PISA1.csv`)

| Score | Points | N | % |
|-------|--------|---|---|
| 0% | 0 | 2 | 1% |
| 25% | 1 | 6 | 3% |
| 50% | 2 | 30 | 15% |
| 75% | 3 | 91 | 46% |
| 100% | 4 | 65 | 33% |
| 125% | 5 | 2 | 1% |

**Note:** 125% indicates bonus points for exceptional responses.

---

## Recommended Files for Analysis

### For Raw Text Responses
```
✓ OUT_next_version_of_firt_one/OUT/adults_dataset1_PISA.csv
  - N = 196 participants
  - 4 PISA questions with full text responses
  - Most complete version
```

### For Pre-Scored Data
```
✓ Res_Recalculated_PISA1.csv
  - N = 196 participants
  - Score (%) and Points (0-4+) columns
  - Skip first row when reading (header row in data)
```

### Reading the Scored File
```python
import pandas as pd
pisa_scores = pd.read_csv('Res_Recalculated_PISA1.csv', skiprows=1)
pisa_scores.columns = ['Respondent ID', 'Nickname', 'Score', 'Points']
```

---

## Participant Linkage

PISA files link to ART data via **Nickname** column:

| Metric | Value |
|--------|-------|
| PISA nicknames | 195 |
| ART nicknames (empty_rm) | 171 |
| Overlap | ~150 |

**Linking strategy:**
```python
nick_col = 'ПОМОГИТЕ!!!11111Пожалуйста, придумайте псевдоним!...'
# Normalize: lowercase, strip whitespace
```

---

## Files NOT Recommended

| File | Reason |
|------|--------|
| `OUT 2/OUT/adults_dataset1_PISA.csv` | Fewer participants (169 vs 196) |
| `quiz/quiz/quizResults*.csv` | ART quiz scores, not PISA |

---

## Relationship to pisa_analysis.ipynb

The notebook performs:
1. Load combined ART+PISA data
2. Filter by age (adults > 18)
3. Match nicknames across files
4. Output to `./OUT/` folder

**Output mapping:**
- Notebook output → `OUT/OUT/` folder
- "Next version" → `OUT_next_version_of_firt_one/OUT/` (updated processing)

---

*Report generated: 2026-02-03*
