# Article package: item-level descriptives (revised layout)

Generated from `scripts/eda/08_item_level_descriptives.ipynb` (export cell).

**Root folder:** `results/item_level_descriptives[_SAMPLE]_article_package_2026-04-17/`

- **`01_article_body/`** — Main article (Results): Tables 1–2, Figures 1–2, foil prose stub.
- **`02_appendix/`** — Appendices A–D and supporting diagnostics.

Source data: `data/stepwise_cleaned_versions/03_participant_demographics_normalized_categories/ART_pretest_(for Castano)_EN__participant_demographics_step04_normalized_categories.csv`

## Main article (`01_article_body/`)

| Output | File | Placement |
|--------|------|-----------|
| Table 1 — score descriptives (M, SD, N; two methods; **always primary full N**, not strict-FA) | `table_1_score_descriptives_two_methods.csv` | Results |
| Primary *N*: foil means + paired *t* / dz (same sample as Table 1) | `primary_sample_descriptives_paired_t_and_mean_foil_rate.csv` | Results (two foil columns: pooled valid cells; per-participant mean % of foils) |
| Figure 1 — KDE of two scoring methods | `figure_1_kde_two_scoring_methods.{png,pdf}` | Results |
| Table 2 — genre intensity & coverage | `table_2_genre_intensity_and_coverage.csv` | Results |
| Figure 2 — author selection lollipop by genre | `figure_2_author_selection_rates_lollipop_by_genre.{png,pdf}` | Results |
| Interactive Figure 2 | `interactive_figure_2_author_selection_rates_lollipop.html` | Supplement (optional) |
| Foil prose stub (top 5 by endorsement-flag) | `paragraph_top_5_flagged_foils_for_results.txt` | Paste/edit in Results |

## Appendix (`02_appendix/`)

| Appendix | File(s) | Role |
|----------|---------|------|
| A — full author table | `appendix_a_full_author_item_table.csv` | Replication |
| B — full foil table | `appendix_b_full_foil_selection_rates.csv` | Replication |
| C — item flags | `appendix_c_multi_threshold_item_flag_matrix.csv`, `appendix_c_flag_rule_counts.csv` | Diagnostics |
| D — false-alarm bins | `appendix_d_false_alarm_count_bins.csv`, `appendix_d_false_alarm_count_histogram.{png,pdf}` | Supporting |
| Supporting (not in short placement list) | `appendix_supporting_*` paired scatter & genre bar charts (static + HTML) | Extra visuals |

## Reproducibility

Notebook export cell is canonical. `scripts/eda/10_export_article_package.py` may lag; align it after changing this layout.
