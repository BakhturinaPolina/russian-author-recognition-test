## Demographic Differences in Theta (Publishing-Ready Report)

### How to read these results (plain-language guide)

`Theta` is a standardized score of print exposure (roughly centered around 0).  
- Positive theta = above-average print exposure in this sample.  
- Negative theta = below-average print exposure in this sample.  
- A **p-value** tells you whether the observed group difference is likely to reflect a real pattern rather than random fluctuation.  
- An **effect size** tells you how large that difference is in practical terms (small/moderate/large), which is often more important for interpretation than p-value alone.

---

### Table 1. Omnibus tests by demographic variable

| Variable | Test | Statistic | p-value | Effect size | Interpretation of magnitude |
|---|---|---:|---:|---:|---|
| Sex | Welch t-test | t(540.1) = 2.623 | .009 | Hedges g = 0.194 | Negligible/small |
| Humanities background | Welch t-test | t(383.9) = -8.998 | < .001 | Hedges g = 0.690 | Medium |
| Age group | One-way ANOVA | F(3, 904) = 20.47 | < .001 | eta² = 0.064; omega² = 0.060 | Small-to-moderate overall |
| Profession/education | Kruskal-Wallis | chi²(4) = 82.186 | < .001 | epsilon² = 0.101 | Non-trivial overall |

**How to read Table 1:** all four demographic variables show statistically reliable differences in theta, but their practical strength differs. The most meaningful effects are for humanities background and profession/education, while sex is much smaller.

---

## 1) Sex

### Table 2. Theta by sex

| Sex | n | Mean theta | SD |
|---|---:|---:|---:|
| F | 597 | 0.064 | 0.916 |
| M | 311 | -0.126 | 1.094 |

**How to read Table 2:** the female mean is above the male mean, but the overlap in standard deviations is large, which is consistent with a small effect size.

Women scored higher than men by about **0.19 theta units** (0.064 - (-0.126) = 0.190).  
This difference is statistically reliable (**p = .009**), but the effect size is **very small** (**g = 0.194**).  

**Interpretation for linguistics readers:** a sex-related difference is detectable in this sample, but its practical size is modest compared with other demographic contrasts below.

---

## 2) Humanities vs non-humanities background

### Table 3. Theta by humanities background

| Group | n | Mean theta | SD |
|---|---:|---:|---:|
| Non-humanities | 599 | -0.132 | 0.956 |
| Humanities | 201 | 0.511 | 0.848 |

**How to read Table 3:** the mean gap is large relative to within-group variability, which is why this contrast is not only significant but also practically meaningful.

Participants with a humanities background scored higher by about **0.64 theta units** (0.511 - (-0.132) = 0.643).  
The difference is highly reliable (**p < .001**) and **moderate in size** (**g = 0.690**).

**Important note:** the negative t-value here reflects model coding/order of groups, not the substantive direction. The group means clearly show humanities > non-humanities.

**Interpretation:** this is one of the strongest effects in the dataset and is theoretically coherent for an author-recognition / print-exposure construct.

---

## 3) Age

### Table 4. Theta by age group

| Age group | n | Mean theta | SD |
|---|---:|---:|---:|
| <=25 | 365 | -0.294 | 0.912 |
| 26-35 | 372 | 0.146 | 1.031 |
| 36-50 | 143 | 0.292 | 0.847 |
| 51+ | 28 | 0.388 | 0.932 |

**How to read Table 4:** mean theta rises stepwise across age bands, with the clearest separation between the youngest group (`<=25`) and everyone older.

There is a clear overall age effect (**F(3,904)=20.47, p<.001**), with small-to-moderate explained variance (**eta²=.064; omega²=.060**).

### Table 5. Tukey post-hoc results (adjusted)

| Comparison | Mean diff | 95% CI | Adjusted p |
|---|---:|---|---:|
| 26-35 vs <=25 | 0.440 | [0.259, 0.621] | < .001 |
| 36-50 vs <=25 | 0.586 | [0.344, 0.828] | < .001 |
| 51+ vs <=25 | 0.682 | [0.201, 1.163] | .002 |
| 36-50 vs 26-35 | 0.146 | [-0.095, 0.388] | .403 |
| 51+ vs 26-35 | 0.242 | [-0.239, 0.723] | .565 |
| 51+ vs 36-50 | 0.096 | [-0.411, 0.603] | .962 |

**How to read Table 5:** confidence intervals crossing 0 indicate no clear difference. Here, only comparisons against `<=25` are clearly different after multiple-comparison correction.

Pattern: the **<=25 group is lower than every older group**; differences among older groups are not significant.

Continuous analyses support the same trend:
- **Pearson r = 0.241 (p < .001)**
- **Spearman rho = 0.306 (p < .001)**

**Interpretation:** theta tends to increase with age, especially from the youngest group to all older groups.

---

## 4) Profession/education category

### Table 6. Theta by profession/education

| Profession | n | Mean theta | SD |
|---|---:|---:|---:|
| Science and Education | 276 | 0.314 | 0.871 |
| Service Industry | 258 | -0.052 | 0.988 |
| IT and Engineering | 143 | -0.401 | 0.953 |
| Art and Culture | 74 | 0.256 | 0.918 |
| Student/School | 26 | -0.686 | 0.609 |

**How to read Table 6:** category means spread widely (from `0.314` to `-0.686`), suggesting meaningful between-group stratification in print exposure.

Overall group differences are strong (**chi²(4)=82.186, p<.001; epsilon²=.101**), indicating meaningful separation across categories.

### Table 7. Pairwise Wilcoxon tests (Holm-adjusted p)

| Comparison | p (adjusted) | Interpretation |
|---|---:|---|
| Service Industry vs Science and Education | < .001 | Significant |
| IT and Engineering vs Science and Education | < .001 | Significant |
| Art and Culture vs Science and Education | .339 | Not significant |
| Student/School vs Science and Education | < .001 | Significant |
| IT and Engineering vs Service Industry | .002 | Significant |
| Art and Culture vs Service Industry | .059 | Not significant (trend) |
| Student/School vs Service Industry | .003 | Significant |
| Art and Culture vs IT and Engineering | < .001 | Significant |
| Student/School vs IT and Engineering | .312 | Not significant |
| Student/School vs Art and Culture | < .001 (reported as 0 after rounding) | Significant |

**How to read Table 7:** significance is selective rather than universal. Several pairs differ strongly, while some adjacent groups remain statistically similar, which is expected in heterogeneous social categories.

**Interpretation in words:** higher theta is concentrated in `Science and Education` and `Art and Culture`; lower theta is concentrated in `IT and Engineering` and especially `Student/School`. Not all contrasts are different, but many are.

---

## Integrated interpretation (for discussion section)

Across demographics, theta differs most clearly by:
1. **Humanities background** (moderate effect),
2. **Age** (younger group distinctly lower),
3. **Profession/education** (non-trivial rank-based separation).

Sex differences are statistically present but **small in practical terms**.  
Substantively, this suggests that print exposure/author recognizability in this sample is more strongly linked to educational-cultural trajectory (humanities orientation, age-related accumulation, profession context) than to sex.

---

## Reporting note for manuscript quality

Two groups are small (`51+`, `n=28`; `Student/School`, `n=26`), so estimates for those groups should be interpreted with extra caution despite significant omnibus tests. This does not invalidate findings, but it is worth stating as a limitation in the paper.
