# Participant-Level EDA Article Package

This folder contains publication-oriented exports derived from `scripts/eda/01_participant_level_checks.ipynb`.

## Suggested Main Text Artifacts

- `figure_score_distributions_hits_falsealarms_correctedscore.png` / `.pdf`: Core distribution figure for participant performance quality.
- `figure_response_style_pattern_proportions.png` / `.pdf`: Quick visual summary of response-style validity patterns.
- `table_study_overview_key_metrics.csv`: Compact study-level numbers for methods/results narrative.
- `table_score_distribution_descriptives.csv`: Descriptive statistics for hits, false alarms, and corrected score.

## Suggested Appendix / Reproducibility Artifacts

- `figure_missingness_distribution_histogram_boxplot.png` / `.pdf`: Demonstrates low and uniform missingness.
- `table_participant_summary_full.csv`: Participant-level full analytic table used in this notebook.
- `table_top15_participants_by_missingness.csv`: Transparent check of highest-missingness participants.
- `table_response_style_pattern_counts_proportions.csv`: Counts/proportions underlying the pattern plot.
- `table_exclusion_near_all_0_participants.csv`: Participants flagged by near-all-0 criterion.
- `table_exclusion_high_false_alarm_participants.csv`: Participants flagged by high false-alarm criterion.
- `table_exclusion_combined_participant_ids.csv`: Final combined participant exclusion list.
- `table_item_missingness_all_affected_items.csv`: All items with any missing responses.
- `table_item_missingness_items_ge_1pct.csv`: Items with >=1% missingness.
- `table_item_exclusion_candidates_ge_1pct_except_ian_fleming.csv`: Candidate item exclusions under notebook rule.

## Notes

- Export logic mirrors the notebook thresholds and definitions:
  - `NEAR_ALL_0_MAX = 0.05`
  - `NEAR_ALL_1_MIN = 0.95`
  - `FA_RATE_THRESHOLD = 0.30`
  - item-exclusion rule based on `missing_pct >= 0.01`, with `Ian Fleming` retained.
- Plot files are provided in both PNG (slides/manuscript drafting) and PDF (publication-quality vector-compatible workflows).
