
<!-- README.md is generated from README.Rmd. Please edit that file -->
ghp
===

GHP stands for General Hierarchical Partitioning. `ghp` is an implementation of the technique of hierarchical partitioning first mentioned by Chevan and Sutherland (1991). This method fits all possible models for a set of covariates and then extracts a goodness of fit (e.g. *R*<sup>2</sup> for linear models) to obtain independent and joint contributions of the independent variables on the selected figure.

This package is an extension of the `hier.part` R package, developed by C. Walsh and R. Mac Nally in 2003. While `hier.part` is fast and simple at what it does, it is limited in the range of possible models as well as goodness of fit figures. Specifically, the motivation of this package is the ability to do deviance partitioning.

Installation
------------

You can install ghp from github with:

``` r
# install.packages("devtools")
devtools::install_github("Stan125/ghp")
```

Example: Partitioning of rsquared in linear regression
------------------------------------------------------

Just call the ghp function with dependent and independent variables to obtain it's independent and joint effects:

``` r
india <- ghp::india
dep <- india$stunting
indep <- subset(india, select = -c(stunting))
results <- ghp(dep, indep, method = "lm", gof = "r.squared")
results
#> $actual
#>                          I             J        Total
#> cage          0.0195242429  7.010337e-03 2.653458e-02
#> csex          0.0038311510  4.663011e-04 4.297452e-03
#> breastfeeding 0.0086394177  4.698817e-03 1.333823e-02
#> ctwin         0.0001131213  1.567455e-04 2.698668e-04
#> mage          0.0001288067 -6.390926e-05 6.489747e-05
#> mbmi          0.0001005444 -9.466058e-06 9.107838e-05
#> mreligion     0.0127136252  8.025658e-05 1.279388e-02
#> 
#> $perc
#>                        I           J
#> cage          43.3381771 56.81409229
#> csex           8.5040482  3.77905868
#> breastfeeding 19.1770106 38.08076367
#> ctwin          0.2510967  1.27031735
#> mage           0.2859137 -0.51794179
#> mbmi           0.2231796 -0.07671607
#> mreligion     28.2205740  0.65042586
#> 
#> attr(,"gof")
#> [1] "r.squared"
```

The first dataframe captures the actual mean influence of the variable on the goodness-of-fit. Also, joint effects are calculated. The second dataframe shows the percentage influence. We can see that `cage` has the highest influence with (~43%).

Bar Plots
---------

To get a bar plot of the percentage independent effects, use `plot_ghp()`:

``` r
plot_ghp(results)
```

![](figures/barplot-1.png)

Comparison with hier.part
-------------------------

Unfortunately, `ghp` is slower than the original `hier.part` package, mostly because it does not rely on C code. A quick time comparison for the same problem:

``` r
system.time(hier.part::hier.part(dep, indep, gof = "Rsqu", barplot = FALSE))
#> Loading required package: gtools
#>    user  system elapsed 
#>   0.347   0.004   0.352
system.time(ghp::ghp(dep, indep, method = "lm", gof = "r.squared"))
#>    user  system elapsed 
#>   4.026   0.036   4.076
```
