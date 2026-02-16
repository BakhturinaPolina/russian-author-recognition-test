# Raw Data Description

Description of every CSV file in `data/raw/`, its content, purpose, and the analysis stage at which it is used in the Moore & Gordon (2015) IRT-based ART replication for Russian.

> **Reference:** Moore, M., & Gordon, P. C. (2015). Reading ability and print exposure: Item response theory analysis of the Author Recognition Test. *Behavior Research Methods, 47*(4), 1095–1109.

---

## Study Design Overview

The study has two instruments administered as separate online surveys, linked by participant-chosen nickname:

| Instrument | Purpose | Moore & Gordon parallel |
|------------|---------|------------------------|
| **ART** (Author Recognition Test) | Measure print exposure via author-name recognition (101 real authors + 103 foils, binary 0/1) | ART used in Moore & Gordon (2015) for IRT calibration |
| **PISA reading comprehension** | Criterion measure of reading ability (open-ended + multiple-choice questions on text passages) | Nelson-Denny Reading Test used in Moore & Gordon (2015) for validity evidence |

Participants were split into three age-based folders after data collection:

- **adults/** — participants aged 18+
- **children/** — participants under 18
- **no_birthdate/** — participants who did not report birthdate (cannot be classified)

Within each age group, data was collected in two waves ("dataset 1" and "dataset 2"), each using a different PISA reading passage.

---

## File Inventory

### 1. `ART_pretest_merged_EN.csv`

| Property | Value |
|----------|-------|
| **Rows** | 1,837 (1 header + 1 item-code row + 1,835 participant rows) |
| **Columns** | ~210 (5 demographic + ~204 item columns + 1 source tag) |
| **Language** | English-translated column headers |

**Content.** The primary merged dataset combining both data-collection waves. Each row is one participant. Columns include:

- **Demographics:** `Submited` (timestamp), `age`, `sex`, `humanities or not`, `education and profession`
- **Item responses:** One column per stimulus name (101 real authors + 103 foils), coded 0/1
- **Row 2 (item codes):** Genre/type tags for each item — `mod` (modern fiction), `cla` (classic fiction), `soc` (Soviet/social realism), `det` (detective), `sci` (science fiction), `fan` (fantasy), `rom` (romance), `sfi` (sci-fi), `fill` (foil)
- **Source column:** `source` — identifies the data-collection wave

**Purpose.** This is the main analysis file for the ART. It is the cleaned, English-translated, binary-coded version of all ART responses.

**Analysis stage.** Used in:

| Stage | Moore & Gordon (2015) equivalent |
|-------|----------------------------------|
| Step 1 — Item descriptives (endorsement rates, floor/ceiling) | Table 1, Figure 1 |
| Step 2 — Dimensionality (EFA, KMO, parallel analysis, scree plot) | Dimensionality analysis |
| Step 3 — IRT calibration (2PL model fitting) | IRT model fitting |
| Step 4 — Item analysis (difficulty *b*, discrimination *a*) | Table 2, item parameter reporting |
| Step 5 — Diagnostics (ICCs, item information, test information, fit) | ICCs, TIF |
| Step 6 — Theta estimation (ability scores) | Ability estimation |
| Step 7 — Scoring comparison (IRT θ vs. classical hits-minus-FA) | Scoring-method comparison |
| Step 8 — Short-form construction (60-item subset) | Not in Moore & Gordon; extension |

---

### 2. `author_lists/real_authors.csv`

| Property | Value |
|----------|-------|
| **Rows** | 100 (1 header + 99 data rows) |
| **Columns** | 2 — author name (mixed Russian/English), recognition count |

**Content.** List of real fiction authors included in the ART with their raw recognition counts (number of participants who endorsed each name).

**Purpose.** Reference list for item identification, labeling, and endorsement-rate computation.

**Analysis stage.** Auxiliary file used at:
- Step 1 (item descriptives) — to map item columns to real-author identities
- Step 4 (item analysis) — to label IRT parameter tables
- Step 8 (short-form selection) — to identify retained items

---

### 3. `author_lists/not_real_authors.csv`

| Property | Value |
|----------|-------|
| **Rows** | 107 (1 header + 106 data rows) |
| **Columns** | 2 — foil name (Russian), false-alarm count |

**Content.** List of foil (non-author) names with the number of participants who incorrectly endorsed each name. Foil names were drawn from editorial boards of non-literary academic journals.

**Purpose.** Reference list for foil identification, false-alarm rate computation, and guessing-behavior analysis.

**Analysis stage.** Auxiliary file used at:
- Step 1 (item descriptives) — false-alarm rate distribution
- Step 7 (scoring comparison) — computing classical ART score (hits − false alarms)
- Data quality checks — flagging participants with excessive false-alarm rates

---

### 4. `adults/adults_dataset1_ART.csv`

| Property | Value |
|----------|-------|
| **Rows** | 264 (multi-row header + ~260 adult participants) |
| **Format** | Raw SurveyMonkey export (Russian) |

**Content.** ART responses from adult participants in data-collection wave 1. Columns include:

- SurveyMonkey metadata (Respondent ID, Collector ID, timestamps, IP)
- Demographics (initials/age/sex free-text, nickname ×2, gender, birthdate, education, literacy-related profession, work domain)
- ART item responses: each column header contains an image URL (postimg.cc) showing an author/foil name; responses are "Да" (yes) or blank/missing

**Purpose.** Raw source for adult ART data in wave 1, before merging and binary recoding.

**Analysis stage.** Upstream of `ART_pretest_merged_EN.csv`. Used for:
- Data preprocessing — merging waves, recoding Russian responses to 0/1, translating headers
- Participant linkage — nickname column links to `adults_dataset1_PISA.csv` for validation

---

### 5. `adults/adults_dataset1_PISA.csv`

| Property | Value |
|----------|-------|
| **Rows** | 198 (multi-row header + ~196 adult participants) |
| **Format** | Raw SurveyMonkey export (Russian) |
| **PISA task** | Play excerpt — Ferenc Molnár, "Theater — and Nothing But Theater" |

**Content.** Reading comprehension responses from adult participants in wave 1. Questions (4 items):

1. What were the characters doing before the curtain rose? (open-ended)
2. Why does Turay consider fifteen minutes "an eternity"? (multiple-choice)
3. Why is Adam the most excited? (open-ended with text evidence)
4. What is Molnár saying by starting his play this way? (multiple-choice)

Also includes the same demographic columns as the ART file and a nickname for cross-survey linkage.

**Purpose.** Criterion reading-ability measure for wave 1 adults. Analogous to the Nelson-Denny Reading Test used in Moore & Gordon (2015) to demonstrate that ART (print exposure) predicts reading ability.

**Analysis stage.** Used at:
- **Criterion validation** — correlating ART θ scores (from IRT calibration) with PISA reading comprehension scores
- Moore & Gordon (2015) equivalent: Table 4 (correlations between ART and reading measures)

---

### 6. `adults/adults_dataset2_ART.csv`

| Property | Value |
|----------|-------|
| **Rows** | 288 (multi-row header + ~285 adult participants) |
| **Format** | Raw SurveyMonkey export (Russian) |

**Content.** Identical in structure to `adults_dataset1_ART.csv` but from data-collection wave 2.

**Purpose & analysis stage.** Same as file 4 above. Merged into `ART_pretest_merged_EN.csv` for IRT calibration; linked via nickname to `adults_dataset2_PISA.csv` for validation.

---

### 7. `adults/adults_dataset2_PISA.csv`

| Property | Value |
|----------|-------|
| **Rows** | 206 (multi-row header + ~204 adult participants) |
| **Format** | Raw SurveyMonkey export (Russian) |
| **PISA task** | "Cow's milk: benefit or harm?" — two opposing articles on milk consumption |

**Content.** Reading comprehension responses from adult participants in wave 2. Questions include:

- Identifying factual claims supported by experts (multiple-choice)
- Identifying the purpose of a text (multiple-choice)
- Summarizing surprising research findings (open-ended)
- Distinguishing fact vs. opinion across two texts (multiple checkboxes)
- Identifying the core disagreement between authors (open-ended)
- Evaluating which discussion partner's position is best supported (multiple-choice + open-ended justification)

**Purpose.** Criterion reading-ability measure for wave 2 adults (different passage, same construct).

**Analysis stage.** Same as file 5 — criterion validation of ART against reading comprehension.

---

### 8. `children/children_dataset1_ART.csv`

| Property | Value |
|----------|-------|
| **Rows** | 45 (multi-row header + ~42 child/adolescent participants) |
| **Format** | Raw SurveyMonkey export (Russian) |

**Content.** ART responses from participants under 18, wave 1. Same column structure as adult ART files.

**Purpose.** Enables developmental comparison: do children's ART psychometric properties differ from adults'?

**Analysis stage.**
- Subgroup analysis — comparing IRT parameters or θ distributions across age groups
- Moore & Gordon (2015) did not include children; this is an extension

---

### 9. `children/children_dataset1_PISA.csv`

| Property | Value |
|----------|-------|
| **Rows** | 18 (multi-row header + ~16 child participants) |
| **Format** | Raw SurveyMonkey export (Russian) |
| **PISA task** | Play excerpt (same as `adults_dataset1_PISA.csv`) |

**Content.** Reading comprehension responses from children, wave 1.

**Purpose.** Criterion validation for the child subsample.

**Analysis stage.** Criterion validation (ART θ × PISA) within the child age group.

---

### 10. `children/children_dataset2_ART.csv`

| Property | Value |
|----------|-------|
| **Rows** | 39 (multi-row header + ~36 child participants) |
| **Format** | Raw SurveyMonkey export (Russian) |

**Content.** ART responses from children, wave 2.

**Purpose & analysis stage.** Same as file 8.

---

### 11. `children/children_dataset2_PISA.csv`

| Property | Value |
|----------|-------|
| **Rows** | 31 (multi-row header + ~29 child participants) |
| **Format** | Raw SurveyMonkey export (Russian) |
| **PISA task** | Milk articles (same as `adults_dataset2_PISA.csv`) |

**Content.** Reading comprehension responses from children, wave 2.

**Purpose & analysis stage.** Same as file 9.

---

### 12. `no_birthdate/no_birthdate_dataset1_ART.csv`

| Property | Value |
|----------|-------|
| **Rows** | 35 (multi-row header + ~32 participants) |
| **Format** | Raw SurveyMonkey export (Russian) |

**Content.** ART responses from participants who did not report a birthdate (wave 1). Cannot be classified as adult or child.

**Purpose.** Included in the merged pretest dataset for IRT calibration (all participants contribute to item parameter estimation regardless of age classification). Not used in age-group subgroup analyses.

**Analysis stage.** Merged into `ART_pretest_merged_EN.csv` for Steps 1–8.

---

### 13. `no_birthdate/no_birthdate_dataset1_PISA.csv`

| Property | Value |
|----------|-------|
| **Rows** | 2 (header only, 1 participant) |
| **Format** | Raw SurveyMonkey export (Russian) |
| **PISA task** | Play excerpt |

**Content.** Effectively empty — only 1 participant without birthdate completed the PISA in wave 1.

**Purpose.** Negligible; retained for completeness.

---

### 14. `no_birthdate/no_birthdate_dataset2_ART.csv`

| Property | Value |
|----------|-------|
| **Rows** | 32 (multi-row header + ~29 participants) |
| **Format** | Raw SurveyMonkey export (Russian) |

**Content.** ART responses from participants without birthdate, wave 2.

**Purpose & analysis stage.** Same as file 12.

---

### 15. `no_birthdate/no_birthdate_dataset2_PISA.csv`

| Property | Value |
|----------|-------|
| **Rows** | 19 (multi-row header + ~17 participants) |
| **Format** | Raw SurveyMonkey export (Russian) |
| **PISA task** | Milk articles |

**Content.** Reading comprehension responses from participants without birthdate, wave 2.

**Purpose.** Limited utility due to small N and missing age classification.

---

## Mapping to Moore & Gordon (2015) Analysis Pipeline

| Moore & Gordon (2015) analysis | Primary raw data file(s) | Stage |
|-------------------------------|--------------------------|-------|
| **Item descriptives** (endorsement rates, floor/ceiling effects) | `ART_pretest_merged_EN.csv`, `author_lists/real_authors.csv`, `author_lists/not_real_authors.csv` | 1 |
| **Dimensionality assessment** (EFA, scree, parallel analysis) | `ART_pretest_merged_EN.csv` | 2 |
| **IRT model fitting** (2PL calibration) | `ART_pretest_merged_EN.csv` | 3 |
| **Item parameter analysis** (*a*, *b* estimation) | `ART_pretest_merged_EN.csv` | 4 |
| **Diagnostic plots** (ICCs, TIF, item information) | `ART_pretest_merged_EN.csv` | 5 |
| **Ability estimation** (θ scores) | `ART_pretest_merged_EN.csv` | 6 |
| **Scoring comparison** (IRT θ vs. classical) | `ART_pretest_merged_EN.csv`, `author_lists/not_real_authors.csv` | 7 |
| **Short-form construction** (60-item subset) | `ART_pretest_merged_EN.csv` | 8 |
| **Criterion validation** (ART × reading ability) | `adults/*_PISA.csv` linked to `adults/*_ART.csv` via nickname | Validation |
| **Subgroup analysis** (age-group comparison) | `children/*` vs. `adults/*` | Extension |

---

## Participant Linkage Across Files

ART and PISA were administered as two separate SurveyMonkey surveys. Participants are linked by their self-chosen **nickname** (column: "Пожалуйста, придумайте псевдоним!"). Linkage requires:

1. Extracting the nickname from both ART and PISA files within the same wave and age group
2. Normalizing (lowercase, strip whitespace)
3. Matching on exact string

Not all ART participants completed the PISA survey (ART N > PISA N in every wave).

---

## Column Naming in `ART_pretest_merged_EN.csv` — Item-Code Legend

Row 2 of the merged file contains genre/type codes for each item:

| Code prefix | Meaning | Example authors |
|-------------|---------|-----------------|
| `fill` | Foil (non-author) | Gerrit HoogenbuM, Gonzalo Hervas |
| `mod` | Modern fiction | Khaled Hosseini, Donna Tartt, Haruki Murakami |
| `cla` | Classic fiction | Gabriel García Márquez, Charles Dickens, Jane Austen |
| `soc` | Soviet/social realism | Valentin Rasputin, Victor Astafiev, Boris Vasiliev |
| `det` | Detective/thriller | Agatha Christie, Gillian Flynn, Paula Hawkins |
| `sci` | Science fiction | Isaac Asimov, Ray Bradbury, Kir Bulychev |
| `fan` | Fantasy | J.R.R. Tolkien, George R.R. Martin, Andrzej Sapkowski |
| `rom` | Romance | Jojo Moyes |
| `sfi` | Sci-fi (overlap with sci) | Jules Verne |

These codes are not used in the IRT analysis directly but are useful for post-hoc analyses of genre effects on recognition.

---

## Notes

- The SurveyMonkey export files contain ART items as embedded image URLs (postimg.cc), not plain text. During preprocessing, these were decoded back to author names.
- Dataset 1 and dataset 2 differ only in the PISA passage used; the ART item set is identical across waves.
- The `ART_pretest_merged_EN.csv` file already combines both waves and all age groups — it is the single file needed for the core IRT analysis pipeline (Steps 1–8).
- PISA files are needed only for criterion validation, which is a separate analysis from the IRT calibration.

---

*Last updated: 2026-02-16*
