
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
#>   D         X.1        X.2 R A         S.1         S.2       Y1        Y0
#> 1 1  1.08604291  0.1810536 2 0  -2.0698785  -0.4934236 3.451211  4.015352
#> 2 1  0.02162517  2.2040962 2 0   3.4451466 -21.1798290 5.450040  4.814120
#> 3 1  1.75959937 -0.2161720 1 1 -10.7370270   3.6346361 1.888321  1.306357
#> 4 1  1.59711872 -0.1018285 2 1  -0.7811347   8.5619841 5.022883  3.409152
#> 5 1 -0.92083938  2.3525706 2 1  -2.3587704  -0.2098783 3.818078  4.315251
#> 6 1  0.16092298 -1.1643267 3 1   7.9846306  -8.2810896 3.969728 -1.078631
#>          Y        tau
#> 1 4.015352 -0.5641415
#> 2 4.814120  0.6359202
#> 3 1.888321  0.5819636
#> 4 5.022883  1.6137311
#> 5 3.818078 -0.4971737
#> 6 3.969728  5.0483588
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
## empirical coverage of the observed outcomes for source (D=1) and target (D=0) data
mapply(function(y, lower, upper)lower <= y & upper >= y, 
       y = df_rst_wS$Y, 
       lower = df_rst_wS$lower.Y,
       upper = df_rst_wS$upper.Y) %>% 
  tapply(df_rst_wS$D, mean)
#>         0         1 
#> 0.9576082 0.9536680
## empirical coverage of the treatment effects for source (D=1) and target (D=0) data
mapply(function(y, lower, upper)lower <= y & upper >= y, 
       y = df_rst_wS$tau, 
       lower = df_rst_wS$lower.tau,
       upper = df_rst_wS$upper.tau) %>% 
  tapply(df_rst_wS$D, mean)
#>         0         1 
#> 0.9607318 0.9575290
```
