#' Unique combinations of variables
#'
#' Function to get all possible combinations for a set of covariates.
#'
#' This function takes a number (\code{k}) and then outputs a matrix with every
#' row depicting one unique combination of covariates. This function is used for
#' \code{\link{mfit}}, where every possible combination of covariates as
#' explanatory variables is computed and then used for fitting all possible
#' models. This function is then further used for creating model names.
#'
#' @param k Number of covariates (or covariate groups).
#'
#' @importFrom gtools combinations
#' @export

acc <- function(k) {
  ## Combinations
  combs <- as.list(1:k)
  combs <- lapply(combs, FUN = function(x)
    return(matrix(0, nrow = n_combs(k, x), ncol = k)))
  for (i in 1:length(combs)) {
    temp_comb <- combinations(k, i)
    dtc <- dim(temp_comb)
    combs[[i]][1:dtc[1], 1:dtc[2]] <- temp_comb
  }
  combs <- do.call(rbind, combs)

  ## Binary combinations
  indices <- cbind(1:nrow(combs), as.vector(combs))
  indices <- indices[indices[, 2] > 0, ]
  binary <- matrix(0, nrow = nrow(combs), ncol = ncol(combs))
  binary[indices] <- 1

  return(list(combs = combs, binary = binary))
}

#' Internal function: Calculate number of combinations
#'
#' Used for \code{\link{mfit}}.
#'
#'@keywords internal

n_combs <- function(n, r)
  return(factorial(n) / (factorial(n - r) * factorial(r)))

#' Internal: Function to make a dataframe out of selected list parts
#'
#' Used for \code{\link{mfit}}.
#'
#' @keywords internal

selector <- function(list, selection)
  return(as.data.frame(list[selection]))
