"""
10_export_article_package.py
============================
Standalone, self-contained export script for the article package produced by
notebook 08_item_level_descriptives.ipynb.

Reads from:
    data/stepwise_cleaned_versions/03_participant_demographics_normalized_categories/
        ART_pretest_(for Castano)_EN__participant_demographics_step04_normalized_categories.csv

Exports to:
    results/item_level_descriptives_article_package_2026-04-06/
"""

from pathlib import Path
import re
import textwrap

import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.lines as mlines
import seaborn as sns
import plotly.graph_objects as go
import plotly.express as px

# ─────────────────────────────────────────────────────────────────────────────
# 0) Paths
# ─────────────────────────────────────────────────────────────────────────────
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
DATA_PATH = (
    PROJECT_ROOT
    / "data"
    / "stepwise_cleaned_versions"
    / "03_participant_demographics_normalized_categories"
    / "ART_pretest_(for Castano)_EN__participant_demographics_step04_normalized_categories.csv"
)
OUT_DIR = PROJECT_ROOT / "results" / "item_level_descriptives_article_package_2026-04-06"
OUT_DIR.mkdir(parents=True, exist_ok=True)

# ─────────────────────────────────────────────────────────────────────────────
# 1) Global plot styling
# ─────────────────────────────────────────────────────────────────────────────
plt.style.use("seaborn-v0_8-whitegrid")
plt.rcParams.update({
    "figure.dpi": 120,
    "savefig.dpi": 300,
    "font.size": 10,
    "axes.titlesize": 13,
    "axes.labelsize": 11,
    "xtick.labelsize": 10,
    "ytick.labelsize": 10,
    "legend.fontsize": 9,
    "axes.titlepad": 10,
})

# ─────────────────────────────────────────────────────────────────────────────
# 2) Load & parse raw data
# ─────────────────────────────────────────────────────────────────────────────
raw = pd.read_csv(DATA_PATH, header=None)
labels = raw.iloc[0].fillna("").astype(str)
codes = raw.iloc[1].fillna("").astype(str)
responses = raw.iloc[2:, :].reset_index(drop=True)

print(f"Loaded: {DATA_PATH}")
print(f"Rows (participants): {len(responses)}")
print(f"Columns (full width): {raw.shape[1]}")

# ─────────────────────────────────────────────────────────────────────────────
# 3) Detect item columns via regex
# ─────────────────────────────────────────────────────────────────────────────
def normalize_code(code: str) -> str:
    return re.sub(r"\s+", "", str(code).strip().lower())

ITEM_CODE_PATTERN = re.compile(r"^(fill\d+|(?:mod|cla|sci|det|fan|soc)\d+)$")

code_norm = codes.map(normalize_code)
item_mask = code_norm.map(lambda x: bool(ITEM_CODE_PATTERN.match(x)))
item_indices = np.flatnonzero(item_mask.to_numpy())

item_labels = labels.iloc[item_indices].astype(str).str.strip().reset_index(drop=True)
item_codes = codes.iloc[item_indices].astype(str).str.strip().reset_index(drop=True)
item_codes_norm = code_norm.iloc[item_indices].reset_index(drop=True)

item_type = np.where(item_codes_norm.str.startswith("fill"), "foil", "author")
item_genre_prefix = item_codes_norm.str.extract(r"^([a-z]+)", expand=False).fillna("")

genre_map = {
    "cla": "Classics",
    "mod": "Modern/Literary",
    "sci": "Sci-Fi",
    "det": "Detective/Thriller",
    "fan": "Fantasy",
    "soc": "Social/Other",
}
item_genre = [
    genre_map.get(prefix, "Foil") if itype == "author" else "Foil"
    for prefix, itype in zip(item_genre_prefix, item_type)
]

item_meta = pd.DataFrame({
    "item_idx": item_indices,
    "item_label": item_labels,
    "item_code": item_codes,
    "item_code_norm": item_codes_norm,
    "item_type": item_type,
    "genre": item_genre,
})

item_meta["item_id"] = [
    f"{code}__{i:03d}" for i, code in enumerate(item_meta["item_code_norm"])
]

item_resp = responses.iloc[:, item_indices].apply(pd.to_numeric, errors="coerce")
item_resp = item_resp.where(item_resp.isin([0, 1]))
item_resp.columns = item_meta["item_id"].tolist()

print(f"Detected item columns: {len(item_indices)}")
print(item_meta["item_type"].value_counts().to_string())

# ─────────────────────────────────────────────────────────────────────────────
# 4) Cleaning: rename genres, clean foil labels, exclude items
# ─────────────────────────────────────────────────────────────────────────────
item_meta["genre"] = item_meta["genre"].replace({"Social/Other": "SovLit"})

_FOIL_FILL_SUFFIX = re.compile(r"(?i)\s*f\s*i\s*l\s*l\s*\d+\s*$")

def _clean_foil_item_label(label) -> str:
    s = _FOIL_FILL_SUFFIX.sub("", str(label))
    return re.sub(r"\s+", " ", s).strip()

foil_mask = item_meta["item_type"].eq("foil")
item_meta.loc[foil_mask, "item_label"] = (
    item_meta.loc[foil_mask, "item_label"].map(_clean_foil_item_label)
)

# ─────────────────────────────────────────────────────────────────────────────
# 5) Scoring keys: exclusions + Ian Fleming fix + deduplication
# ─────────────────────────────────────────────────────────────────────────────
feynman_mask = (
    (item_meta["item_label"].astype(str).str.strip() == "Richard Feynman")
    & (item_meta["item_code_norm"].astype(str).str.strip() == "cla17")
)

siptits_mask = (
    (item_meta["item_label"].astype(str).str.strip() == "Sergey Siptits")
    & (item_meta["item_type"] == "foil")
)
chucky_mask = (
    (item_meta["item_label"].astype(str).str.strip() == "Chabo Chucky")
    & (item_meta["item_type"] == "foil")
)
gerrit_mask = (
    (item_meta["item_label"].astype(str).str.strip() == "Gerrit HoogenbuM")
    & (item_meta["item_type"] == "foil")
)
foil_exclusion_mask = siptits_mask | chucky_mask | gerrit_mask

author_key_raw = item_meta.loc[
    (item_meta["item_type"] == "author") & ~feynman_mask
].copy()
foil_key = item_meta.loc[
    (item_meta["item_type"] == "foil") & ~foil_exclusion_mask
].copy()

ian_mask = author_key_raw["item_label"].astype(str).str.strip() == "Ian Fleming"
author_key_raw.loc[ian_mask, "genre"] = "Detective/Thriller"

ian_mod33_mask = (
    (author_key_raw["item_label"].astype(str).str.strip() == "Ian Fleming")
    & (author_key_raw["item_code_norm"].astype(str).str.strip() == "mod33")
)
author_key_raw = author_key_raw.loc[~ian_mod33_mask].copy()

author_item_ids_raw = author_key_raw["item_id"].tolist()
author_resp_raw = item_resp[author_item_ids_raw].where(
    item_resp[author_item_ids_raw].isin([0, 1])
)

label_to_ids = (
    author_key_raw.groupby("item_label", sort=False)["item_id"].apply(list).to_dict()
)
merged_cols = {}
for label, ids in label_to_ids.items():
    sub = author_resp_raw[ids]
    merged = sub.sum(axis=1, skipna=True)
    all_missing = sub.isna().all(axis=1)
    merged_cols[label] = merged.where(~all_missing, np.nan)

author_resp_bin = pd.DataFrame(merged_cols, index=author_resp_raw.index)

author_key = (
    author_key_raw
    .drop_duplicates(subset=["item_label"], keep="first")
    .copy()
)
author_key["item_id"] = author_key["item_label"]
author_key = (
    author_key
    .set_index("item_id", drop=False)
    .loc[author_resp_bin.columns]
    .reset_index(drop=True)
)

author_item_ids = author_key["item_id"].tolist()
foil_item_ids = foil_key["item_id"].tolist()

foil_resp_bin = item_resp[foil_item_ids].where(item_resp[foil_item_ids].isin([0, 1]))

print(f"Final author items after deduplication: {len(author_item_ids)}")
print(f"Final foil items (after Siptits/Chucky/Gerrit exclusion): {len(foil_item_ids)}")

# ─────────────────────────────────────────────────────────────────────────────
# 6) ART scores
# ─────────────────────────────────────────────────────────────────────────────
hits = author_resp_bin.sum(axis=1, skipna=True)
false_alarms = foil_resp_bin.sum(axis=1, skipna=True)

standard_art_score = hits - false_alarms
art_name_score = hits

participant_scores_art = pd.DataFrame({
    "hits": hits,
    "false_alarms": false_alarms,
    "standard_art_score": standard_art_score,
    "art_name_score": art_name_score,
})

n_participants = int(len(participant_scores_art))
scale_label = f"{len(author_item_ids)}-author scale"

# ─────────────────────────────────────────────────────────────────────────────
# TABLE: Scale descriptives (Standard vs Name ART)  [cell 10]
# ─────────────────────────────────────────────────────────────────────────────
table1_art = pd.DataFrame([
    {
        "Scales": scale_label,
        "Method": "Standard ART score",
        "N": n_participants,
        "M": standard_art_score.mean(),
        "SD": standard_art_score.std(ddof=1),
        "Range": standard_art_score.max() - standard_art_score.min(),
    },
    {
        "Scales": scale_label,
        "Method": "ART name score",
        "N": n_participants,
        "M": art_name_score.mean(),
        "SD": art_name_score.std(ddof=1),
        "Range": art_name_score.max() - art_name_score.min(),
    },
])
table1_art[["M", "SD", "Range"]] = table1_art[["M", "SD", "Range"]].round(2)
table1_art.to_csv(OUT_DIR / "table_scale_descriptives_standard_vs_name_art.csv", index=False)
print("Saved: table_scale_descriptives_standard_vs_name_art.csv")

# ─────────────────────────────────────────────────────────────────────────────
# Prepare plot_df for cell-11 figures
# ─────────────────────────────────────────────────────────────────────────────
plot_df = participant_scores_art[
    ["standard_art_score", "art_name_score", "false_alarms"]
].dropna().copy()
plot_df["delta"] = plot_df["art_name_score"] - plot_df["standard_art_score"]

n_plot = len(plot_df)

c_standard = "#1f77b4"
c_name = "#ff7f0e"

m_std = plot_df["standard_art_score"].mean()
med_std = plot_df["standard_art_score"].median()
sd_std = plot_df["standard_art_score"].std(ddof=1)

m_name = plot_df["art_name_score"].mean()
med_name = plot_df["art_name_score"].median()
sd_name = plot_df["art_name_score"].std(ddof=1)

corr = plot_df[["standard_art_score", "art_name_score"]].corr().iloc[0, 1]
mean_delta = plot_df["delta"].mean()
med_delta = plot_df["delta"].median()
pct_above = (plot_df["art_name_score"] > plot_df["standard_art_score"]).mean() * 100

line_min = min(plot_df["standard_art_score"].min(), plot_df["art_name_score"].min())
line_max = max(plot_df["standard_art_score"].max(), plot_df["art_name_score"].max())

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE: Overlaid KDE densities  [cell 11, Figure 1]
# ─────────────────────────────────────────────────────────────────────────────
sns.set_theme(style="whitegrid")
fig1, ax1 = plt.subplots(figsize=(10.5, 5.5))

sns.kdeplot(data=plot_df, x="standard_art_score", fill=True, alpha=0.30,
            linewidth=2, color=c_standard, ax=ax1)
sns.kdeplot(data=plot_df, x="art_name_score", fill=True, alpha=0.30,
            linewidth=2, color=c_name, ax=ax1)

for mean_val, med_val, sd_val, color in [
    (m_std, med_std, sd_std, c_standard),
    (m_name, med_name, sd_name, c_name),
]:
    ax1.axvline(mean_val, color=color, linestyle="--", linewidth=1.8, alpha=0.9)
    ax1.axvline(med_val, color=color, linestyle="-.", linewidth=1.8, alpha=0.9)
    ax1.axvline(mean_val - sd_val, color=color, linestyle=":", linewidth=1.4, alpha=0.65)
    ax1.axvline(mean_val + sd_val, color=color, linestyle=":", linewidth=1.4, alpha=0.65)

leg_density = [
    mlines.Line2D([], [], color=c_standard, linewidth=8, alpha=0.4,
                  label="hits - false alarms"),
    mlines.Line2D([], [], color=c_name, linewidth=8, alpha=0.4,
                  label="hits only"),
    mlines.Line2D([], [], color="gray", linestyle="--", linewidth=1.8, label="Mean"),
    mlines.Line2D([], [], color="gray", linestyle="-.", linewidth=1.8, label="Median"),
    mlines.Line2D([], [], color="gray", linestyle=":", linewidth=1.4, label="±1 SD"),
]
ax1.legend(handles=leg_density, frameon=False,
           loc="upper left", bbox_to_anchor=(1.02, 1.0),
           borderaxespad=0, fontsize=9)
ax1.set_title(f"Overlaid Density of ART Scoring Methods (N = {n_plot})",
              fontsize=12, pad=10)
ax1.set_xlabel("Score")
ax1.set_ylabel("Density")
fig1.tight_layout()

for ext in ("png", "pdf"):
    fig1.savefig(OUT_DIR / f"figure_score_distributions_kde_standard_vs_name.{ext}",
                 bbox_inches="tight")
plt.close(fig1)
print("Saved: figure_score_distributions_kde_standard_vs_name.{png,pdf}")

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE: Paired scores scatter colored by FA  [cell 11, Figure 2]
# ─────────────────────────────────────────────────────────────────────────────
fig2, ax2 = plt.subplots(figsize=(10.5, 5.5))

sc = ax2.scatter(
    plot_df["standard_art_score"],
    plot_df["art_name_score"],
    c=plot_df["false_alarms"],
    cmap="viridis", alpha=0.48, s=26, edgecolors="none",
)
ax2.plot([line_min, line_max], [line_min, line_max], "k--", linewidth=1.2)
ax2.scatter(m_std, m_name, marker="X", s=130, color="crimson",
            edgecolors="white", linewidth=0.8, zorder=5)

ax2.set_title(f"Paired ART Scores by Participant (N = {n_plot})",
              fontsize=12, pad=10)
ax2.set_xlabel("hits - false alarms")
ax2.set_ylabel("hits only")

leg_scatter = [
    mlines.Line2D([], [], marker="o", color="#2a9d8f", linestyle="None",
                  markersize=7, label="Single Participant"),
    mlines.Line2D([], [], color="black", linestyle="--", linewidth=1.2,
                  label="Equal Scores Line (x = y)"),
    mlines.Line2D([], [], marker="X", color="crimson", linestyle="None",
                  markersize=8, markeredgecolor="white", label="Mean Score"),
]

cbar = fig2.colorbar(sc, ax=ax2, pad=0.02)
cbar.ax.set_ylabel("false alarms", rotation=270, va="bottom", labelpad=18)

fig2.subplots_adjust(left=0.08, right=0.88, top=0.92, bottom=0.10)
ax2.legend(
    handles=leg_scatter,
    loc="upper left",
    bbox_to_anchor=(0.02, 0.98),
    borderaxespad=0.0,
    frameon=True,
    fancybox=True,
    framealpha=0.95,
    edgecolor="black",
    facecolor="#e6eef7",
    fontsize=11,
)

for ext in ("png", "pdf"):
    fig2.savefig(OUT_DIR / f"figure_paired_scores_scatter_colored_by_fa.{ext}",
                 bbox_inches="tight")
plt.close(fig2)
print("Saved: figure_paired_scores_scatter_colored_by_fa.{png,pdf}")

# ─────────────────────────────────────────────────────────────────────────────
# PLOTLY HTML: Interactive paired scatter  [cell 11, Figure 3]
# ─────────────────────────────────────────────────────────────────────────────
plot_df_hover = plot_df.copy()
plot_df_hover["false alarms"] = plot_df_hover["false_alarms"].astype(int)

fig_int = go.Figure()

fig_int.add_trace(go.Scatter(
    x=plot_df_hover["standard_art_score"],
    y=plot_df_hover["art_name_score"],
    mode="markers",
    showlegend=False,
    marker=dict(
        size=7,
        color=plot_df_hover["false alarms"],
        colorscale="Viridis",
        opacity=0.6,
        colorbar=dict(
            title=dict(text="false alarms", side="right", font=dict(size=12)),
            thickness=14, x=1.02, xpad=12,
        ),
        showscale=True,
    ),
    customdata=plot_df_hover[["false alarms", "delta"]].values,
    hovertemplate=(
        "<b>hits - false alarms:</b> %{x}<br>"
        "<b>hits only:</b> %{y}<br>"
        "<b>false alarms:</b> %{customdata[0]}<br>"
        "<b>delta:</b> %{customdata[1]:.2f}"
        "<extra></extra>"
    ),
))

fig_int.add_trace(go.Scatter(
    x=[None], y=[None],
    mode="markers",
    marker=dict(size=9, color="#2a9d8f"),
    name="Single Participant",
    hoverinfo="skip",
))

fig_int.add_trace(go.Scatter(
    x=[line_min, line_max], y=[line_min, line_max],
    mode="lines",
    line=dict(color="black", width=1.5, dash="dash"),
    name="Equal Scores Line (x = y)",
    hoverinfo="skip",
))

fig_int.add_trace(go.Scatter(
    x=[m_std], y=[m_name],
    mode="markers",
    marker=dict(symbol="x", size=14, color="crimson",
                line=dict(color="white", width=1)),
    name="Mean Score",
    hovertemplate=(
        f"Mean Score<br>hits - false alarms: {m_std:.2f}"
        f"<br>hits only: {m_name:.2f}<extra></extra>"
    ),
))

fig_int.update_layout(
    title=dict(
        text=f"Paired ART Scores by Participant (N = {n_plot})",
        font=dict(size=14), x=0.5, xanchor="center", y=0.96, yanchor="top",
    ),
    xaxis_title="hits - false alarms",
    yaxis_title="hits only",
    xaxis=dict(title_font=dict(size=12), tickfont=dict(size=10)),
    yaxis=dict(title_font=dict(size=12), tickfont=dict(size=10)),
    font=dict(family="DejaVu Sans", size=11, color="black"),
    autosize=False, width=1050, height=550,
    legend=dict(
        x=0.02, y=0.98, xanchor="left", yanchor="top",
        traceorder="normal", font=dict(size=11),
        bgcolor="LightSteelBlue", bordercolor="Black", borderwidth=2,
    ),
    margin=dict(t=90, b=60, r=150),
)

fig_int.write_html(OUT_DIR / "interactive_paired_scores_scatter.html",
                   include_plotlyjs="cdn")
print("Saved: interactive_paired_scores_scatter.html")

# ─────────────────────────────────────────────────────────────────────────────
# TABLE: Author selection rates  [cell 12]
# ─────────────────────────────────────────────────────────────────────────────
author_selection_rates = pd.DataFrame({
    "item_label": author_key["item_label"].values,
    "genre": author_key["genre"].values,
    "n_selected": author_resp_bin.sum(axis=0, skipna=True).values,
    "n_valid": author_resp_bin.notna().sum(axis=0).values,
})

author_selection_rates["selection_rate"] = (
    author_selection_rates["n_selected"]
    / author_selection_rates["n_valid"].replace(0, np.nan)
)
author_selection_rates["selection_rate_pct"] = (
    (author_selection_rates["selection_rate"] * 100).round(1)
)

author_selection_rates = author_selection_rates.sort_values(
    "selection_rate", ascending=False
).reset_index(drop=True)
author_selection_rates.insert(0, "rank", author_selection_rates.index + 1)

author_selection_rates[
    ["rank", "item_label", "genre", "selection_rate_pct", "n_selected", "n_valid"]
].to_csv(OUT_DIR / "table_author_selection_rates.csv", index=False)
print("Saved: table_author_selection_rates.csv")

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE + HTML: Author selection rates lollipop  [cell 13]
# ─────────────────────────────────────────────────────────────────────────────
asr_plot = author_selection_rates.dropna(
    subset=["selection_rate_pct", "n_selected", "n_valid"]
).copy()
asr_plot["n_selected"] = asr_plot["n_selected"].astype(float)
asr_plot["n_valid"] = asr_plot["n_valid"].astype(float)

item_order_desc = asr_plot["item_label"].tolist()
item_order_asc = item_order_desc[::-1]

_set2_hex = [
    "#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3",
    "#a6d854", "#ffd92f", "#e5c494", "#b3b3b3",
]
genres_sorted = sorted(asr_plot["genre"].dropna().unique().tolist())
color_map = {g: _set2_hex[i % len(_set2_hex)] for i, g in enumerate(genres_sorted)}

palette = px.colors.qualitative.Set2
color_map_plotly = {g: palette[i % len(palette)] for i, g in enumerate(genres_sorted)}

# --- Matplotlib static lollipop ---
fig_lol, ax_lol = plt.subplots(figsize=(10, max(14, 0.22 * len(asr_plot))))

for _, row in asr_plot.iterrows():
    ax_lol.plot(
        [0, row["selection_rate_pct"]],
        [row["item_label"], row["item_label"]],
        color=color_map.get(row["genre"], "#999999"),
        linewidth=1.3, alpha=0.75,
    )

for genre_name in genres_sorted:
    sub = asr_plot[asr_plot["genre"] == genre_name]
    ax_lol.scatter(
        sub["selection_rate_pct"], sub["item_label"],
        s=50, color=color_map[genre_name],
        edgecolors="#333", linewidth=0.5,
        label=genre_name, zorder=5,
    )

ax_lol.set_yticks(range(len(item_order_desc)))
ax_lol.set_yticklabels(item_order_desc, fontsize=7)
ax_lol.invert_yaxis()
ax_lol.set_xlim(0, 100)
ax_lol.set_xlabel("Selection Rate (%)", fontsize=11)
ax_lol.set_ylabel("Author Name", fontsize=11)
ax_lol.set_title(
    f"Author-Level Selection Rates Across Genres (N = {n_participants})",
    fontsize=12, pad=10,
)
ax_lol.legend(title="Genre", loc="lower right", fontsize=8, title_fontsize=9)
ax_lol.spines["top"].set_visible(False)
ax_lol.spines["right"].set_visible(False)
fig_lol.tight_layout()

for ext in ("png", "pdf"):
    fig_lol.savefig(
        OUT_DIR / f"figure_author_selection_rates_lollipop.{ext}",
        bbox_inches="tight",
    )
plt.close(fig_lol)
print("Saved: figure_author_selection_rates_lollipop.{png,pdf}")

# --- Plotly interactive lollipop ---
hover_template = (
    "<b>Author Name:</b> %{customdata[0]}<br>"
    "<b>Genre:</b> %{customdata[1]}<br>"
    "<b>Selection Rate:</b> %{x:.1f}%<br>"
    "<b>n selected:</b> %{customdata[2]:.0f}"
    "<extra></extra>"
)

fig_lollipop = go.Figure()

for _, row in asr_plot.iterrows():
    fig_lollipop.add_shape(
        type="line",
        x0=0, x1=float(row["selection_rate_pct"]),
        y0=row["item_label"], y1=row["item_label"],
        xref="x", yref="y",
        line=dict(color=color_map_plotly.get(row["genre"], "#999999"), width=1.3),
        opacity=0.75,
    )

for genre_name in genres_sorted:
    sub = asr_plot[asr_plot["genre"] == genre_name]
    fig_lollipop.add_trace(go.Scatter(
        x=sub["selection_rate_pct"],
        y=sub["item_label"],
        mode="markers",
        name=genre_name,
        marker=dict(size=9, color=color_map_plotly[genre_name],
                    line=dict(width=0.5, color="#333")),
        customdata=sub[["item_label", "genre", "n_selected"]].to_numpy(),
        hovertemplate=hover_template,
    ))

fig_lollipop.update_layout(
    margin_autoexpand=False,
    title=dict(
        text="<b>Author-Level Selection Rates Across Genres (N = 908)</b>",
        xref="paper", yref="paper",
        x=0.5, xanchor="center", y=1.0, yanchor="bottom",
        automargin=False, pad=dict(t=0, b=0),
    ),
    template="plotly_white",
    height=max(700, int(18 * len(asr_plot))),
    margin=dict(t=28, r=155, b=28, l=180, pad=0),
    legend=dict(
        title=dict(text="Genre", font=dict(weight=700)),
        xref="paper", yref="paper",
        x=1.005, xanchor="left", y=1.0, yanchor="top", valign="top",
    ),
)
fig_lollipop.update_xaxes(
    range=[0, 100], automargin=False,
    title=dict(text="<b>Selection Rate (%)</b>", standoff=11),
)
fig_lollipop.update_yaxes(
    automargin=False,
    title=dict(text="<b>Author Name</b>", standoff=4),
    categoryorder="array",
    categoryarray=item_order_asc,
)

fig_lollipop.write_html(
    OUT_DIR / "interactive_author_selection_rates_lollipop.html",
    include_plotlyjs="cdn",
)
print("Saved: interactive_author_selection_rates_lollipop.html")

# ─────────────────────────────────────────────────────────────────────────────
# TABLE: False alarm count bins  [cell 15]
# ─────────────────────────────────────────────────────────────────────────────
fa_counts = false_alarms.fillna(0).astype(int)

bin_starts = list(range(0, 35, 5))
table3_rows = []
for start in bin_starts:
    end = start + 5
    if start == 30:
        pct = ((fa_counts >= start) & (fa_counts <= end)).mean() * 100
    else:
        pct = ((fa_counts >= start) & (fa_counts < end)).mean() * 100
    table3_rows.append({"Errors": f"{start}-{end}", "%": pct})

table3_art = pd.DataFrame(table3_rows)
table3_art["%"] = table3_art["%"].round(1)
table3_art.to_csv(OUT_DIR / "table_false_alarm_count_bins.csv", index=False)
print("Saved: table_false_alarm_count_bins.csv")

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE: False alarm histogram  [cell 16]
# ─────────────────────────────────────────────────────────────────────────────
plot_fa = table3_art.copy()
plot_fa["%"] = pd.to_numeric(plot_fa["%"], errors="coerce")
ordered_fa = plot_fa.sort_values("%", ascending=False).reset_index(drop=True)

n_obs = len(fa_counts)
highlight_label = ordered_fa.loc[0, "Errors"]

base_color = "#BDBDBD"
highlight_color = "#B71C1C"
colors_highlight = [
    highlight_color if lbl == highlight_label else base_color
    for lbl in ordered_fa["Errors"]
]

fig_fa, ax_fa = plt.subplots(figsize=(10, 6))
fig_fa.patch.set_facecolor("whitesmoke")
ax_fa.set_facecolor("whitesmoke")
ax_fa.spines["top"].set_visible(False)
ax_fa.spines["right"].set_visible(False)

bars = ax_fa.bar(ordered_fa["Errors"], ordered_fa["%"],
                 color=colors_highlight, edgecolor="white", linewidth=0.8)
ax_fa.set_title(f"False Alarm Error Distribution (N = {n_obs})")
ax_fa.set_xlabel("False Alarm Count Range")
ax_fa.set_ylabel("Share of Participants (%)")
ax_fa.grid(axis="y", linestyle="--", alpha=0.35)
ax_fa.set_ylim(0, ordered_fa["%"].max() + 4)

for b in bars:
    h = b.get_height()
    ax_fa.text(b.get_x() + b.get_width() / 2, h + 0.35,
               f"{h:.1f}%", ha="center", va="bottom", fontsize=9)

fig_fa.tight_layout()

for ext in ("png", "pdf"):
    fig_fa.savefig(OUT_DIR / f"figure_false_alarm_count_histogram.{ext}",
                   bbox_inches="tight")
plt.close(fig_fa)
print("Saved: figure_false_alarm_count_histogram.{png,pdf}")

# ─────────────────────────────────────────────────────────────────────────────
# TABLE: Foil selection rates  [cell 17]
# ─────────────────────────────────────────────────────────────────────────────
foil_selection_rates = pd.DataFrame({
    "item_label": foil_key["item_label"].values,
    "genre": foil_key["genre"].values,
    "n_selected": foil_resp_bin.sum(axis=0, skipna=True).values,
    "n_valid": foil_resp_bin.notna().sum(axis=0).values,
})

foil_selection_rates["selection_rate"] = (
    foil_selection_rates["n_selected"]
    / foil_selection_rates["n_valid"].replace(0, np.nan)
)
foil_selection_rates["selection_rate_pct"] = (
    (foil_selection_rates["selection_rate"] * 100).round(1)
)

foil_selection_rates = foil_selection_rates.sort_values(
    "selection_rate", ascending=False
).reset_index(drop=True)
foil_selection_rates.insert(0, "rank", foil_selection_rates.index + 1)

foil_selection_rates[
    ["rank", "item_label", "genre", "selection_rate_pct", "n_selected", "n_valid"]
].to_csv(OUT_DIR / "table_foil_selection_rates.csv", index=False)
print("Saved: table_foil_selection_rates.csv")

# ─────────────────────────────────────────────────────────────────────────────
# TABLE: Genre selection rates  [cell 18]
# ─────────────────────────────────────────────────────────────────────────────
genre_to_item_ids = author_key.groupby("genre")["item_id"].apply(list).to_dict()

genre_rows = []
for genre, g_item_ids in genre_to_item_ids.items():
    genre_mat = author_resp_bin[g_item_ids]
    n_items = len(g_item_ids)

    answered_any = genre_mat.notna().sum(axis=1) > 0
    selected_any = genre_mat.fillna(0).sum(axis=1) > 0

    n_valid = int(answered_any.sum())
    n_selected_any = int(selected_any.sum())
    selected_any_pct = (n_selected_any / n_valid * 100) if n_valid else np.nan

    participant_genre_rate = genre_mat.mean(axis=1, skipna=True)
    selection_rate_pct = (
        participant_genre_rate.mean() * 100
        if participant_genre_rate.notna().any()
        else np.nan
    )

    genre_rows.append({
        "genre": genre,
        "n_items": n_items,
        "selection_rate_pct": selection_rate_pct,
        "n_selected_any": n_selected_any,
        "selected_any_pct": selected_any_pct,
        "n_valid": n_valid,
    })

genre_selection_rates = pd.DataFrame(genre_rows)
genre_selection_rates[["selection_rate_pct", "selected_any_pct"]] = (
    genre_selection_rates[["selection_rate_pct", "selected_any_pct"]].round(1)
)
genre_selection_rates = genre_selection_rates.sort_values(
    "selection_rate_pct", ascending=False
).reset_index(drop=True)
genre_selection_rates.insert(0, "rank", genre_selection_rates.index + 1)

genre_selection_rates[
    ["rank", "genre", "n_items", "selection_rate_pct",
     "n_selected_any", "selected_any_pct", "n_valid"]
].to_csv(OUT_DIR / "table_genre_selection_rates.csv", index=False)
print("Saved: table_genre_selection_rates.csv")

# ─────────────────────────────────────────────────────────────────────────────
# FIGURE + HTML: Genre intensity vs coverage  [cell 19]
# ─────────────────────────────────────────────────────────────────────────────
gsr_plot = genre_selection_rates.copy()
gsr_plot = gsr_plot.dropna(
    subset=["selection_rate_pct", "selected_any_pct", "n_items", "genre", "rank"]
)
gsr_plot["rank"] = gsr_plot["rank"].astype(int)
gsr_plot["n_items"] = gsr_plot["n_items"].astype(int)
gsr_plot = gsr_plot.sort_values("selection_rate_pct", ascending=False).reset_index(drop=True)
gsr_plot["genre_label"] = (
    gsr_plot["rank"].astype(str) + ". " + gsr_plot["genre"].astype(str)
)

# --- Matplotlib static grouped horizontal bars ---
fig_genre, ax_genre = plt.subplots(figsize=(10, 5.5))

y_pos = np.arange(len(gsr_plot))
bar_height = 0.35

bars1 = ax_genre.barh(
    y_pos - bar_height / 2,
    gsr_plot["selection_rate_pct"],
    height=bar_height,
    color="#2a9d8f",
    label="Selection Rate (%)",
)
bars2 = ax_genre.barh(
    y_pos + bar_height / 2,
    gsr_plot["selected_any_pct"],
    height=bar_height,
    color="#e76f51",
    label="Selected Any (%)",
)

ax_genre.set_yticks(y_pos)
ax_genre.set_yticklabels(gsr_plot["genre_label"].tolist())
ax_genre.invert_yaxis()
ax_genre.set_xlim(0, 100)
ax_genre.set_xlabel("Percentage (%)")
ax_genre.set_ylabel("Genre (Rank)")
ax_genre.set_title("Genre Intensity vs Coverage (Grouped Bars)", fontsize=12, pad=10)
ax_genre.legend(loc="lower right", fontsize=9)
ax_genre.spines["top"].set_visible(False)
ax_genre.spines["right"].set_visible(False)
fig_genre.tight_layout()

for ext in ("png", "pdf"):
    fig_genre.savefig(
        OUT_DIR / f"figure_genre_intensity_coverage_barh.{ext}",
        bbox_inches="tight",
    )
plt.close(fig_genre)
print("Saved: figure_genre_intensity_coverage_barh.{png,pdf}")

# --- Plotly interactive grouped bars ---
common_customdata = gsr_plot[
    ["genre", "n_items", "selection_rate_pct", "selected_any_pct"]
].to_numpy()

fig_genre_grouped = go.Figure()

fig_genre_grouped.add_trace(go.Bar(
    x=gsr_plot["selection_rate_pct"],
    y=gsr_plot["genre_label"],
    orientation="h",
    name="Selection Rate (%)",
    marker=dict(color="#2a9d8f"),
    customdata=common_customdata,
    hovertemplate=(
        "<b>Genre:</b> %{customdata[0]}<br>"
        "<b>n items:</b> %{customdata[1]:.0f}<br>"
        "<b>Selection Rate:</b> %{customdata[2]:.1f}%<br>"
        "<b>Selected Any:</b> %{customdata[3]:.1f}%"
        "<extra></extra>"
    ),
))

fig_genre_grouped.add_trace(go.Bar(
    x=gsr_plot["selected_any_pct"],
    y=gsr_plot["genre_label"],
    orientation="h",
    name="Selected Any (%)",
    marker=dict(color="#e76f51"),
    customdata=common_customdata,
    hovertemplate=(
        "<b>Genre:</b> %{customdata[0]}<br>"
        "<b>n items:</b> %{customdata[1]:.0f}<br>"
        "<b>Selection Rate:</b> %{customdata[2]:.1f}%<br>"
        "<b>Selected Any:</b> %{customdata[3]:.1f}%"
        "<extra></extra>"
    ),
))

fig_genre_grouped.update_layout(
    title=dict(text="<b>Genre Intensity vs Coverage (Grouped Bars)</b>", x=0.5),
    template="plotly_white",
    barmode="group",
    height=520,
    margin=dict(t=48, r=40, b=40, l=190),
    legend=dict(x=0.0, y=1.08, orientation="h"),
)
fig_genre_grouped.update_xaxes(
    range=[0, 100], title=dict(text="<b>Percentage (%)</b>")
)
fig_genre_grouped.update_yaxes(
    title=dict(text="<b>Genre (Rank)</b>"),
    categoryorder="array",
    categoryarray=gsr_plot["genre_label"].tolist()[::-1],
)

fig_genre_grouped.write_html(
    OUT_DIR / "interactive_genre_intensity_coverage_barh.html",
    include_plotlyjs="cdn",
)
print("Saved: interactive_genre_intensity_coverage_barh.html")

# ─────────────────────────────────────────────────────────────────────────────
# 7) Item flag thresholds  [cell 20]
# ─────────────────────────────────────────────────────────────────────────────
def corrected_item_total_corr(df_bin: pd.DataFrame) -> pd.Series:
    out = {}
    for col in df_bin.columns:
        x = df_bin[col]
        valid = x.notna()
        if valid.sum() < 3:
            out[col] = np.nan
            continue
        sub = df_bin.loc[valid]
        x_valid = x.loc[valid]
        corrected_total = sub.sum(axis=1, skipna=True) - x_valid
        if x_valid.nunique(dropna=True) < 2 or corrected_total.nunique(dropna=True) < 2:
            out[col] = np.nan
        else:
            out[col] = x_valid.corr(corrected_total)
    return pd.Series(out, name="corrected_item_total_corr")

author_flags = author_selection_rates.copy()
foil_flags = foil_selection_rates.copy()

author_flags["selection_rate"] = author_flags["selection_rate_pct"] / 100.0
foil_flags["selection_rate"] = foil_flags["selection_rate_pct"] / 100.0

citc = corrected_item_total_corr(author_resp_bin)
author_flags = author_flags.merge(
    citc.rename_axis("item_label").reset_index(),
    on="item_label", how="left",
)

author_flags["flag_endorsement_extreme_<.05_or_>.95"] = (
    (author_flags["selection_rate"] < 0.05) | (author_flags["selection_rate"] > 0.95)
)
author_flags["flag_citc_<.10"] = author_flags["corrected_item_total_corr"] < 0.10
author_flags["flag_citc_negative"] = author_flags["corrected_item_total_corr"] < 0

author_flags["flag_author_any_requested"] = (
    author_flags["flag_endorsement_extreme_<.05_or_>.95"]
    | author_flags["flag_citc_<.10"]
    | author_flags["flag_citc_negative"]
)

def add_multi_threshold_flags(
    df: pd.DataFrame, value_col: str, prefix: str,
    fixed_threshold: float = 0.20,
) -> pd.DataFrame:
    mean_val = df[value_col].mean()
    std_val = df[value_col].std(ddof=0)
    q1 = df[value_col].quantile(0.25)
    q3 = df[value_col].quantile(0.75)
    iqr = q3 - q1
    p95 = df[value_col].quantile(0.95)

    z_col = f"{prefix}_z"
    flag_z_col = f"flag_{prefix}_z_>2"
    flag_iqr_col = f"flag_{prefix}_iqr_>Q3+1.5IQR"
    flag_p95_col = f"flag_{prefix}_top_5pct_>P95"
    flag_fixed_col = f"flag_{prefix}_fixed_>0.20"
    flag_any_col = f"flag_{prefix}_any_threshold"

    out = df.copy()
    out[z_col] = (
        (out[value_col] - mean_val) / std_val if std_val and std_val > 0 else np.nan
    )
    out[flag_z_col] = out[z_col] > 2
    out[flag_iqr_col] = out[value_col] > (q3 + 1.5 * iqr)
    out[flag_p95_col] = out[value_col] > p95
    out[flag_fixed_col] = out[value_col] > fixed_threshold
    out[flag_any_col] = out[
        [flag_z_col, flag_iqr_col, flag_p95_col, flag_fixed_col]
    ].any(axis=1)
    return out

author_flags = add_multi_threshold_flags(
    author_flags, value_col="selection_rate",
    prefix="author_endorsement", fixed_threshold=0.20,
)

foil_flags = add_multi_threshold_flags(
    foil_flags, value_col="selection_rate",
    prefix="foil_endorsement", fixed_threshold=0.20,
)

# Missingness flags
author_missing_df = author_flags[
    ["item_label", "genre", "n_valid", "selection_rate_pct"]
].copy()
author_missing_df["item_type"] = "author"
author_missing_df["missing_rate"] = 1 - (
    author_missing_df["n_valid"] / author_missing_df["n_valid"].max()
)
author_missing_df["missing_rate_pct"] = author_missing_df["missing_rate"] * 100
author_missing_df = add_multi_threshold_flags(
    author_missing_df, value_col="missing_rate",
    prefix="author_missingness", fixed_threshold=0.20,
)

foil_missing_df = foil_flags[
    ["item_label", "genre", "n_valid", "selection_rate_pct"]
].copy()
foil_missing_df["item_type"] = "foil"
foil_missing_df["missing_rate"] = 1 - (
    foil_missing_df["n_valid"] / foil_missing_df["n_valid"].max()
)
foil_missing_df["missing_rate_pct"] = foil_missing_df["missing_rate"] * 100
foil_missing_df = add_multi_threshold_flags(
    foil_missing_df, value_col="missing_rate",
    prefix="foil_missingness", fixed_threshold=0.20,
)

# ─────────────────────────────────────────────────────────────────────────────
# TABLE: Flag count summary  [cell 20 summary_flags]
# ─────────────────────────────────────────────────────────────────────────────
summary_flags = pd.DataFrame({
    "rule": [
        "Author endorsement <.05 or >.95",
        "Author corrected item-total <.10",
        "Author corrected item-total negative",
        "Author endorsement z > 2",
        "Author endorsement > Q3 + 1.5*IQR",
        "Author endorsement > P95",
        "Author endorsement > 0.20",
        "Foil endorsement z > 2",
        "Foil endorsement > Q3 + 1.5*IQR",
        "Foil endorsement > P95",
        "Foil endorsement > 0.20",
        "Author missingness z > 2",
        "Author missingness > Q3 + 1.5*IQR",
        "Author missingness > P95",
        "Author missingness > 0.20",
        "Foil missingness z > 2",
        "Foil missingness > Q3 + 1.5*IQR",
        "Foil missingness > P95",
        "Foil missingness > 0.20",
    ],
    "n_flagged": [
        int(author_flags["flag_endorsement_extreme_<.05_or_>.95"].sum()),
        int(author_flags["flag_citc_<.10"].sum()),
        int(author_flags["flag_citc_negative"].sum()),
        int(author_flags["flag_author_endorsement_z_>2"].sum()),
        int(author_flags["flag_author_endorsement_iqr_>Q3+1.5IQR"].sum()),
        int(author_flags["flag_author_endorsement_top_5pct_>P95"].sum()),
        int(author_flags["flag_author_endorsement_fixed_>0.20"].sum()),
        int(foil_flags["flag_foil_endorsement_z_>2"].sum()),
        int(foil_flags["flag_foil_endorsement_iqr_>Q3+1.5IQR"].sum()),
        int(foil_flags["flag_foil_endorsement_top_5pct_>P95"].sum()),
        int(foil_flags["flag_foil_endorsement_fixed_>0.20"].sum()),
        int(author_missing_df["flag_author_missingness_z_>2"].sum()),
        int(author_missing_df["flag_author_missingness_iqr_>Q3+1.5IQR"].sum()),
        int(author_missing_df["flag_author_missingness_top_5pct_>P95"].sum()),
        int(author_missing_df["flag_author_missingness_fixed_>0.20"].sum()),
        int(foil_missing_df["flag_foil_missingness_z_>2"].sum()),
        int(foil_missing_df["flag_foil_missingness_iqr_>Q3+1.5IQR"].sum()),
        int(foil_missing_df["flag_foil_missingness_top_5pct_>P95"].sum()),
        int(foil_missing_df["flag_foil_missingness_fixed_>0.20"].sum()),
    ],
})

summary_flags.to_csv(OUT_DIR / "table_item_flag_summary.csv", index=False)
print("Saved: table_item_flag_summary.csv")

# ─────────────────────────────────────────────────────────────────────────────
# TABLE: Author flags detail  [cell 20 author_flags]
# ─────────────────────────────────────────────────────────────────────────────
author_flags.to_csv(OUT_DIR / "table_author_flags_detail.csv", index=False)
print("Saved: table_author_flags_detail.csv")

# ─────────────────────────────────────────────────────────────────────────────
# TABLE: Foil flags detail  [cell 20 foil_flags]
# ─────────────────────────────────────────────────────────────────────────────
foil_flags.to_csv(OUT_DIR / "table_foil_flags_detail.csv", index=False)
print("Saved: table_foil_flags_detail.csv")

# ─────────────────────────────────────────────────────────────────────────────
# README.md
# ─────────────────────────────────────────────────────────────────────────────
readme_text = textwrap.dedent("""\
    # Article Package: Item-Level Descriptives (04)

    Generated from `scripts/eda/08_item_level_descriptives.ipynb`.

    Source data: `data/stepwise_cleaned_versions/03_participant_demographics_normalized_categories/ART_pretest_(for Castano)_EN__participant_demographics_step04_normalized_categories.csv`

    ## Tables (CSV)

    | File | Description | Suggested placement |
    |------|-------------|---------------------|
    | `table_scale_descriptives_standard_vs_name_art.csv` | N, M, SD, Range for Standard and Name-only ART scoring | Main text (Table 1) |
    | `table_author_selection_rates.csv` | Per-author endorsement %, genre, rank | Main text or Appendix |
    | `table_foil_selection_rates.csv` | Per-foil endorsement % | Appendix |
    | `table_false_alarm_count_bins.csv` | Table 3-style bins of false alarm counts and participant % | Main text (Table 3) |
    | `table_genre_selection_rates.csv` | Per-genre intensity (selection rate) and coverage (selected any %) | Main text or Appendix |
    | `table_item_flag_summary.csv` | Counts per flagging rule across multi-threshold methods | Main text (Table) |
    | `table_author_flags_detail.csv` | Per-item flags for authors (endorsement, CITC, missingness) | Appendix |
    | `table_foil_flags_detail.csv` | Per-item flags for foils (endorsement, missingness) | Appendix |

    ## Static Figures (PNG + PDF, 300 dpi)

    | File | Description | Suggested placement |
    |------|-------------|---------------------|
    | `figure_score_distributions_kde_standard_vs_name.*` | Overlaid KDE densities of Standard vs Name-only ART scores | Main text (Figure 1) |
    | `figure_paired_scores_scatter_colored_by_fa.*` | Scatter of paired scores colored by false alarms | Main text (Figure 2) |
    | `figure_author_selection_rates_lollipop.*` | Lollipop chart of per-author selection rates by genre | Main text or Appendix |
    | `figure_false_alarm_count_histogram.*` | Bar chart of false alarm count distribution | Main text (Figure) |
    | `figure_genre_intensity_coverage_barh.*` | Grouped horizontal bars for genre intensity vs coverage | Main text or Appendix |

    ## Interactive Figures (HTML, Plotly CDN)

    | File | Description | Suggested placement |
    |------|-------------|---------------------|
    | `interactive_paired_scores_scatter.html` | Interactive scatter of paired ART scores | Supplement |
    | `interactive_author_selection_rates_lollipop.html` | Interactive lollipop of author selection rates | Supplement |
    | `interactive_genre_intensity_coverage_barh.html` | Interactive grouped bars for genre metrics | Supplement |

    ## Reproducibility

    This package was generated by `scripts/eda/10_export_article_package.py`
    (standalone) or from cell 22 of the source notebook.
""")

(OUT_DIR / "README.md").write_text(readme_text)
print("Saved: README.md")

# ─────────────────────────────────────────────────────────────────────────────
# Final manifest
# ─────────────────────────────────────────────────────────────────────────────
print("\n=== Article package complete ===")
print(f"Output directory: {OUT_DIR}")
for f in sorted(OUT_DIR.iterdir()):
    size_kb = f.stat().st_size / 1024
    print(f"  {f.name:60s} {size_kb:8.1f} KB")
