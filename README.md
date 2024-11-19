
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
#>   D         X.1        X.2 A        S.1        S.2        Y1         Y0
#> 1 1 -0.70437687 -0.2249257 1   4.742445   4.836154 2.3449222 -3.6211037
#> 2 1  0.99592612  1.8593479 1  -9.722967 -13.267322 0.5571586 -0.4690458
#> 3 1 -0.95481251  0.1090067 1   1.406036   8.350572 2.0224639 -2.0952098
#> 4 1  1.67025877  1.2172118 0   9.752718  -8.990909 4.8706893  1.1177575
#> 5 1  2.35650444  0.9375346 1   2.832568  -5.192889 4.3443584  6.5631635
#> 6 1 -0.06272265  1.2432012 0 -13.539727 -17.988827 3.4749543  2.3968879
#>           Y       tau
#> 1 2.3449222  5.966026
#> 2 0.5571586  1.026204
#> 3 2.0224639  4.117674
#> 4 1.1177575  3.752932
#> 5 4.3443584 -2.218805
#> 6 2.3968879  1.078066
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
## D = 0: target data, the primary outcomes are missing
mapply(function(y, lower, upper)lower <= y & upper >= y, 
       y = df_rst_wS$Y, 
       lower = df_rst_wS$lower.Y,
       upper = df_rst_wS$upper.Y) %>% 
  tapply(df_rst_wS$D, mean)
#>         0         1 
#> 0.9346867 0.9444444
```
