# Article package export for notebook 06 (IRT item calibration).
# Run after analysis through person theta (cells through `theta-scores`).

stopifnot(
  exists("PROJECT_ROOT"), exists("author_mat"), exists("author_df"),
  exists("item_key"), exists("mod_1pl"), exists("mod_2pl"), exists("mod_3pl"),
  exists("params_df"), exists("theta_df")
)

OUT_DIR <- file.path(PROJECT_ROOT, "results", "irt_item_calibration_article_package_2026-04-06")
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

write_safe <- function(df, name) {
  path <- file.path(OUT_DIR, name)
  utils::write.csv(df, path, row.names = FALSE)
  message("Wrote ", path)
}

save_both <- function(plot, base, w = 8, h = 5) {
  png <- file.path(OUT_DIR, paste0(base, ".png"))
  pdf <- file.path(OUT_DIR, paste0(base, ".pdf"))
  ggplot2::ggsave(png, plot, width = w, height = h, dpi = 300)
  ggplot2::ggsave(pdf, plot, width = w, height = h, device = "pdf")
  message("Wrote ", png, " / ", pdf)
}

# ── Tables ────────────────────────────────────────────────────────────────
comp_df <- data.frame(
  Model      = c("1PL (Rasch)", "2PL", "3PL"),
  Converged  = c(mod_1pl@OptimInfo$converged,
                  mod_2pl@OptimInfo$converged,
                  mod_3pl@OptimInfo$converged),
  LogLik     = c(mirt::extract.mirt(mod_1pl, "logLik"),
                 mirt::extract.mirt(mod_2pl, "logLik"),
                 mirt::extract.mirt(mod_3pl, "logLik")),
  AIC        = c(mirt::extract.mirt(mod_1pl, "AIC"),
                 mirt::extract.mirt(mod_2pl, "AIC"),
                 mirt::extract.mirt(mod_3pl, "AIC")),
  BIC        = c(mirt::extract.mirt(mod_1pl, "BIC"),
                 mirt::extract.mirt(mod_2pl, "BIC"),
                 mirt::extract.mirt(mod_3pl, "BIC")),
  stringsAsFactors = FALSE
)
write_safe(comp_df, "table_model_comparison_1pl_2pl_3pl.csv")

a12 <- as.data.frame(anova(mod_1pl, mod_2pl))
a23 <- as.data.frame(anova(mod_2pl, mod_3pl))
a12$nested_comparison <- "1PL_vs_2PL"
a23$nested_comparison <- "2PL_vs_3PL"
write_safe(a12, "table_anova_1pl_vs_2pl.csv")
write_safe(a23, "table_anova_2pl_vs_3pl.csv")
if (identical(names(a12), names(a23))) {
  write_safe(rbind(a12, a23), "table_anova_model_comparisons.csv")
} else {
  message("ANOVA tables have differing columns; only separate CSVs written.")
}

params_out <- params_df
write_safe(params_out, "table_2pl_item_parameters.csv")

dec_keep <- c(
  "matrix_item_id", "item_label", "genre", "irt06_2pl_a", "irt06_2pl_b",
  "irt06_keep_drop_review", "irt06_rationale",
  "flag_irt06_low_discrimination", "flag_irt06_high_discrimination",
  "flag_irt06_extreme_difficulty"
)
dec_keep <- intersect(dec_keep, names(item_key))
write_safe(item_key[, dec_keep, drop = FALSE], "table_item_decision_keep_review_drop.csv")

th <- theta_df$irt06_theta
th_se <- theta_df$irt06_theta_se
theta_desc <- data.frame(
  statistic = c(
    "n", "mean_theta", "sd_theta", "min_theta", "q25_theta", "median_theta",
    "q75_theta", "max_theta", "mean_theta_se", "sd_theta_se",
    "min_theta_se", "max_theta_se"
  ),
  value = c(
    nrow(theta_df),
    mean(th, na.rm = TRUE), stats::sd(th, na.rm = TRUE),
    min(th, na.rm = TRUE), stats::quantile(th, 0.25, na.rm = TRUE),
    stats::median(th, na.rm = TRUE), stats::quantile(th, 0.75, na.rm = TRUE),
    max(th, na.rm = TRUE),
    mean(th_se, na.rm = TRUE), stats::sd(th_se, na.rm = TRUE),
    min(th_se, na.rm = TRUE), max(th_se, na.rm = TRUE)
  ),
  stringsAsFactors = FALSE
)
write_safe(theta_desc, "table_theta_descriptives.csv")

# ── Figures ─────────────────────────────────────────────────────────────────
p1 <- ggplot2::ggplot(params_df, ggplot2::aes(x = irt06_2pl_a)) +
  ggplot2::geom_histogram(bins = 20, fill = "steelblue", color = "white") +
  ggplot2::labs(title = "Distribution of 2PL discrimination (a)",
                x = "Discrimination (a)", y = "Count") +
  ggplot2::theme_minimal()
save_both(p1, "figure_discrimination_a_histogram", w = 7, h = 4.5)

p2 <- ggplot2::ggplot(params_df, ggplot2::aes(x = irt06_2pl_b)) +
  ggplot2::geom_histogram(bins = 20, fill = "coral", color = "white") +
  ggplot2::labs(title = "Distribution of 2PL difficulty (b)",
                x = "Difficulty (b)", y = "Count") +
  ggplot2::theme_minimal()
save_both(p2, "figure_difficulty_b_histogram", w = 7, h = 4.5)

sorted_b <- params_df[order(params_df$irt06_2pl_b), ]
sorted_a <- params_df[order(params_df$irt06_2pl_a), ]
easiest_10  <- sorted_b$matrix_item_id[1:10]
hardest_10  <- sorted_b$matrix_item_id[(nrow(sorted_b) - 9):nrow(sorted_b)]
highest_a10 <- sorted_a$matrix_item_id[(nrow(sorted_a) - 9):nrow(sorted_a)]
lowest_a10  <- sorted_a$matrix_item_id[1:10]

theta_grid <- matrix(seq(-4, 4, length.out = 200), ncol = 1)
id_to_label <- stats::setNames(item_key$item_label, item_key$matrix_item_id)

plot_icc_subset <- function(mod, item_ids, title) {
  item_nums <- which(colnames(author_mat) %in% item_ids)
  probs_list <- list()
  for (i in item_nums) {
    item_code <- colnames(author_mat)[i]
    label <- id_to_label[item_code]
    p <- mirt::probtrace(mirt::extract.item(mod, i), theta_grid)[, 2]
    probs_list[[label]] <- p
  }
  plot_df <- data.frame(
    theta = rep(theta_grid[, 1], length(probs_list)),
    prob  = unlist(probs_list),
    item  = rep(names(probs_list), each = nrow(theta_grid)),
    stringsAsFactors = FALSE
  )
  ggplot2::ggplot(plot_df, ggplot2::aes(x = theta, y = prob, color = item)) +
    ggplot2::geom_line(linewidth = 0.6) +
    ggplot2::labs(title = title, x = expression(theta), y = "P(X = 1)") +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "right",
                   legend.text = ggplot2::element_text(size = 7))
}

save_both(
  plot_icc_subset(mod_2pl, easiest_10, "ICCs: 10 easiest items (lowest b)"),
  "figure_icc_easiest_10", w = 9, h = 5.5
)
save_both(
  plot_icc_subset(mod_2pl, hardest_10, "ICCs: 10 hardest items (highest b)"),
  "figure_icc_hardest_10", w = 9, h = 5.5
)
save_both(
  plot_icc_subset(mod_2pl, highest_a10, "ICCs: 10 highest-discrimination items"),
  "figure_icc_highest_a_10", w = 9, h = 5.5
)
save_both(
  plot_icc_subset(mod_2pl, lowest_a10, "ICCs: 10 lowest-discrimination items"),
  "figure_icc_lowest_a_10", w = 9, h = 5.5
)

theta_seq  <- seq(-4, 4, length.out = 200)
info_vals  <- mirt::testinfo(mod_2pl, matrix(theta_seq, ncol = 1))
tif_df <- data.frame(theta = theta_seq, information = as.numeric(info_vals))
peak_theta <- theta_seq[which.max(info_vals)]
peak_info  <- max(info_vals)

p_tif <- ggplot2::ggplot(tif_df, ggplot2::aes(x = theta, y = information)) +
  ggplot2::geom_line(linewidth = 1, color = "steelblue") +
  ggplot2::geom_vline(xintercept = peak_theta, linetype = "dashed", color = "grey40") +
  ggplot2::annotate(
    "text", x = peak_theta + 0.3, y = peak_info * 0.95,
    label = sprintf("Peak at theta = %.2f", peak_theta),
    hjust = 0, size = 3.5
  ) +
  ggplot2::labs(title = "Test information function (2PL)",
                x = expression(theta), y = "Information") +
  ggplot2::theme_minimal()
save_both(p_tif, "figure_test_information_function", w = 8, h = 4.5)

se_vals <- 1 / sqrt(info_vals)
se_df   <- data.frame(theta = theta_seq, se = as.numeric(se_vals))
p_se <- ggplot2::ggplot(se_df, ggplot2::aes(x = theta, y = se)) +
  ggplot2::geom_line(linewidth = 1, color = "coral") +
  ggplot2::geom_hline(
    yintercept = 1 / sqrt(peak_info), linetype = "dashed", color = "grey40"
  ) +
  ggplot2::labs(title = "Conditional standard error (2PL)",
                x = expression(theta), y = "SE(theta)") +
  ggplot2::theme_minimal()
save_both(p_se, "figure_conditional_standard_error", w = 8, h = 4.5)

p_theta <- ggplot2::ggplot(theta_df, ggplot2::aes(x = irt06_theta)) +
  ggplot2::geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  ggplot2::labs(title = "Person ability estimates (EAP theta)",
                x = expression(theta), y = "Count") +
  ggplot2::theme_minimal()
save_both(p_theta, "figure_theta_distribution_histogram", w = 8, h = 4.5)

message("Article package complete: ", OUT_DIR)
