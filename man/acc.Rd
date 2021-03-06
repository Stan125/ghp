% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/02_helpers.R
\name{acc}
\alias{acc}
\title{Unique combinations of variables}
\usage{
acc(k)
}
\arguments{
\item{k}{Number of covariates (or covariate groups).}
}
\description{
Function to get all possible combinations for a set of covariates.
}
\details{
This function takes a number (\code{k}) and then outputs a matrix with every
row depicting one unique combination of covariates. This function is used for
\code{\link{mfit}}, where every possible combination of covariates as
explanatory variables is computed and then used for fitting all possible
models. This function is then further used for creating model names.
}
