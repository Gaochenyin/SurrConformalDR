
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SurrConformalDR

<!-- badges: start -->
<!-- badges: end -->

An R package for Surrogate-assisted Conformal Inference for Efficient
Individual Causal Effect Estimation

## Installation

To access the vignette, you can install the development version of
SurrConformalDR from [GitHub](https://github.com/) with:

``` r
install.packages("devtools")
devtools::install_github("Gaochenyin/SurrConformalDR",
                         build_vignettes = TRUE)
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
#>   D        X.1        X.2 A       S.1        S.2         Y       tau
#> 1 1  0.4507388  1.9623630 0 -2.826700  -5.230578  3.144383 0.7512173
#> 2 1 -0.5297559  1.1580891 1 -2.225087   6.768717  2.805374 3.5948053
#> 3 1  1.4327919  0.5554295 0 -8.079096   3.889108  2.770920 3.5558811
#> 4 1  1.5135549  0.1923019 0  1.569142  -8.277306  1.378160 0.9845718
#> 5 1  1.7926916  0.8053363 0 10.126140 -19.128686  1.772369 0.6799895
#> 6 1  0.7306572 -0.2206441 0  5.431296   6.301006 -1.165080 2.5319028
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
