# Dimensionality / Unidimensionality Check — Article Package

Source notebook: `scripts/dimensionality_analysis/11_dimensionality_unidimensionality_check.ipynb`

Regenerate this folder by running the final **Article package export** cell in that notebook (or `source()` the script below from the project root with `PROJECT_ROOT` set).

```r
# After running all analysis cells in the notebook (objects in memory):
source(file.path(PROJECT_ROOT, "scripts", "dimensionality_analysis", "12_export_article_package.R"))
```

**Note:** The export script writes tables and figures from **existing** notebook objects; it does not refit models. Run the full notebook first if those objects are missing.

## Suggested main-text figures

1. `figure_parallel_analysis_scree.png` / `.pdf` — observed vs random eigenvalues.
2. `figure_efa_1factor_loadings_lollipop.png` / `.pdf` — one-factor EFA loadings with 0.30 guideline.
3. `figure_cfa_loadings_barplot.png` / `.pdf` — standardized CFA loadings (WLSMV).
4. `figure_irt_2pl_a_vs_b.png` / `.pdf` — exploratory 2PL item parameter map from `mirt`.

## Suggested main-text tables

1. `table_cfa_fit_indices.csv` — RMSEA, CFI, TLI, SRMR, etc., for full vs trimmed CFA.
2. `table_cfa_standardized_loadings.csv` — item-level CFA loadings and metadata.
3. `table_decision_summary.csv` — compact summary aligned with the notebook’s unidimensionality recommendation.
4. `table_trimmed_analysis_summary.csv` — side-by-side full vs trimmed item set (column names `Full` / `Trimmed`; row `Items` reflects `ncol(author_mat)` and `ncol(author_mat_trimmed)` from the run).

## Suggested appendix / diagnostics

1. `table_item_endorsement_rates.csv` — endorsement with genre labels.
2. `table_sparse_pair_diagnostics.csv` — 2×2 tables with zero cells (tetrachoric sparsity).
3. `table_eigenvalues_parallel_analysis.csv` — parallel analysis eigenvalue comparison (first factors).
4. `table_efa_1factor_loadings.csv`, `table_efa_2factor_loadings.csv` — full EFA output.
5. `table_irt_2pl_parameters.csv` — `mirt` 2PL *a*, *b* with item metadata.
6. `figure_endorsement_rates_by_item.png` / `.pdf`
7. `figure_tetrachoric_correlation_heatmap.png` / `.pdf` — ggplot heatmap (notebook also uses `corrplot` interactively).

## Notes

- Tables are CSV-only; figures are 300 dpi PNG and vector PDF.
- The export script does **not** rewrite dimensionality input CSVs in `data/stepwise_cleaned_versions/05_dimensionality_inputs/` (that remains the notebook’s reproducible pipeline step).
