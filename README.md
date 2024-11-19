
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SurrConformalDR

<!-- badges: start -->
<!-- badges: end -->

An R package for Surrogate-assisted Conformal Inference for Efficient
Individual Causal Effect Estimation

## Installation

You can install the development version of SurrConformalDR from
[GitHub](https://github.com/) with:

``` r
install.packages("devtools")
devtools::install_github("Gaochenyin/SurrConformalDR")
```

## Example

We illustrate the usage of `SurrConformalDR` using simple synthetic
datasets for continuous primary outcomes

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
#>   D        X.1        X.2 R A        S.1       S.2       Y1           Y0
#> 1 1 -0.6144153  2.0566804 1 0   1.393544  4.583308 3.011056 -0.007931304
#> 2 1  1.2916534  1.3247535 1 0  -1.265404 -6.660800 2.639487  4.059997206
#> 3 1 -0.6099622  0.3811491 3 1   8.337192  2.479153 4.533423  3.481307107
#> 4 1  1.0642303 -0.7863794 1 1  -3.974042 -2.875011 1.474831 -0.535595404
#> 5 1  2.2464721  0.4266237 1 0   2.749122 12.694962 5.320752  1.495874211
#> 6 1  0.7198231  0.5279439 3 1 -11.207589 13.443301 5.670473  5.930293765
#>              Y        tau
#> 1 -0.007931304  3.0189868
#> 2  4.059997206 -1.4205104
#> 3  4.533423084  1.0521160
#> 4  1.474830533  2.0104259
#> 5  1.495874211  3.8248776
#> 6  5.670472607 -0.2598212
```

``` r
# create two folds (75% for training and 25% for evaluation)
train.idx <- caret::createDataPartition(1:nrow(df), p = 0.75)$Resample1
eval.idx <- setdiff(1:nrow(df), train.idx)
# Surrogate-assisted Conformal Inference for Efficient Individual Causal Effect Estimation
df_rst_wS <- SurrConformalDR(df, 
                        train.idx = train.idx, 
                        eval.idx = eval.idx,
                        SL.library = SL.library,
                        outcome.type = 'Continuous',
                        alphaCI = 0.05, nested = TRUE)
## empirical coverage of the observed outcomes 
## for source (D=1) and target (D=0) data
mapply(function(y, lower, upper)lower <= y & upper >= y, 
       y = df_rst_wS$Y, 
       lower = df_rst_wS$lower.Y,
       upper = df_rst_wS$upper.Y) %>% 
  tapply(df_rst_wS$D, mean)
#>         0         1 
#> 0.9381122 0.9527559
## empirical coverage of the treatment effects 
## for source (D=1) and target (D=0) data
mapply(function(y, lower, upper)lower <= y & upper >= y, 
       y = df_rst_wS$tau, 
       lower = df_rst_wS$lower.tau,
       upper = df_rst_wS$upper.tau) %>% 
  tapply(df_rst_wS$D, mean)
#>         0         1 
#> 0.9341051 0.9606299
```
