
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
#>   D       X.1       X.2 R A        S.1          S.2        Y1        Y0
#> 1 1 0.2013591 2.6452879 3 0  -6.297297   7.48350565 10.493081 4.1455857
#> 2 1 1.0236769 2.2664267 1 0   8.288764   3.18133654  4.441828 1.9252446
#> 3 1 0.1132067 1.5965351 2 0 -19.447546  -0.03894729  8.092122 4.5600226
#> 4 1 2.6104495 0.4126416 1 0   3.173371 -21.97942904  6.486438 5.6390851
#> 5 1 1.4290971 2.2440912 1 0  -7.716774   6.66357257  4.341646 3.6694013
#> 6 1 1.2609798 0.4957531 1 0  12.159874  -1.81231906  5.381929 0.9862175
#>           Y       tau
#> 1 4.1455857 6.3474953
#> 2 1.9252446 2.5165830
#> 3 4.5600226 3.5320999
#> 4 5.6390851 0.8473527
#> 5 3.6694013 0.6722446
#> 6 0.9862175 4.3957113
```

``` r
set.seed(1234)
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
#> 0.9338041 0.9529915
## empirical coverage of the treatment effects 
## for source (D=1) and target (D=0) data
mapply(function(y, lower, upper)lower <= y & upper >= y, 
       y = df_rst_wS$tau, 
       lower = df_rst_wS$lower.tau,
       upper = df_rst_wS$upper.tau) %>% 
  tapply(df_rst_wS$D, mean)
#>         0         1 
#> 0.9002648 0.8931624
```
