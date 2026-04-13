# Article package export for notebook 07 (person scoring).
# Requires `person_df` and `PROJECT_ROOT` from the notebook (after merge + score columns).

stopifnot(exists("PROJECT_ROOT"), exists("person_df"))

req <- c(
  "hits", "corrected_art_score", "stronger_penalty_score", "theta", "irt06_theta_se",
  "sex", "humanities_or_not", "age", "education_and_profession"
)
miss <- setdiff(req, names(person_df))
if (length(miss)) {
  stop("person_df missing columns: ", paste(miss, collapse = ", "))
}

if (!exists("RESULTS_TAG")) {
  config <- jsonlite::fromJSON(file.path(PROJECT_ROOT, "scripts", "config.json"))
  RESULTS_TAG <- if (config$SAMPLE_VERSION == "full") "" else paste0("_", config$SAMPLE_VERSION)
}
OUT_DIR <- file.path(PROJECT_ROOT, "results",
                     paste0("person_scoring", RESULTS_TAG, "_article_package_2026-04-06"))
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

score_cols <- c("hits", "corrected_art_score", "stronger_penalty_score", "theta")

# ── Tables ────────────────────────────────────────────────────────────────
desc <- psych::describe(person_df[, score_cols])
desc_df <- data.frame(
  score = rownames(desc),
  as.data.frame(desc[, c("n", "mean", "sd", "min", "max", "skew", "kurtosis")]),
  stringsAsFactors = FALSE,
  row.names = NULL
)
write_safe(desc_df, "table_score_type_descriptives.csv")

theta_desc <- psych::describe(person_df$theta)
theta_detail <- data.frame(
  statistic = names(theta_desc),
  value = as.numeric(theta_desc),
  stringsAsFactors = FALSE
)
write_safe(theta_detail, "table_theta_descriptives_detail.csv")

floor_ceiling <- data.frame(score = score_cols, stringsAsFactors = FALSE)
for (sc in score_cols) {
  x <- person_df[[sc]]
  if (sc == "theta") {
    floor_val   <- stats::quantile(x, 0.02, na.rm = TRUE)
    ceiling_val <- stats::quantile(x, 0.98, na.rm = TRUE)
  } else {
    floor_val   <- min(x, na.rm = TRUE)
    ceiling_val <- max(x, na.rm = TRUE)
  }
  n_floor   <- sum(x <= floor_val, na.rm = TRUE)
  n_ceiling <- sum(x >= ceiling_val, na.rm = TRUE)
  n_total   <- sum(!is.na(x))
  floor_ceiling$floor_val[floor_ceiling$score   == sc] <- round(floor_val, 3)
  floor_ceiling$ceiling_val[floor_ceiling$score == sc] <- round(ceiling_val, 3)
  floor_ceiling$n_floor[floor_ceiling$score     == sc] <- n_floor
  floor_ceiling$n_ceiling[floor_ceiling$score   == sc] <- n_ceiling
  floor_ceiling$pct_floor[floor_ceiling$score   == sc] <- round(100 * n_floor / n_total, 1)
  floor_ceiling$pct_ceiling[floor_ceiling$score == sc] <- round(100 * n_ceiling / n_total, 1)
}
write_safe(floor_ceiling, "table_floor_ceiling_analysis.csv")

theta_cut <- stats::quantile(person_df$theta, c(0.05, 0.95), na.rm = TRUE)
person_df$theta_region <- ifelse(
  person_df$theta <= theta_cut[1], "Bottom 5%",
  ifelse(person_df$theta >= theta_cut[2], "Top 5%", "Middle 90%")
)
person_df$theta_region <- factor(
  person_df$theta_region,
  levels = c("Bottom 5%", "Middle 90%", "Top 5%")
)
se_summary <- stats::aggregate(
  irt06_theta_se ~ theta_region,
  data = person_df,
  FUN = function(x) round(mean(x, na.rm = TRUE), 3)
)
names(se_summary)[2] <- "mean_theta_se"
write_safe(se_summary, "table_theta_se_by_region.csv")

# Sex
person_df$sex_clean <- ifelse(person_df$sex %in% c("M", "F"), person_df$sex, NA)
sex_df <- person_df[!is.na(person_df$sex_clean) & !is.na(person_df$theta), ]
sex_agg <- stats::aggregate(theta ~ sex_clean, data = sex_df,
                            FUN = function(x) c(n = length(x), mean = mean(x), sd = stats::sd(x)))
sex_agg <- do.call(data.frame, sex_agg)
names(sex_agg) <- c("sex", "n", "mean_theta", "sd_theta")
t_sex <- stats::t.test(theta ~ sex_clean, data = sex_df)
sex_tbl <- transform(sex_agg, comparison = "sex_M_vs_F")
sex_test <- data.frame(
  comparison = "sex_M_vs_F",
  test = "Welch t-test",
  statistic = unname(t_sex$statistic),
  df = unname(t_sex$parameter),
  p_value = unname(t_sex$p.value),
  stringsAsFactors = FALSE
)
write_safe(sex_tbl, "table_group_comparison_sex_descriptives.csv")
write_safe(sex_test, "table_group_comparison_sex_test.csv")

# Humanities
person_df$hum_clean <- ifelse(
  person_df$humanities_or_not %in% c("+", "-"),
  person_df$humanities_or_not, NA
)
hum_df <- person_df[!is.na(person_df$hum_clean) & !is.na(person_df$theta), ]
hum_df$hum_label <- ifelse(hum_df$hum_clean == "+", "Humanities", "Non-humanities")
hum_df$hum_label <- factor(hum_df$hum_label, levels = c("Non-humanities", "Humanities"))
hum_agg <- stats::aggregate(theta ~ hum_label, data = hum_df,
                          FUN = function(x) c(n = length(x), mean = mean(x), sd = stats::sd(x)))
hum_agg <- do.call(data.frame, hum_agg)
names(hum_agg) <- c("group", "n", "mean_theta", "sd_theta")
t_hum <- stats::t.test(theta ~ hum_label, data = hum_df)
hum_tbl <- transform(hum_agg, comparison = "humanities_vs_non")
hum_test <- data.frame(
  comparison = "humanities_vs_non",
  test = "Welch t-test",
  statistic = unname(t_hum$statistic),
  df = unname(t_hum$parameter),
  p_value = unname(t_hum$p.value),
  stringsAsFactors = FALSE
)
write_safe(hum_tbl, "table_group_comparison_humanities_descriptives.csv")
write_safe(hum_test, "table_group_comparison_humanities_test.csv")

# Age
person_df$age_group <- cut(
  person_df$age,
  breaks = c(-Inf, 25, 35, 50, Inf),
  labels = c("\u226425", "26-35", "36-50", "51+"),
  right = TRUE
)
age_df <- person_df[!is.na(person_df$age_group) & !is.na(person_df$theta), ]
age_agg <- stats::aggregate(theta ~ age_group, data = age_df,
                            FUN = function(x) c(n = length(x), mean = mean(x), sd = stats::sd(x)))
age_agg <- do.call(data.frame, age_agg)
names(age_agg) <- c("age_group", "n", "mean_theta", "sd_theta")
aov_age <- stats::aov(theta ~ age_group, data = age_df)
aov_summary <- summary(aov_age)[[1]]
aov_row <- data.frame(
  comparison = "age_group_ANOVA",
  test = "one-way ANOVA",
  F_value = unname(aov_summary[["F value"]][1]),
  df1 = unname(aov_summary[["Df"]][1]),
  df2 = unname(aov_summary[["Df"]][2]),
  p_value = unname(aov_summary[["Pr(>F)"]][1]),
  stringsAsFactors = FALSE
)
write_safe(age_agg, "table_group_comparison_age_descriptives.csv")
write_safe(aov_row, "table_group_comparison_age_test.csv")

# Profession
valid_profs <- c(
  "Science and Education", "Service Industry", "IT and Engineering",
  "Art and Culture", "Student/School"
)
prof_df <- person_df[
  person_df$education_and_profession %in% valid_profs & !is.na(person_df$theta),
]
prof_df$education_and_profession <- factor(
  prof_df$education_and_profession,
  levels = valid_profs
)
if (nrow(prof_df) >= 2L && length(unique(prof_df$education_and_profession)) >= 2L) {
  prof_agg <- stats::aggregate(theta ~ education_and_profession, data = prof_df,
                               FUN = function(x) c(n = length(x), mean = mean(x), sd = stats::sd(x)))
  prof_agg <- do.call(data.frame, prof_agg)
  names(prof_agg) <- c("profession", "n", "mean_theta", "sd_theta")
  kw_prof <- stats::kruskal.test(theta ~ education_and_profession, data = prof_df)
  prof_test <- data.frame(
    comparison = "profession_categories",
    test = "Kruskal-Wallis",
    statistic = unname(kw_prof$statistic),
    df = unname(kw_prof$parameter),
    p_value = unname(kw_prof$p.value),
    stringsAsFactors = FALSE
  )
  write_safe(prof_agg, "table_group_comparison_profession_descriptives.csv")
  write_safe(prof_test, "table_group_comparison_profession_test.csv")
} else {
  kw_prof <- list(statistic = NA_real_, parameter = NA_real_, p.value = NA_real_)
  message("Skipping profession tables: insufficient data in profession filter.")
}

score_mat <- person_df[, score_cols]
cor_pearson  <- stats::cor(score_mat, method = "pearson",  use = "complete.obs")
cor_spearman <- stats::cor(score_mat, method = "spearman", use = "complete.obs")
cp <- cbind(score = rownames(cor_pearson), as.data.frame(cor_pearson), row.names = NULL)
cs <- cbind(score = rownames(cor_spearman), as.data.frame(cor_spearman), row.names = NULL)
write_safe(cp, "table_correlation_matrix_pearson.csv")
write_safe(cs, "table_correlation_matrix_spearman.csv")

# ── Figures ─────────────────────────────────────────────────────────────────
fig_theta_hist <- ggplot2::ggplot(person_df, ggplot2::aes(x = theta)) +
  ggplot2::geom_histogram(ggplot2::aes(y = ggplot2::after_stat(density)),
                           bins = 40, fill = "steelblue", colour = "white", alpha = 0.7) +
  ggplot2::geom_density(colour = "firebrick", linewidth = 0.9) +
  ggplot2::geom_vline(
    xintercept = mean(person_df$theta, na.rm = TRUE),
    linetype = "dashed", colour = "black"
  ) +
  ggplot2::labs(
    title = "Distribution of 2PL theta estimates",
    subtitle = sprintf(
      "N = %d | mean = %.2f | SD = %.2f | skew = %.2f",
      sum(!is.na(person_df$theta)),
      mean(person_df$theta, na.rm = TRUE),
      stats::sd(person_df$theta, na.rm = TRUE),
      psych::describe(person_df$theta)$skew
    ),
    x = "Theta (2PL EAP)", y = "Density"
  ) +
  ggplot2::theme_bw(base_size = 13)
save_both(fig_theta_hist, "figure_theta_histogram", w = 8, h = 5)

fig_qq <- ggplot2::ggplot(person_df, ggplot2::aes(sample = theta)) +
  ggplot2::stat_qq(colour = "steelblue", alpha = 0.5) +
  ggplot2::stat_qq_line(colour = "firebrick", linewidth = 0.9) +
  ggplot2::labs(
    title = "Normal Q-Q plot of theta",
    x = "Theoretical quantiles",
    y = "Sample quantiles (theta)"
  ) +
  ggplot2::theme_bw(base_size = 13)
save_both(fig_qq, "figure_theta_qq_plot", w = 7, h = 5)

r_pearson  <- stats::cor.test(person_df$theta, person_df$corrected_art_score, method = "pearson")
r_spearman <- stats::cor.test(person_df$theta, person_df$corrected_art_score, method = "spearman")
fig_scatter <- ggplot2::ggplot(person_df, ggplot2::aes(x = corrected_art_score, y = theta)) +
  ggplot2::geom_point(alpha = 0.35, colour = "steelblue", size = 1.5) +
  ggplot2::geom_smooth(method = "loess", colour = "firebrick", linewidth = 0.9, se = TRUE) +
  ggplot2::labs(
    title = "Theta vs. corrected ART score",
    subtitle = sprintf(
      "Pearson r = %.3f | Spearman r = %.3f",
      unname(r_pearson$estimate), unname(r_spearman$estimate)
    ),
    x = "Corrected ART score (hits - false alarms)",
    y = "Theta (2PL EAP)"
  ) +
  ggplot2::theme_bw(base_size = 13)
save_both(fig_scatter, "figure_corrected_art_vs_theta_scatter", w = 8, h = 5.5)

fig_se <- ggplot2::ggplot(person_df, ggplot2::aes(x = theta, y = irt06_theta_se)) +
  ggplot2::geom_point(alpha = 0.3, colour = "steelblue", size = 1.2) +
  ggplot2::geom_smooth(method = "loess", colour = "firebrick", linewidth = 0.9, se = FALSE) +
  ggplot2::labs(
    title = "Theta standard error vs. theta",
    x = "Theta (2PL EAP)",
    y = "Standard error of theta"
  ) +
  ggplot2::theme_bw(base_size = 13)
save_both(fig_se, "figure_theta_vs_se_scatter", w = 8, h = 5.5)

fig_sex <- ggplot2::ggplot(sex_df, ggplot2::aes(x = sex_clean, y = theta, fill = sex_clean)) +
  ggplot2::geom_boxplot(alpha = 0.6, outlier.shape = 16, outlier.size = 1.5) +
  ggplot2::scale_fill_manual(values = c("F" = "#E8A0BF", "M" = "#A0C4E8"), guide = "none") +
  ggplot2::labs(
    title = "Theta by sex",
    subtitle = sprintf("Welch t = %.3f, p = %.4f", t_sex$statistic, t_sex$p.value),
    x = "Sex", y = "Theta (2PL EAP)"
  ) +
  ggplot2::theme_bw(base_size = 13)
save_both(fig_sex, "figure_theta_by_sex_boxplot", w = 6, h = 5)

fig_hum <- ggplot2::ggplot(hum_df, ggplot2::aes(x = hum_label, y = theta, fill = hum_label)) +
  ggplot2::geom_boxplot(alpha = 0.6, outlier.shape = 16, outlier.size = 1.5) +
  ggplot2::scale_fill_manual(
    values = c("Humanities" = "#B5D5A8", "Non-humanities" = "#D5A8B5"),
    guide = "none"
  ) +
  ggplot2::labs(
    title = "Theta by humanities background",
    subtitle = sprintf("Welch t = %.3f, p = %.4f", t_hum$statistic, t_hum$p.value),
    x = "Group", y = "Theta (2PL EAP)"
  ) +
  ggplot2::theme_bw(base_size = 13)
save_both(fig_hum, "figure_theta_by_humanities_boxplot", w = 7, h = 5)

fig_age <- ggplot2::ggplot(age_df, ggplot2::aes(x = age_group, y = theta, fill = age_group)) +
  ggplot2::geom_boxplot(alpha = 0.6, outlier.shape = 16, outlier.size = 1.5) +
  ggplot2::scale_fill_brewer(palette = "Set2", guide = "none") +
  ggplot2::labs(
    title = "Theta by age group",
    subtitle = sprintf(
      "ANOVA: F(%d,%d) = %.2f, p = %.4f",
      aov_summary[["Df"]][1], aov_summary[["Df"]][2],
      aov_summary[["F value"]][1], aov_summary[["Pr(>F)"]][1]
    ),
    x = "Age group", y = "Theta (2PL EAP)"
  ) +
  ggplot2::theme_bw(base_size = 13)
save_both(fig_age, "figure_theta_by_age_group_boxplot", w = 7, h = 5)

if (nrow(prof_df) >= 2L && length(unique(prof_df$education_and_profession)) >= 2L) {
  fig_prof <- ggplot2::ggplot(
    prof_df,
    ggplot2::aes(x = education_and_profession, y = theta, fill = education_and_profession)
  ) +
    ggplot2::geom_boxplot(alpha = 0.6, outlier.shape = 16, outlier.size = 1.5) +
    ggplot2::scale_fill_brewer(palette = "Set2", guide = "none") +
    ggplot2::coord_flip() +
    ggplot2::labs(
      title = "Theta by education / profession category",
      subtitle = sprintf(
        "Kruskal-Wallis: chi-sq = %.2f, df = %d, p = %.4f",
        kw_prof$statistic, kw_prof$parameter, kw_prof$p.value
      ),
      x = NULL, y = "Theta (2PL EAP)"
    ) +
    ggplot2::theme_bw(base_size = 13)
  save_both(fig_prof, "figure_theta_by_profession_boxplot", w = 9, h = 6)
}

cor_long <- reshape2::melt(cor_pearson)
names(cor_long) <- c("Var1", "Var2", "r")
cor_long$label <- sprintf("%.3f", cor_long$r)
fig_cor_p <- ggplot2::ggplot(cor_long, ggplot2::aes(x = Var1, y = Var2, fill = r)) +
  ggplot2::geom_tile(colour = "white") +
  ggplot2::geom_text(ggplot2::aes(label = label), size = 4.5) +
  ggplot2::scale_fill_gradient2(
    low = "#4575B4", mid = "white", high = "#D73027",
    midpoint = 0, limits = c(-1, 1), name = "Pearson r"
  ) +
  ggplot2::labs(title = "Pearson correlation matrix — score types", x = NULL, y = NULL) +
  ggplot2::coord_fixed() +
  ggplot2::theme_bw(base_size = 13)
save_both(fig_cor_p, "figure_correlation_heatmap_pearson", w = 6.5, h = 5.5)

cor_long_sp <- reshape2::melt(cor_spearman)
names(cor_long_sp) <- c("Var1", "Var2", "r")
cor_long_sp$label <- sprintf("%.3f", cor_long_sp$r)
fig_cor_s <- ggplot2::ggplot(cor_long_sp, ggplot2::aes(x = Var1, y = Var2, fill = r)) +
  ggplot2::geom_tile(colour = "white") +
  ggplot2::geom_text(ggplot2::aes(label = label), size = 4.5) +
  ggplot2::scale_fill_gradient2(
    low = "#4575B4", mid = "white", high = "#D73027",
    midpoint = 0, limits = c(-1, 1), name = "Spearman rho"
  ) +
  ggplot2::labs(title = "Spearman correlation matrix — score types", x = NULL, y = NULL) +
  ggplot2::coord_fixed() +
  ggplot2::theme_bw(base_size = 13)
save_both(fig_cor_s, "figure_correlation_heatmap_spearman", w = 6.5, h = 5.5)

score_mat_lab <- person_df[, score_cols]
names(score_mat_lab) <- c("Hits", "Corrected_ART", "Stronger_penalty", "Theta")
if (requireNamespace("GGally", quietly = TRUE)) {
  fig_pairs <- GGally::ggpairs(
    score_mat_lab,
    upper = list(continuous = GGally::wrap("cor", size = 3)),
    lower = list(continuous = GGally::wrap("points", alpha = 0.35, size = 0.8)),
    diag  = list(continuous = GGally::wrap("densityDiag", alpha = 0.6)),
    progress = FALSE
  ) +
    ggplot2::theme_bw(base_size = 9)
  ggplot2::ggsave(
    file.path(OUT_DIR, "figure_score_scatterplot_matrix.png"),
    fig_pairs, width = 10, height = 10, dpi = 300
  )
  ggplot2::ggsave(
    file.path(OUT_DIR, "figure_score_scatterplot_matrix.pdf"),
    fig_pairs, width = 10, height = 10, device = "pdf"
  )
  message("Wrote GGally scatterplot matrix (PNG/PDF)")
} else {
  message("Package GGally not installed — skipping figure_score_scatterplot_matrix")
}

message("Article package complete: ", OUT_DIR)
