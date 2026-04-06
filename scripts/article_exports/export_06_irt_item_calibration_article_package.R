# Article package: IRT item calibration (notebook 06).
# Requires: mirt, psych, ggplot2, reshape2
# Usage:
#   PROJECT_ROOT <- normalizePath("."); source("scripts/article_exports/export_06_irt_item_calibration_article_package.R")

options(mc.cores = 1L)
Sys.setenv(MC_CORES = "1")

suppressPackageStartupMessages({
  library(mirt)
  library(psych)
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

OUT_DIR <- file.path(PROJECT_ROOT, "results", "irt_item_calibration_article_package_2026-04-06")
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

DATA_DIR <- file.path(PROJECT_ROOT, "data", "stepwise_cleaned_versions", "05_dimensionality_inputs")

author_df <- read.csv(
  file.path(DATA_DIR, "ART_pretest_(for Castano)_EN__dimensionality_input__author_response_matrix.csv"),
  stringsAsFactors = FALSE
)
item_key <- read.csv(
  file.path(DATA_DIR, "ART_pretest_(for Castano)_EN__dimensionality_input__author_item_key.csv"),
  stringsAsFactors = FALSE
)

author_mat <- as.matrix(author_df[, -which(names(author_df) == "participant_id")])

save_dual <- function(plot_obj, base_name) {
  ggsave(file.path(OUT_DIR, paste0(base_name, ".png")), plot_obj, dpi = 300, bg = "white")
  ggsave(file.path(OUT_DIR, paste0(base_name, ".pdf")), plot_obj, device = "pdf", bg = "white")
}

cat("Fitting 1PL...\n")
mod_1pl <- mirt(author_mat, model = 1L, itemtype = "Rasch", SE = TRUE, verbose = FALSE)
cat("Fitting 2PL...\n")
mod_2pl <- mirt(author_mat, model = 1L, itemtype = "2PL", SE = TRUE, verbose = FALSE)
cat("Fitting 3PL...\n")
mod_3pl <- mirt(author_mat, model = 1L, itemtype = "3PL", SE = TRUE, verbose = FALSE)

comp_df <- data.frame(
  Model = c("1PL (Rasch)", "2PL", "3PL"),
  Converged = c(mod_1pl@OptimInfo$converged, mod_2pl@OptimInfo$converged, mod_3pl@OptimInfo$converged),
  LogLik = c(extract.mirt(mod_1pl, "logLik"), extract.mirt(mod_2pl, "logLik"), extract.mirt(mod_3pl, "logLik")),
  AIC = c(extract.mirt(mod_1pl, "AIC"), extract.mirt(mod_2pl, "AIC"), extract.mirt(mod_3pl, "AIC")),
  BIC = c(extract.mirt(mod_1pl, "BIC"), extract.mirt(mod_2pl, "BIC"), extract.mirt(mod_3pl, "BIC")),
  stringsAsFactors = FALSE
)
write.csv(comp_df, file.path(OUT_DIR, "table_model_comparison_1pl_2pl_3pl.csv"), row.names = FALSE)

anova_to_df <- function(av) {
  m <- as.matrix(av)
  data.frame(
    rowname = rownames(m),
    as.data.frame(m, stringsAsFactors = FALSE),
    stringsAsFactors = FALSE
  )
}

av12 <- tryCatch(anova_to_df(anova(mod_1pl, mod_2pl)), error = function(e) NULL)
av23 <- tryCatch(anova_to_df(anova(mod_2pl, mod_3pl)), error = function(e) NULL)
if (!is.null(av12)) av12$comparison <- "1PL_vs_2PL"
if (!is.null(av23)) av23$comparison <- "2PL_vs_3PL"
parts <- list(av12, av23)
parts <- parts[!vapply(parts, is.null, logical(1))]
anova_out <- if (length(parts)) do.call(rbind, parts) else data.frame(note = "anova_export_failed", stringsAsFactors = FALSE)
write.csv(anova_out, file.path(OUT_DIR, "table_anova_model_comparisons.csv"), row.names = FALSE)

params_2pl <- coef(mod_2pl, IRTpars = TRUE, simplify = TRUE)$items
params_df <- as.data.frame(params_2pl)
params_df$matrix_item_id <- rownames(params_df)
if ("a" %in% names(params_df)) {
  names(params_df)[names(params_df) == "a"] <- "irt06_2pl_a"
}
if ("a1" %in% names(params_df) && !"irt06_2pl_a" %in% names(params_df)) {
  names(params_df)[names(params_df) == "a1"] <- "irt06_2pl_a"
}
if ("b" %in% names(params_df)) {
  names(params_df)[names(params_df) == "b"] <- "irt06_2pl_b"
}
params_df$g <- NULL
params_df$u <- NULL

id_to_label <- setNames(item_key$item_label, item_key$matrix_item_id)
params_df$item_label <- id_to_label[params_df$matrix_item_id]
write.csv(params_df, file.path(OUT_DIR, "table_2pl_item_parameters.csv"), row.names = FALSE)

p1 <- ggplot(params_df, aes(x = irt06_2pl_a)) +
  geom_histogram(bins = 20L, fill = "steelblue", color = "white") +
  labs(title = "Distribution of 2PL discrimination (a)", x = "a", y = "Count") +
  theme_minimal()
p2 <- ggplot(params_df, aes(x = irt06_2pl_b)) +
  geom_histogram(bins = 20L, fill = "coral", color = "white") +
  labs(title = "Distribution of 2PL difficulty (b)", x = "b", y = "Count") +
  theme_minimal()
save_dual(p1, "figure_discrimination_a_histogram")
save_dual(p2, "figure_difficulty_b_histogram")

is_trueish <- function(x) {
  if (is.logical(x)) return(x)
  toupper(trimws(as.character(x))) %in% c("TRUE", "T", "1", "YES")
}

prev_irt_cols <- grep("^irt06_|^flag_irt06_", names(item_key), value = TRUE)
if (length(prev_irt_cols) > 0L) {
  item_key <- item_key[, !(names(item_key) %in% prev_irt_cols), drop = FALSE]
}

item_key <- merge(
  item_key,
  params_df[, c("matrix_item_id", "irt06_2pl_a", "irt06_2pl_b")],
  by = "matrix_item_id", all.x = TRUE
)

item_key$flag_irt06_low_discrimination <- item_key$irt06_2pl_a < 0.5
item_key$flag_irt06_high_discrimination <- item_key$irt06_2pl_a > 2.5
item_key$flag_irt06_extreme_difficulty <- abs(item_key$irt06_2pl_b) > 3.0

neg_citc <- is_trueish(item_key$flag_citc_negative)
cfa_low <- if ("flag_dim05_cfa_loading_below_020" %in% names(item_key)) {
  item_key$flag_dim05_cfa_loading_below_020 %in% TRUE
} else {
  rep(FALSE, nrow(item_key))
}
end_ext <- if ("flag_endorsement_extreme_..05_or_..95" %in% names(item_key)) {
  is_trueish(item_key$flag_endorsement_extreme_..05_or_..95)
} else {
  rep(FALSE, nrow(item_key))
}

item_key$irt06_keep_drop_review <- ifelse(
  item_key$flag_irt06_low_discrimination | neg_citc,
  "drop",
  ifelse(
    item_key$flag_irt06_extreme_difficulty | cfa_low | end_ext,
    "review",
    "keep"
  )
)

item_key$irt06_rationale <- ifelse(
  item_key$irt06_keep_drop_review == "drop",
  ifelse(item_key$flag_irt06_low_discrimination, "low discrimination (a < 0.5)", "negative corrected item-total correlation"),
  ifelse(
    item_key$irt06_keep_drop_review == "review",
    trimws(gsub(
      ";\\s*$", "",
      paste0(
        ifelse(item_key$flag_irt06_extreme_difficulty, "extreme difficulty; ", ""),
        ifelse(cfa_low, "CFA loading < .20; ", ""),
        ifelse(end_ext, "extreme endorsement rate; ", "")
      )
    )),
    ""
  )
)

decision_tbl <- item_key[, intersect(
  c(
    "matrix_item_id", "item_label", "genre", "selection_rate_pct", "corrected_item_total_corr",
    "dim05_cfa_loading_full", "irt06_2pl_a", "irt06_2pl_b", "irt06_keep_drop_review", "irt06_rationale"
  ),
  names(item_key)
)]
decision_tbl <- decision_tbl[order(decision_tbl$irt06_keep_drop_review, -decision_tbl$irt06_2pl_a), ]
write.csv(decision_tbl, file.path(OUT_DIR, "table_item_decision_keep_review_drop.csv"), row.names = FALSE)

sorted_b <- params_df[order(params_df$irt06_2pl_b), ]
sorted_a <- params_df[order(params_df$irt06_2pl_a), ]
easiest_10 <- sorted_b$matrix_item_id[seq_len(10L)]
hardest_10 <- sorted_b$matrix_item_id[seq(nrow(sorted_b) - 9L, nrow(sorted_b))]
highest_a10 <- sorted_a$matrix_item_id[seq(nrow(sorted_a) - 9L, nrow(sorted_a))]
lowest_a10 <- sorted_a$matrix_item_id[seq_len(10L)]

theta_grid <- matrix(seq(-4, 4, length.out = 200L), ncol = 1L)

plot_icc_subset <- function(mod, item_ids, title) {
  item_nums <- which(colnames(author_mat) %in% item_ids)
  probs_list <- list()
  for (i in item_nums) {
    item_code <- colnames(author_mat)[i]
    label <- id_to_label[item_code]
    p <- probtrace(extract.item(mod, i), theta_grid)[, 2L]
    probs_list[[label]] <- p
  }
  plot_df <- data.frame(
    theta = rep(theta_grid[, 1L], length(probs_list)),
    prob = unlist(probs_list),
    item = rep(names(probs_list), each = nrow(theta_grid)),
    stringsAsFactors = FALSE
  )
  ggplot(plot_df, aes(x = theta, y = prob, color = item)) +
    geom_line(linewidth = 0.6) +
    labs(title = title, x = expression(theta), y = "P(X = 1)") +
    theme_minimal() +
    theme(legend.position = "right", legend.text = element_text(size = 7))
}

save_dual(plot_icc_subset(mod_2pl, easiest_10, "ICCs: 10 easiest items (lowest b)"), "figure_icc_easiest_10")
save_dual(plot_icc_subset(mod_2pl, hardest_10, "ICCs: 10 hardest items (highest b)"), "figure_icc_hardest_10")
save_dual(plot_icc_subset(mod_2pl, highest_a10, "ICCs: 10 highest-discrimination items"), "figure_icc_highest_a_10")
save_dual(plot_icc_subset(mod_2pl, lowest_a10, "ICCs: 10 lowest-discrimination items"), "figure_icc_lowest_a_10")

theta_seq <- seq(-4, 4, length.out = 200L)
info_vals <- testinfo(mod_2pl, matrix(theta_seq, ncol = 1L))
tif_df <- data.frame(theta = theta_seq, information = as.numeric(info_vals))
peak_theta <- theta_seq[which.max(info_vals)]
peak_info <- max(info_vals)

p_tif <- ggplot(tif_df, aes(x = theta, y = information)) +
  geom_line(linewidth = 1, color = "steelblue") +
  geom_vline(xintercept = peak_theta, linetype = "dashed", color = "grey40") +
  annotate("text", x = peak_theta + 0.3, y = peak_info * 0.95,
           label = sprintf("Peak at theta = %.2f", peak_theta), hjust = 0, size = 3.5) +
  labs(title = "Test information function (2PL)", x = expression(theta), y = "Information") +
  theme_minimal()
save_dual(p_tif, "figure_test_information_function")

se_vals <- 1 / sqrt(info_vals)
se_df <- data.frame(theta = theta_seq, se = as.numeric(se_vals))
p_se <- ggplot(se_df, aes(x = theta, y = se)) +
  geom_line(linewidth = 1, color = "coral") +
  geom_hline(yintercept = 1 / sqrt(peak_info), linetype = "dashed", color = "grey40") +
  labs(title = "Conditional standard error (2PL)", x = expression(theta), y = "SE(theta)") +
  theme_minimal()
save_dual(p_se, "figure_conditional_standard_error")

theta_mat <- fscores(mod_2pl, method = "EAP", full.scores.SE = TRUE)
theta_df <- data.frame(
  participant_id = author_df$participant_id,
  irt06_theta = theta_mat[, 1L],
  irt06_theta_se = theta_mat[, 2L],
  stringsAsFactors = FALSE
)

theta_desc <- psych::describe(theta_df$irt06_theta)
theta_desc_row <- data.frame(
  n = theta_desc$n,
  mean = theta_desc$mean,
  sd = theta_desc$sd,
  min = theta_desc$min,
  max = theta_desc$max,
  skew = theta_desc$skew,
  kurtosis = theta_desc$kurtosis,
  se = theta_desc$se
)
write.csv(theta_desc_row, file.path(OUT_DIR, "table_theta_descriptives.csv"), row.names = FALSE)

p_theta <- ggplot(theta_df, aes(x = irt06_theta)) +
  geom_histogram(bins = 30L, fill = "steelblue", color = "white") +
  labs(title = "Distribution of EAP theta (2PL)", x = expression(theta), y = "Count") +
  theme_minimal()
save_dual(p_theta, "figure_theta_distribution_histogram")

cat("Article package written to:\n  ", OUT_DIR, "\n", sep = "")
