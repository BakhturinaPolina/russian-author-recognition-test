# Article package: dimensionality / unidimensionality check (notebook 05).
# Usage (from repo root):
#   Rscript -e 'PROJECT_ROOT <- normalizePath("."); source("scripts/article_exports/export_05_dimensionality_article_package.R")'
# Or from IRkernel after:
#   PROJECT_ROOT <- normalizePath(file.path("..", ".."), mustWork = TRUE)
#   source(file.path(PROJECT_ROOT, "scripts", "article_exports", "export_05_dimensionality_article_package.R"))

options(mc.cores = 1L)
Sys.setenv(MC_CORES = "1")

suppressPackageStartupMessages({
  library(psych)
  library(mirt)
  library(lavaan)
  library(ggplot2)
  library(reshape2)
})

if (!exists("PROJECT_ROOT", inherits = TRUE)) {
  tr <- commandArgs(trailingOnly = TRUE)
  if (length(tr) >= 1L) {
    PROJECT_ROOT <- normalizePath(tr[1], mustWork = TRUE)
  } else {
    stop("Set PROJECT_ROOT before sourcing, or pass repo root as first CLI argument.")
  }
}

OUT_DIR <- file.path(PROJECT_ROOT, "results", "dimensionality_check_article_package_2026-04-06")
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

DATA_DIR <- file.path(PROJECT_ROOT, "data", "stepwise_cleaned_versions", "05_dimensionality_inputs")

manifest <- read.csv(
  file.path(DATA_DIR, "ART_pretest_(for Castano)_EN__dimensionality_input__manifest.csv"),
  stringsAsFactors = FALSE
)
author_df <- read.csv(
  file.path(DATA_DIR, "ART_pretest_(for Castano)_EN__dimensionality_input__author_response_matrix.csv"),
  stringsAsFactors = FALSE
)
item_key <- read.csv(
  file.path(DATA_DIR, "ART_pretest_(for Castano)_EN__dimensionality_input__author_item_key.csv"),
  stringsAsFactors = FALSE
)

author_mat <- as.matrix(author_df[, -1L])
non_binary <- sum(!author_mat %in% c(0, 1, NA))
if (non_binary > 0L) {
  author_mat[author_mat > 1] <- 1L
}
storage.mode(author_mat) <- "integer"

expected_n <- as.integer(manifest$value[manifest$field == "n_participants"])
expected_k <- as.integer(manifest$value[manifest$field == "n_author_items"])
stopifnot(nrow(author_mat) == expected_n, ncol(author_mat) == expected_k)

label_lookup <- setNames(
  paste0(item_key$item_label, " (", item_key$matrix_item_id, ")"),
  item_key$matrix_item_id
)

# --- Endorsement ---
endorsement <- colMeans(author_mat, na.rm = TRUE)
endorse_df <- data.frame(
  item = names(endorsement),
  rate = as.numeric(endorsement),
  stringsAsFactors = FALSE
)
endorse_df <- merge(
  endorse_df,
  item_key[, c("matrix_item_id", "item_label", "genre")],
  by.x = "item", by.y = "matrix_item_id", all.x = TRUE
)
endorse_df <- endorse_df[order(endorse_df$rate), ]
write.csv(endorse_df, file.path(OUT_DIR, "table_item_endorsement_rates.csv"), row.names = FALSE)

p_endorse <- ggplot(endorse_df, aes(x = reorder(item, rate), y = rate, fill = genre)) +
  geom_col(width = 0.7) +
  geom_hline(yintercept = c(0.05, 0.95), linetype = "dashed", color = "red", linewidth = 0.5) +
  coord_flip() +
  labs(
    title = "Author item endorsement rates",
    x = NULL, y = "Endorsement proportion", fill = "Genre"
  ) +
  theme_minimal(base_size = 8) +
  theme(axis.text.y = element_text(size = 5))

ggsave(file.path(OUT_DIR, "figure_endorsement_rates_by_item.png"), p_endorse,
       width = 10, height = 6, dpi = 300
)
ggsave(file.path(OUT_DIR, "figure_endorsement_rates_by_item.pdf"), p_endorse,
       width = 10, height = 6, device = "pdf"
)

# --- Tetrachoric ---
cat("Computing tetrachoric correlations (98 items)...\n")
tet <- psych::tetrachoric(author_mat)

# Sparse 2x2 diagnostics
x <- as.matrix(author_mat)
p <- ncol(x)
pair_rows <- vector("list", p * (p - 1L) / 2L)
k <- 1L
for (i in 2L:p) {
  xi <- x[, i]
  for (j in 1L:(i - 1L)) {
    xj <- x[, j]
    ok <- is.finite(xi) & is.finite(xj)
    if (!any(ok)) next
    tab <- table(factor(xi[ok], levels = c(0, 1)), factor(xj[ok], levels = c(0, 1)))
    zero_cells <- sum(tab == 0L)
    if (zero_cells > 0L) {
      pair_rows[[k]] <- data.frame(
        item_i = colnames(x)[i],
        author_i = label_lookup[colnames(x)[i]],
        item_j = colnames(x)[j],
        author_j = label_lookup[colnames(x)[j]],
        n00 = unname(tab["0", "0"]),
        n01 = unname(tab["0", "1"]),
        n10 = unname(tab["1", "0"]),
        n11 = unname(tab["1", "1"]),
        zero_cells = zero_cells,
        stringsAsFactors = FALSE
      )
      k <- k + 1L
    }
  }
}
problem_pairs <- do.call(rbind, pair_rows)
if (is.null(problem_pairs) || nrow(problem_pairs) == 0L) {
  problem_pairs <- data.frame(
    item_i = character(0), author_i = character(0), item_j = character(0),
    author_j = character(0), n00 = integer(0), n01 = integer(0), n10 = integer(0),
    n11 = integer(0), zero_cells = integer(0), stringsAsFactors = FALSE
)
} else {
  problem_pairs <- problem_pairs[order(-problem_pairs$zero_cells), ]
}
write.csv(problem_pairs, file.path(OUT_DIR, "table_sparse_pair_diagnostics.csv"), row.names = FALSE)

total_pairs <- p * (p - 1L) / 2L
n_prob <- nrow(problem_pairs)

# Trimmed set (same rule as notebook)
TRIM_LO <- 0.08
TRIM_HI <- 0.95
item_prev <- colMeans(author_mat, na.rm = TRUE)
all_items_pp <- if (n_prob > 0L) c(problem_pairs$item_i, problem_pairs$item_j) else character(0)
pp_counts <- table(factor(all_items_pp, levels = colnames(author_mat)))
excl_mask <- (item_prev < TRIM_LO) | (item_prev > TRIM_HI)
excl_items <- colnames(author_mat)[excl_mask]
kept_items <- colnames(author_mat)[!excl_mask]
author_mat_trimmed <- author_mat[, kept_items, drop = FALSE]

# Residual problem pairs on trimmed matrix
xt <- as.matrix(author_mat_trimmed)
pt <- ncol(xt)
n_prob_trimmed <- 0L
for (i in 2L:pt) {
  xi <- xt[, i]
  for (j in 1L:(i - 1L)) {
    xj <- xt[, j]
    ok <- is.finite(xi) & is.finite(xj)
    if (!any(ok)) next
    tab <- table(factor(xi[ok], levels = c(0, 1)), factor(xj[ok], levels = c(0, 1)))
    if (any(tab == 0L)) n_prob_trimmed <- n_prob_trimmed + 1L
  }
}
total_trimmed_pairs <- pt * (pt - 1L) / 2L

# --- Tetrachoric heatmap (ggplot) ---
ord <- hclust(as.dist(1 - tet$rho), method = "ward.D2")$order
lab_ord <- colnames(tet$rho)[ord]
rsub <- tet$rho[ord, ord, drop = FALSE]
tdf <- reshape2::melt(rsub)
colnames(tdf) <- c("Var1", "Var2", "r")
tdf$Var1 <- factor(tdf$Var1, levels = lab_ord)
tdf$Var2 <- factor(tdf$Var2, levels = rev(lab_ord))

p_tet <- ggplot(tdf, aes(Var1, Var2, fill = r)) +
  geom_tile() +
  scale_fill_gradient2(low = "#2166AC", mid = "white", high = "#B2182B", midpoint = 0, limits = c(-1, 1)) +
  labs(
    title = "Tetrachoric correlation matrix (Ward.D2 order)",
    x = NULL, y = NULL, fill = "r"
  ) +
  theme_minimal(base_size = 6) +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 4),
    axis.text.y = element_text(size = 4),
    panel.grid = element_blank()
  )

ggsave(file.path(OUT_DIR, "figure_tetrachoric_correlation_heatmap.png"), p_tet,
       width = 10, height = 10, dpi = 300
)
ggsave(file.path(OUT_DIR, "figure_tetrachoric_correlation_heatmap.pdf"), p_tet,
       width = 10, height = 10, device = "pdf"
)

# --- Eigenvalues & parallel analysis ---
eig_vals <- eigen(tet$rho)$values

set.seed(42)
pa <- psych::fa.parallel(author_mat, cor = "tet", fa = "fa", n.iter = 20, plot = FALSE, correct = 0.5)
pa_nfact <- pa$nfact

n_show <- min(20L, length(pa$fa.values))
comp_df <- data.frame(
  Factor = seq_len(n_show),
  Actual = pa$fa.values[seq_len(n_show)],
  Simulated_95th_pctile = pa$fa.sim[seq_len(n_show)],
  Above_Random = ifelse(
    pa$fa.values[seq_len(n_show)] > pa$fa.sim[seq_len(n_show)], "***", ""
  ),
  stringsAsFactors = FALSE
)
write.csv(comp_df, file.path(OUT_DIR, "table_eigenvalues_parallel_analysis.csv"), row.names = FALSE)

pa_plot_df <- data.frame(
  Factor = rep(seq_len(n_show), 2L),
  Eigenvalue = c(comp_df$Actual, comp_df$Simulated_95th_pctile),
  Source = rep(c("Actual", "Simulated_95th_pctile"), each = n_show),
  stringsAsFactors = FALSE
)

p_pa <- ggplot(pa_plot_df, aes(x = Factor, y = Eigenvalue, color = Source, linetype = Source)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  geom_hline(yintercept = 1.0, linetype = "dotted", color = "grey40") +
  scale_x_continuous(breaks = seq_len(n_show)) +
  scale_color_manual(values = c("Actual" = "steelblue", "Simulated_95th_pctile" = "tomato")) +
  labs(
    title = "Parallel analysis scree plot (tetrachoric)",
    x = "Factor number", y = "Eigenvalue"
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", legend.title = element_blank())

ggsave(file.path(OUT_DIR, "figure_parallel_analysis_scree.png"), p_pa, width = 9, height = 5, dpi = 300)
ggsave(file.path(OUT_DIR, "figure_parallel_analysis_scree.pdf"), p_pa, width = 9, height = 5, device = "pdf")

# --- EFA 1 & 2 ---
fa1 <- psych::fa(tet$rho, nfactors = 1L, n.obs = nrow(author_mat), fm = "minres")
load1 <- data.frame(
  item = rownames(fa1$loadings),
  loading = as.numeric(fa1$loadings[, 1L]),
  communality = fa1$communalities,
  uniqueness = fa1$uniquenesses,
  stringsAsFactors = FALSE
)
load1 <- merge(
  load1,
  item_key[, c("matrix_item_id", "item_label", "genre", "selection_rate_pct", "corrected_item_total_corr")],
  by.x = "item", by.y = "matrix_item_id", all.x = TRUE
)
load1 <- load1[order(load1$loading), ]
write.csv(load1, file.path(OUT_DIR, "table_efa_1factor_loadings.csv"), row.names = FALSE)

fa2 <- psych::fa(tet$rho, nfactors = 2L, n.obs = nrow(author_mat), fm = "minres", rotate = "oblimin")
load2 <- data.frame(
  item = rownames(fa2$loadings),
  F1 = as.numeric(fa2$loadings[, 1L]),
  F2 = as.numeric(fa2$loadings[, 2L]),
  stringsAsFactors = FALSE
)
load2 <- merge(
  load2,
  item_key[, c("matrix_item_id", "item_label", "genre", "selection_rate_pct")],
  by.x = "item", by.y = "matrix_item_id", all.x = TRUE
)
write.csv(load2, file.path(OUT_DIR, "table_efa_2factor_loadings.csv"), row.names = FALSE)

f2_primary <- load2[abs(load2$F2) > abs(load2$F1), ]

load1_sorted <- load1[order(load1$loading), ]
load1_sorted$item_label_short <- ifelse(
  nchar(load1_sorted$item_label) > 25L,
  paste0(substr(load1_sorted$item_label, 1L, 22L), "..."),
  load1_sorted$item_label
)
load1_sorted$display <- paste0(load1_sorted$item, ": ", load1_sorted$item_label_short)
load1_sorted$display <- factor(load1_sorted$display, levels = load1_sorted$display)

p_efa1 <- ggplot(load1_sorted, aes(x = loading, y = display, color = genre)) +
  geom_point(size = 2) +
  geom_segment(aes(xend = 0, yend = display), linewidth = 0.3) +
  geom_vline(xintercept = 0.30, linetype = "dashed", color = "red", linewidth = 0.4) +
  labs(
    title = "One-factor EFA loadings (tetrachoric, minres)",
    x = "Factor loading", y = NULL, color = "Genre"
  ) +
  theme_minimal(base_size = 8) +
  theme(axis.text.y = element_text(size = 5), legend.position = "bottom")

ggsave(file.path(OUT_DIR, "figure_efa_1factor_loadings_lollipop.png"), p_efa1, width = 10, height = 12, dpi = 300)
ggsave(file.path(OUT_DIR, "figure_efa_1factor_loadings_lollipop.pdf"), p_efa1, width = 10, height = 12, device = "pdf")

# --- mirt 2PL (exploratory IFA) ---
cat("Fitting mirt 2PL (single factor)...\n")
mod1 <- mirt::mirt(author_mat, model = 1L, itemtype = "2PL", verbose = FALSE)
item_pars <- coef(mod1, IRTpars = TRUE, simplify = TRUE)$items
item_pars_df <- as.data.frame(item_pars)
item_pars_df$item <- rownames(item_pars_df)
if (!"a" %in% names(item_pars_df) && "a1" %in% names(item_pars_df)) {
  item_pars_df$a <- item_pars_df$a1
}
if (!"b" %in% names(item_pars_df) && "d" %in% names(item_pars_df) && "a1" %in% names(item_pars_df)) {
  item_pars_df$b <- -item_pars_df$d / item_pars_df$a1
}
item_pars_df <- merge(
  item_pars_df,
  item_key[, c("matrix_item_id", "item_label", "genre", "selection_rate_pct")],
  by.x = "item", by.y = "matrix_item_id", all.x = TRUE
)
write.csv(item_pars_df, file.path(OUT_DIR, "table_irt_2pl_parameters.csv"), row.names = FALSE)

ifa_df <- data.frame(
  item = item_pars_df$item,
  a = item_pars_df$a,
  b = item_pars_df$b,
  item_label = item_pars_df$item_label,
  genre = item_pars_df$genre,
  selection_rate_pct = item_pars_df$selection_rate_pct,
  stringsAsFactors = FALSE
)

genre_colors <- c(
  "Classics" = "#2166AC",
  "Modern/Literary" = "#B2182B",
  "SovLit" = "#4DAF4A",
  "Detective/Thriller" = "#FF7F00",
  "Sci-Fi" = "#984EA3",
  "Fantasy" = "#A65628"
)
label_subset <- subset(ifa_df, a < 0.55 | a > 2.8 | abs(b) > 4)
use_repel <- requireNamespace("ggrepel", quietly = TRUE)

p_irt <- ggplot(ifa_df, aes(x = b, y = a, color = genre)) +
  geom_point(size = 2.5, alpha = 0.8) +
  geom_hline(yintercept = 0.30, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_hline(yintercept = 0.50, linetype = "dotted", color = "grey60", linewidth = 0.4) +
  scale_color_manual(values = genre_colors) +
  labs(
    title = "2PL discrimination (a) vs difficulty (b)",
    x = "Difficulty (b)", y = "Discrimination (a)", color = "Genre"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

if (use_repel) {
  p_irt <- p_irt + ggrepel::geom_text_repel(
    data = label_subset,
    aes(label = item_label),
    size = 2.5, max.overlaps = 25L, segment.alpha = 0.4, show.legend = FALSE
  )
} else {
  p_irt <- p_irt + geom_text(
    data = label_subset,
    aes(label = item_label),
    size = 2.2, check_overlap = TRUE, vjust = -0.8, show.legend = FALSE
  )
}

ggsave(file.path(OUT_DIR, "figure_irt_2pl_a_vs_b.png"), p_irt, width = 12, height = 8, dpi = 300)
ggsave(file.path(OUT_DIR, "figure_irt_2pl_a_vs_b.pdf"), p_irt, width = 12, height = 8, device = "pdf")

# --- CFA full ---
cat("Fitting one-factor CFA (WLSMV), full item set — may take several minutes...\n")
author_cfa_df <- as.data.frame(author_mat)
item_names <- colnames(author_cfa_df)
model_syntax <- paste0("F1 =~ ", paste(item_names, collapse = " + "))
cfa_fit <- lavaan::cfa(
  model = model_syntax,
  data = author_cfa_df,
  ordered = item_names,
  estimator = "WLSMV"
)

fm <- lavaan::fitMeasures(cfa_fit, c(
  "chisq", "df", "pvalue",
  "rmsea", "rmsea.ci.lower", "rmsea.ci.upper", "rmsea.pvalue",
  "cfi", "tli", "srmr"
))
fit_table <- data.frame(
  metric = names(fm),
  value = as.numeric(fm),
  analysis = "full_98",
  stringsAsFactors = FALSE
)

std_est <- lavaan::standardizedSolution(cfa_fit)
loadings_df <- std_est[std_est$op == "=~", c("rhs", "est.std", "se", "z", "pvalue")]
colnames(loadings_df) <- c("item", "std_loading", "se", "z", "pvalue")
loadings_df <- merge(
  loadings_df,
  item_key[, c("matrix_item_id", "item_label", "genre", "selection_rate_pct")],
  by.x = "item", by.y = "matrix_item_id", all.x = TRUE
)
loadings_df <- loadings_df[order(loadings_df$std_loading), ]
write.csv(loadings_df, file.path(OUT_DIR, "table_cfa_standardized_loadings.csv"), row.names = FALSE)

loadings_df$item_label_short <- ifelse(
  nchar(loadings_df$item_label) > 25L,
  paste0(substr(loadings_df$item_label, 1L, 22L), "..."),
  loadings_df$item_label
)
loadings_df$display <- paste0(loadings_df$item, ": ", loadings_df$item_label_short)
loadings_df$display <- factor(loadings_df$display, levels = loadings_df$display)

p_cfa <- ggplot(loadings_df, aes(x = std_loading, y = display, fill = genre)) +
  geom_col(width = 0.6) +
  geom_vline(xintercept = 0.30, linetype = "dashed", color = "red", linewidth = 0.4) +
  labs(
    title = "One-factor CFA standardized loadings (WLSMV)",
    x = "Standardized loading", y = NULL, fill = "Genre"
  ) +
  theme_minimal(base_size = 8) +
  theme(axis.text.y = element_text(size = 5), legend.position = "bottom")

ggsave(file.path(OUT_DIR, "figure_cfa_loadings_barplot.png"), p_cfa, width = 10, height = 12, dpi = 300)
ggsave(file.path(OUT_DIR, "figure_cfa_loadings_barplot.pdf"), p_cfa, width = 10, height = 12, device = "pdf")

# --- Decision summary (mirrors notebook narrative) ---
n_items <- nrow(loadings_df)
n_above_30 <- sum(loadings_df$std_loading >= 0.30)
n_below_20 <- sum(loadings_df$std_loading < 0.20)
pct_above_30 <- 100 * n_above_30 / n_items
rmsea_val <- unname(fm["rmsea"])
cfi_val <- unname(fm["cfi"])
tli_val <- unname(fm["tli"])
eig_ratio <- eig_vals[1L] / eig_vals[2L]
cfa_acceptable <- (rmsea_val < 0.08) && (cfi_val > 0.90)
loadings_ok <- pct_above_30 >= 80
if (cfa_acceptable && loadings_ok) {
  rec <- "PROCEED_unidimensional_IRT"
} else if (cfa_acceptable) {
  rec <- "PROCEED_WITH_CAUTION"
} else {
  rec <- "INVESTIGATE_FURTHER"
}

decision_tbl <- data.frame(
  recommendation = rec,
  eigenvalue_ratio_lambda1_lambda2 = eig_ratio,
  parallel_analysis_n_factors_suggested = pa_nfact,
  efa_1f_variance_explained = unname(fa1$Vaccounted[2L, 1L]),
  rmsea = rmsea_val,
  cfi = cfi_val,
  tli = tli_val,
  n_items = n_items,
  n_loadings_ge_030 = n_above_30,
  pct_loadings_ge_030 = pct_above_30,
  n_loadings_lt_020 = n_below_20,
  n_f2_primary_items = if (exists("f2_primary") && nrow(f2_primary) > 0L) nrow(f2_primary) else 0L,
  stringsAsFactors = FALSE
)
write.csv(decision_tbl, file.path(OUT_DIR, "table_decision_summary.csv"), row.names = FALSE)

# --- Trimmed analyses ---
cat("Trimmed-matrix analyses...\n")
tet_trimmed <- psych::tetrachoric(author_mat_trimmed)
eig_vals_trimmed <- eigen(tet_trimmed$rho)$values

set.seed(42)
pa_trimmed <- psych::fa.parallel(author_mat_trimmed, cor = "tet", fa = "fa", n.iter = 20, plot = FALSE, correct = 0.5)
pa_nfact_trimmed <- pa_trimmed$nfact

fa1_trimmed <- psych::fa(tet_trimmed$rho, nfactors = 1L, n.obs = nrow(author_mat_trimmed), fm = "minres")
fa2_trimmed <- psych::fa(tet_trimmed$rho, nfactors = 2L, n.obs = nrow(author_mat_trimmed), fm = "minres", rotate = "oblimin")

trimmed_cfa_df <- as.data.frame(author_mat_trimmed)
trimmed_names <- colnames(trimmed_cfa_df)
model_syntax_tr <- paste0("F1 =~ ", paste(trimmed_names, collapse = " + "))
cfa_fit_trimmed <- lavaan::cfa(
  model_syntax_tr,
  data = trimmed_cfa_df,
  ordered = trimmed_names,
  estimator = "WLSMV"
)
fm_tr <- lavaan::fitMeasures(cfa_fit_trimmed, c(
  "chisq", "df", "pvalue",
  "rmsea", "rmsea.ci.lower", "rmsea.ci.upper", "rmsea.pvalue",
  "cfi", "tli", "srmr"
))
fit_table_tr <- data.frame(
  metric = names(fm_tr),
  value = as.numeric(fm_tr),
  analysis = "trimmed_84",
  stringsAsFactors = FALSE
)
write.csv(rbind(fit_table, fit_table_tr), file.path(OUT_DIR, "table_cfa_fit_indices.csv"), row.names = FALSE)

std_est_tr <- lavaan::standardizedSolution(cfa_fit_trimmed)
loadings_tr <- std_est_tr[std_est_tr$op == "=~", c("rhs", "est.std", "se")]
colnames(loadings_tr) <- c("item", "std_loading", "se")
loadings_tr <- merge(
  loadings_tr,
  item_key[, c("matrix_item_id", "item_label", "genre", "selection_rate_pct")],
  by.x = "item", by.y = "matrix_item_id", all.x = TRUE
)

fm_full <- lavaan::fitMeasures(cfa_fit, c("rmsea", "rmsea.ci.lower", "rmsea.ci.upper", "cfi", "tli", "srmr"))
n_above30_full <- sum(loadings_df$std_loading >= 0.30)
n_below20_full <- sum(loadings_df$std_loading < 0.20)
mean_load_full <- mean(loadings_df$std_loading)
n_above30_tr <- sum(loadings_tr$std_loading >= 0.30)
n_below20_tr <- sum(loadings_tr$std_loading < 0.20)
mean_load_tr <- mean(loadings_tr$std_loading)

comparison <- data.frame(
  Metric = c(
    "Items",
    "Problem pairs (zero cells)",
    "Problem pairs (%)",
    "Eigenvalue ratio (lam1/lam2)",
    "Parallel analysis n-factors",
    "1-factor variance explained (%)",
    "1-factor RMSR",
    "RMSEA [90% CI]",
    "CFI",
    "TLI",
    "SRMR",
    "Loadings >= 0.30 (n)",
    "Loadings >= 0.30 (%)",
    "Loadings < 0.20 (n)",
    "Mean loading"
  ),
  Full_98 = c(
    "98",
    as.character(n_prob),
    sprintf("%.2f", 100 * n_prob / total_pairs),
    sprintf("%.2f", eig_vals[1L] / eig_vals[2L]),
    as.character(pa_nfact),
    sprintf("%.1f", 100 * fa1$Vaccounted[2L, 1L]),
    sprintf("%.4f", fa1$rms),
    sprintf("%.4f [%.4f, %.4f]", fm_full["rmsea"], fm_full["rmsea.ci.lower"], fm_full["rmsea.ci.upper"]),
    sprintf("%.4f", fm_full["cfi"]),
    sprintf("%.4f", fm_full["tli"]),
    sprintf("%.4f", ifelse(is.na(fm_full["srmr"]), NA_real_, fm_full["srmr"])),
    as.character(n_above30_full),
    sprintf("%.1f", 100 * n_above30_full / nrow(loadings_df)),
    as.character(n_below20_full),
    sprintf("%.4f", mean_load_full)
  ),
  Trimmed_84 = c(
    as.character(ncol(author_mat_trimmed)),
    as.character(n_prob_trimmed),
    sprintf("%.2f", 100 * n_prob_trimmed / total_trimmed_pairs),
    sprintf("%.2f", eig_vals_trimmed[1L] / eig_vals_trimmed[2L]),
    as.character(pa_nfact_trimmed),
    sprintf("%.1f", 100 * fa1_trimmed$Vaccounted[2L, 1L]),
    sprintf("%.4f", fa1_trimmed$rms),
    sprintf("%.4f [%.4f, %.4f]", fm_tr["rmsea"], fm_tr["rmsea.ci.lower"], fm_tr["rmsea.ci.upper"]),
    sprintf("%.4f", fm_tr["cfi"]),
    sprintf("%.4f", fm_tr["tli"]),
    sprintf("%.4f", ifelse(is.na(fm_tr["srmr"]), NA_real_, fm_tr["srmr"])),
    as.character(n_above30_tr),
    sprintf("%.1f", 100 * n_above30_tr / nrow(loadings_tr)),
    as.character(n_below20_tr),
    sprintf("%.4f", mean_load_tr)
  ),
  stringsAsFactors = FALSE
)
write.csv(comparison, file.path(OUT_DIR, "table_trimmed_analysis_summary.csv"), row.names = FALSE)

cat("Article package written to:\n  ", OUT_DIR, "\n", sep = "")
