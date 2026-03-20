# Archive — Legacy Data

This folder contains **older or superseded** data and source folders, kept for reference only.

## Docs (root of archive)

- **pretest_dataset_ART_only_EN.md** — Data description for `pretest_dataset_ART_only_EN.xlsx`.
- **ART_pretest_Castano_analysis.md** — Pretest analysis (IRT readiness, item stats).
- **ART_datasets_comparison.md** — Comparison of ART_prestest_responses, polinaART, pretest_EN; merged core recommendation.

## Data files (root of archive)

- **ART_prestest_responses.xlsx** — 800 participants, 205 items (Russian); source for merge script.
- **ART_SCT_0221.xls** — ART/SCT run, 68 rows, different format.
- **polinaART.xlsx** — 1,035 participants, 214 items (coded columns); same sample as pretest_dataset_ART_only_EN.
- **Primary&Secondary Print Exposure Raw Data.xls** — Print exposure questionnaire (114 rows, 235 cols).

## Folders

- **empty_rm/** — Cleaned ART CSVs (empty responses removed): empty-resp-removed1_ART.csv, empty-resp-removed2_ART.csv.
- **OUT/** — First export: adults/children/no_birthdate combined datasets (ART only).
- **OUT 2/** — Second export: same structure, ART and PISA in separate files.
- **OUT_next_version_of_firt_one/** — Source of the canonical CSVs now in `data/raw/` (copied there).
- **quiz/** — Quiz summary results (quizResults1.csv, quizResults2.csv).

## `legacy_csv/`

Flat copies of superseded CSVs and xlsx: empty-resp-removed\*_ART, OUT/OUT 2 exports, quizResults, Res_Recalculated_PISA1.csv, pretest_dataset_ART_only.xlsx, rightART ТОЛОКА.xlsx, rightART-ТОЛОКА-2.0.xlsx, RT СИНТАКСИСright.xlsx.

**Active dataset:** `data/raw/` — `pretest_dataset_ART_only_EN.xlsx` + CSVs from OUT_next_version.
