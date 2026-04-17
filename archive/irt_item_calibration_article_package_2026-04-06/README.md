# Article Package: IRT Item Calibration (06)

Source notebook: `scripts/irt_analysis/13_irt_item_calibration.ipynb`

**Regenerate:** Run the notebook through the **theta-scores** cell, then the final export cell, or from R:

```r
# After notebook objects exist (mod_1pl, mod_2pl, mod_3pl, params_df, theta_df, item_key, …)
source(file.path(PROJECT_ROOT, "scripts", "irt_analysis", "14_export_article_package.R"))
```

**Note:** Export uses fitted models already in memory (no refit). ICC/TIF/CSE recomputation is quick.

Pipeline inputs follow `scripts/config.json` → `SAMPLE_VERSION`: **`full`** uses `data/stepwise_cleaned_versions/05_dimensionality_inputs/`; **tagged** runs (e.g. `strict_fa`) use `data/stepwise_cleaned_versions_<tag>/05_dimensionality_inputs/` if that folder exists, otherwise `.../03_dimensionality_inputs/`. Article exports land in `results/irt_item_calibration_<tag>_article_package_2026-04-06/` when the tag is not `full`.

## Tables (CSV)

| File | Description |
|------|-------------|
| `table_model_comparison_1pl_2pl_3pl.csv` | Log-likelihood, AIC, BIC, convergence |
| `table_anova_1pl_vs_2pl.csv` | LR ANOVA: 1PL vs 2PL |
| `table_anova_2pl_vs_3pl.csv` | LR ANOVA: 2PL vs 3PL |
| `table_anova_model_comparisons.csv` | Stacked rows (only if both ANOVA frames share identical columns) |
| `table_2pl_item_parameters.csv` | Per-item 2PL *a* and *b* |
| `table_item_decision_keep_review_drop.csv` | Keep / review / drop with rationale and flags |
| `table_theta_descriptives.csv` | Summary stats for EAP theta and SE |

## Figures (PNG + PDF, 300 dpi PNG)

| File | Description |
|------|-------------|
| `figure_discrimination_a_histogram.*` | Histogram of 2PL *a* |
| `figure_difficulty_b_histogram.*` | Histogram of 2PL *b* |
| `figure_icc_easiest_10.*` / `figure_icc_hardest_10.*` | ICC panels |
| `figure_icc_highest_a_10.*` / `figure_icc_lowest_a_10.*` | ICC panels |
| `figure_test_information_function.*` | TIF with peak annotation |
| `figure_conditional_standard_error.*` | CSE vs theta |
| `figure_theta_distribution_histogram.*` | EAP theta histogram |

## Suggested main text

- Figures: TIF, CSE, ICC easiest/hardest examples.
- Tables: model comparison, ANOVA(s), 2PL parameters, item decisions.

## Notes

- Notebook **data** exports under `data/stepwise_cleaned_versions/06_irt_item_calibration/` are unchanged; this folder is for manuscript-ready copies under `results/`.
- Until the export script is run, this folder may only contain this `README.md`.
