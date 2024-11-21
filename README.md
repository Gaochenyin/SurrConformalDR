
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
browseVignettes('SurrCOnformalDR')
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
#>   D           X.1         X.2 A         S.1       S.2          Y      tau
#> 1 1  0.9344298181  1.50654807 1  -0.5923450 17.925295  5.0125712 4.369550
#> 2 1  0.1180022205 -1.46831822 1   7.4957294 -1.281488  0.3858690 3.436900
#> 3 1  0.1631931058  0.03128082 0  -4.3552952  9.576404 -0.4557191 2.949004
#> 4 1  1.7523477344 -0.44745989 1   0.1024618 21.827223  5.8026611 5.809164
#> 5 1 -0.0007801354 -0.13282172 1 -15.9127180 10.409168  0.6253772 1.331686
#> 6 1  1.5002355489  0.41572800 0   1.2627452  8.807817  0.6696196 2.750940
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
