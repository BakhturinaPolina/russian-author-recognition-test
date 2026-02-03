# Russian Author Recognition Test (ART) — Research Project

Replication and extension of the Moore & Gordon (2015) IRT-based ART methodology for Russian, with validation against reading and language measures.

## Repository structure

```
.
├── data/                    # Canonical dataset
│   ├── raw/                 # pretest_dataset_ART_only_EN.xlsx + OUT_next_version CSVs
│   └── processed/           # Derived outputs
├── archive/                 # Legacy/superseded files (reference only)
│   └── legacy_csv/
├── docs/                    # Analysis reports + references (PDFs)
│   └── references/
├── scripts/                 # Notebooks and scripts
│   ├── pisa_analysis.ipynb
│   ├── translate_art_dataset.py
│   └── testconstruction.r
├── requirements.txt
└── README.md
```

## Data

- **Active data:** `data/raw/` — `pretest_dataset_ART_only_EN.xlsx` and CSVs from the most complete processed export (adults/children/no_birthdate, ART + PISA).
- **Archive:** `archive/legacy_csv/` — Older CSVs (empty_rm, OUT, OUT 2, quiz, Res_Recalculated_PISA1).

See `data/README.md` for file descriptions and usage.

## Setup

```bash
python3 -m venv .venv
source .venv/bin/activate   # or .venv\Scripts\activate on Windows
pip install -r requirements.txt
```

## References

- Moore, M., & Gordon, P. C. (2015). Reading ability and print exposure: Item response theory analysis of the author recognition test. *Behavior Research Methods*, 47(4), 1095–1109.

## License

Specify your license (e.g. CC BY 4.0, MIT) as needed.
