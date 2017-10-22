library(testthat)
library(ghp)
library(rmarkdown)

test_check("ghp")

# Render README.Rmd
render("README.Rmd")
