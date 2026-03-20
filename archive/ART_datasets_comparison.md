# ART pretest datasets: comparison and recommendation

## 1. The three main ART files

| File | Participants | Item columns | Demographics | Item labels |
|------|--------------|--------------|--------------|-------------|
| **ART_prestest_responses.xlsx** | **800** | **205** | Row 0 (Russian) | Russian author/foil names in row 0 |
| **polinaART.xlsx** | **1,035** | **214** | Cols 0–4 (English/coded) | Coded: `fil*`, `mod*`, `cla*`, `det*`, `sci*`, `soc*`, etc. |
| **pretest_dataset_ART_only_EN.xlsx** | **1,035** | **214** | Row 0 (English) | Row 0: English names; row 1: codes (`fill*`, `mod*`, `cla*`, …) |

### Participant count

- **polinaART.xlsx** and **pretest_dataset_ART_only_EN.xlsx** are the **same respondents**: 1,035 participants. First row of data matches (date, age, sex, education). The doc “ART pretest Castano analysis” refers to 1,036 — likely an earlier version or counting including a header.
- **ART_prestest_responses.xlsx** is a **different (smaller) export**: 800 participants and **different first row** (other submission time, age, sex). So it is **not** the same sample as polinaART/pretest_EN; it is a subset or a different batch (e.g. earlier export or filtered).

### Item count

- **214-item version** (polinaART, pretest_EN): 106 real authors + 108 foils (see `docs/ART_pretest_Castano_analysis.md`).
- **205-item version** (ART_prestest_responses): same item **order** as the first 205 columns of the 214-item file. The **last 9 items** of the full list are missing (from “Vladimir Gusakov fill 101” through “Ian Fleming”). So 205 = 214 − 9.

### Structure

- **pretest_EN**: Row 0 = English labels, row 1 = short codes (e.g. `fill1`, `mod1`, `cla1`), rows 2+ = data. Column order is **not** the same as in polinaART (different code names: `fill1` vs `fil2`, `mod2` vs `mod13`, etc.).
- **polinaART**: One header row with coded column names; 108 foil codes (`fil2`, `fil22`, …) and 106 real-author codes (`mod*`, `cla*`, `det*`, `sci*`, `soc*`, `fan*`, `rom*`). Same 214 items, different column order than pretest_EN.
- **ART_prestest_responses**: Russian labels in row 0; 205 columns; no second “code” row. Aligns by **position** with the first 205 columns of pretest_EN (same item order).

---

## 2. 67- and 98-author lists (ODS)

| File | Authors | Content |
|------|---------|--------|
| **67_avtorov_rus.ods** | **67** (68 name columns; one may be empty) | Row 0: Russian author names. Rows 1–7: metadata (country, period, level, etc.). |
| **98_avtorov_rus.ods** | **98** | Same structure; extended list. 98 = 67 + 30 (all 67 are contained in the 98 list). |

- These are **curated author pools** with metadata (Russian), not response data.
- Names are in **Russian**; pretest_EN and polinaART use **English** names or **codes**. So matching 67/98 to pretest items needs a name/code mapping (e.g. via ART_prestest_responses Russian headers or real_authors.xls).

---

## 3. Why the numbers differ

### Participants

- **800 (ART_prestest_responses)** vs **1,035 (polinaART / pretest_EN)**: different exports or subsamples. The 800-file is not “the same dataset with fewer rows” — the first respondent differs (date, age, sex, text), so it’s a different or filtered batch.
- **1,035 vs 1,036**: the written “1,036” in the Castano analysis is almost certainly the same study; the 1-row difference is likely header vs data-row counting.

### Authors / items

- **67** and **98**: number of **real authors** in the two ODS pools (metadata tables).
- **106**: number of **real-author items** in the 214-item pretest (polinaART / pretest_EN). So the pretest uses **more** real authors (106) than the 67 list and **more** than the 98 list (98). The pretest item set is **not** a subset of 67 or 98; it’s a larger set.
- **205** (ART_prestest_responses): 214 minus the last 9 items in the same order.

---

## 4. Recommendation: start from polinaART vs 67/98

### Option A: Use **polinaART.xlsx** as the core dataset

**Pros**

- **Largest sample**: 1,035 participants (vs 800 in ART_prestest_responses).
- **Full item set**: all 214 items (vs 205 in the Russian export).
- **Already used in analysis**: `docs/ART_pretest_Castano_analysis.md` and IRT pipeline assume 214 items, 106 real + 108 foils, and this sample.
- **Clean layout**: one header row, numeric 0/1 responses, coded columns; no extra “code” row to strip.
- **Demographics** in English/coded form (sex, age, humanities, education).

**Cons**

- Column names are **codes** (`fil2`, `mod1`, …), not names. You need a **mapping** from code → author/foil (available from `pretest_dataset_ART_only_EN.xlsx`: row 0 = names, row 1 = codes; or from `real_authors.xls` / `not_real_authors.xls` if you link codes to those lists).
- Column **order** differs from pretest_EN; merging by code (not by index) is required.

**Conclusion:** For **existing pretest analyses and IRT**, starting from **polinaART as the core** is easier: same N and item set as in the docs, no need to re-derive who is real vs foil or to stitch 800 + 205 with the 1,035 + 214 dataset.