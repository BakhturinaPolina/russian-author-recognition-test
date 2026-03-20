# IRT Analysis of Russian ART — Jupyter Notebook

Below is the complete Python notebook, split into cells. Copy each section into a separate Jupyter cell. Every cell prints its results so you can evaluate the analysis without opening output files.

---

## Cell 0 — Install dependencies (run once)

```python
# Run this cell once to install all required packages.
# After installation, restart the kernel before continuing.

!pip install pandas numpy matplotlib seaborn scipy
!pip install factor_analyzer      # for exploratory factor analysis (Step 2)
!pip install girth                # for IRT 2PL estimation (Steps 3-5)
```

---

## Cell 1 — Load data & identify authors vs. foils

```python
# ============================================================
# STEP 0 · DATA LOADING
# We read the CSV.  Row 2 contains genre/type codes for every
# item column (e.g. "cla", "mod", "fill").
# "fill" = foil (fake name);  everything else = real author.
# ============================================================
import pandas as pd, numpy as np, warnings
warnings.filterwarnings("ignore")

raw = pd.read_csv("ART_pretest_merged_EN.csv", header=0, dtype=str)

# Row 0 is the header (column names = stimulus names).
# Row 1 (index 0 after header) holds genre codes.
genre_row = raw.iloc[0]           # Series: column_name → genre tag
data      = raw.iloc[1:].copy()   # participant rows only
data.reset_index(drop=True, inplace=True)

# Demographic columns (first 5) + source column
demo_cols  = list(data.columns[:5])
source_col = "source" if "source" in data.columns else data.columns[-1]

# Item columns = everything that has a genre code and is not demographic/source
item_cols = [c for c in data.columns
             if c not in demo_cols + [source_col]
             and genre_row.get(c, "") != ""]

# Separate author items from foils using the genre tag row
author_cols = [c for c in item_cols if str(genre_row[c]).strip().lower() != "fill"]
foil_cols   = [c for c in item_cols if str(genre_row[c]).strip().lower() == "fill"]

# Convert item responses to int
for c in item_cols:
    data[c] = pd.to_numeric(data[c], errors="coerce").fillna(0).astype(int)

N = len(data)
print(f"Participants (N)       : {N}")
print(f"Total item columns     : {len(item_cols)}")
print(f"  ↳ Real authors       : {len(author_cols)}")
print(f"  ↳ Foils              : {len(foil_cols)}")
print(f"Demographic columns    : {demo_cols}")
print(f"Source column           : {source_col}")
print(f"\nGenre tags found       : {sorted(set(genre_row[item_cols].str.strip().str.lower()))}")
print(f"First 10 author names  : {author_cols[:10]}")
print(f"First 10 foil names    : {foil_cols[:10]}")
```

---

## Cell 2 — STEP 1: Descriptive Statistics

```python
# ============================================================
# STEP 1 · DESCRIPTIVE STATISTICS
# Following Moore & Gordon Table 1, Table 2, Table 3.
#
# "Standard ART score" = authors selected − foils selected
# "Name score"          = authors selected (no penalty)
# ============================================================
import os

# --- Per-participant scores ---
data["hits"]         = data[author_cols].sum(axis=1)
data["false_alarms"] = data[foil_cols].sum(axis=1)
data["standard_ART"] = data["hits"] - data["false_alarms"]
data["name_score"]   = data["hits"]

# ─── TABLE 1: Score summary (like Moore & Gordon Table 1) ───
table1_rows = []
for label, col, nitems in [
    (f"Full {len(author_cols)}-author scale — Standard ART score", "standard_ART", len(author_cols)),
    (f"Full {len(author_cols)}-author scale — Name score",         "name_score",   len(author_cols)),
]:
    s = data[col]
    table1_rows.append({
        "Scale": label,
        "N items": nitems,
        "N": N,
        "M": round(s.mean(), 2),
        "SD": round(s.std(), 2),
        "Min": int(s.min()),
        "Max": int(s.max()),
        "Range": int(s.max() - s.min()),
        "Skew": round(s.skew(), 2),
    })

table1 = pd.DataFrame(table1_rows)
print("=" * 70)
print("TABLE 1 — ART results with different scoring methods")
print("(cf. Moore & Gordon 2015, Table 1)")
print("=" * 70)
print(table1.to_string(index=False))
table1.to_csv("Table_1.csv", index=False)
print("\n→ Saved: Table_1.csv")

# ─── TABLE 2: Per-author selection rates (like Moore & Gordon Table 2) ───
author_stats = pd.DataFrame({
    "Author Name":     author_cols,
    "Genre":           [str(genre_row[c]).strip() for c in author_cols],
    "Percent Selected": [round(data[c].mean() * 100, 1) for c in author_cols],
}).sort_values("Percent Selected", ascending=False).reset_index(drop=True)
author_stats.index = author_stats.index + 1
author_stats.index.name = "Rank"

print("\n" + "=" * 70)
print("TABLE 2 — Author selection rates (sorted by popularity)")
print("(cf. Moore & Gordon 2015, Table 2; IRT params added in Step 3)")
print("=" * 70)
print(author_stats.to_string())
author_stats.to_csv("Table_2_selection_rates.csv")
print(f"\n→ Saved: Table_2_selection_rates.csv")

mean_sel = author_stats["Percent Selected"].mean()
print(f"\nMean author selection rate: {mean_sel:.1f}%")
print(f"Easiest author: {author_stats.iloc[0]['Author Name']} ({author_stats.iloc[0]['Percent Selected']}%)")
print(f"Hardest author: {author_stats.iloc[-1]['Author Name']} ({author_stats.iloc[-1]['Percent Selected']}%)")

# ─── TABLE 3: Foil error distribution (like Moore & Gordon Table 3) ───
fa_counts = data["false_alarms"].value_counts().sort_index()
fa_dist = pd.DataFrame({
    "Errors": fa_counts.index,
    "N participants": fa_counts.values,
    "% of sample": [round(v / N * 100, 1) for v in fa_counts.values],
})

print("\n" + "=" * 70)
print("TABLE 3 — False-alarm (foil selection) distribution")
print("(cf. Moore & Gordon 2015, Table 3)")
print("=" * 70)
print(fa_dist.to_string(index=False))
fa_dist.to_csv("Table_3.csv", index=False)
print(f"\n→ Saved: Table_3.csv")

print(f"\nMean false alarms per participant: {data['false_alarms'].mean():.2f}  (SD = {data['false_alarms'].std():.2f})")
print(f"Participants with 0 false alarms: {(data['false_alarms']==0).sum()} ({(data['false_alarms']==0).mean()*100:.1f}%)")

# Most-selected foils
foil_rates = pd.DataFrame({
    "Foil Name":        foil_cols,
    "Percent Selected": [round(data[c].mean() * 100, 1) for c in foil_cols],
}).sort_values("Percent Selected", ascending=False).reset_index(drop=True)
print(f"\nTop 10 most-selected foils:")
print(foil_rates.head(10).to_string(index=False))

never_selected = (foil_rates["Percent Selected"] == 0.0).sum()
print(f"\nFoils never selected by anyone: {never_selected}")
```

---

## Cell 3 — STEP 2: Dimensionality Assessment (Factor Analysis)

```python
# ============================================================
# STEP 2 · EXPLORATORY FACTOR ANALYSIS
# Moore & Gordon used IRTPRO with oblique CF-quartimax rotation
# on 65 author items → removed 15 guessing-prone items →
# re-ran on 50 items.
#
# We use Python's factor_analyzer with promax (oblique) rotation
# on all author items first, then refine.
# ============================================================
from factor_analyzer import FactorAnalyzer
from factor_analyzer.factor_analyzer import calculate_bartlett_sphericity, calculate_kmo

# Prepare binary author response matrix
X_authors = data[author_cols].values.astype(float)

# --- Suitability checks ---
chi2, p_bart = calculate_bartlett_sphericity(X_authors)
kmo_all, kmo_model = calculate_kmo(X_authors)
print("Bartlett's test of sphericity:")
print(f"  χ² = {chi2:.1f},  p = {p_bart:.4e}")
print(f"KMO measure of sampling adequacy: {kmo_model:.3f}")
print()

# --- Step 2a: Initial factor analysis on ALL authors ---
# Fit with several factors to check eigenvalues
fa_init = FactorAnalyzer(n_factors=min(10, len(author_cols)),
                         rotation=None, method="minres", is_corr_matrix=False)
fa_init.fit(X_authors)
ev, _ = fa_init.get_eigenvalues()

print("Top 10 eigenvalues (scree):")
for i, e in enumerate(ev[:10], 1):
    bar = "█" * int(e * 2)
    print(f"  Factor {i:2d}: {e:6.2f}  {bar}")

# --- Step 2b: Two-factor model with oblique rotation ---
fa2 = FactorAnalyzer(n_factors=2, rotation="promax", method="minres",
                     is_corr_matrix=False)
fa2.fit(X_authors)
loadings_all = pd.DataFrame(
    fa2.loadings_,
    index=author_cols,
    columns=["Factor_1", "Factor_2"]
)

# Identify "guessing" items: those with high Factor 2 loading AND
# very low selection rate (< threshold).  Moore & Gordon removed
# items loading > 0.4 on the "guessing" second factor that had
# very low mean selection rates (≈6.5%).
# We identify candidates similarly.

sel_rates = data[author_cols].mean()
loadings_all["pct_selected"] = sel_rates.values * 100

# Flag items: high loading on whichever factor is the "minor" one
# AND low selection rate.  We'll detect the guessing factor as the
# one where high-loaders have the lowest average selection rate.
f1_high = loadings_all[loadings_all["Factor_1"].abs() > 0.4]
f2_high = loadings_all[loadings_all["Factor_2"].abs() > 0.4]

if f2_high["pct_selected"].mean() < f1_high["pct_selected"].mean():
    guess_factor, content_factor = "Factor_2", "Factor_1"
else:
    guess_factor, content_factor = "Factor_1", "Factor_2"

# Items to remove: load > 0.4 on guessing factor AND low selection
GUESS_LOAD_THRESH = 0.40
LOW_SELECT_THRESH = 10.0   # adjust if needed — Moore & Gordon used ≈6.5%

guessing_items = loadings_all[
    (loadings_all[guess_factor].abs() > GUESS_LOAD_THRESH) &
    (loadings_all["pct_selected"] < LOW_SELECT_THRESH)
].index.tolist()

print(f"\nGuessing-factor = {guess_factor}  (mean selection of high-loaders: "
      f"{loadings_all[loadings_all[guess_factor].abs()>0.4]['pct_selected'].mean():.1f}%)")
print(f"Items flagged for removal (|loading| > {GUESS_LOAD_THRESH} on {guess_factor} "
      f"AND selection < {LOW_SELECT_THRESH}%): {len(guessing_items)}")
for it in guessing_items:
    row = loadings_all.loc[it]
    print(f"  {it:40s}  load={row[guess_factor]:+.2f}  sel={row['pct_selected']:.1f}%")

# --- Step 2c: Re-run on retained items ---
retained_authors = [c for c in author_cols if c not in guessing_items]
X_retained = data[retained_authors].values.astype(float)
n_retained = len(retained_authors)

fa2r = FactorAnalyzer(n_factors=2, rotation="promax", method="minres",
                      is_corr_matrix=False)
fa2r.fit(X_retained)
loadings_ret = pd.DataFrame(
    fa2r.loadings_,
    index=retained_authors,
    columns=["Factor_1", "Factor_2"]
)

# Factor intercorrelation
phi = fa2r.phi_   # factor correlation matrix for oblique rotation
factor_corr = phi[0, 1] if phi is not None else float("nan")

# ─── TABLE 4: Factor loadings on retained items ───
loadings_ret_sorted = loadings_ret.copy()
loadings_ret_sorted["Genre"] = [str(genre_row[c]).strip() for c in retained_authors]
loadings_ret_sorted = loadings_ret_sorted.sort_values("Factor_1", ascending=False)

print(f"\n{'='*70}")
print(f"TABLE 4 — Factor loadings ({n_retained}-item, two-factor, oblique rotation)")
print(f"(cf. Moore & Gordon 2015, Table 4)")
print(f"{'='*70}")
print(loadings_ret_sorted.round(3).to_string())
print(f"\nFactor intercorrelation: r = {factor_corr:.3f}")
print(f"Items retained: {n_retained}")

loadings_ret_sorted.to_csv("Table_4.csv")
print("→ Saved: Table_4.csv")

# Compare 1-factor vs 2-factor (using BIC-like approach)
fa1 = FactorAnalyzer(n_factors=1, rotation=None, method="minres",
                     is_corr_matrix=False)
fa1.fit(X_retained)

# Variance explained comparison
var1 = fa1.get_factor_variance()
var2 = fa2r.get_factor_variance()
print(f"\n1-factor cumulative variance explained: {var1[2][0]*100:.1f}%")
print(f"2-factor cumulative variance explained: {var2[2][1]*100:.1f}%")

# Identify top loaders per factor
f1_top = loadings_ret_sorted.nlargest(10, "Factor_1")[["Factor_1", "Genre"]]
f2_top = loadings_ret_sorted.nlargest(10, "Factor_2")[["Factor_2", "Genre"]]
print(f"\nTop 10 Factor 1 loaders:")
print(f1_top.to_string())
print(f"\nTop 10 Factor 2 loaders:")
print(f2_top.to_string())
```

---

## Cell 4 — STEP 3: 2PL IRT Model Fitting

```python
# ============================================================
# STEP 3 · 2PL IRT MODEL
# Moore & Gordon fit a two-parameter logistic model:
#     P(correct) = 1 / (1 + exp(−a(θ − b)))
# where a = discrimination, b = difficulty, θ = person ability.
#
# We use the `girth` library which implements marginal maximum
# likelihood estimation for 2PL.
# ============================================================
from girth import twopl_mml
import matplotlib.pyplot as plt

# Fit on the retained author items
X_ret = data[retained_authors].values.astype(int)

# girth expects items × persons, so transpose
estimates = twopl_mml(X_ret.T)

a_params = estimates["Discrimination"]
b_params = estimates["Difficulty"]

# Build Table 2 with IRT parameters (like Moore & Gordon Table 2)
table2_irt = pd.DataFrame({
    "Author Name":      retained_authors,
    "Genre":            [str(genre_row[c]).strip() for c in retained_authors],
    "Percent Selected": [round(data[c].mean() * 100, 1) for c in retained_authors],
    "a (discrimination)": np.round(a_params, 2),
    "b (difficulty)":     np.round(b_params, 2),
})
table2_irt = table2_irt.sort_values("Percent Selected", ascending=False).reset_index(drop=True)
table2_irt.index = table2_irt.index + 1
table2_irt.index.name = "Rank"

print("=" * 80)
print(f"TABLE 2 — Author selection rates & 2PL IRT parameters ({n_retained} items)")
print("(cf. Moore & Gordon 2015, Table 2)")
print("=" * 80)
print(table2_irt.to_string())
table2_irt.to_csv("Table_2.csv")
print("\n→ Saved: Table_2.csv")

# Summary statistics of IRT parameters
print(f"\n--- IRT parameter summary ---")
print(f"Discrimination (a):  M = {a_params.mean():.2f},  SD = {a_params.std():.2f},  "
      f"range = [{a_params.min():.2f}, {a_params.max():.2f}]")
print(f"Difficulty (b):      M = {b_params.mean():.2f},  SD = {b_params.std():.2f},  "
      f"range = [{b_params.min():.2f}, {b_params.max():.2f}]")

# Items with highest and lowest discrimination
print(f"\nTop 5 most discriminating items (highest a):")
top_a = table2_irt.nlargest(5, "a (discrimination)")
print(top_a[["Author Name", "a (discrimination)", "b (difficulty)", "Percent Selected"]].to_string(index=False))
print(f"\nBottom 5 least discriminating items (lowest a):")
bot_a = table2_irt.nsmallest(5, "a (discrimination)")
print(bot_a[["Author Name", "a (discrimination)", "b (difficulty)", "Percent Selected"]].to_string(index=False))

# ─── FIG 1: Item Characteristic Curves ───
# Left panel: 4 effective items (high a, spanning easy→hard)
# Right panel: 4 ineffective items (lowest a)
theta = np.linspace(-4, 4, 200)

def icc(theta, a, b):
    """2PL item characteristic curve."""
    return 1.0 / (1.0 + np.exp(-a * (theta - b)))

# Select 4 effective items: highest a, varying difficulty
effective = table2_irt.nlargest(8, "a (discrimination)").sort_values("b (difficulty)")
# Pick 4 that span the difficulty range
eff_indices = [effective.index[0],
               effective.index[len(effective)//3],
               effective.index[2*len(effective)//3],
               effective.index[-1]]
eff_items = effective.loc[eff_indices]

# Select 4 least discriminating items
ineff_items = table2_irt.nsmallest(4, "a (discrimination)")

fig, axes = plt.subplots(1, 2, figsize=(14, 5), sharey=True)

ax = axes[0]
ax.set_title("Effective items (high discrimination)", fontsize=12)
for _, row in eff_items.iterrows():
    y = icc(theta, row["a (discrimination)"], row["b (difficulty)"])
    ax.plot(theta, y, linewidth=2, label=f'{row["Author Name"]} (a={row["a (discrimination)"]:.2f})')
ax.set_xlabel("Ability (θ)")
ax.set_ylabel("P(correct)")
ax.legend(fontsize=8)
ax.set_ylim(-0.05, 1.05)
ax.axhline(0.5, color="grey", linestyle="--", alpha=0.5)
ax.grid(alpha=0.3)

ax = axes[1]
ax.set_title("Ineffective items (low discrimination)", fontsize=12)
for _, row in ineff_items.iterrows():
    y = icc(theta, row["a (discrimination)"], row["b (difficulty)"])
    ax.plot(theta, y, linewidth=2, label=f'{row["Author Name"]} (a={row["a (discrimination)"]:.2f})')
ax.set_xlabel("Ability (θ)")
ax.legend(fontsize=8)
ax.set_ylim(-0.05, 1.05)
ax.axhline(0.5, color="grey", linestyle="--", alpha=0.5)
ax.grid(alpha=0.3)

plt.suptitle(f"Fig. 1 — Item Characteristic Curves ({n_retained}-item Russian ART)", fontsize=13, y=1.02)
plt.tight_layout()
plt.savefig("Fig_1.png", dpi=200, bbox_inches="tight")
plt.show()
print("→ Saved: Fig_1.png")
```

---

## Cell 5 — STEP 4: Test Information Function

```python
# ============================================================
# STEP 4 · TEST INFORMATION FUNCTION
# For a 2PL model, item information at ability θ is:
#     I_i(θ) = a_i² · P_i(θ) · (1 − P_i(θ))
# The test information is the sum over all items.
# This tells us where the test measures most precisely.
# ============================================================

theta = np.linspace(-4, 4, 300)

# Compute item-level information
item_info_matrix = np.zeros((len(retained_authors), len(theta)))
for j in range(len(retained_authors)):
    p = icc(theta, a_params[j], b_params[j])
    item_info_matrix[j, :] = a_params[j]**2 * p * (1 - p)

# Sum to get test information function
tif = item_info_matrix.sum(axis=0)

# Standard error of measurement = 1 / sqrt(TIF)
sem = 1.0 / np.sqrt(tif)

# ─── FIG 2: Test Information Function ───
fig, ax1 = plt.subplots(figsize=(10, 5))

color_tif = "#2166ac"
color_sem = "#b2182b"

ax1.plot(theta, tif, color=color_tif, linewidth=2.5, label="Test Information")
ax1.set_xlabel("Ability (θ)", fontsize=12)
ax1.set_ylabel("Information", fontsize=12, color=color_tif)
ax1.tick_params(axis="y", labelcolor=color_tif)
ax1.fill_between(theta, tif, alpha=0.15, color=color_tif)

# Secondary axis for SEM
ax2 = ax1.twinx()
ax2.plot(theta, sem, color=color_sem, linewidth=2, linestyle="--", label="SE of measurement")
ax2.set_ylabel("Standard Error", fontsize=12, color=color_sem)
ax2.tick_params(axis="y", labelcolor=color_sem)

ax1.set_title(f"Fig. 2 — Test Information Function ({n_retained}-item Russian ART)", fontsize=13)
ax1.grid(alpha=0.3)

lines1, labels1 = ax1.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax1.legend(lines1 + lines2, labels1 + labels2, loc="upper left")

plt.tight_layout()
plt.savefig("Fig_2.png", dpi=200, bbox_inches="tight")
plt.show()
print("→ Saved: Fig_2.png")

# Report key statistics
peak_theta = theta[np.argmax(tif)]
peak_info  = tif.max()
print(f"\nPeak information = {peak_info:.1f}  at θ = {peak_theta:.2f}")
print(f"Information at θ = −2:  {tif[np.argmin(np.abs(theta - (-2)))]:.1f}")
print(f"Information at θ =  0:  {tif[np.argmin(np.abs(theta - 0))]:.1f}")
print(f"Information at θ = +2:  {tif[np.argmin(np.abs(theta - 2))]:.1f}")

if peak_theta > 0.5:
    print("\n⚠ The test provides more information at higher ability levels — "
          "similar to Moore & Gordon, consider adding easier items.")
elif peak_theta < -0.5:
    print("\n⚠ The test provides more information at lower ability levels — "
          "consider adding harder items for better differentiation at high ability.")
else:
    print("\n✓ The test information is roughly centred around average ability.")
```

---

## Cell 6 — STEP 5: Ability Estimation & Scoring Comparison

```python
# ============================================================
# STEP 5 · ABILITY ESTIMATION & SCORING OPTIMIZATION
# Moore & Gordon computed EAP (Expected A Posteriori) ability
# estimates for each person, then combined them with different
# foil penalties.  We replicate the same logic:
#   IRT score  =  EAP_θ_rescaled  −  penalty × false_alarms
#
# Without external criterion (eye-tracking), we compare the
# scoring methods descriptively and save them for future use.
# ============================================================
from girth import ability_eap

# Compute EAP ability estimates
theta_eap = ability_eap(X_ret.T, estimates["Difficulty"], estimates["Discrimination"])

# Rescale EAP to match the summed name-score mean & SD
# (Moore & Gordon: "means and standard deviations of these new
#  scores were matched with those of the summed scores")
name_score_ret = data[retained_authors].sum(axis=1)
mu_ns, sd_ns   = name_score_ret.mean(), name_score_ret.std()
mu_eap, sd_eap = theta_eap.mean(), theta_eap.std()

eap_rescaled = (theta_eap - mu_eap) / sd_eap * sd_ns + mu_ns

# Apply foil penalties
fa = data["false_alarms"].values.astype(float)

data["standard_ART_ret"]   = name_score_ret - fa              # classical: −1 per foil
data["name_score_ret"]     = name_score_ret                   # no penalty
data["IRT_no_penalty"]     = eap_rescaled
data["IRT_minus1"]         = eap_rescaled - 1 * fa
data["IRT_minus2"]         = eap_rescaled - 2 * fa

# ─── TABLE 1 extended (like Moore & Gordon Table 1, bottom rows) ───
score_cols_info = [
    (f"Full {len(author_cols)}-author — Standard ART", "standard_ART", len(author_cols)),
    (f"Full {len(author_cols)}-author — Name score",   "name_score",   len(author_cols)),
    (f"{n_retained}-author — Standard ART",            "standard_ART_ret", n_retained),
    (f"{n_retained}-author — Name score",              "name_score_ret",   n_retained),
    (f"{n_retained}-author — IRT (no penalty)",        "IRT_no_penalty",   n_retained),
    (f"{n_retained}-author — IRT (−1 × errors)",       "IRT_minus1",       n_retained),
    (f"{n_retained}-author — IRT (−2 × errors)",       "IRT_minus2",       n_retained),
]

table1_ext = []
for label, col, ni in score_cols_info:
    s = data[col]
    table1_ext.append({
        "Scale": label,
        "N items": ni,
        "N": N,
        "M": round(s.mean(), 2),
        "SD": round(s.std(), 2),
        "Min": round(s.min(), 2),
        "Max": round(s.max(), 2),
        "Range": round(s.max() - s.min(), 2),
        "Skew": round(s.skew(), 2),
    })
table1_ext = pd.DataFrame(table1_ext)

print("=" * 90)
print("TABLE 1 (extended) — ART scores with different scoring methods")
print("(cf. Moore & Gordon 2015, Table 1)")
print("=" * 90)
print(table1_ext.to_string(index=False))
table1_ext.to_csv("Table_1.csv", index=False)
print("\n→ Saved: Table_1.csv  (overwritten with extended version)")

# Correlations between scoring methods
score_keys = ["standard_ART_ret", "name_score_ret",
              "IRT_no_penalty", "IRT_minus1", "IRT_minus2"]
corr_matrix = data[score_keys].corr().round(3)
print(f"\nCorrelations between scoring methods:")
print(corr_matrix.to_string())

# Save EAP thetas for each participant
data[["IRT_no_penalty", "IRT_minus1", "IRT_minus2",
      "standard_ART", "name_score", "hits", "false_alarms"]].to_csv(
    "participant_scores.csv", index=False)
print("\n→ Saved: participant_scores.csv")
```

---

## Cell 7 — STEP 7: Genre-Based Analysis & Source-Wave Stability

```python
# ============================================================
# STEP 7 · GENRE-BASED ANALYSIS & WAVE STABILITY
# Moore & Gordon examined factor-level difficulty vs. frequency
# and temporal stability across studies.
#
# Our adaptation:
# (a) Compare IRT parameters (a, b) across genre categories
#     (cla, mod, soc, det, sci, fan, rom, sfi …).
# (b) If data has two collection waves ("source"), compare
#     selection proportions across waves (stability check).
# ============================================================
from scipy import stats

# --- Build per-item summary with IRT params & genre ---
item_summary = pd.DataFrame({
    "author":    retained_authors,
    "genre":     [str(genre_row[c]).strip().lower() for c in retained_authors],
    "pct_sel":   [data[c].mean() * 100 for c in retained_authors],
    "a":         a_params,
    "b":         b_params,
})

# (a) Genre comparison — descriptive + one-way ANOVA on b and a
genre_groups = item_summary.groupby("genre").agg(
    n_items = ("author", "count"),
    mean_pct_sel = ("pct_sel", "mean"),
    mean_a  = ("a", "mean"),
    sd_a    = ("a", "std"),
    mean_b  = ("b", "mean"),
    sd_b    = ("b", "std"),
).round(2).sort_values("mean_b")

print("=" * 70)
print("STEP 7a — IRT parameters by genre")
print("=" * 70)
print(genre_groups.to_string())
print()

# ANOVA on difficulty (b) across genres
genre_labels = item_summary["genre"].unique()
groups_b = [item_summary.loc[item_summary["genre"] == g, "b"].values for g in genre_labels]
groups_b = [g for g in groups_b if len(g) >= 2]
if len(groups_b) >= 2:
    F_b, p_b = stats.f_oneway(*groups_b)
    print(f"One-way ANOVA on difficulty (b) across genres: F = {F_b:.2f}, p = {p_b:.4f}")
else:
    print("Not enough genres with ≥2 items for ANOVA on b.")

# ANOVA on discrimination (a) across genres
groups_a = [item_summary.loc[item_summary["genre"] == g, "a"].values for g in genre_labels]
groups_a = [g for g in groups_a if len(g) >= 2]
if len(groups_a) >= 2:
    F_a, p_a = stats.f_oneway(*groups_a)
    print(f"One-way ANOVA on discrimination (a) across genres: F = {F_a:.2f}, p = {p_a:.4f}")

genre_groups.to_csv("genre_comparison.csv")
print("\n→ Saved: genre_comparison.csv")

# (b) Wave stability — compare selection rates across source waves
waves = data[source_col].unique()
print(f"\n{'='*70}")
print(f"STEP 7b — Selection-rate stability across data-collection waves")
print(f"{'='*70}")
print(f"Waves found in '{source_col}' column: {list(waves)}")

if len(waves) >= 2:
    wave_rates = {}
    for w in sorted(waves):
        mask = data[source_col] == w
        rates = data.loc[mask, retained_authors].mean() * 100
        wave_rates[w] = rates
        print(f"  Wave '{w}': N = {mask.sum()}, mean author selection = {rates.mean():.1f}%")

    # Correlation of item selection rates between waves
    w_keys = sorted(waves)[:2]  # take first two waves
    r_waves, p_waves = stats.pearsonr(wave_rates[w_keys[0]], wave_rates[w_keys[1]])
    print(f"\nPearson r between wave '{w_keys[0]}' and wave '{w_keys[1]}' "
          f"selection rates: r = {r_waves:.3f}, p = {p_waves:.2e}")

    # Logit-transform selection proportions for comparison
    def safe_logit(p):
        p = np.clip(p / 100, 0.001, 0.999)
        return np.log(p / (1 - p))

    logit_w1 = safe_logit(wave_rates[w_keys[0]])
    logit_w2 = safe_logit(wave_rates[w_keys[1]])
    delta_logit = logit_w2 - logit_w1

    # ─── FIG 5: Wave stability scatter ───
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.scatter(wave_rates[w_keys[0]], wave_rates[w_keys[1]], s=30, alpha=0.7)
    ax.set_xlabel(f"Selection rate — wave '{w_keys[0]}' (%)")
    ax.set_ylabel(f"Selection rate — wave '{w_keys[1]}' (%)")
    ax.set_title(f"Fig. 5 — Author selection-rate stability across waves\n"
                 f"r = {r_waves:.3f}, p = {p_waves:.2e}")
    lim = max(ax.get_xlim()[1], ax.get_ylim()[1])
    ax.plot([0, lim], [0, lim], "k--", alpha=0.4, label="identity line")
    ax.legend()
    ax.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig("Fig_5.png", dpi=200, bbox_inches="tight")
    plt.show()
    print("→ Saved: Fig_5.png")

    # Mean score comparison across waves (like Moore & Gordon's
    # within-study temporal decline check)
    for w in sorted(waves):
        mask = data[source_col] == w
        ms = data.loc[mask, "standard_ART"].mean()
        print(f"  Mean standard ART score — wave '{w}': {ms:.2f}")

    if len(w_keys) == 2:
        t_stat, p_t = stats.ttest_ind(
            data.loc[data[source_col]==w_keys[0], "standard_ART"],
            data.loc[data[source_col]==w_keys[1], "standard_ART"])
        print(f"  t-test between waves: t = {t_stat:.2f}, p = {p_t:.4f}")
else:
    print("  Only one wave found — skipping stability analysis.")
```

---

## Cell 8 — Summary & output inventory

```python
# ============================================================
# SUMMARY — list all saved files
# ============================================================
import os, glob

output_files = sorted(glob.glob("Table_*.csv") + glob.glob("Fig_*.png")
                      + glob.glob("*.csv"))
output_files = list(dict.fromkeys(output_files))  # deduplicate keeping order

print("=" * 60)
print("ALL OUTPUT FILES")
print("=" * 60)
for f in output_files:
    size = os.path.getsize(f) / 1024
    print(f"  {f:40s}  {size:6.1f} KB")

print(f"\nAnalysis complete.  {N} participants, "
      f"{len(author_cols)} total authors, "
      f"{n_retained} retained after removing {len(guessing_items)} guessing items, "
      f"{len(foil_cols)} foils.")
```

---

## File naming cross-reference

| Moore & Gordon original | Our output file | Content |
|---|---|---|
| Table 1 | `Table_1.csv` | Score descriptives (all scoring methods) |
| Table 2 | `Table_2.csv` | Per-author selection rate + IRT a, b params |
| Table 3 | `Table_3.csv` | Foil error distribution |
| Table 4 | `Table_4.csv` | Two-factor loadings (oblique rotation) |
| Fig. 1  | `Fig_1.png`   | ICCs — effective vs. ineffective items |
| Fig. 2  | `Fig_2.png`   | Test Information Function |
| Fig. 5  | `Fig_5.png`   | Wave stability (replaces temporal comparison) |
| —       | `participant_scores.csv` | Per-participant IRT & classical scores |
| —       | `genre_comparison.csv`  | IRT params aggregated by genre tag |

