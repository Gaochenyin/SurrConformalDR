
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SurrConformalDR

<!-- badges: start -->
<!-- badges: end -->

An R package for Surrogate-assisted Conformal Inference for Efficient
Individual Causal Effect Estimation

## Installation

To implement the method and access the vignette, you can install the
development version of SurrConformalDR from
[GitHub](https://github.com/) with:

``` r
install.packages("devtools")
devtools::install_github("Gaochenyin/SurrConformalDR",
                         build_vignettes = TRUE)
browseVignettes('SurrConformalDR')
```

## Example

We illustrate the usage of `SurrConformalDR` using simple synthetic
datasets for continuous primary outcomes. For details please read the
vignette (`vignette("demo_SCIENCE", package = "SurrConformalDR")`)

``` r
## basic example code
# sample size
N <- 1e4
# library for SuperLearner
SL.library <- c('SL.glm')
seed <- 2333
# an example for Gaussian outcomes
df <- genData.conformal(seed = seed, N = N, 
                        outcome.type = 'Continuous',
                        beta.S = 10)
head(df)
#>   D         X.1         X.2 A       S.1        S.2          Y       tau
#> 1 1  0.69270129  0.22106718 1  2.652121 -13.945063  0.1100479 -1.684839
#> 2 1 -0.25693360  2.38729869 0 10.704680   1.106399 -0.4942529  3.920490
#> 3 1  1.55944440  0.80973097 1 -7.846135   5.738938  3.3390603 -0.598128
#> 4 1  1.85601245 -0.45858866 0 -7.253635  -2.836619 -0.2017726  3.326415
#> 5 1 -0.06525964  0.05591135 1  9.264676   9.291850  2.9695520  3.605217
#> 6 1  1.04611286  0.01006772 1 17.103869 -21.675263  1.9479473  2.052303
```

``` r
set.seed(1234)
# create two folds (75% for training and 25% for evaluation)
train.idx <- caret::createDataPartition(1:nrow(df), p = 0.75)$Resample1
eval.idx <- setdiff(1:nrow(df), train.idx)
# SCIENCE framework
df_rst_wS <- SurrConformalDR(df, 
                        train.idx = train.idx, 
                        eval.idx = eval.idx,
                        SL.library = SL.library,
                        outcome.type = 'Continuous',
                        alphaCI = 0.05, nested = TRUE)
## empirical coverage of the observed outcomes for D = 0 and 1
## D = 1: source data, the primary outcomes are observed
mapply(function(y, lower, upper)lower <= y & upper >= y, 
       y = (df_rst_wS%>%filter(D==1))$Y, 
       lower = (df_rst_wS%>%filter(D==1))$lower.Y,
       upper = (df_rst_wS%>%filter(D==1))$upper.Y) %>% 
   mean(na.rm = TRUE)
#> [1] 0.9487179
```
