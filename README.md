
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ghp

[![Build
Status](https://travis-ci.org/Stan125/ghp.svg?branch=master)](https://travis-ci.org/Stan125/ghp)

GHP stands for General Hierarchical Partitioning. `ghp` is an
implementation of the technique of hierarchical partitioning first
mentioned by Chevan and Sutherland (1991). This method fits all possible
models for a set of covariates and then extracts a goodness of fit
(e.g. \(R^2\) for linear models) to obtain independent and joint
contributions of the independent variables on the selected figure.

This package is an extension of the `hier.part` R package, developed by
C. Walsh and R. Mac Nally in 2003. While `hier.part` is fast and simple
at what it does, it is limited in the range of possible models as well
as goodness of fit figures. Specifically, the motivation of this package
is the ability to do deviance partitioning.

## Installation

You can install ghp from github with:

``` r
# install.packages("devtools")
devtools::install_github("Stan125/ghp")
```

## Example: Partitioning of rsquared in linear regression

Just call the ghp function with the name of the dependent variable (arg:
`dep`) and a data.frame with all relevant variables to obtain the
independent and joint effects of the explanatory covariates.

``` r
india <- ghp::india
results_lm <- ghp(depname = "stunting", india, method = "lm", gof = "r.squared")
results_lm
#> $results
#> # A tibble: 7 x 7
#>   var   param indep_effects joint_effects total_effects indep_perc
#>   <chr> <chr>         <dbl>         <dbl>         <dbl>      <dbl>
#> 1 cage  mu        0.0323        0.0123        0.0446      0.269   
#> 2 csex  mu        0.000746     -0.000167      0.000579    0.00623 
#> 3 brea… mu        0.0295        0.0166        0.0461      0.246   
#> 4 ctwin mu        0.0000974    -0.0000199     0.0000775   0.000814
#> 5 mage  mu        0.0322        0.00878       0.0410      0.269   
#> 6 mbmi  mu        0.0196        0.00872       0.0283      0.164   
#> 7 mrel… mu        0.00538       0.000626      0.00600     0.0449  
#> # … with 1 more variable: joint_perc <dbl>
#> 
#> $npar
#> [1] 1
#> 
#> $method
#> [1] "lm"
#> 
#> $gof
#> [1] "r.squared"
#> 
#> $joint_results
#> # A tibble: 8 x 15
#>   var      cage     csex breastfeeding    ctwin    mage    mbmi mreligion
#>   <fct>   <dbl>    <dbl>         <dbl>    <dbl>   <dbl>   <dbl>     <dbl>
#> 1 cage  0        1.74e-5       0.00404  3.57e-6 0.00140 9.85e-4   2.53e-4
#> 2 csex  0.00180  0.            0.00237 -1.12e-6 0.00128 1.18e-3   7.06e-5
#> 3 brea… 0.00343 -3.08e-5       0        2.86e-6 0.00139 1.77e-3   1.41e-4
#> 4 ctwin 0.00177 -2.21e-5       0.00238  0.      0.00126 1.22e-3   8.88e-5
#> 5 mage  0.00191  1.23e-6       0.00251  3.11e-6 0       2.30e-3  -3.25e-5
#> 6 mbmi  0.00150 -8.99e-5       0.00289 -2.49e-5 0.00231 0.        1.05e-4
#> 7 mrel… 0.00193 -4.27e-5       0.00243 -3.44e-6 0.00113 1.26e-3   0.     
#> 8 SUM   0.0123  -1.67e-4       0.0166  -1.99e-5 0.00878 8.72e-3   6.26e-4
#> # … with 7 more variables: cage_perc <dbl>, csex_perc <dbl>,
#> #   breastfeeding_perc <dbl>, ctwin_perc <dbl>, mage_perc <dbl>,
#> #   mbmi_perc <dbl>, mreligion_perc <dbl>
#> 
#> attr(,"class")
#> [1] "part"
```

The first dataframe captures the actual mean influence of the variable
on the goodness-of-fit. Also, joint effects are calculated. The second
dataframe shows the percentage influence. We can see that `cage` has the
highest influence with (\~43%).

## Example: Partitioning of deviance in gamlss models

It is now possible to do deviance partitiong of gamlss models. Gamlss
models can model multiple parameters of a distribution. `ghp` can handle
up to two modeled parameters, so you can find out what influence
covariates have on the second modeled parameter (e.g. the variance).

``` r
results_gamlss <- ghp("stunting", india, method = "gamlss", 
                      gof = "deviance", npar = 2)
results_gamlss
#> $results
#> # A tibble: 14 x 7
#>    var   param indep_effects joint_effects total_effects indep_perc
#>    <chr> <chr>         <dbl>         <dbl>         <dbl>      <dbl>
#>  1 cage  mu         -13.3         -4.35        -17.6       0.269   
#>  2 csex  mu          -0.309        0.0854       -0.224     0.00628 
#>  3 brea… mu         -12.1         -6.14        -18.2       0.245   
#>  4 ctwin mu          -0.0396       0.00969      -0.0299    0.000804
#>  5 mage  mu         -13.3         -2.87        -16.2       0.270   
#>  6 mbmi  mu          -8.03        -3.05        -11.1       0.163   
#>  7 mrel… mu          -2.23        -0.0941       -2.32      0.0453  
#>  8 cage  sigma       -9.96        -2.14        -12.1       0.280   
#>  9 csex  sigma       -0.577        0.0372       -0.540     0.0162  
#> 10 brea… sigma       -8.73        -1.01         -9.74      0.246   
#> 11 ctwin sigma      -11.7          2.47         -9.23      0.329   
#> 12 mage  sigma       -0.360        0.290        -0.0696    0.0101  
#> 13 mbmi  sigma       -0.100        0.0936       -0.00681   0.00282 
#> 14 mrel… sigma       -4.13         1.19         -2.94      0.116   
#> # … with 1 more variable: joint_perc <dbl>
#> 
#> $npar
#> [1] 2
#> 
#> $method
#> [1] "gamlss"
#> 
#> $gof
#> [1] "deviance"
#> 
#> $joint_results
#> $joint_results$res_mu
#> # A tibble: 8 x 15
#>   var     cage     csex breastfeeding    ctwin   mage   mbmi mreligion
#>   <fct>  <dbl>    <dbl>         <dbl>    <dbl>  <dbl>  <dbl>     <dbl>
#> 1 cage   0     -0.00400        -1.53  -1.10e-3 -0.433 -0.302  -0.0747 
#> 2 csex  -0.637  0              -0.873  7.02e-4 -0.420 -0.409  -0.00566
#> 3 brea… -1.27   0.0158          0     -8.18e-4 -0.429 -0.628  -0.0279 
#> 4 ctwin -0.624  0.0115         -0.879  0.      -0.413 -0.427  -0.0132 
#> 5 mage  -0.644  0.00257        -0.896 -9.37e-4  0     -0.849   0.0430 
#> 6 mbmi  -0.486  0.0395         -1.07   1.02e-2 -0.823  0      -0.0156 
#> 7 mrel… -0.682  0.0200         -0.891  1.60e-3 -0.354 -0.438   0      
#> 8 SUM   -4.35   0.0854         -6.14   9.69e-3 -2.87  -3.05   -0.0941 
#> # … with 7 more variables: cage_perc <dbl>, csex_perc <dbl>,
#> #   breastfeeding_perc <dbl>, ctwin_perc <dbl>, mage_perc <dbl>,
#> #   mbmi_perc <dbl>, mreligion_perc <dbl>
#> 
#> $joint_results$res_sigma
#> # A tibble: 8 x 15
#>   var     cage    csex breastfeeding ctwin   mage    mbmi mreligion
#>   <fct>  <dbl>   <dbl>         <dbl> <dbl>  <dbl>   <dbl>     <dbl>
#> 1 cage   0     0.00701      -0.588   0.497 0.0424 0.0123      0.162
#> 2 csex  -0.304 0            -0.145   0.352 0.0388 0.0128      0.178
#> 3 brea… -0.750 0.00498       0       0.521 0.0316 0.0163      0.308
#> 4 ctwin -0.161 0.00491       0.0243  0     0.0669 0.0284      0.169
#> 5 mage  -0.305 0.00264      -0.154   0.378 0      0.00911     0.202
#> 6 mbmi  -0.307 0.00478      -0.141   0.367 0.0372 0           0.171
#> 7 mrel… -0.314 0.0129       -0.00579 0.351 0.0732 0.0147      0    
#> 8 SUM   -2.14  0.0372       -1.01    2.47  0.290  0.0936      1.19 
#> # … with 7 more variables: cage_perc <dbl>, csex_perc <dbl>,
#> #   breastfeeding_perc <dbl>, ctwin_perc <dbl>, mage_perc <dbl>,
#> #   mbmi_perc <dbl>, mreligion_perc <dbl>
#> 
#> 
#> attr(,"class")
#> [1] "part"
```

## Example: Variable grouping

Since 0.3.0 you can specify variable groups. The partitioning is now not
happening with specific variables, but by testing all group
combinations. In the given `ghp::india` dataset, which captures the
nutrition of children in india we can now divide all covariates into to
groups: those that give information about the child, and those that give
information about the mother. Let’s try that out:

``` r
# Specifying the groups should happen in a data.frame 
groupings <- data.frame(varnames = colnames(india), 
                        groups = c("0", "child", "child", "mother", 
                                   "child", "mother", "mother", "mother"))
results_groups <- ghp(depname = "stunting", india, method = "lm", gof = "r.squared",
                      group_df = groupings)
results_groups
#> $results
#> # A tibble: 2 x 7
#>   var   param indep_effects joint_effects total_effects indep_perc
#>   <chr> <chr>         <dbl>         <dbl>         <dbl>      <dbl>
#> 1 child mu           0.0332        0.0116        0.0447      0.277
#> 2 moth… mu           0.0866        0.0116        0.0981      0.723
#> # … with 1 more variable: joint_perc <dbl>
#> 
#> $npar
#> [1] 1
#> 
#> $method
#> [1] "lm"
#> 
#> $gof
#> [1] "r.squared"
#> 
#> $joint_results
#> # A tibble: 3 x 5
#>   var     child mother child_perc mother_perc
#>   <fct>   <dbl>  <dbl>      <dbl>       <dbl>
#> 1 child  0      0.0116          0           1
#> 2 mother 0.0116 0               1           0
#> 3 SUM    0.0116 0.0116          1           1
#> 
#> attr(,"class")
#> [1] "part"
```

We can now see that both groups have almost the same amount of influence
on the \(R^2\).

## Bar Plots

To get a bar plot of the percentage independent effects, use
`plot_ghp()`:

``` r
plot_ghp(results_lm)
```

![](figures/barplot-1.png)<!-- -->

``` r
plot_ghp(results_gamlss) +
  ggplot2::scale_fill_grey()
```

![](figures/barplot-2.png)<!-- -->

## Comparison with hier.part

Since `0.4.0`, `ghp` is almost as fast as its counterpart `hier.part`,
because the core partitioning was written with C++. A quick comparison:

``` r
hp <- function()
  hier.part::hier.part(india$stunting, dplyr::select(india,-stunting),
                       gof = "Rsqu", barplot = FALSE)
ghp <- function()
  ghp::ghp("stunting", india, method = "lm", gof = "r.squared")
microbenchmark::microbenchmark(hp, ghp)
#> Unit: nanoseconds
#>  expr min lq  mean median uq  max neval
#>    hp  29 30 56.78     31 32 2585   100
#>   ghp  29 30 39.26     31 32  801   100
```

This README.Rmd was run on:

``` r
date()
#> [1] "Wed Feb  6 10:41:55 2019"
```
