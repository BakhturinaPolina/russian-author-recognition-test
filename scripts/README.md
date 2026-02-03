# Scripts

Analysis and data preparation scripts. Data is read from `../data/raw/` (and project root where noted); derived outputs go to `../data/processed/`.

## Layout

- **data_prep/** — ETL: build and translate datasets
  - `extract_author_metadata.py` — Author metadata from ODS → CSV/JSON (reads `archive/67_avtorov_rus.ods`, `archive/98_avtorov_rus.ods`; `data/raw/ART_pretest_merged_EN.xlsx`).
  - `translate_art_dataset.py` — Translate single ART Excel RU→EN (default: `data/raw/pretest_dataset_ART_only.xlsx` → `data/processed/pretest_dataset_ART_only_EN.xlsx`).
  - `merge_and_translate_art.py` — Merge 800 + 1,035 ART exports and translate; writes to `data/raw/ART_pretest_merged_EN.xlsx`.
  - `_translate_utils.py` — Shared helpers for translation (used by the two scripts above).
- **analysis/** — Notebooks and one-off analyses
  - `pisa_analysis.ipynb` — ART+PISA analysis. Expects `PISA/` at project root; run with cwd = `scripts/analysis`. Writes to `data/processed/pisa_analysis/`.
- **psychometrics/** — R / test construction
  - `testconstruction.r` — Workshop script (psychometrics, ELFE example). Not ART-specific; adjust paths and `data.RData` as needed.

## Run order (data_prep)

1. `python scripts/data_prep/extract_author_metadata.py` (requires ODS files and `ART_pretest_merged_EN.xlsx` in place).
2. `python scripts/data_prep/translate_art_dataset.py` and/or `python scripts/data_prep/merge_and_translate_art.py` as needed.

Run from **project root** so paths resolve correctly.

## Dependencies

```bash
pip install -r scripts/requirements.txt
```

R scripts in `psychometrics/` need R packages: `psych`, `difR`, `TAM`, `eRm`, `cNORM`, `lavaan`, `semTools`, `openxlsx` (see comments in `testconstruction.r`).
