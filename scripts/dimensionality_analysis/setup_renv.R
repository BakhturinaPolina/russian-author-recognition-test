#!/usr/bin/env Rscript
#
# setup_renv.R — Bootstrap script for the dimensionality analysis environment
#
# This project uses R for dimensionality / unidimensionality testing of ART
# author items (tetrachoric correlations, EFA, CFA with WLSMV).
#
# ── Environment setup (micromamba / conda) ───────────────────────────────
#
# 1. Install micromamba (no sudo needed):
#      curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest \
#        | tar -xvj -C ~/.local/bin/ --strip-components=1 bin/micromamba
#      micromamba shell init -s bash -r ~/micromamba
#      source ~/.bashrc
#
# 2. Create the environment from the lockfile:
#      micromamba create -f environment.yml
#    OR from scratch:
#      micromamba create -n r_dimensionality -c conda-forge -y \
#        r-base r-psych r-mirt r-lavaan r-corrplot r-ggplot2 \
#        r-semplot r-irkernel r-knitr
#
# 3. Activate and register Jupyter kernel:
#      micromamba activate r_dimensionality
#      Rscript -e 'IRkernel::installspec(user = TRUE,
#                    displayname = "R (r_dimensionality)")'
#
# 4. Run the notebook:
#      jupyter notebook 05_dimensionality_unidimensionality_check.ipynb
#
# ── Verification (this script) ──────────────────────────────────────────
#
# Run after setup to confirm all packages are available:
#   micromamba activate r_dimensionality
#   Rscript setup_renv.R

cat("── Dimensionality analysis R environment check ──\n\n")

pkgs <- c(
  "psych",      # tetrachoric correlations, EFA, scree / parallel analysis
  "mirt",       # exploratory item factor analysis, M2 fit statistics
  "lavaan",     # CFA with WLSMV for categorical indicators
  "corrplot",   # correlation heatmaps
  "ggplot2",    # publication-quality plots
  "semPlot",    # CFA path diagrams (optional)
  "IRkernel",   # Jupyter R kernel
  "knitr"       # formatted tables
)

cat(sprintf("R version: %s.%s\n\n", R.version$major, R.version$minor))

all_ok <- TRUE
for (p in pkgs) {
  v <- tryCatch(as.character(packageVersion(p)), error = function(e) NA)
  if (is.na(v)) {
    cat(sprintf("  [MISSING]  %s\n", p))
    all_ok <- FALSE
  } else {
    cat(sprintf("  [OK]       %-12s  %s\n", p, v))
  }
}

cat("\n")
if (all_ok) {
  cat("All packages found. Environment is ready.\n")
} else {
  cat("Some packages are missing. Re-run:\n")
  cat("  micromamba create -f environment.yml\n")
}
