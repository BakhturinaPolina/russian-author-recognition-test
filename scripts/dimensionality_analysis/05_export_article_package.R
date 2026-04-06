# Article package export for notebook 05 (dimensionality / unidimensionality).
# Run after all analysis cells in 05_dimensionality_unidimensionality_check.ipynb
# (expects PROJECT_ROOT, author_mat, item_key, tet, pa, fa1, fa2, load1, load2,
#  mod1, item_pars_df, cfa_fit, fm, fit_table, loadings_df, problem_pairs,
#  comparison, eig_vals, and — from the decision cell — f2_primary if present).

stopifnot(exists("PROJECT_ROOT"), exists("author_mat"), exists("tet"), exists("pa"),
          exists("fa1"), exists("load1"), exists("load2"), exists("cfa_fit"), exists("fm"),
          exists("fit_table"), exists("loadings_df"), exists("endorse_df"),
          exists("item_pars_df"))

OUT_DIR <- file.path(PROJECT_ROOT, "results", "dimensionality_check_article_package_2026-04-06")
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

write_safe <- function(df, name) {
  path <- file.path(OUT_DIR, name)
  utils::write.csv(df, path, row.names = FALSE)
  message("Wrote ", path)
}

# ── Tables ────────────────────────────────────────────────────────────────
write_safe(endorse_df, "table_item_endorsement_rates.csv")

if (!is.null(problem_pairs) && nrow(problem_pairs) > 0) {
  write_safe(problem_pairs, "table_sparse_pair_diagnostics.csv")
} else {
  write_safe(data.frame(
    item_i = character(0), author_i = character(0),
    item_j = character(0), author_j = character(0),
    note = "no pairs with zero cells in 2x2 tables"
  ), "table_sparse_pair_diagnostics.csv")
}

n_pa <- min(length(pa$fa.values), length(pa$fa.sim))
pa_eig <- data.frame(
  factor = seq_len(n_pa),
  actual = as.numeric(pa$fa.values[seq_len(n_pa)]),
  simulated_95 = as.numeric(pa$fa.sim[seq_len(n_pa)]),
  above_random = as.logical(pa$fa.values[seq_len(n_pa)] > pa$fa.sim[seq_len(n_pa)]),
  stringsAsFactors = FALSE
)
write_safe(pa_eig, "table_eigenvalues_parallel_analysis.csv")

efa1_out <- load1
write_safe(efa1_out, "table_efa_1factor_loadings.csv")
write_safe(load2, "table_efa_2factor_loadings.csv")

irt_out <- item_pars_df
write_safe(irt_out, "table_irt_2pl_parameters.csv")

write_safe(fit_table, "table_cfa_fit_indices.csv")

cfa_load <- loadings_df[, !names(loadings_df) %in% c("item_label_short", "display")]
write_safe(cfa_load, "table_cfa_standardized_loadings.csv")

stopifnot(exists("comparison"))
write_safe(comparison, "table_trimmed_analysis_summary.csv")

# Decision summary (tall)
n_items <- nrow(loadings_df)
n_above_30 <- sum(loadings_df$std_loading >= 0.30)
n_below_20 <- sum(loadings_df$std_loading < 0.20)
pct_above_30 <- 100 * n_above_30 / n_items
rmsea_val <- fm["rmsea"]
cfi_val <- fm["cfi"]
tli_val <- fm["tli"]
eig_ratio <- eig_vals[1] / eig_vals[2]
pa_nfact <- pa$nfact
cfa_acceptable <- (rmsea_val < 0.08) && (cfi_val > 0.90)
loadings_ok <- pct_above_30 >= 80
rec_text <- if (cfa_acceptable && loadings_ok) {
  "PROCEED with unidimensional IRT"
} else if (cfa_acceptable) {
  "PROCEED with CAUTION"
} else {
  "INVESTIGATE FURTHER"
}
n_f2 <- if (exists("f2_primary") && is.data.frame(f2_primary) && nrow(f2_primary) > 0) {
  nrow(f2_primary)
} else {
  0L
}

decision_tbl <- data.frame(
  metric = c(
    "eigenvalue_ratio_lambda1_lambda2",
    "parallel_analysis_n_factors",
    "efa_1factor_variance_explained_pct",
    "cfa_rmsea", "cfa_cfi", "cfa_tli",
    "n_items_std_loading_ge_030",
    "n_items_std_loading_below_020",
    "pct_items_std_loading_ge_030",
    "n_items_primary_on_factor2_two_factor_efa",
    "recommendation_text",
    "criterion_cfa_acceptable",
    "criterion_loadings_ok_pct_ge_030_ge_80"
  ),
  value = c(
    format(round(eig_ratio, 4), scientific = FALSE),
    as.character(pa_nfact),
    format(round(100 * fa1$Vaccounted[2, 1], 2), scientific = FALSE),
    format(round(rmsea_val, 4), scientific = FALSE),
    format(round(cfi_val, 4), scientific = FALSE),
    format(round(tli_val, 4), scientific = FALSE),
    as.character(n_above_30),
    as.character(n_below_20),
    format(round(pct_above_30, 2), scientific = FALSE),
    as.character(n_f2),
    rec_text,
    as.character(cfa_acceptable),
    as.character(loadings_ok)
  ),
  stringsAsFactors = FALSE
)
write_safe(decision_tbl, "table_decision_summary.csv")

# ── Figures (ggplot2 + ggsave) ────────────────────────────────────────────
genre_colors <- c(
  "Classics"           = "#2166AC",
  "Modern/Literary"    = "#B2182B",
  "SovLit"             = "#4DAF4A",
  "Detective/Thriller" = "#FF7F00",
  "Sci-Fi"             = "#984EA3",
  "Fantasy"            = "#A65628"
)

save_both <- function(plot, base, w = 10, h = 7) {
  png <- file.path(OUT_DIR, paste0(base, ".png"))
  pdf <- file.path(OUT_DIR, paste0(base, ".pdf"))
  ggplot2::ggsave(png, plot, width = w, height = h, dpi = 300)
  ggplot2::ggsave(pdf, plot, width = w, height = h, device = "pdf")
  message("Wrote ", png, " / ", pdf)
}

fig_endorse <- ggplot2::ggplot(endorse_df, ggplot2::aes(x = reorder(item, rate), y = rate, fill = genre)) +
  ggplot2::geom_col(width = 0.7) +
  ggplot2::geom_hline(yintercept = c(0.05, 0.95), linetype = "dashed", color = "red", linewidth = 0.5) +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Author item endorsement rates",
                x = NULL, y = "Endorsement proportion", fill = "Genre") +
  ggplot2::theme_minimal(base_size = 8) +
  ggplot2::theme(axis.text.y = ggplot2::element_text(size = 5))
save_both(fig_endorse, "figure_endorsement_rates_by_item", w = 10, h = 6)

cn <- colnames(tet$rho)
hmd <- expand.grid(
  item_i = factor(cn, levels = cn),
  item_j = factor(cn, levels = cn),
  stringsAsFactors = FALSE
)
hmd$r <- as.vector(tet$rho)
rng <- range(hmd$r, na.rm = TRUE)
fig_heat <- ggplot2::ggplot(hmd, ggplot2::aes(x = item_j, y = item_i, fill = r)) +
  ggplot2::geom_tile() +
  ggplot2::scale_y_discrete(limits = rev(cn)) +
  ggplot2::scale_fill_gradientn(
    colours = c("#2166AC", "white", "#B2182B"),
    limits = rng,
    name = "r"
  ) +
  ggplot2::theme_minimal(base_size = 8) +
  ggplot2::theme(
    axis.text = ggplot2::element_blank(),
    panel.grid = ggplot2::element_blank(),
    plot.title = ggplot2::element_text(face = "bold")
  ) +
  ggplot2::labs(
    title = "Tetrachoric correlation matrix (98 author items)",
    x = NULL, y = NULL
  )
save_both(fig_heat, "figure_tetrachoric_correlation_heatmap", w = 9, h = 9)

n_show <- min(20L, length(pa$fa.values))
pa_plot_df <- data.frame(
  Factor = rep(seq_len(n_show), 2),
  Eigenvalue = c(pa$fa.values[seq_len(n_show)], pa$fa.sim[seq_len(n_show)]),
  Source = rep(c("Actual", "Simulated 95th pctile"), each = n_show),
  stringsAsFactors = FALSE
)
fig_pa <- ggplot2::ggplot(pa_plot_df, ggplot2::aes(
  x = Factor, y = Eigenvalue, color = Source, linetype = Source
)) +
  ggplot2::geom_line(linewidth = 0.8) +
  ggplot2::geom_point(size = 2) +
  ggplot2::geom_hline(yintercept = 1.0, linetype = "dotted", color = "grey40") +
  ggplot2::annotate(
    "text", x = 5, y = pa$fa.values[1] - 1.5,
    label = sprintf("\u03bb1/\u03bb2 = %.2f", pa$fa.values[1] / pa$fa.values[2]),
    size = 3.5, fontface = "bold"
  ) +
  ggplot2::scale_x_continuous(breaks = seq_len(n_show)) +
  ggplot2::scale_color_manual(values = c("Actual" = "steelblue", "Simulated 95th pctile" = "tomato")) +
  ggplot2::labs(
    title = "Parallel analysis scree plot (tetrachoric correlations)",
    x = "Factor number", y = "Eigenvalue",
    caption = "N = 908. Actual vs. 95th-percentile eigenvalues from random data."
  ) +
  ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(legend.position = "bottom", legend.title = ggplot2::element_blank())
save_both(fig_pa, "figure_parallel_analysis_scree", w = 9, h = 5)

load1_sorted <- load1[order(load1$loading), ]
load1_sorted$item_label_short <- ifelse(
  nchar(load1_sorted$item_label) > 25,
  paste0(substr(load1_sorted$item_label, 1, 22), "..."),
  load1_sorted$item_label
)
load1_sorted$display <- paste0(load1_sorted$item, ": ", load1_sorted$item_label_short)
load1_sorted$display <- factor(load1_sorted$display, levels = load1_sorted$display)

fig_efa1 <- ggplot2::ggplot(load1_sorted, ggplot2::aes(x = loading, y = display, color = genre)) +
  ggplot2::geom_point(size = 2) +
  ggplot2::geom_segment(ggplot2::aes(xend = 0, yend = display), linewidth = 0.3) +
  ggplot2::geom_vline(xintercept = 0.30, linetype = "dashed", color = "red", linewidth = 0.4) +
  ggplot2::annotate("text", x = 0.32, y = 5, label = "0.30 threshold",
                   size = 2.8, color = "red", hjust = 0) +
  ggplot2::labs(title = "One-factor EFA loadings (tetrachoric, minres)",
                x = "Factor loading", y = NULL, color = "Genre") +
  ggplot2::theme_minimal(base_size = 8) +
  ggplot2::theme(axis.text.y = ggplot2::element_text(size = 5), legend.position = "bottom")
save_both(fig_efa1, "figure_efa_1factor_loadings_lollipop", w = 10, h = 12)

if (!exists("ifa_df")) {
  ifa_df <- data.frame(
    item = item_pars_df$item,
    a    = item_pars_df$a,
    b    = item_pars_df$b,
    stringsAsFactors = FALSE
  )
  ifa_df <- merge(ifa_df,
                  item_key[, c("matrix_item_id", "item_label", "genre", "selection_rate_pct")],
                  by.x = "item", by.y = "matrix_item_id", all.x = TRUE)
}
label_subset <- subset(ifa_df, a < 0.55 | a > 2.8 | abs(b) > 4)
use_repel <- requireNamespace("ggrepel", quietly = TRUE)
fig_irt <- ggplot2::ggplot(ifa_df, ggplot2::aes(x = b, y = a, color = genre)) +
  ggplot2::geom_point(size = 2.5, alpha = 0.8) +
  ggplot2::geom_hline(yintercept = 0.30, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  ggplot2::geom_hline(yintercept = 0.50, linetype = "dotted", color = "grey60", linewidth = 0.4) +
  ggplot2::scale_color_manual(values = genre_colors) +
  ggplot2::labs(
    title = "2PL: discrimination (a) vs. difficulty (b)",
    x = "Difficulty (b)", y = "Discrimination (a)", color = "Genre"
  ) +
  ggplot2::theme_minimal(base_size = 12) +
  ggplot2::theme(legend.position = "bottom")
if (use_repel) {
  fig_irt <- fig_irt + ggrepel::geom_text_repel(
    data = label_subset, ggplot2::aes(label = item_label),
    size = 2.8, max.overlaps = 25, segment.alpha = 0.4, show.legend = FALSE
  )
} else {
  fig_irt <- fig_irt + ggplot2::geom_text(
    data = label_subset, ggplot2::aes(label = item_label),
    size = 2.5, check_overlap = TRUE, vjust = -0.8, show.legend = FALSE
  )
}
save_both(fig_irt, "figure_irt_2pl_a_vs_b", w = 12, h = 8)

ld <- loadings_df
ld$item_label_short <- ifelse(
  nchar(ld$item_label) > 25,
  paste0(substr(ld$item_label, 1, 22), "..."),
  ld$item_label
)
ld$display <- paste0(ld$item, ": ", ld$item_label_short)
ld$display <- factor(ld$display, levels = ld$display)

fig_cfa <- ggplot2::ggplot(ld, ggplot2::aes(x = std_loading, y = display, fill = genre)) +
  ggplot2::geom_col(width = 0.6) +
  ggplot2::geom_vline(xintercept = 0.30, linetype = "dashed", color = "red", linewidth = 0.4) +
  ggplot2::annotate("text", x = 0.32, y = 5, label = "0.30 threshold",
                    size = 2.8, color = "red", hjust = 0) +
  ggplot2::labs(title = "One-factor CFA: standardized loadings (WLSMV)",
                x = "Standardized loading", y = NULL, fill = "Genre") +
  ggplot2::theme_minimal(base_size = 8) +
  ggplot2::theme(axis.text.y = ggplot2::element_text(size = 5), legend.position = "bottom")
save_both(fig_cfa, "figure_cfa_loadings_barplot", w = 10, h = 12)

message("Article package complete: ", OUT_DIR)
