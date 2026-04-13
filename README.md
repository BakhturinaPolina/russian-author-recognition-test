# Russian Author Recognition Test (ART)

Replication and extension of the Moore & Gordon (2015) IRT-based ART methodology for Russian, with dimensionality checks, item calibration, and person scoring pipelines.

## Repository structure

```
.
├── data/                                  # Active project data
├── docs/                                  # Reports and notes
├── results/                               # Exported article packages and figures
├── scripts/
│   ├── config.json                        # Active sample version toggle
│   ├── set_version.py                     # CLI helper: full | strict_fa
│   ├── data_prep/                         # 01_* to 05_* preparation scripts
│   ├── eda/                               # 06_* to 10_* EDA notebooks/scripts
│   ├── dimensionality_analysis/           # 11_* to 12_* + R env files
│   ├── irt_analysis/                      # 13_* to 16_* notebooks/scripts
│   └── article_exports/                   # 17_* to 19_* R export scripts
├── requirements.txt                       # Python environment (venv)
└── README.md
```

## Version switch

Set the active sample version in `scripts/config.json`:

```bash
python3 scripts/set_version.py strict_fa
# or
python3 scripts/set_version.py full
```

## Environment setup

### Python (`.venv`)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### R dimensionality environment (micromamba/conda)

R dimensionality work is configured in:
- `scripts/dimensionality_analysis/environment.yml`
- `scripts/dimensionality_analysis/renv.lock`
- `scripts/dimensionality_analysis/setup_renv.R`

Create and verify:

```bash
micromamba create -f scripts/dimensionality_analysis/environment.yml
micromamba activate r_dimensionality
Rscript scripts/dimensionality_analysis/setup_renv.R
```

## Notes

- `archive/` is fully ignored by git and treated as local legacy material.
- See `data/README.md` and `scripts/README.md` for folder-level details.
