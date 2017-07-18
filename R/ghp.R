#' Function to get all possible combinations for a set of covariates
#'
#' @importFrom gtools combinations
#' @export

acc <- function(k) {
  combs <- function(k) {
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

    return(binary)
  }
}

#' Internal function: Calculate number of combinations
#'
n_combs <- function(n, r)
  return(factorial(n) / (factorial(n - r) * factorial(r)))

#' Function to do hierarchical partitioning
#'
#' @import dplyr
#' @importFrom combinat permn
#' @importFrom Matrix bdiag
#' @export

ghp <- function(dep, indep, barplot = FALSE, gof = "r.squared",
                model_fun = lm, ...) {

  # Get all variable combinations
  combs <- combinat::permn(1:ncol(indep))

  # model_function with summary
  if (identical(model_fun, gamlss)) {
    model_function <- function(...)
      return(model_fun(...)[[gof]])
  } else {
    model_function <- function(...)
      return(summary(model_fun(...))[[gof]])
  }

  # Create gof list for all possible combinations
  res <- vector("list", length(combs)) %>% # ascending for all combs
    lapply(FUN = as.numeric)
  res_s <- vector("list", length(combs)) %>% # ascending for all comb substractions
    lapply(FUN = as.numeric)

  # Get gof's for first combs
  for (j in 1:length(combs)) {
    vars <- numeric()
    for (i in 1:ncol(indep)) {
      vars <- c(vars, combs[[j]][i])
      res[[j]][i] <- model_function(dep ~ ., data = dplyr::select(indep, vars), ...)
    }
  }

  # Get gof's for substractions
  for (j in 1:length(combs)) {
    vars <- numeric()
    for (i in 2:ncol(indep)) {
      vars <- c(vars, combs[[j]][i])
      res_s[[j]][i-1] <- model_function(dep ~ ., data = dplyr::select(indep, vars), ...)
    }
  }

  # Add gof of empty model to differences
  r2_empty <- model_function(dep ~ 1, ..., data = indep)
  res_s <- lapply(res_s, FUN = function(x) return(c(r2_empty, x)))

  # Convert to matrices
  res <- matrix(unlist(res), ncol = length(combs))
  res_s <- matrix(unlist(res_s), ncol = length(combs))

  # Get differences
  res_d <- res - res_s

  # Sort by first element of permutation in ascending order
  firsts <- sapply(combs, FUN = function(x) return(x[1]))
  sort_order <- sort(firsts, index.return = TRUE)$ix # correct sorting order
  res_d <- res_d[, sort_order] # sort it to have right variable sorting

  # Averages per grouping
  mean_d <- apply(res_d, FUN = mean, MARGIN = 2)
  total_grand <- sum(apply(res_d, FUN = sum, MARGIN = 2))

  # Create averaging matrix
  alist <- lapply(vector("list", ncol(indep)),
                  FUN = function(x) return(as.matrix(t(rep(1, factorial(ncol(indep) - 1))))))
  av_m <- as.matrix(do.call(Matrix::bdiag, alist)) * 1 / factorial(ncol(indep) - 1)

  # Get averages for group and name them
  I <- av_m %*% mean_d
  I_perc <- I / sum(I)

  # Get r2 of lone effects
  Tot <- vector("numeric", ncol(indep))
  for (i in 1:ncol(indep))
    Tot[i] <- model_function(dep ~ ., data = dplyr::select(indep, i), ...)

  # Complete DF
  df_compl <- data.frame(I = I,
                         Total = Tot) %>%
    dplyr::mutate(J = Total - I) %>%
    dplyr::select(I, J, Total)
  row.names(df_compl) <- colnames(indep)

  df_perc <- apply(df_compl[, -3], MARGIN = 2,
                   FUN = function(x) return(x / sum(x) * 100))
  return(list(actual = df_compl, percentages = df_perc))
}
