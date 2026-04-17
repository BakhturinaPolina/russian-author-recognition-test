# Russian Author Recognition Test (ART)

Replication and extension of the Moore & Gordon (2015) IRT-based ART methodology for Russian, with dimensionality checks, item calibration, and person scoring pipelines.

## Repository structure

```
.
├── data/                                  # Active project data
├── docs/                                  # Reports and notes
├── archive/                               # Prior article packages, figures, and moved reports
├── results/                               # New exports land here (see archive/ for 2026-04-06 packages)
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
- `scripts/dimensionality_analysis/21_21_environment.yml`
- `scripts/dimensionality_analysis/22_22_renv.lock`
- `scripts/dimensionality_analysis/20_20_setup_renv.R`

Create and verify:

```bash
micromamba create -f scripts/dimensionality_analysis/21_21_environment.yml
micromamba activate r_dimensionality
Rscript scripts/dimensionality_analysis/20_20_setup_renv.R
```
