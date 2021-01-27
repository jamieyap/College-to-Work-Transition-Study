# Code in this repository

This repository contains code to process data collected during the study and investigate hypotheses.

## 1. Code for data processing

| <img height=0 width=350> File <img height=0 width=350> | <img height=0 width=800> Brief Description <img height=0 width=800> |
|:------------------------------------------:|:--------------------------------------------------------------------------------------------------|
|[construct-variables-baseline.R](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/construct-variables-baseline.R)| Construct variables using raw data collected at baseline (i.e., the 'baseline dataset'); raw data is in tabular format. |
|[construct-variables-screener.R](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/construct-variables-screener.R)| Construct variables raw data collected at screening (i.e., the 'screener dataset'); raw data is in tabular format.  |
|[construct-variables-wnw.R](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/construct-variables-wnw.R)| Construct variables using raw data collected after baseline (i.e., the 'wnw dataset'); raw data is in tabular format.  |
|[reshape-data.R](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/reshape-data.R)| Identify rows within the wnw dataset to associate with 'time zero' (i.e., the first time an individual reports to be full-time employed) and 'time one' (i.e., twelve months after time zero). In addition, apply exclusion criteria (e.g., exclude individuals who are not full time employed at both time zero and time one). |
|[analysis-00.Rmd](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-00.Rmd)| At time zero and time one, calculate min, max, mean, standard deviation, and amount of missing data in each variable constructed using the baseline, screener, and wnw datasets. Results are displayed in [analysis-00.pdf](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-00.pdf). |

## 2. Code for investigating hypotheses

| <img height=0 width=350> File <img height=0 width=350> | <img height=0 width=800> Brief Description <img height=0 width=800> |
|:------------------------------------------:|:--------------------------------------------------------------------------------------------------|
|[analysis-01-RAPI.Rmd](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-01-RAPI.Rmd)| Investigate Hypothesis H1a, H1b, H4, H5 with RAPI as alcohol use outcome. Results are displayed in [analysis-01-RAPI.pdf](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-01-RAPI.pdf). |
|[analysis-02a-RAPI.Rmd](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-02a-RAPI.Rmd)| Investigate Hypothesis H1c with RAPI as alcohol use outcome. Results are displayed in [analysis-02a-RAPI.pdf](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-02a-RAPI.pdf). |
|[analysis-02b-RAPI.Rmd](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-02b-RAPI.Rmd)| Investigate Hypothesis H2, H3 with RAPI as alcohol use outcome. Results are displayed in [analysis-02b-RAPI.pdf](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-02b-RAPI.pdf). |
|[analysis-01-HED.Rmd](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-01-HED.Rmd)| Investigate Hypothesis H1a, H1b, H4, H5 with HED as alcohol use outcome. Results are displayed in [analysis-01-HED.pdf](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-01-HED.pdf). |
|[analysis-02a-HED.Rmd](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-02a-HED.Rmd)| Investigate Hypothesis H1c with HED as alcohol use outcome. Results are displayed in [analysis-02a-HED.pdf](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-02a-HED.pdf). |
|[analysis-02b-HED.Rmd](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-02b-HED.Rmd)| Investigate Hypothesis H2, H3 with HED as alcohol use outcome. Results are displayed in [analysis-02b-HED.pdf](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-02b-HED.pdf). |
|[analysis-utils.R](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/analysis-utils.R)| A collection of functions for obtaining summary statistics, estimating moderated effects, and formatting output. |
|[boot-mediation-2a.R](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/boot-mediation-02a.R)| Use bootstrapping to estimate mediated effect for Hypothesis H1c. |
|[boot-mediation-2b.R](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/boot-mediation-02b.R)| Use bootstrapping to estimate mediated effect for Hypothesis H2. |
|[boot-mediation-2c.R](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/boot-mediation-02c.R)| Use bootstrapping to estimate mediated effect for Hypothesis H3. |

# Other

## Intermediate output of code for investigating hypotheses

| <img height=0 width=350> File <img height=0 width=350> | <img height=0 width=800> Brief Description <img height=0 width=800> |
|:------------------------------------------:|:--------------------------------------------------------------------------------------------------|
|[list_models_rutgers_02a.RData](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/list_models_rutgers_02a.RData)| Output of [boot-mediation-2a.R](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/boot-mediation-02a.R) |
|[list_models_rutgers_02b.RData](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/list_models_rutgers_02b.RData)| Output of [boot-mediation-2b.R](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/boot-mediation-02b.R) |
|[list_models_rutgers_02c.RData](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/list_models_rutgers_02c.RData)| Output of [boot-mediation-2c.R](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/boot-mediation-02c.R) |
|[list_models_HED_02a.RData](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/list_models_HED_02a.RData)| Output of [boot-mediation-2a.R](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/boot-mediation-02a.R) |
|[list_models_HED_02b.RData](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/list_models_HED_02b.RData)| Output of [boot-mediation-2b.R](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/boot-mediation-02b.R) |
|[list_models_HED_02c.RData](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/list_models_HED_02c.RData)|  Output of [boot-mediation-2c.R](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/boot-mediation-02c.R)  |

## Record of R packages utilized

| <img height=0 width=350> File <img height=0 width=350> | <img height=0 width=800> Brief Description <img height=0 width=800> |
|:------------------------------------------:|:--------------------------------------------------------------------------------------------------|
|[renv.lock](https://github.com/jamieyap/College-to-Work-Transition-Study/blob/master/renv.lock)| Records the collection of R packages and specific versions utilized. |

