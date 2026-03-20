# ART Pretest — Data Analysis Report

## Dataset Overview

| Property | Value |
|----------|-------|
| **File** | `pretest_dataset_ART_only.xlsx` |
| **Total Participants** | 1,036 |
| **Total Items** | 214 |
| **Real Authors** | 106 |
| **Foils** | 108 (marked with "fill" + number) |

---

## Demographics

| Variable | Summary |
|----------|---------|
| **Age** | M = 27.5, SD = 9.7, Range = 1–65 |
| **Sex** | 692 female (67%), 343 male (33%) |
| **Humanities-connected** | 231 yes / 667 no / 3 missing |
| **Education/Profession** | 42 categories (top: science & education, service industry, IT) |

---

## Item Classification

### Real Authors (N = 106)
Items for IRT modeling (Moore & Gordon, 2015 methodology).

| Statistic | Value |
|-----------|-------|
| Mean endorsement | 52.1% |
| SD | 25.9% |
| Range | 4.3% – 100% |

**Easiest items (ceiling):**
- Jules Verne (98.1%)
- Jack London (97.7%)
- Arthur Conan Doyle (97.2%)
- Agatha Christie (97.1%)

**Hardest items (floor):**
- Yustein Gordier (4.3%)
- Reshad Nuri Gyuntekin (5.1%)
- Marie-Aude Murai (7.2%)
- Lee Bardugo (7.3%)

### Foils (N = 108)
Items for penalty scoring only — **not included in IRT model**.

| Statistic | Value |
|-----------|-------|
| Mean false alarm rate | 4.4% |
| SD | 4.1% |
| Range | 0.1% – 21.9% |

**Highest false alarm rates:**
- Пол Уильямс fill37 (21.9%)
- Валентин Левин fill24 (19.1%)
- Владимир Поздняков fill13 (16.8%)

---

## Psychometric Properties

| Metric | Value | Interpretation |
|--------|-------|----------------|
| Author Hits | M = 53.2, SD = 21.7 | Good variance |
| Foil False Alarms | M = 4.7, SD = 7.6 | Low guessing |
| ART Raw Score | M = 48.5, SD = 21.9 | Normal distribution |
| Hits–FA Correlation | r = 0.148 | Guessing ≠ ability (good) |

---

## IRT Analysis Readiness

| Criterion | Status |
|-----------|--------|
| Binary response format (0/1) | ✓ Ready |
| Sample size (N > 300 recommended) | ✓ N = 1,036 |
| Item difficulty range | ✓ 4% – 100% |
| Foils identified separately | ✓ 108 foils marked |
| Moore & Gordon design compliance | ✓ Authors + foils separated |

---

## Data Quality Notes

1. **Missing data:** No participants have complete data across all items; 6 items have >10% missing
2. **Response coding:** Mostly 0/1; some cells contain text ("fill1", "falce") — require cleaning
3. **Duplicate item:** "Ian Fleming" appears twice (columns 70 and 218)

---

## Limitations

**No external validation measures in this file:**
- No PISA reading comprehension scores
- No vocabulary measures
- No reading speed data
- No syntax/morphology processing measures

External validation data exists in separate files (`OUT 2/OUT/adults_dataset1_PISA.csv`) but appears to be from a **different sample** (~170 participants vs 1,036 here).

---

## Recommended Analysis Pipeline

### Phase 1: Data Preparation
1. Extract binary ART matrix (columns 5–218)
2. Clean non-numeric values
3. Separate authors from foils using "fill" marker

### Phase 2: IRT Modeling (Moore & Gordon Steps 1–5)
1. EFA for dimensionality check
2. Fit 1PL, 2PL, 3PL models
3. Model comparison → select 2PL
4. Extract item parameters (a, b)
5. Estimate θ (EAP)

### Phase 3: Scoring
1. Calculate θ-based ART scores
2. Apply foil penalties (−1 or −2 per false alarm)
3. Compare penalty options

### Phase 4: External Validation (requires linked data)
- Correlate θ with reading measures
- Test convergent/discriminant validity

---

## File Structure Reference

```
Columns 0-4:   Demographics (Submited, age, sex, humanities, profession)
Columns 5-218: ART items
  - Real authors: No "fill" in name
  - Foils: "fill" + number in name (e.g., "Геррит ХугенбуM fill1"). See `translate_art_dataset.py` for English version.
```

---

*Report generated: 2026-02-03*
