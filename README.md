
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

This is a basic example which shows you how to solve a common problem:

``` r
library(SurrConformalDR)
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
#>   D        X.1        X.2 R A       S.1       S.2       Y1       Y0        Y
#> 1 1 2.57131189  3.1590285 2 0  1.014841 -5.555050 9.657706 7.523006 7.523006
#> 2 1 1.44033262  2.3231929 2 0 -4.681614 -1.373136 8.064739 3.518379 3.518379
#> 3 1 0.52552390  1.2850988 2 0 -1.560407 14.119184 4.118260 1.980238 1.980238
#> 4 1 0.94098398  0.8230806 1 0 -8.330689  3.232820 2.963901 1.831450 1.831450
#> 5 1 2.26572785  2.1540065 1 0 -6.776186 -1.747418 7.926421 4.469206 4.469206
#> 6 1 0.07181894 -0.5207388 3 0 -7.599327  7.747409 3.053651 3.786942 3.786942
#>          tau
#> 1  2.1346998
#> 2  4.5463602
#> 3  2.1380220
#> 4  1.1324512
#> 5  3.4572150
#> 6 -0.7332917
```
