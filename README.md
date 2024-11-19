
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
library(SurrConformalDR)
library(dplyr)
#> 
#> 载入程序包：'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(SuperLearner)
#> 载入需要的程序包：nnls
#> 载入需要的程序包：gam
#> 载入需要的程序包：splines
#> 载入需要的程序包：foreach
#> Loaded gam 1.22-5
#> Super Learner
#> Version: 2.0-29
#> Package created on 2024-02-06
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
#>   D        X.1         X.2 R A         S.1         S.2        Y1       Y0
#> 1 1 -0.1689732  0.25991086 2 1 -10.3633473  -0.2672595 0.8087446 1.567940
#> 2 1  1.3985697 -1.21133275 3 1   3.0322537 -11.1691124 1.6449347 3.008854
#> 3 1  1.2815862  1.72347697 3 1  -0.3584979   4.3339493 7.4991193 3.700602
#> 4 1 -1.5750551  0.63347062 3 1   3.6668240   7.6021385 3.4496082 3.188919
#> 5 1  1.0931254 -0.06084825 1 1  12.2669631  -1.0121564 3.8282332 1.547041
#> 6 1  1.6886319  0.50601804 1 0  13.4782558  -0.3372688 4.9692179 1.624507
#>           Y        tau
#> 1 0.8087446 -0.7591952
#> 2 1.6449347 -1.3639194
#> 3 7.4991193  3.7985178
#> 4 3.4496082  0.2606890
#> 5 3.8282332  2.2811922
#> 6 1.6245073  3.3447106
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
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
#> Warning in predict.lm(object, newdata, se.fit, scale = 1, type = if (type == :
#> prediction from rank-deficient fit; attr(*, "non-estim") has doubtful cases
## empirical coverage of the observed outcomes for source (D=1) and target (D=0) data
mapply(function(y, lower, upper)lower <= y & upper >= y, 
       y = df_rst_wS$Y, 
       lower = df_rst_wS$lower.Y,
       upper = df_rst_wS$upper.Y) %>% 
  tapply(df_rst_wS$D, mean)
#>         0         1 
#> 0.9411765 0.9523810
## empirical coverage of the treatment effects for source (D=1) and target (D=0) data
mapply(function(y, lower, upper)lower <= y & upper >= y, 
       y = df_rst_wS$Y, 
       lower = df_rst_wS$lower.tau,
       upper = df_rst_wS$upper.tau) %>% 
  tapply(df_rst_wS$D, mean)
#>         0         1 
#> 0.7894028 0.8241758
```
