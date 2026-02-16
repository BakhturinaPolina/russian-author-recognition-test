# ART Data Cleaning Decisions

Documentation of cleaning steps applied to the Russian ART pretest dataset before IRT analysis.

**Source:** `scripts/data_prep/art_data_prep.ipynb`  
**Output:** `data/processed/art_cleaned/`  
**Date:** 2026-02-16

---

## Pre-Cleaning Diagnostics Summary

Diagnostics were run on the raw dataset (1,835 participants × 214 item columns). Key findings:

| Issue | Detail | Severity |
|-------|--------|----------|
| Duplicate column names | Ian Fleming ×2 (det4, mod33) | HIGH |
| Non-binary values | 1 cell: "falce" in Gerrit HoogenbuM fill1 | HIGH |
| Items >40% missing | 9 items | HIGH |
| Items 5–40% missing | 2 items (Yuri Tsypkin, Andrea Segre fill93) | MEDIUM |
| Duplicate item codes | 14 codes (metadata only) | MEDIUM |
| Near-floor items (<1%) | 13 items | LOW |
| Ceiling items (>95%) | 7 items | LOW |

---

## Cleaning Decisions Applied

### Step 1: Recode non-binary value
- **Item:** Gerrit HoogenbuM fill1 (fill1)
- **Issue:** 1 cell contained "falce" (typo for "false")
- **Action:** Recode → 0 (non-endorsement)
- **Rationale:** Single cell; treat as data-entry error.

### Step 2: Drop duplicate Ian Fleming (mod33)
- **Item:** Ian Fleming at position 213, code mod33
- **Issue:** Duplicate column; 99.9% missing (1834/1835)
- **Action:** Drop this column; keep Ian Fleming det4 (position 65, 0.1% missing)
- **Rationale:** mod33 effectively empty; det4 has usable data.

### Step 3: Drop 8 items with >40% missing
- **Items:** Sergey Nikitin fill 103, Lyudmila Ulitskaya, Alexander Tvardovsky, Ilya Ilf, Ivan Savin fill 102, Evgenia Serova fill 104, Vladimir Gusakov fill 101, Chabo Chucky fill 105
- **Action:** Exclude from analysis
- **Rationale:** Moore & Gordon (2015) and IRT practice: items with >40% missing yield unstable parameter estimates.

### Step 4: Keep items with 5–40% missing
- **Items:** Yuri Tsypkin (mod31, 31.9%), Andrea Segre fill 93 (31.4%)
- **Action:** Retain
- **Rationale:** Below 40% threshold; useful for IRT; can run sensitivity checks if needed.

### Step 5: Duplicate item codes
- **Action:** No change
- **Rationale:** Metadata issue only; items are distinct. Optionally fix codes in metadata table later.

### Step 6: Near-floor and ceiling items
- **Action:** Retain for main analysis
- **Rationale:** Ceiling items (Jack London, Agatha Christie, etc.) are highly recognizable but still informative. Near-floor items are mostly foils (expected). Optional sensitivity analyses may exclude ceiling items.

---

## Output Files

| File | Description |
|------|--------------|
| `ART_pretest_merged_EN_cleaned.csv` | Cleaned dataset; same structure as raw (row 0 = labels, row 1 = codes, rows 2+ = data) |
| `item_metadata.csv` | Retained items: item_index, item_label, item_code, is_real_author, is_foil |
| `excluded_items.csv` | Dropped items and reason |

---

## Summary

- **Before:** 214 items, 1,835 participants
- **After:** 205 items, 1,835 participants
- **Dropped:** 9 items (1 duplicate + 8 high-missing)
- **Recoded:** 1 cell ("falce" → 0)

Downstream IRT analysis (`scripts/analysis/irt_art_analysis.ipynb`) should use `data/processed/art_cleaned/ART_pretest_merged_EN_cleaned.csv` as input.
