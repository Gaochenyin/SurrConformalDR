
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
#>   D        X.1       X.2 A       S.1         S.2          Y        tau
#> 1 1  0.9140278 1.6618960 0  3.667808 -19.6982223  3.0554016  0.3439893
#> 2 1  2.0287279 1.6637934 0 -8.473835  -0.4330812  3.5517326 -0.3044858
#> 3 1  1.0240139 0.1187267 0 -2.895742  -6.1990638  1.1624350  2.6715778
#> 4 1  1.4608617 2.9740439 1  6.130101   3.8535435  5.7884840  2.7269300
#> 5 1  0.6504144 1.2618083 0  2.123511  -1.1487733 -0.1215526  3.6591536
#> 6 1 -0.1430252 0.9640842 0 -9.107182  -0.5233964  0.5017106  1.2408225
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
