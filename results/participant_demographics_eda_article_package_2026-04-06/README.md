# Participant Demographics EDA Article Package

Source notebook: `scripts/eda/03_participant_demographics_eda.ipynb`

This package contains publication-oriented artifacts from participant demographics EDA after applying the notebook's adult-only analysis frame (`age >= 18`, valid age range `10-100`) and education/profession harmonization.

## Suggested Main-Text Figures

1. `figure_adults_age_distribution_histogram.png` and `.pdf`
   - Adult age distribution with mean/median and SD bands.
2. `figure_adults_gender_distribution_barh.png` and `.pdf`
   - Gender composition of adult sample.
3. `figure_adults_humanities_distribution_barh.png` and `.pdf`
   - Humanities background composition.
4. `figure_adults_education_profession_profile_barh.png` and `.pdf`
   - Normalized education/profession profile.

## Suggested Main-Text Tables

1. `table_step03_demographics_overview_key_metrics.csv`
   - Compact metrics for sample filtering and final adult N.
2. `table_adults_age_distribution_descriptives.csv`
   - Adult age descriptive statistics.
3. `table_adults_gender_distribution.csv`
   - Adult gender counts and percentages.
4. `table_adults_humanities_distribution.csv`
   - Adult humanities counts and percentages.
5. `table_adults_education_normalized_category_counts.csv`
   - Final normalized education/profession categories.

## Suggested Appendix / Reproducibility Tables

1. `table_submitted_date_range_summary.csv`
   - Collection date range and parse quality checks.
2. `table_age_quality_summary_pre_adult_filter.csv`
   - Pre-step03 age screening details and under-18 breakdown.
3. `table_adults_education_raw_category_counts.csv`
   - Raw education/profession string frequencies.
4. `table_adults_education_raw_to_canonical_mapping.csv`
   - Raw-to-canonical mapping with similarity score and frequency.
5. `table_adults_student_school_age_profile.csv`
   - Age profile of merged `Student/School` group.

## Notes

- Tables are CSV-only by request.
- Plots are exported as both PNG and PDF by request.
- This folder is intended for manuscript production and reproducibility documentation.
