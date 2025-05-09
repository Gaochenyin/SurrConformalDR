
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SurrConformalDR

<!-- badges: start -->
<!-- badges: end -->

An R package for Surrogate-assisted Conformal Inference for Efficient
Individual Causal Effect Estimation

## Installation

To implement the method and access the vignette, you can install the
development version of SurrConformalDR from
[GitHub](https://github.com/) with:

``` r
install.packages("devtools")
devtools::install_github("Gaochenyin/SurrConformalDR",
                         build_vignettes = TRUE)
browseVignettes('SurrConformalDR')
```

## Example 1: Surrogate-assisted efficient conformal inferece

We illustrate the use of the SurrConformalDR package by generating a
synthetic dataset with continuous primary outcomes. For additional
details, please consult the respective vignette by running:
`vignette("demo_SCIENCE", package = "SurrConformalDR")`

``` r
# Sample size
N <- 1e4

# SuperLearner library
SL.library <- c("SL.glm")

# Set random seed
seed <- 2333

# Generate a synthetic dataset with continuous outcomes
df <- genData.conformal(
  seed = seed, 
  N = N, 
  outcome.type = "Continuous",
  beta.S = 10
)

head(df)
#>   D       X.1         X.2 A         S.1         S.2          Y        tau
#> 1 1 0.7784601  0.37782944 1   4.4534353  12.5192262  5.1330824  8.3715390
#> 2 1 2.3800287  0.26293879 0   0.5683353  22.0100488 -1.0317784  5.2544756
#> 3 1 1.7820937 -1.04586879 1 -26.2420947 -12.0179963 -0.4181503  0.6594862
#> 4 1 2.0148899  2.10162563 0 -20.1522985 -15.7478299  5.9369484 -1.1814841
#> 5 1 0.8512081  0.91471787 1 -16.3370513   0.6206081  0.2275705  0.1368420
#> 6 1 2.3840674  0.04635982 0  -0.6944457   2.1978613  2.6187903  0.9689545
```

``` r
set.seed(1234)

# Create two folds (75% training, 25% evaluation)
train.idx <- caret::createDataPartition(seq_len(nrow(df)), p = 0.75)$Resample1
eval.idx <- setdiff(seq_len(nrow(df)), train.idx)

# Apply the Surrogate-Assisted Conformal Inference (SCIENCE) framework
df_rst_wS <- SurrConformalDR(
  df, 
  train.idx = train.idx, 
  eval.idx = eval.idx,
  SL.library = SL.library,
  outcome.type = "Continuous",
  alphaCI = 0.05, 
  nested = TRUE
)

# Compute empirical coverage for the observed outcomes when D = 1
coverage_D1 <- mapply(
  function(y, lower, upper) lower <= y & upper >= y, 
  y     = (df_rst_wS %>% filter(D == 1))$Y,
  lower = (df_rst_wS %>% filter(D == 1))$lower.Y,
  upper = (df_rst_wS %>% filter(D == 1))$upper.Y
) %>% mean(na.rm = TRUE)

coverage_D1
#> [1] 0.9529915
```

## Example 2: Surrogate-assisted clustered conformal inferece for fairness

We now demonstrate the package’s clustered conformal inference features,
which aim to enhance fairness across different protected groups.

``` r
# Generate a synthetic dataset with categorical outcomes
df <- genData.clustered.conformal(
  seed = seed,
  N = N,
  numgroup = 3, 
  numcluster = 2,
  outcome.type = "Categorical",
  beta.S = 10
)

head(df)
#>   D        X.1        X.2 R A        S.1        S.2 Y1 Y0 Y
#> 1 1  2.9159572  0.8000212 2 0 -11.888376 -14.307708  1  4 4
#> 2 1  1.4773438  0.6672756 3 1   7.352489  11.383682  5  4 5
#> 3 1 -0.1695525  2.7591301 3 0   4.723183 -16.851196  3  2 2
#> 4 1  2.0841432  1.7604820 1 1  13.382544   4.882784  3  1 3
#> 5 1  1.3576543 -0.7150404 2 0  -5.297849  -3.138188  1  2 2
#> 6 1  1.5225674  0.6439116 3 1   3.283982   7.448059  5  1 5
```

``` r
set.seed(1234)

# Create two folds (75% training, 25% evaluation)
train.idx <- caret::createDataPartition(seq_len(nrow(df)), p = 0.75)$Resample1
eval.idx <- setdiff(seq_len(nrow(df)), train.idx)

# SCIENCE framework: efficient conformal inference
rst.wS <- SurrConformalDR(
  df,
  train.idx = train.idx, 
  eval.idx = eval.idx,
  SL.library = SL.library,
  outcome.type = "Categorical",
  alphaCI = 0.05, 
  nested = TRUE
)

# SAGCCI framework: surrogate-assisted clustered conformal inference
rst.wSCluster <- SurrClusterConformalDR(
  df,
  train.idx,
  eval.idx,
  numcluster = "auto",
  minsize = 1 / 0.05 - 1,
  outcome.type = "Categorical",
  SL.library = SL.library,
  alphaCI = 0.05
)

# Evaluate metrics:
# 1) CovGap (coverage gap for fairness)
# 2) AvgSize (average size for efficiency)
get.metric(rst.wS)
#>    CovGap   AvgSize 
#> 0.5487111 2.0447223
```

``` r
get.metric(rst.wSCluster)
#>     CovGap    AvgSize 
#> 0.04445183 2.01534038
```

``` r

# The SAGCCI approach often reduces coverage gap (CovGap) 
# while maintaining a similar average prediction interval size (AvgSize).
```
