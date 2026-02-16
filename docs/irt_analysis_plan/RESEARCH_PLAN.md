# Russian ART IRT Analysis Plan

## Goal
Replicate the Moore and Gordon (2015) ART psychometric workflow on the cleaned Russian ART dataset, using the project cleaning outputs as the single source of truth for item identity and class labels.

## Inputs
- `data/processed/art_cleaned/ART_pretest_merged_EN_cleaned.csv`
- `data/processed/art_cleaned/item_metadata.csv`
- `data/processed/art_cleaned/excluded_items.csv` (audit trail)
- Cleaning rationale: `docs/art_cleaning/CLEANING_DECISIONS.md`

## Analysis Notebook
- `scripts/analysis/russian_art_irt_replication.ipynb`
- Structure: Cell 0 through Cell 8 (9 cells total), with print-heavy outputs in each step.

## Methods
1. **Dependency setup**
   - Install `factor_analyzer` and `girth` plus core analysis libraries.
2. **Data loading and validation**
   - Load cleaned CSV with preserved two-row header structure.
   - Validate that item columns exactly align with `item_metadata.csv`.
   - Use metadata booleans (`is_real_author`, `is_foil`) to define author and foil sets.
3. **Step 1: Descriptive statistics**
   - Compute hits, false alarms, standard ART, name score.
   - Export initial score table, item endorsement rates, and foil error distribution.
4. **Step 2: Dimensionality assessment**
   - Run EFA with oblique rotation.
   - Identify low-endorsement, high-loading guessing candidates.
   - Refit EFA on retained author items.
5. **Step 3: 2PL IRT**
   - Fit 2PL model (`girth.twopl_mml`) on retained author items.
   - Export item parameter table and ICC figure.
6. **Step 4: Test information**
   - Compute item and test information functions across ability.
   - Export TIF and SEM figure.
7. **Step 5: Ability estimation and scoring**
   - Estimate EAP ability, rescale to summed-score metric.
   - Compare foil penalties (0, -1, -2), export extended score summary and participant-level scores.
8. **Step 7: Genre and wave stability**
   - Extract genre robustly from `item_code` prefixes.
   - Compare IRT parameters by genre (descriptive + ANOVA where valid).
   - Run wave stability in two modes:
     - first two waves (direct comparability with prior script)
     - all pairwise wave comparisons (complete view)

## Output Files
- `data/processed/irt_art_results/Table_1.csv`
- `data/processed/irt_art_results/Table_2.csv`
- `data/processed/irt_art_results/Table_3.csv`
- `data/processed/irt_art_results/Table_4.csv`
- `data/processed/irt_art_results/Fig_1.png`
- `data/processed/irt_art_results/Fig_2.png`
- `data/processed/irt_art_results/Fig_5.png`
- `data/processed/irt_art_results/participant_scores.csv`
- `data/processed/irt_art_results/genre_comparison.csv`
- `data/processed/irt_art_results/wave_stability_pairwise.csv`

## Assumptions
- The cleaned dataset remains in the same row format used by the prep notebook: row 0 labels, row 1 item codes, rows 2+ participant data.
- Metadata ordering stays aligned to item columns.
- Binary responses are coded as `0/1` after cleaning; unexpected values are coerced to numeric in analysis.
- EFA filtering threshold (`LOW_SELECT_THRESH = 10%`) is a tunable analytic choice and should be sensitivity-tested if conclusions depend on it.

## Reproducibility Notes
- Run cells sequentially from 0 to 8 in one kernel session.
- Save notebook outputs after successful run to preserve printed diagnostics.
- Keep input files versioned and immutable between reruns.
- Record package versions from the active environment when preparing final report tables/figures.
