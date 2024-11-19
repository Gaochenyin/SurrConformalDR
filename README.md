
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SurrConformalDR

<!-- badges: start -->
<!-- badges: end -->

The goal of SurrConformalDR is to …

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
#>   D       X.1        X.2 R A        S.1        S.2       Y1        Y0         Y
#> 1 1 0.8921895 0.08607659 1 0 -0.9766149 -3.7873795 3.757858 0.4152928 0.4152928
#> 2 1 2.2078099 2.02550138 1 0  9.0809008 -2.1615746 3.001961 4.0553883 4.0553883
#> 3 1 0.4400919 0.96957213 3 1  4.7234885 11.3668155 6.868767 3.7970159 6.8687670
#> 4 1 0.1758621 0.04126497 1 1 -1.1424120  0.6458969 4.464843 0.3656095 4.4648427
#> 5 1 1.1787492 0.62537313 1 1 -6.1469572 -4.7855041 2.542721 1.0456875 2.5427209
#> 6 1 1.1490216 1.19632238 2 0  4.3048266 -7.9343330 3.752202 3.1312889 3.1312889
#>          tau
#> 1  3.3425655
#> 2 -1.0534273
#> 3  3.0717511
#> 4  4.0992332
#> 5  1.4970334
#> 6  0.6209132
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
## empirical coverage of the observed outcomes for source (D=1) and target (D=0) data
mapply(function(y, lower, upper)lower <= y & upper >= y, 
       y = df_rst_wS$Y, 
       lower = df_rst_wS$lower.Y,
       upper = df_rst_wS$upper.Y) %>% 
  tapply(df_rst_wS$D, mean)
#>         0         1 
#> 0.9414115 0.9473684
## empirical coverage of the treatment effects for source (D=1) and target (D=0) data
mapply(function(y, lower, upper)lower <= y & upper >= y, 
       y = df_rst_wS$tau, 
       lower = df_rst_wS$lower.tau,
       upper = df_rst_wS$upper.tau) %>% 
  tapply(df_rst_wS$D, mean)
#>         0         1 
#> 0.9378606 0.9230769
```
