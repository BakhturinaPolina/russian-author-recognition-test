# Article Package: Person Scoring (07)

Generated from `scripts/irt_analysis/07_person_scoring.ipynb`.

**Reproducibility:** Run the notebook through the merged `person_df` (with `hits`, `corrected_art_score`, `stronger_penalty_score`, `theta`, `irt06_theta_se`, and demographics), then execute the final cell or:

`source(file.path(PROJECT_ROOT, "scripts", "irt_analysis", "07_export_article_package.R"))`

## Tables (CSV)

| File | Description | Suggested placement |
|------|-------------|---------------------|
| `table_score_type_descriptives.csv` | N, mean, SD, min, max, skew, kurtosis for four score types | Main text |
| `table_theta_descriptives_detail.csv` | Full `psych::describe` row for theta | Appendix |
| `table_floor_ceiling_analysis.csv` | Floor/ceiling counts and % per score type | Appendix |
| `table_theta_se_by_region.csv` | Mean theta SE for bottom 5% / middle 90% / top 5% | Appendix |
| `table_group_comparison_sex_descriptives.csv` | N, mean, SD of theta by sex | Appendix |
| `table_group_comparison_sex_test.csv` | Welch *t*-test summary | Main text or Appendix |
| `table_group_comparison_humanities_descriptives.csv` | N, mean, SD by humanities vs non | Appendix |
| `table_group_comparison_humanities_test.csv` | Welch *t*-test summary | Main text or Appendix |
| `table_group_comparison_age_descriptives.csv` | N, mean, SD by age group | Appendix |
| `table_group_comparison_age_test.csv` | One-way ANOVA summary | Main text or Appendix |
| `table_group_comparison_profession_descriptives.csv` | N, mean, SD by profession category | Appendix |
| `table_group_comparison_profession_test.csv` | Kruskal–Wallis summary | Main text or Appendix |
| `table_correlation_matrix_pearson.csv` | 4×4 Pearson *r* among score types | Main text |
| `table_correlation_matrix_spearman.csv` | 4×4 Spearman ρ | Appendix |

## Static figures (PNG + PDF, 300 dpi for PNG)

| File | Description | Suggested placement |
|------|-------------|---------------------|
| `figure_theta_histogram.*` | Theta with density overlay | Main text |
| `figure_theta_qq_plot.*` | Normal Q–Q for theta | Appendix |
| `figure_corrected_art_vs_theta_scatter.*` | Scatter + LOESS | Main text |
| `figure_theta_vs_se_scatter.*` | Precision (SE vs theta) with LOESS | Appendix |
| `figure_theta_by_sex_boxplot.*` | | Main text or Appendix |
| `figure_theta_by_humanities_boxplot.*` | | Main text |
| `figure_theta_by_age_group_boxplot.*` | | Main text or Appendix |
| `figure_theta_by_profession_boxplot.*` | | Appendix |
| `figure_correlation_heatmap_pearson.*` | Tile heatmap with coefficients | Main text or Appendix |
| `figure_correlation_heatmap_spearman.*` | Same for Spearman | Appendix |
| `figure_score_scatterplot_matrix.*` | `GGally::ggpairs` (requires **GGally**; skipped if not installed) | Appendix |

## Notes

- Group comparison tables are split into **descriptives** and **test** CSVs for clarity; merge in your manuscript workflow if you prefer one table per contrast.
- In the notebook narrative/output, demographic contrasts are reported with effect sizes alongside p-values (Hedges *g* for two-group tests, eta^2/omega^2 for ANOVA, epsilon^2 for Kruskal-Wallis), plus post-hoc tests where relevant.
- Score-type comparison output includes pairwise correlation tests with Pearson 95% CIs and BH-adjusted p-values (in addition to matrix-style correlations).
- Until the export script is run, this folder may only contain this `README.md`.
