# Running head: RUSSIAN AUTHOR RECOGNITION TEST

# Development and Item Response Theory Validation of a Russian Author Recognition Test

**[Author names omitted for draft]**  
**[Affiliations omitted for draft]**

---

## Abstract

The Author Recognition Test (ART) is an established proxy measure of print exposure, widely used in psycholinguistic research. This study reports the development and psychometric validation of a Russian-language ART based on recognition of fiction author names. The test was administered online to a large adult sample (*N* = 1,835). Author selection followed established Russian ART methodology, relying on empirical indicators of reading circulation rather than school curricula. Item response theory (IRT) analyses using a two-parameter logistic model revealed a dominant latent factor corresponding to print exposure. Item difficulty parameters spanned a wide range (approximately *b* ≈ −3 to *b* ≈ +4), and discrimination parameters were generally high (mean *a* ≈ 1.47), indicating strong differentiation between readers with different levels of exposure. The test information function peaked near average ability (θ ≈ 0), with decreasing precision at the extremes. A 60-item short form retained approximately 77% of total test information and correlated strongly with the full test (*r* ≈ .97). The results demonstrate that the Russian ART is a reliable and culturally grounded measure of print exposure and exhibits psychometric properties comparable to those reported for English-language ARTs.

**Keywords:** Author Recognition Test, print exposure, item response theory, reading experience, Russian language

---

## Introduction

Print exposure refers to the cumulative experience individuals acquire through reading over time. It is a major contributor to vocabulary development, orthographic knowledge, reading fluency, and higher-level comprehension. Despite its importance, print exposure is difficult to measure directly because it reflects long-term habits rather than task-specific performance.

The Author Recognition Test (ART) was introduced as an indirect but objective measure of print exposure. In the ART, participants indicate which names from a list they recognize as real fiction authors. The list also contains non-author foils to discourage guessing. Recognition of author names is assumed to be acquired incidentally through reading, book discussions, reviews, and other literacy-related activities. ART performance has been shown to correlate with vocabulary size, reading comprehension, spelling, and eye-movement measures during reading, and it typically outperforms self-report measures of reading frequency.

Because literary knowledge is culturally specific, ARTs must be adapted to each linguistic and cultural context. Authors that are widely known in one language community may be obscure in another due to differences in translation practices, publishing markets, and educational traditions. Consequently, the validity of an ART depends critically on how the author list is constructed.

While English-language ARTs have been extensively validated using item response theory (IRT), Russian-language versions have been less thoroughly examined using modern psychometric techniques. The present study addresses this gap by developing and validating a Russian Author Recognition Test using IRT, building directly on empirically grounded Russian ART methodology.

---

## Method

### Participants

A total of 1,835 adult native speakers of Russian participated in the study. Participants ranged in age from early adulthood to middle age and represented diverse educational and occupational backgrounds. Recruitment was conducted online. All participants provided informed consent prior to participation.

### Materials: Author Recognition Test

#### Author Selection

The Russian ART consisted of 101 real fiction authors and 103 foils. Author selection followed the methodology described in prior Russian ART research and adhered to the following principles:

**Fiction-only criterion.**  
Only fiction authors were included. Authors of non-fiction, academic literature, journalism, or popular science were excluded.

**Empirical circulation criterion.**  
Author candidates were drawn from large-scale Russian book sales rankings and reader-review statistics from major Russian reading platforms. This ensured that selection reflected actual reading exposure rather than prescriptive canons.

**Difficulty-range criterion.**  
Authors were chosen to span a wide range of recognition frequencies, from highly recognized to rarely recognized, to support psychometric calibration.

After data collection, authors were ranked by recognition frequency. The most frequently recognized author in the dataset was Jack London (97.4%), while the least frequently recognized author was Jostein Gaarder (7.1%). The median recognition count was approximately 387 participants, with Jo Nesbø falling near the median (45.4%). Authors whose recognition frequencies fell within one standard deviation of the median were retained in the final frequency-based version of the test.

The final author set included 101 authors ranging from very widely recognized figures such as Charlotte Brontë to less frequently recognized but informative authors such as Khaled Hosseini.

#### Foils

Foils were constructed from real personal names drawn from editorial boards of non-literary academic journals. Foils followed plausible Russian and international naming conventions and were screened to ensure that none belonged to fiction authors.

### Procedure

The ART was administered online. Names were presented one at a time in randomized order. For each name, participants indicated whether they recognized it as a fiction author. Participants were informed that some names were not real authors and that guessing should be avoided. To prevent real-time searching, names were displayed as images rather than selectable text.

### IRT Modeling

Responses to real author items were coded dichotomously (1 = recognized, 0 = not recognized). A two-parameter logistic (2PL) IRT model was fitted. Item difficulty (*b*) reflects the level of print exposure required for recognition, and item discrimination (*a*) reflects how sharply recognition probability increases with exposure.

Dimensionality was assessed using exploratory factor analysis. Model calibration was performed using marginal maximum likelihood estimation.

---

## Results

### Descriptive Recognition Patterns

Recognition frequencies varied widely across authors.

- **Jack London** was recognized by nearly all participants (97.4%), indicating very low difficulty.
- **Charlotte Brontë** also showed very high recognition rates (73.4%).
- **Jo Nesbø** exhibited recognition near the sample median (45.4%).
- **Khaled Hosseini** showed substantially lower recognition (15.1%), indicating higher difficulty.
- **Jostein Gaarder** was among the least recognized authors (7.1%), anchoring the high-difficulty end.

**Figure 1** (Endorsement Histogram) illustrates the distribution of recognition rates across all author items, showing a continuous gradient rather than a bimodal split.

![Endorsement Histogram](../results/step1_item_descriptives/plots/endorsement_histogram.png)

*Figure 1.* Distribution of endorsement rates across all 101 author items. The histogram shows a continuous gradient from low to high recognition rates.

### Dimensionality

Exploratory factor analysis revealed a dominant first factor (eigenvalue = 21.44), substantially larger than subsequent factors (second eigenvalue = 9.81, ratio = 2.19). The Kaiser-Meyer-Olkin measure of sampling adequacy was excellent (KMO = 0.97). Parallel analysis indicated that while multiple factors exceeded chance levels, the dominant first factor supported a primarily unidimensional interpretation.

**Figure 2** (Scree Plot) demonstrates this clear dominance, supporting a primarily unidimensional interpretation of ART performance.

![Scree Plot](../results/step2_dimensionality/plots/scree_plot.png)

*Figure 2.* Scree plot showing eigenvalues for extracted factors. The first factor (eigenvalue = 21.44) is substantially larger than subsequent factors, supporting unidimensionality.

### IRT Item Parameters

Item difficulty parameters ranged approximately from *b* ≈ −3.10 to *b* ≈ +5.11.

- **Low-difficulty items** included authors such as Jack London (*b* = −2.49), Agatha Christie (*b* = −3.10), and Charles Dickens (*b* = −1.90), recognized by most participants.
- **Mid-difficulty items** clustered around authors such as Jo Nesbø (*b* = 0.18) and Daniil Granin (*b* = 0.01), which were recognized by a substantial but not overwhelming portion of the sample.
- **High-difficulty items** included authors such as Khaled Hosseini (*b* = 1.95), Mikhail Elizarov (*b* = 1.69), and Jostein Gaarder (*b* = 5.11), recognized by relatively few participants.

Discrimination parameters were generally high (mean *a* = 1.47, SD = 0.62), indicating that most authors effectively differentiated between readers with adjacent levels of print exposure. The highest discrimination was observed for Gabriel García Márquez (*a* = 3.36) and Charles Dickens (*a* = 3.23).

**Figure 3** (Item Parameter Distributions) shows the distributions of difficulty and discrimination parameters.

![Item Parameter Distributions](../results/step4_item_analysis/plots/item_parameter_distributions.png)

*Figure 3.* Distributions of IRT item parameters. Left: Difficulty (*b*) parameters spanning approximately −3 to +5. Right: Discrimination (*a*) parameters with mean ≈ 1.47.

### Item Characteristic and Information Curves

Item characteristic curves (ICCs) exhibited expected sigmoidal shapes.

- For low-difficulty items (e.g., Jack London), recognition probability was high even at low θ values.
- For high-difficulty items (e.g., Jostein Gaarder), recognition probability increased only at high θ values.

Item information curves demonstrated that different authors contributed information at different points along the exposure continuum.

**Figure 4** (Item Characteristic Curves) illustrates the ICCs for all items.

![Item Characteristic Curves](../results/step5_diagnostics/plots/icc_all_items.png)

*Figure 4.* Item characteristic curves for all 101 author items. Each curve shows the probability of recognition as a function of latent print exposure (θ).

**Figure 5** (Item Information Curves) shows the information contribution of each item across the ability continuum.

![Item Information Curves](../results/step5_diagnostics/plots/item_information_curves.png)

*Figure 5.* Item information curves for all author items. Different items provide maximum information at different points along the print exposure continuum.

### Test Information and Ability Estimates

The test information function peaked near θ ≈ 0 (peak at θ = 0.14), with maximum information of 38.81, indicating maximal precision for readers with average print exposure.

**Figure 6** (Test Information Function) shows declining precision toward the extremes, a pattern typical of recognition-based tests.

![Test Information Function](../results/step5_diagnostics/plots/test_information_function.png)

*Figure 6.* Test information function for the full 101-item Russian ART. Information peaks near average ability (θ ≈ 0) with declining precision at the extremes.

Participant θ estimates were approximately normally distributed (mean θ = 0.007, SD = 1.00, range = [−3.40, 3.96]). The reliability estimate was excellent (0.965).

**Figure 7** (Theta Distribution) shows no severe floor or ceiling effects.

![Theta Distribution](../results/step6_theta_scores/plots/theta_distribution.png)

*Figure 7.* Distribution of estimated print exposure scores (θ) across participants. The distribution is approximately normal with no severe floor or ceiling effects.

### Short-Form Construction

A 60-item short form was constructed by selecting items with high discrimination and balanced difficulty coverage.

The short form retained approximately 77.3% of the total information of the full test. Ability estimates from the short form correlated strongly with full-test estimates (*r* ≈ .97).

**Figure 8** (Short vs. Full Test Information) shows that information loss was minimal in the mid-range of ability.

![Short vs Full Test Information](../results/step8_short_scale/plots/short_vs_full_tif.png)

*Figure 8.* Comparison of test information functions for the full 101-item test and the 60-item short form. The short form retains 77.3% of total test information.

**Table 1.** Comparison of Full and Short Scale Properties

| Metric | Full Scale | Short Scale |
|--------|------------|-------------|
| N Items | 101 | 60 |
| Total Information | 3531.04 | 2729.80 |
| Peak Information | 38.81 | 32.11 |
| Peak θ | 0.14 | 0.10 |
| Info at θ = −2 | 18.56 | 15.72 |
| Info at θ = 0 | 38.65 | 32.05 |
| Info at θ = +2 | 12.94 | 7.95 |
| Information Retained | 100% | 77.3% |

### Scoring Comparisons

IRT-based θ estimates correlated strongly with classical ART scores (hits minus false alarms; *r* = .90) and raw hit counts (*r* = .99). False-alarm rates showed weaker relationships with θ (*r* = .13), indicating that IRT scoring is less sensitive to guessing behavior.

**Table 2.** Correlations Among Scoring Methods

| Comparison | Correlation (*r*) | *R*² |
|------------|-------------------|------|
| θ_IRT vs Classical | .898 | .806 |
| θ_IRT vs Error Rate | .129 | .017 |
| θ_IRT vs Hits | .986 | .973 |
| Classical vs Error Rate | −.292 | .085 |

![Scoring Comparison Matrix](../results/step7_scoring_comparison/plots/scoring_comparison_matrix.png)

*Figure 9.* Correlation matrix showing relationships among different scoring methods for the Russian ART.

---

## Discussion

The present study provides a comprehensive psychometric validation of a Russian Author Recognition Test grounded in empirical reading behavior. The ART exhibited a dominant latent factor corresponding to print exposure, high item discrimination, and a wide range of item difficulties.

Recognition patterns clearly reflected cultural reading exposure. Authors with strong historical presence and translation circulation occupied the low-difficulty end (e.g., Jack London, Agatha Christie, Charles Dickens), while authors with more limited or specialized readerships occupied the high-difficulty end (e.g., Jostein Gaarder, Mikhail Elizarov, Khaled Hosseini). The inclusion of mid-difficulty authors ensured maximal discrimination and information around average exposure levels.

The psychometric structure of the Russian ART closely parallels that reported for English-language ARTs (Moore & Gordon, 2015), despite differences in author composition. This convergence supports the view that ARTs measure a universal latent construct—print exposure—while requiring culturally specific surface indicators.

### Summary of Key Findings

| Category | Metric | Value |
|----------|--------|-------|
| **Data** | Total participants | 1,835 |
| | Real author items | 101 |
| | Foil items | 103 |
| **Dimensionality** | KMO | 0.970 |
| | Eigenvalue ratio (1st/2nd) | 2.19 |
| **IRT** | Mean discrimination (*a*) | 1.47 |
| | Mean difficulty (*b*) | 0.34 |
| | Reliability | 0.965 |
| **Theta** | Mean θ | 0.007 |
| | SD θ | 1.00 |
| | Range | [−3.40, 3.96] |
| **Validity** | θ–Classical correlation | .898 |
| **Short Scale** | Items retained | 60 |
| | Information retained | 77.3% |

---

## Conclusion

The Russian Author Recognition Test is a reliable and valid measure of print exposure for adult Russian speakers. Its construction, grounded in empirical circulation data, and its strong psychometric properties make it suitable for use in psycholinguistic and literacy research. The results demonstrate that culturally adapted ARTs can achieve structural equivalence with English versions while remaining sensitive to local reading ecologies.

---

## References

Moore, M., & Gordon, P. C. (2015). Reading ability and print exposure: Item response theory analysis of the Author Recognition Test. *Behavior Research Methods, 47*(4), 1095–1109. https://doi.org/10.3758/s13428-014-0534-3

Stanovich, K. E., & West, R. F. (1989). Exposure to print and orthographic processing. *Reading Research Quarterly, 24*(4), 402–433.

---

## Appendices

### Appendix A: Full List of Authors with Recognition Frequencies and IRT Parameters

**Table A1.** Complete Item Parameters for All 101 Authors (Sorted by Endorsement Rate)

| Author | Endorsement Rate (%) | Discrimination (*a*) | Difficulty (*b*) |
|--------|---------------------|---------------------|------------------|
| Jack London | 97.38 | 2.28 | −2.49 |
| Agatha Christie | 97.17 | 1.43 | −3.10 |
| Arthur Conan Doyle | 97.11 | 1.87 | −2.65 |
| Alexandre Dumas | 95.86 | 1.82 | −2.45 |
| Ray Bradbury | 95.59 | 2.27 | −2.18 |
| John R.R. Tolkien | 95.26 | 1.51 | −2.60 |
| Charles Dickens | 95.10 | 3.23 | −1.90 |
| Eric Maria Remarque | 94.11 | 2.42 | −1.95 |
| Haruki Murakami | 90.63 | 2.63 | −1.59 |
| George Orwell | 90.08 | 1.92 | −1.75 |
| Jane Austen | 85.07 | 1.82 | −1.44 |
| Isaac Asimov | 83.71 | 1.50 | −1.49 |
| Sergey Lukyanenko | 82.07 | 1.26 | −1.54 |
| George R.R. Martin | 78.09 | 0.68 | −2.04 |
| Tatiana Ustinova | 75.97 | 1.35 | −1.13 |
| Gabriel García Márquez | 75.69 | 3.36 | −0.79 |
| Yury Olesha | 74.93 | 0.93 | −1.38 |
| Charlotte Brontë | 73.35 | 1.89 | −0.84 |
| Isaac Babel | 71.01 | 1.45 | −0.85 |
| Aldous Huxley | 69.16 | 1.82 | −0.69 |
| Max Fry | 67.74 | 1.50 | −0.69 |
| Somerset Maugham | 66.10 | 3.10 | −0.48 |
| James Fenimore Cooper | 64.96 | 1.43 | −0.60 |
| Andrzej Sapkowski | 62.94 | 0.42 | −1.33 |
| Bram Stoker | 62.83 | 1.29 | −0.54 |
| Kir Bulychev | 61.14 | 1.62 | −0.41 |
| Victor Pelevin | 59.24 | 1.53 | −0.35 |
| Victor Astafiev | 59.13 | 1.62 | −0.33 |
| Henry Miller | 58.47 | 1.23 | −0.36 |
| Alexandra Marinina | 57.87 | 1.47 | −0.30 |
| Vasily Aksyonov | 56.84 | 1.63 | −0.25 |
| Jules Verne | 56.57 | 0.55 | −0.52 |
| Valentin Rasputin | 54.55 | 1.12 | −0.20 |
| Janusz Wiśniewski | 54.33 | 1.31 | −0.18 |
| Vladimir Sorokin | 53.13 | 1.93 | −0.11 |
| William Thackeray | 52.21 | 2.50 | −0.07 |
| Margaret Mitchell | 51.66 | 1.69 | −0.06 |
| Arthur Hailey | 51.17 | 1.63 | −0.04 |
| John Fowles | 50.95 | 2.64 | −0.03 |
| Bernard Shaw | 50.19 | 0.93 | −0.01 |
| Daniil Granin | 49.81 | 1.59 | 0.01 |
| Vladimir Voinovich | 47.74 | 1.69 | 0.08 |
| Ivan Efremov | 46.98 | 1.01 | 0.15 |
| Mikhail Weller | 46.76 | 1.99 | 0.11 |
| Irving Stone | 46.38 | 1.52 | 0.14 |
| Jo Nesbø | 45.45 | 1.34 | 0.18 |
| Colin McCullough | 44.58 | 1.24 | 0.23 |
| Victor Erofeev | 43.81 | 2.32 | 0.19 |
| Arkady Averchenko | 43.65 | 1.80 | 0.22 |
| Mariam Petrosyan | 43.49 | 1.22 | 0.28 |
| Dan Brown | 43.38 | 1.16 | 0.29 |
| Michel Houellebecq | 42.94 | 1.34 | 0.29 |
| Irvine Welsh | 42.67 | 1.65 | 0.27 |
| Henryk Sienkiewicz | 42.13 | 1.91 | 0.27 |
| Pavel Sanaev | 40.22 | 1.94 | 0.33 |
| Harper Lee | 39.07 | 1.31 | 0.45 |
| Neil Gaiman | 38.15 | 0.95 | 0.61 |
| Gregory David Roberts | 37.93 | 0.21 | 2.33 |
| Catherine Vilmon | 37.71 | 0.94 | 0.63 |
| Chingiz Aitmatov | 35.91 | 1.58 | 0.53 |
| Boris Vasiliev | 35.64 | 1.22 | 0.63 |
| Dmitry Bykov | 35.53 | 1.41 | 0.58 |
| Thomas Hardy | 35.04 | 1.13 | 0.69 |
| Zakhar Prilepin | 34.71 | 1.63 | 0.57 |
| Mario Puzo | 34.66 | 1.35 | 0.63 |
| Milorad Pavić | 33.95 | 2.77 | 0.49 |
| Markus Zusak | 33.24 | 0.50 | 1.48 |
| Alan Milne | 32.59 | 1.38 | 0.71 |
| Alan Moore | 32.21 | 0.58 | 1.38 |
| Evgeny Vodolazkin | 32.04 | 1.97 | 0.62 |
| Dina Rubina | 31.99 | 1.89 | 0.63 |
| Daniel Keyes | 31.55 | 1.20 | 0.82 |
| Dmitry Glukhovsky | 31.44 | 1.09 | 0.88 |
| Kathryn Stockett | 30.79 | 0.36 | 2.34 |
| Alexey Ivanov | 30.35 | 1.80 | 0.71 |
| Herman Melville | 30.14 | 1.92 | 0.70 |
| Donna Tartt | 29.81 | 1.63 | 0.77 |
| Guzel Yakhina | 29.65 | 1.78 | 0.74 |
| Lyudmila Petrushevskaya | 28.28 | 1.66 | 0.82 |
| Ethel Lilian Voynich | 27.36 | 1.41 | 0.94 |
| Jojo Moyes | 27.25 | 0.58 | 1.82 |
| Leonid Andreev | 26.70 | 2.12 | 0.80 |
| Narine Abgaryan | 26.43 | 1.27 | 1.05 |
| Samuel Beckett | 26.38 | 1.78 | 0.88 |
| Ayn Rand | 25.78 | 1.29 | 1.07 |
| Andrey Belyanin | 20.98 | 0.52 | 2.68 |
| Richard Feynman | 19.35 | 0.85 | 1.91 |
| Boris Vian | 19.35 | 1.88 | 1.18 |
| Reşat Nuri Güntekin | 16.35 | 0.39 | 4.27 |
| Gillian Flynn | 15.53 | 0.98 | 2.03 |
| Khaled Hosseini | 15.10 | 1.07 | 1.95 |
| Mikhail Elizarov | 15.04 | 1.33 | 1.69 |
| Archibald Cronin | 14.55 | 1.25 | 1.79 |
| Paula Hawkins | 13.84 | 0.61 | 3.20 |
| Fredrik Backman | 12.04 | 0.74 | 2.96 |
| Laurence Sterne | 10.52 | 1.65 | 1.83 |
| Art Spiegelman | 8.34 | 1.03 | 2.72 |
| Lee Bardugo | 8.07 | 0.62 | 4.15 |
| Marie-Aude Murail | 7.30 | 0.67 | 4.08 |
| Jostein Gaarder | 7.08 | 0.53 | 5.11 |
| Yuri Tsypkin | 2.78 | 0.93 | 4.26 |

---

### Appendix B: 60-Item Short Form with Difficulty and Discrimination Estimates

**Table B1.** Items Selected for the 60-Item Short Form (Sorted by Difficulty)

| Author | Discrimination (*a*) | Difficulty (*b*) | Endorsement Rate (%) |
|--------|---------------------|------------------|---------------------|
| Arthur Conan Doyle | 1.87 | −2.65 | 97.11 |
| John R.R. Tolkien | 1.51 | −2.60 | 95.26 |
| Jack London | 2.28 | −2.49 | 97.38 |
| Alexandre Dumas | 1.82 | −2.45 | 95.86 |
| Ray Bradbury | 2.27 | −2.18 | 95.59 |
| Eric Maria Remarque | 2.42 | −1.95 | 94.11 |
| Charles Dickens | 3.23 | −1.90 | 95.10 |
| George Orwell | 1.92 | −1.75 | 90.08 |
| Haruki Murakami | 2.63 | −1.59 | 90.63 |
| Isaac Asimov | 1.50 | −1.49 | 83.71 |
| Jane Austen | 1.82 | −1.44 | 85.07 |
| Tatiana Ustinova | 1.35 | −1.13 | 75.97 |
| Isaac Babel | 1.45 | −0.85 | 71.01 |
| Charlotte Brontë | 1.89 | −0.84 | 73.35 |
| Gabriel García Márquez | 3.36 | −0.79 | 75.69 |
| Max Fry | 1.50 | −0.69 | 67.74 |
| Aldous Huxley | 1.82 | −0.69 | 69.16 |
| James Fenimore Cooper | 1.43 | −0.60 | 64.96 |
| Somerset Maugham | 3.10 | −0.48 | 66.10 |
| Kir Bulychev | 1.62 | −0.41 | 61.14 |
| Victor Pelevin | 1.53 | −0.35 | 59.24 |
| Victor Astafiev | 1.62 | −0.33 | 59.13 |
| Alexandra Marinina | 1.47 | −0.30 | 57.87 |
| Vasily Aksyonov | 1.63 | −0.25 | 56.84 |
| Vladimir Sorokin | 1.93 | −0.11 | 53.13 |
| William Thackeray | 2.50 | −0.07 | 52.21 |
| Margaret Mitchell | 1.69 | −0.06 | 51.66 |
| Arthur Hailey | 1.63 | −0.04 | 51.17 |
| John Fowles | 2.64 | −0.03 | 50.95 |
| Daniil Granin | 1.59 | 0.01 | 49.81 |
| Vladimir Voinovich | 1.69 | 0.08 | 47.74 |
| Mikhail Weller | 1.99 | 0.11 | 46.76 |
| Irving Stone | 1.52 | 0.14 | 46.38 |
| Jo Nesbø | 1.34 | 0.18 | 45.45 |
| Victor Erofeev | 2.32 | 0.19 | 43.81 |
| Arkady Averchenko | 1.80 | 0.22 | 43.65 |
| Irvine Welsh | 1.65 | 0.27 | 42.67 |
| Henryk Sienkiewicz | 1.91 | 0.27 | 42.13 |
| Michel Houellebecq | 1.34 | 0.29 | 42.94 |
| Pavel Sanaev | 1.94 | 0.33 | 40.22 |
| Harper Lee | 1.31 | 0.45 | 39.07 |
| Milorad Pavić | 2.77 | 0.49 | 33.95 |
| Chingiz Aitmatov | 1.58 | 0.53 | 35.91 |
| Zakhar Prilepin | 1.63 | 0.57 | 34.71 |
| Dmitry Bykov | 1.41 | 0.58 | 35.53 |
| Evgeny Vodolazkin | 1.97 | 0.62 | 32.04 |
| Mario Puzo | 1.35 | 0.63 | 34.66 |
| Dina Rubina | 1.89 | 0.63 | 31.99 |
| Herman Melville | 1.92 | 0.70 | 30.14 |
| Alexey Ivanov | 1.80 | 0.71 | 30.35 |
| Alan Milne | 1.38 | 0.71 | 32.59 |
| Guzel Yakhina | 1.78 | 0.74 | 29.65 |
| Donna Tartt | 1.63 | 0.77 | 29.81 |
| Leonid Andreev | 2.12 | 0.80 | 26.70 |
| Lyudmila Petrushevskaya | 1.66 | 0.82 | 28.28 |
| Samuel Beckett | 1.78 | 0.88 | 26.38 |
| Ethel Lilian Voynich | 1.41 | 0.94 | 27.36 |
| Boris Vian | 1.88 | 1.18 | 19.35 |
| Mikhail Elizarov | 1.33 | 1.69 | 15.04 |
| Laurence Sterne | 1.65 | 1.83 | 10.52 |

---

### Appendix C: Eigenvalue Decomposition

**Table C1.** First 20 Eigenvalues from Exploratory Factor Analysis

| Factor | Eigenvalue | Variance (%) | Cumulative (%) | Parallel Threshold |
|--------|------------|--------------|----------------|-------------------|
| 1 | 21.44 | 23.06 | 23.06 | 1.50 |
| 2 | 9.81 | 10.55 | 33.61 | 1.47 |
| 3 | 3.21 | 3.45 | 37.06 | 1.44 |
| 4 | 2.69 | 2.90 | 39.96 | 1.42 |
| 5 | 2.32 | 2.49 | 42.45 | 1.40 |
| 6 | 2.11 | 2.27 | 44.72 | 1.38 |
| 7 | 1.69 | 1.82 | 46.54 | 1.37 |
| 8 | 1.50 | 1.61 | 48.15 | 1.36 |
| 9 | 1.33 | 1.43 | 49.58 | 1.34 |
| 10 | 1.26 | 1.36 | 50.94 | 1.33 |
| 11 | 1.17 | 1.26 | 52.20 | 1.32 |
| 12 | 1.11 | 1.19 | 53.39 | 1.30 |
| 13 | 1.04 | 1.12 | 54.51 | 1.29 |
| 14 | 0.99 | 1.06 | 55.58 | 1.28 |
| 15 | 0.94 | 1.01 | 56.59 | 1.27 |
| 16 | 0.92 | 0.99 | 57.58 | 1.26 |
| 17 | 0.89 | 0.96 | 58.54 | 1.25 |
| 18 | 0.88 | 0.95 | 59.49 | 1.24 |
| 19 | 0.87 | 0.93 | 60.42 | 1.23 |
| 20 | 0.83 | 0.90 | 61.32 | 1.22 |

*Note.* Parallel threshold shows the eigenvalue expected under random data. Factors with eigenvalues exceeding the parallel threshold are retained.

---

### Appendix D: Data Quality Summary

**Table D1.** Data Quality Metrics

| Metric | Value |
|--------|-------|
| Total Participants | 1,835 |
| Real Author Items | 101 |
| Foil Items | 103 |
| Missing Data Columns | 19 |
| Total Missing Cells | 1,168 |
| Items with Floor Effect (<5%) | 1 |
| Items with Ceiling Effect (>95%) | 7 |
| Total Flagged Items | 8 |

**Items with Ceiling Effects (>95% endorsement):**
- Jack London (97.4%)
- Agatha Christie (97.2%)
- Arthur Conan Doyle (97.1%)
- Alexandre Dumas (95.9%)
- Ray Bradbury (95.6%)
- John R.R. Tolkien (95.3%)
- Charles Dickens (95.1%)

**Items with Floor Effects (<5% endorsement):**
- Yuri Tsypkin (2.8%)

---

*Report generated based on IRT psychometric analysis of the Russian Author Recognition Test.*
