# Exclusion Decision Validation Article Package

This folder contains publication-oriented exports derived from `scripts/eda/02_exclusion_decision_validation.ipynb`.

## Suggested Main Text Artifacts

- `figure_post_step01_validation_histograms_missingness_fa_corrected.png` / `.pdf`: Core post-cleaning distribution panel for missingness, false-alarm rate, and corrected score.
- `figure_post_step01_residual_flag_counts.png` / `.pdf`: Key validation figure showing residual extreme-pattern flag counts.
- `table_post_step01_overview_key_metrics.csv`: Compact metrics table for reporting post-step01 sample quality.
- `table_post_step01_distribution_descriptives.csv`: Descriptive statistics for missingness, FA rate, and corrected score.

## Suggested Appendix / Reproducibility Artifacts

- `table_post_step01_participant_summary_full.csv`: Full participant-level post-step01 validation table.
- `table_post_step01_residual_flag_counts.csv`: Underlying counts/proportions for each residual flag criterion.
- `table_post_step01_residual_flagged_participants.csv`: Participant rows still flagged by any criterion (empty if no residual flags).
- `table_post_step01_top20_by_false_alarm_rate.csv`: Highest post-step01 FA rates for transparent threshold proximity checks.

## Notes

- Source data: `ART_pretest_(for Castano)_EN__participant_level_checks_step01.csv`.
- Item selection keeps only ART-like item-code columns matching:
  `fill`, `mod`, `cla`, `soc`, `det`, `fan`, `sci` prefixes.
- Residual-flag thresholds mirror notebook logic:
  - `near_all_0`: `ones_rate > 0` and `<= 0.05`
  - `near_all_1`: `ones_rate < 1` and `>= 0.95`
  - `high_fa`: `fa_rate >= 0.30`
