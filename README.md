
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ghp

[![Build
Status](https://travis-ci.org/Stan125/ghp.svg?branch=master)](https://travis-ci.org/Stan125/ghp)

GHP stands for General Hierarchical Partitioning. `ghp` is an
implementation of the technique of hierarchical partitioning first
mentioned by Chevan and Sutherland (1991). This method fits all possible
models for a set of covariates and then extracts a goodness of fit (e.g.
\(R^2\) for linear models) to obtain independent and joint contributions
of the independent variables on the selected figure.

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
#>   var           param indep_effects joint_effects total_effects indep_perc
#>   <chr>         <chr>         <dbl>         <dbl>         <dbl>      <dbl>
#> 1 cage          mu        0.0323        0.0123        0.0446      0.269   
#> 2 csex          mu        0.000746     -0.000167      0.000579    0.00623 
#> 3 breastfeeding mu        0.0295        0.0166        0.0461      0.246   
#> 4 ctwin         mu        0.0000974    -0.0000199     0.0000775   0.000814
#> 5 mage          mu        0.0322        0.00878       0.0410      0.269   
#> 6 mbmi          mu        0.0196        0.00872       0.0283      0.164   
#> 7 mreligion     mu        0.00538       0.000626      0.00600     0.0449  
#> # ... with 1 more variable: joint_perc <dbl>
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
#>   var       cage     csex breastfeeding    ctwin    mage    mbmi mreligion
#> * <fct>    <dbl>    <dbl>         <dbl>    <dbl>   <dbl>   <dbl>     <dbl>
#> 1 cage   0        1.74e⁻⁵       0.00404  3.57e⁻⁶ 0.00140 9.85e⁻⁴   2.53e⁻⁴
#> 2 csex   0.00180  0             0.00237 -1.12e⁻⁶ 0.00128 1.18e⁻³   7.06e⁻⁵
#> 3 breas… 0.00343 -3.08e⁻⁵       0        2.86e⁻⁶ 0.00139 1.77e⁻³   1.41e⁻⁴
#> 4 ctwin  0.00177 -2.21e⁻⁵       0.00238  0       0.00126 1.22e⁻³   8.88e⁻⁵
#> 5 mage   0.00191  1.23e⁻⁶       0.00251  3.11e⁻⁶ 0       2.30e⁻³  -3.25e⁻⁵
#> 6 mbmi   0.00150 -8.99e⁻⁵       0.00289 -2.49e⁻⁵ 0.00231 0         1.05e⁻⁴
#> 7 mreli… 0.00193 -4.27e⁻⁵       0.00243 -3.44e⁻⁶ 0.00113 1.26e⁻³   0      
#> 8 SUM    0.0123  -1.67e⁻⁴       0.0166  -1.99e⁻⁵ 0.00878 8.72e⁻³   6.26e⁻⁴
#> # ... with 7 more variables: cage_perc <dbl>, csex_perc <dbl>,
#> #   breastfeeding_perc <dbl>, ctwin_perc <dbl>, mage_perc <dbl>,
#> #   mbmi_perc <dbl>, mreligion_perc <dbl>
#> 
#> attr(,"class")
#> [1] "part"
```

The first dataframe captures the actual mean influence of the variable
on the goodness-of-fit. Also, joint effects are calculated. The second
dataframe shows the percentage influence. We can see that `cage` has the
highest influence with (~43%).

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
#>    var          param indep_effects joint_effects total_effects indep_perc
#>    <chr>        <chr>         <dbl>         <dbl>         <dbl>      <dbl>
#>  1 cage         mu         -13.3             9304          4995   0.269   
#>  2 csex         mu         - 0.309           9309          5012   0.00628 
#>  3 breastfeedi… mu         -12.1             9303          4994   0.245   
#>  4 ctwin        mu         - 0.0396          9309          5012   0.000804
#>  5 mage         mu         -13.3             9306          4996   0.270   
#>  6 mbmi         mu         - 8.03            9306          5001   0.163   
#>  7 mreligion    mu         - 2.23            9309          5010   0.0453  
#>  8 cage         sigma      - 9.96            9307          5000   0.280   
#>  9 csex         sigma      - 0.577           9309          5012   0.0162  
#> 10 breastfeedi… sigma      - 8.73            9308          5003   0.246   
#> 11 ctwin        sigma      -11.7             9311          5003   0.329   
#> 12 mage         sigma      - 0.360           9309          5012   0.0101  
#> 13 mbmi         sigma      - 0.100           9309          5012   0.00282 
#> 14 mreligion    sigma      - 4.13            9310          5009   0.116   
#> # ... with 1 more variable: joint_perc <dbl>
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
#>   var       cage  csex breastfeeding ctwin  mage  mbmi mreligion cage_perc
#> * <fct>    <dbl> <dbl>         <dbl> <dbl> <dbl> <dbl>     <dbl>     <dbl>
#> 1 cage      5012   716           715   716   716   716       716    0.539 
#> 2 csex       715  5012           715   716   716   716       716    0.0769
#> 3 breastf…   715   716          5012   716   716   715       716    0.0768
#> 4 ctwin      715   716           715  5012   716   716       716    0.0769
#> 5 mage       715   716           715   716  5012   715       716    0.0769
#> 6 mbmi       716   716           715   716   715  5012       716    0.0769
#> 7 mreligi…   715   716           715   716   716   716      5012    0.0769
#> 8 SUM       9304  9309          9303  9309  9306  9306      9309    1.00  
#> # ... with 6 more variables: csex_perc <dbl>, breastfeeding_perc <dbl>,
#> #   ctwin_perc <dbl>, mage_perc <dbl>, mbmi_perc <dbl>,
#> #   mreligion_perc <dbl>
#> 
#> $joint_results$res_sigma
#> # A tibble: 8 x 15
#>   var       cage  csex breastfeeding ctwin  mage  mbmi mreligion cage_perc
#> * <fct>    <dbl> <dbl>         <dbl> <dbl> <dbl> <dbl>     <dbl>     <dbl>
#> 1 cage      5012   716           715   717   716   716       716    0.539 
#> 2 csex       716  5012           716   716   716   716       716    0.0769
#> 3 breastf…   715   716          5012   717   716   716       716    0.0769
#> 4 ctwin      716   716           716  5012   716   716       716    0.0769
#> 5 mage       716   716           716   716  5012   716       716    0.0769
#> 6 mbmi       716   716           716   716   716  5012       716    0.0769
#> 7 mreligi…   716   716           716   716   716   716      5012    0.0769
#> 8 SUM       9307  9309          9308  9311  9309  9309      9310    1.00  
#> # ... with 6 more variables: csex_perc <dbl>, breastfeeding_perc <dbl>,
#> #   ctwin_perc <dbl>, mage_perc <dbl>, mbmi_perc <dbl>,
#> #   mreligion_perc <dbl>
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
#>   var    param indep_effects joint_effects total_effects indep_perc
#>   <chr>  <chr>         <dbl>         <dbl>         <dbl>      <dbl>
#> 1 child  mu           0.0332        0.0116        0.0447      0.277
#> 2 mother mu           0.0866        0.0116        0.0981      0.723
#> # ... with 1 more variable: joint_perc <dbl>
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
#> * <fct>   <dbl>  <dbl>      <dbl>       <dbl>
#> 1 child  0      0.0116       0           1.00
#> 2 mother 0.0116 0            1.00        0   
#> 3 SUM    0.0116 0.0116       1.00        1.00
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
plot_ghp(results_gamlss)
```

![](figures/barplot-2.png)<!-- -->

## Comparison with hier.part

Since `0.4.0`, `ghp` is almost as fast as its counterpart `hier.part`,
because the core partitioning was written with C++. A quick
comparison:

``` r
system.time(hier.part::hier.part(india$stunting, dplyr::select(india, -stunting), gof = "Rsqu", barplot = FALSE))
#> Loading required package: gtools
#>    user  system elapsed 
#>   0.324   0.009   0.338
system.time(ghp::ghp("stunting", india, method = "lm", gof = "r.squared"))
#>    user  system elapsed 
#>   0.353   0.004   0.363
```

This README.Rmd was run on:

``` r
date()
#> [1] "Thu Feb 22 14:11:03 2018"
```
