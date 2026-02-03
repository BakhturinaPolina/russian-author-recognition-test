# RT СИНТАКСИСright.xlsx — Data Analysis Report

> **Note:** Despite "СИНТАКСИС" (syntax) in the filename, this file contains **ART (Author Recognition Test) binary response data**, NOT reaction time data.

## Dataset Overview

| Property | Value |
|----------|-------|
| **File** | `RT СИНТАКСИСright.xlsx` |
| **Total Participants** | 870 |
| **Total ART Items** | 195 |
| **Data Type** | Binary (0/1) author recognition responses |

---

## File Structure

```
Row 0: Demographic column labels (SEX, ID, AGE, EDUCATION, etc.)
Row 1: Item Q-codes (Q10, Q11, Q12, ... Q208)
Row 2: Author names (Agatha Christie, Adjay Kohley, etc.)
Row 3: Empty
Row 4+: Participant data
```

### Column Layout
- **Columns 0–16:** Demographics and metadata
- **Columns 17–211:** ART item responses (binary 0/1)

---

## Demographics

| Variable | Distribution |
|----------|--------------|
| **Sex** | M: 353 (41%), F: 343 (39%), none: 174 (20%) |
| **Education** | school, university, etc. |
| **Humanities connection** | + (yes) / - (no) |

---

## ART Item Analysis

### Endorsement Rates

| Statistic | Value |
|-----------|-------|
| N Items | 195 |
| Mean endorsement | ~50% |
| Range | 13.3% – 100% |

### Easiest Items (Ceiling)
| Author | Endorsement |
|--------|-------------|
| Jules Verne | 100.0% |
| Alexandre Dumas | 97.6% |
| Jack London | 96.8% |
| Chingiz Aitmatov | 96.8% |
| Arthur Conan Doyle | 96.2% |

### Hardest Items (Floor)
| Author | Endorsement |
|--------|-------------|
| Tatiana Kasyonnova | 13.3% |
| Sergey Lukyanenko | 14.1% |
| Vasily Usun | 14.5% |
| Victor Khlystun | 15.3% |
| Alexandre Petrikov | 15.6% |

---

## Foil Classification

**Critical Issue:** No items are explicitly marked as foils in this file.

However, comparing with `rightART ТОЛОКА.xlsx`:
- Author lists are **IDENTICAL** (194 matching names)
- The ТОЛОКА file has the same item set

**Implication:** Foil classification must be inferred from:
1. Cross-referencing with other files that have explicit foil markers
2. Using endorsement rate thresholds (<10% = likely foil)

---

## Relationship to Other Files

| File | Relationship |
|------|--------------|
| `rightART ТОЛОКА.xlsx` | **IDENTICAL** author list (194/194 match) |
| `rightART-ТОЛОКА-2.0.xlsx` | Same study, different administration |
| `ART_pretest_(for Castano).xlsx` | Different study (214 items with explicit foil markers) |

---

## Data Quality

| Issue | Status |
|-------|--------|
| Missing sex data | 174 participants (20%) have "none" |
| Item labels | No explicit author vs foil distinction |
| Binary format | ✓ Clean 0/1 responses |

---

## Recommended Use

This file is suitable for:
1. **Exploratory analysis** of ART response patterns
2. **Comparison** with other ART administrations (ТОЛОКА files)
3. **IRT modeling** (after merging foil classification from external source)

**Not suitable for:**
- Standalone IRT analysis (missing foil classification)
- RT/reaction time analysis (data is binary, not RT)

---

*Report generated: 2026-02-03*
