
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
#>   D       X.1       X.2 A        S.1        S.2         Y
#> 1 1  2.674478 0.9233647 0 -10.546764 -10.531640 6.1857457
#> 2 1  3.053843 1.8836734 0 -13.196210   6.511411 4.6297624
#> 3 1  1.475156 1.1085576 1  -3.711756  -7.967273 1.6325787
#> 4 1 -0.841142 1.5948930 1   4.516589  -2.375909 0.9543361
#> 5 1  1.115709 1.2595377 1   6.123498 -13.431442 2.7116487
#> 6 1  2.241426 0.2469364 1   7.659264  -5.440272 3.0583206
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
