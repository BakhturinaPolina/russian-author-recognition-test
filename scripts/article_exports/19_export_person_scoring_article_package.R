# Article package: person scoring / validity (notebook 07).
# Requires: mirt, psych, ggplot2, dplyr, reshape2; optional GGally for scatter matrix

options(mc.cores = 1L)
Sys.setenv(MC_CORES = "1")

suppressPackageStartupMessages({
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

if (!exists("SAMPLE_VERSION")) {
  config <- jsonlite::fromJSON(file.path(PROJECT_ROOT, "scripts", "config.json"))
  SAMPLE_VERSION <- config$SAMPLE_VERSION
}
if (!exists("RESULTS_TAG")) {
  RESULTS_TAG <- if (SAMPLE_VERSION == "full") "" else paste0("_", SAMPLE_VERSION)
}

OUT_DIR <- file.path(PROJECT_ROOT, "results",
                     paste0("person_scoring", RESULTS_TAG, "_article_package_2026-04-06"))
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

save_dual <- function(plot_obj, base_name, w = 8, h = 6) {
  ggsave(file.path(OUT_DIR, paste0(base_name, ".png")), plot_obj, width = w, height = h, dpi = 300, bg = "white")
  ggsave(file.path(OUT_DIR, paste0(base_name, ".pdf")), plot_obj, width = w, height = h, device = "pdf", bg = "white")
}

if (SAMPLE_VERSION == "full") {
  THETA_DIR <- file.path(PROJECT_ROOT, "data", "stepwise_cleaned_versions", "06_irt_item_calibration")
  DIM_DIR   <- file.path(PROJECT_ROOT, "data", "stepwise_cleaned_versions", "05_dimensionality_inputs")
} else {
  THETA_DIR <- file.path(PROJECT_ROOT, "data",
                         paste0("stepwise_cleaned_versions_", SAMPLE_VERSION),
                         "04_irt_item_calibration")
  DIM_DIR   <- file.path(PROJECT_ROOT, "data",
                         paste0("stepwise_cleaned_versions_", SAMPLE_VERSION),
                         "03_dimensionality_inputs")
}

theta_df <- read.csv(
  file.path(THETA_DIR,
            "ART_pretest_(for Castano)_EN__irt_theta_scores.csv"),
  stringsAsFactors = FALSE
)
summary_df <- read.csv(
  file.path(DIM_DIR,
            "ART_pretest_(for Castano)_EN__dimensionality_input__participant_summary.csv"),
  stringsAsFactors = FALSE
)
demo_df <- read.csv(
  file.path(DIM_DIR,
            "ART_pretest_(for Castano)_EN__dimensionality_input__participant_demographics.csv"),
  stringsAsFactors = FALSE
)

person_df <- merge(theta_df, summary_df, by = "participant_id", all = TRUE)
person_df <- merge(person_df, demo_df, by = "participant_id", all = TRUE)

N_AUTHORS <- 98L
N_FOILS <- 104L
FOIL_PENALTY_MULTIPLIER <- N_FOILS / N_AUTHORS

person_df$hits <- person_df$author_hits
person_df$corrected_art_score <- person_df$hits - person_df$false_alarms
person_df$stronger_penalty_score <- person_df$hits - FOIL_PENALTY_MULTIPLIER * person_df$false_alarms
person_df$theta <- person_df$irt06_theta

score_cols <- c("hits", "corrected_art_score", "stronger_penalty_score", "theta")
desc <- psych::describe(person_df[, score_cols])
desc_out <- round(desc[, c("n", "mean", "sd", "min", "max", "skew", "kurtosis")], 4)
desc_out$score_type <- rownames(desc_out)
write.csv(desc_out, file.path(OUT_DIR, "table_score_type_descriptives.csv"), row.names = FALSE)

theta_detail <- as.data.frame(psych::describe(person_df$theta))
write.csv(theta_detail, file.path(OUT_DIR, "table_theta_descriptives_detail.csv"), row.names = TRUE)

# Histogram + density
p_hist <- ggplot(person_df, aes(x = theta)) +
  geom_histogram(aes(y = after_stat(density)), bins = 40L, fill = "steelblue", colour = "white", alpha = 0.7) +
  geom_density(colour = "firebrick", linewidth = 0.9) +
  geom_vline(xintercept = mean(person_df$theta, na.rm = TRUE), linetype = "dashed", colour = "black") +
  labs(
    title = "Distribution of 2PL theta estimates",
    subtitle = sprintf(
      "N = %d | mean = %.2f | SD = %.2f | skew = %.2f",
      sum(!is.na(person_df$theta)),
      mean(person_df$theta, na.rm = TRUE),
      sd(person_df$theta, na.rm = TRUE),
      psych::describe(person_df$theta)$skew
    ),
    x = "Theta (2PL EAP)", y = "Density"
  ) +
  theme_bw(base_size = 13)
save_dual(p_hist, "figure_theta_histogram", 8, 6)

p_qq <- ggplot(person_df, aes(sample = theta)) +
  stat_qq(colour = "steelblue", alpha = 0.5) +
  stat_qq_line(colour = "firebrick", linewidth = 0.9) +
  labs(title = "Normal Q-Q plot of theta", x = "Theoretical quantiles", y = "Sample quantiles") +
  theme_bw(base_size = 13)
save_dual(p_qq, "figure_theta_qq_plot", 8, 6)

r_pearson <- cor.test(person_df$theta, person_df$corrected_art_score, method = "pearson")
r_spearman <- cor.test(person_df$theta, person_df$corrected_art_score, method = "spearman")

p_scatter_art <- ggplot(person_df, aes(x = corrected_art_score, y = theta)) +
  geom_point(alpha = 0.35, colour = "steelblue", size = 1.5) +
  geom_smooth(method = "loess", colour = "firebrick", linewidth = 0.9, se = TRUE) +
  labs(
    title = "Theta vs. corrected ART score",
    subtitle = sprintf("Pearson r = %.3f | Spearman r = %.3f", unname(r_pearson$estimate), unname(r_spearman$estimate)),
    x = "Corrected ART score (hits - false alarms)", y = "Theta (2PL EAP)"
  ) +
  theme_bw(base_size = 13)
save_dual(p_scatter_art, "figure_corrected_art_vs_theta_scatter", 8, 6)

# Floor / ceiling
floor_ceiling <- data.frame(score = score_cols, stringsAsFactors = FALSE)
for (sc in score_cols) {
  x <- person_df[[sc]]
  if (sc == "theta") {
    floor_val <- quantile(x, 0.02, na.rm = TRUE)
    ceiling_val <- quantile(x, 0.98, na.rm = TRUE)
  } else {
    floor_val <- min(x, na.rm = TRUE)
    ceiling_val <- max(x, na.rm = TRUE)
  }
  n_floor <- sum(x <= floor_val, na.rm = TRUE)
  n_ceiling <- sum(x >= ceiling_val, na.rm = TRUE)
  n_total <- sum(!is.na(x))
  floor_ceiling$floor_val[floor_ceiling$score == sc] <- round(floor_val, 3)
  floor_ceiling$ceiling_val[floor_ceiling$score == sc] <- round(ceiling_val, 3)
  floor_ceiling$n_floor[floor_ceiling$score == sc] <- n_floor
  floor_ceiling$n_ceiling[floor_ceiling$score == sc] <- n_ceiling
  floor_ceiling$pct_floor[floor_ceiling$score == sc] <- round(100 * n_floor / n_total, 1)
  floor_ceiling$pct_ceiling[floor_ceiling$score == sc] <- round(100 * n_ceiling / n_total, 1)
}
write.csv(floor_ceiling, file.path(OUT_DIR, "table_floor_ceiling_analysis.csv"), row.names = FALSE)

theta_cut <- quantile(person_df$theta, c(0.05, 0.95), na.rm = TRUE)
person_df$theta_region <- ifelse(
  person_df$theta <= theta_cut[1L], "Bottom 5%",
  ifelse(person_df$theta >= theta_cut[2L], "Top 5%", "Middle 90%")
)
person_df$theta_region <- factor(person_df$theta_region, levels = c("Bottom 5%", "Middle 90%", "Top 5%"))
se_summary <- aggregate(irt06_theta_se ~ theta_region, data = person_df,
                        FUN = function(z) round(mean(z, na.rm = TRUE), 3))
write.csv(se_summary, file.path(OUT_DIR, "table_theta_se_by_region.csv"), row.names = FALSE)

p_se <- ggplot(person_df, aes(x = theta, y = irt06_theta_se)) +
  geom_point(alpha = 0.3, colour = "steelblue", size = 1.2) +
  geom_smooth(method = "loess", colour = "firebrick", linewidth = 0.9, se = FALSE) +
  labs(
    title = "Theta standard error vs. theta",
    x = "Theta (2PL EAP)", y = "Standard error of theta"
  ) +
  theme_bw(base_size = 13)
save_dual(p_se, "figure_theta_vs_se_scatter", 8, 6)

# Sex
person_df$sex_clean <- ifelse(person_df$sex %in% c("M", "F"), person_df$sex, NA)
sex_df <- person_df[!is.na(person_df$sex_clean) & !is.na(person_df$theta), ]
sex_agg <- aggregate(theta ~ sex_clean, data = sex_df,
                     FUN = function(x) c(n = length(x), mean = mean(x), sd = sd(x)))
sex_agg <- do.call(data.frame, sex_agg)
names(sex_agg) <- c("sex", "n", "mean_theta", "sd_theta")
t_sex <- t.test(theta ~ sex_clean, data = sex_df)
sex_out <- cbind(sex_agg, data.frame(
  t_statistic = unname(t_sex$statistic),
  df = unname(t_sex$parameter),
  p_value = unname(t_sex$p.value),
  stringsAsFactors = FALSE
))
write.csv(sex_out, file.path(OUT_DIR, "table_group_comparison_sex.csv"), row.names = FALSE)

p_sex <- ggplot(sex_df, aes(x = sex_clean, y = theta, fill = sex_clean)) +
  geom_boxplot(alpha = 0.6, outlier.shape = 16, outlier.size = 1.5) +
  scale_fill_manual(values = c("F" = "#E8A0BF", "M" = "#A0C4E8"), guide = "none") +
  labs(
    title = "Theta by sex",
    subtitle = sprintf("Welch t = %.3f, p = %.4f", unname(t_sex$statistic), t_sex$p.value),
    x = "Sex", y = "Theta (2PL EAP)"
  ) +
  theme_bw(base_size = 13)
save_dual(p_sex, "figure_theta_by_sex_boxplot", 8, 6)

# Humanities
person_df$hum_clean <- ifelse(person_df$humanities_or_not %in% c("+", "-"), person_df$humanities_or_not, NA)
hum_df <- person_df[!is.na(person_df$hum_clean) & !is.na(person_df$theta), ]
hum_df$hum_label <- ifelse(hum_df$hum_clean == "+", "Humanities", "Non-humanities")
hum_df$hum_label <- factor(hum_df$hum_label, levels = c("Non-humanities", "Humanities"))
hum_agg <- aggregate(theta ~ hum_label, data = hum_df,
                     FUN = function(x) c(n = length(x), mean = mean(x), sd = sd(x)))
hum_agg <- do.call(data.frame, hum_agg)
names(hum_agg) <- c("group", "n", "mean_theta", "sd_theta")
t_hum <- t.test(theta ~ hum_label, data = hum_df)
hum_out <- cbind(hum_agg, data.frame(
  t_statistic = unname(t_hum$statistic),
  df = unname(t_hum$parameter),
  p_value = unname(t_hum$p.value),
  stringsAsFactors = FALSE
))
write.csv(hum_out, file.path(OUT_DIR, "table_group_comparison_humanities.csv"), row.names = FALSE)

p_hum <- ggplot(hum_df, aes(x = hum_label, y = theta, fill = hum_label)) +
  geom_boxplot(alpha = 0.6, outlier.shape = 16, outlier.size = 1.5) +
  scale_fill_manual(values = c("Humanities" = "#B5D5A8", "Non-humanities" = "#D5A8B5"), guide = "none") +
  labs(
    title = "Theta by humanities background",
    subtitle = sprintf("Welch t = %.3f, p = %.4f", unname(t_hum$statistic), t_hum$p.value),
    x = "Group", y = "Theta (2PL EAP)"
  ) +
  theme_bw(base_size = 13)
save_dual(p_hum, "figure_theta_by_humanities_boxplot", 8, 6)

# Age
person_df$age_group <- cut(
  person_df$age,
  breaks = c(-Inf, 25, 35, 50, Inf),
  labels = c("\u226425", "26-35", "36-50", "51+"),
  right = TRUE
)
age_df <- person_df[!is.na(person_df$age_group) & !is.na(person_df$theta), ]
age_agg <- aggregate(theta ~ age_group, data = age_df,
                     FUN = function(x) c(n = length(x), mean = mean(x), sd = sd(x)))
age_agg <- do.call(data.frame, age_agg)
names(age_agg) <- c("age_group", "n", "mean_theta", "sd_theta")
aov_age <- aov(theta ~ age_group, data = age_df)
aov_summary <- summary(aov_age)[[1]]
age_out <- cbind(age_agg, data.frame(
  F_value = aov_summary[["F value"]][1L],
  df_group = aov_summary[["Df"]][1L],
  df_resid = aov_summary[["Df"]][2L],
  p_value = aov_summary[["Pr(>F)"]][1L],
  stringsAsFactors = FALSE
))
write.csv(age_out, file.path(OUT_DIR, "table_group_comparison_age.csv"), row.names = FALSE)

p_age <- ggplot(age_df, aes(x = age_group, y = theta, fill = age_group)) +
  geom_boxplot(alpha = 0.6, outlier.shape = 16, outlier.size = 1.5) +
  scale_fill_brewer(palette = "Set2", guide = "none") +
  labs(
    title = "Theta by age group",
    subtitle = sprintf(
      "ANOVA: F(%d,%d) = %.2f, p = %.4f",
      as.integer(aov_summary[["Df"]][1L]), as.integer(aov_summary[["Df"]][2L]),
      aov_summary[["F value"]][1L], aov_summary[["Pr(>F)"]][1L]
    ),
    x = "Age group", y = "Theta (2PL EAP)"
  ) +
  theme_bw(base_size = 13)
save_dual(p_age, "figure_theta_by_age_group_boxplot", 8, 6)

# Profession
valid_profs <- c("Science and Education", "Service Industry", "IT and Engineering",
                 "Art and Culture", "Student/School")
prof_df <- person_df[person_df$education_and_profession %in% valid_profs & !is.na(person_df$theta), ]
prof_df$education_and_profession <- factor(prof_df$education_and_profession, levels = valid_profs)
prof_agg <- aggregate(theta ~ education_and_profession, data = prof_df,
                      FUN = function(x) c(n = length(x), mean = mean(x), sd = sd(x)))
prof_agg <- do.call(data.frame, prof_agg)
names(prof_agg) <- c("profession", "n", "mean_theta", "sd_theta")
kw_prof <- kruskal.test(theta ~ education_and_profession, data = prof_df)
prof_out <- cbind(prof_agg, data.frame(
  kw_chisq = unname(kw_prof$statistic),
  kw_df = unname(kw_prof$parameter),
  p_value = unname(kw_prof$p.value),
  stringsAsFactors = FALSE
))
write.csv(prof_out, file.path(OUT_DIR, "table_group_comparison_profession.csv"), row.names = FALSE)

p_prof <- ggplot(prof_df, aes(x = education_and_profession, y = theta, fill = education_and_profession)) +
  geom_boxplot(alpha = 0.6, outlier.shape = 16, outlier.size = 1.5) +
  scale_fill_brewer(palette = "Set2", guide = "none") +
  coord_flip() +
  labs(
    title = "Theta by education / profession category",
    subtitle = sprintf("Kruskal-Wallis: chi2 = %.2f, df = %d, p = %.4f",
                       unname(kw_prof$statistic), as.integer(kw_prof$parameter), kw_prof$p.value),
    x = NULL, y = "Theta (2PL EAP)"
  ) +
  theme_bw(base_size = 13)
save_dual(p_prof, "figure_theta_by_profession_boxplot", 9, 6)

# Correlations
score_mat <- person_df[, score_cols]
names(score_mat) <- c("Hits", "Corrected_ART", "Stronger_penalty", "Theta")
cor_pearson <- cor(score_mat, method = "pearson", use = "complete.obs")
cor_spearman <- cor(score_mat, method = "spearman", use = "complete.obs")
cp <- as.data.frame(cor_pearson)
cp <- cbind(variable = rownames(cp), cp)
write.csv(cp, file.path(OUT_DIR, "table_correlation_matrix_pearson.csv"), row.names = FALSE)
cs <- as.data.frame(cor_spearman)
cs <- cbind(variable = rownames(cs), cs)
write.csv(cs, file.path(OUT_DIR, "table_correlation_matrix_spearman.csv"), row.names = FALSE)

cor_long <- reshape2::melt(cor_pearson)
names(cor_long) <- c("Var1", "Var2", "r")
cor_long$label <- sprintf("%.3f", cor_long$r)

p_corp <- ggplot(cor_long, aes(x = Var1, y = Var2, fill = r)) +
  geom_tile(colour = "white") +
  geom_text(aes(label = label), size = 4.5) +
  scale_fill_gradient2(low = "#4575B4", mid = "white", high = "#D73027", midpoint = 0, limits = c(-1, 1), name = "Pearson r") +
  labs(title = "Pearson correlation matrix - score types", x = NULL, y = NULL) +
  coord_fixed() +
  theme_bw(base_size = 13)
save_dual(p_corp, "figure_correlation_heatmap_pearson", 7, 6)

cor_long_sp <- reshape2::melt(cor_spearman)
names(cor_long_sp) <- c("Var1", "Var2", "r")
cor_long_sp$label <- sprintf("%.3f", cor_long_sp$r)

p_cors <- ggplot(cor_long_sp, aes(x = Var1, y = Var2, fill = r)) +
  geom_tile(colour = "white") +
  geom_text(aes(label = label), size = 4.5) +
  scale_fill_gradient2(low = "#4575B4", mid = "white", high = "#D73027", midpoint = 0, limits = c(-1, 1), name = "Spearman rho") +
  labs(title = "Spearman correlation matrix - score types", x = NULL, y = NULL) +
  coord_fixed() +
  theme_bw(base_size = 13)
save_dual(p_cors, "figure_correlation_heatmap_spearman", 7, 6)

# Scatter matrix (GGally if available)
sm_df <- person_df[, c("hits", "corrected_art_score", "stronger_penalty_score", "theta")]
names(sm_df) <- c("Hits", "Corrected_ART", "Stronger_penalty", "Theta")
if (requireNamespace("GGally", quietly = TRUE)) {
  p_pairs <- GGally::ggpairs(
    sm_df,
    lower = list(continuous = GGally::wrap("points", alpha = 0.25, size = 0.6)),
    diag = list(continuous = GGally::wrap("densityDiag", alpha = 0.6)),
    upper = list(continuous = GGally::wrap("cor", size = 3))
  ) +
    theme_bw(base_size = 9)
  save_dual(p_pairs, "figure_score_scatterplot_matrix", 10, 10)
} else {
  message("GGally not installed — skipping figure_score_scatterplot_matrix; install.packages('GGally') to enable.")
}

cat("Article package written to:\n  ", OUT_DIR, "\n", sep = "")
