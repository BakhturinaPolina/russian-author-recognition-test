# Analysis stage → notebook map

Notebook numbers refer to files under `scripts/eda/` (e.g. `08_item_level_descriptives.ipynb`).

| Analysis stage          | Notebook | Primary N | Strict-FA applied | Notes                                                                                   |
| ----------------------- | -------- | --------- | ----------------- | --------------------------------------------------------------------------------------- |
| Item-level descriptives | 08       | 908       | No                | Endorsement rates most stable at full adult N; matches Moore & Gordon practice          |
| Dimensionality check    | 11       | 908       | No                | Sensitivity check re-run at N = 688; unidimensionality conclusion should hold in both   |
| IRT model comparison    | 13       | 688       | Yes               | Calibration sample; guessing distorts model selection less with conservative responders |
| Item parameters (a, b)  | 13       | 688       | Yes               | Fixed parameters applied to all downstream scoring                                      |
| IRT sensitivity check   | 13       | 908       | No                | Re-estimate 2PL; report r(a₉₀₈, a₆₈₈) and r(b₉₀₈, b₆₈₈); expected > .95                 |
| TIF / ICC plots         | 13       | 688       | Yes               | Based on calibration model                                                              |
| Theta distribution      | 15       | 908       | No                | Apply N = 688 parameters to full adult sample; more representative population estimate  |
| Floor/ceiling check     | 15       | 908       | No                | Includes the low-end participants removed by strict-FA; honest coverage estimate        |
| Score-type correlations | 15       | 908       | No                | Hits vs. corrected ART vs. theta comparison on full adult sample                        |
| Sex comparison          | 15       | 908       | No                | Larger N increases power for the smaller effect (g = 0.21)                              |
| Humanities comparison   | 15       | 908       | No                | Main validity argument; medium effect (g = 0.76) stable regardless of N                 |
| Age comparison          | 15       | 908       | No                | Full adult age range better represented at N = 908                                      |
| Profession comparison   | 15       | 688       | Yes               | Only sample with profession field; state N = 688 explicitly in the paper                |