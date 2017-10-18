#' Partitioning
#'
#' @importFrom combinat permn
#' @import Matrix
#' @export

## Do partitioning
part <- function(gofs, depname, data, group_df = NULL, outside = FALSE) {

  # Transform the independent variables (Grouping happens here)
  # but only if the data come from the inside of the package
  if (!outside) {
    indep <- indep_tf(depname, data, group_df)
  } else if (outside) {
    indep <- data
  }


  # Get number of vars
  nvar <- length(indep)

  # Get all permutations and sort them
  perms <- permn(nvar)
  firsts <- sapply(perms, FUN = function(x) return(x[1]))
  sort_order <- sort(firsts, index.return = TRUE)$ix
  perms <- perms[sort_order]

  # All model combination names
  combs <- apply(acc(nvar)$combs, MARGIN = 1, FUN = function(x)
    return(as.character(x[x > 0])))
  combs <- sapply(combs, FUN = function(x)
    return(do.call(paste0, as.list(c("x", x)))))
  combs <- c("x0", combs)

  # Differences for each permutation
  diffs <- lapply(perms, FUN = function(x)
    return(perm_diff(x, combs, gofs)))

  # Get mean per grouping
  diffs_mean <- sapply(diffs, mean)

  # Make averaging matrices
  alist <- lapply(vector("list", nvar), FUN = function(x)
    return(as.matrix(t(rep(1, factorial(nvar - 1))))))
  av_m <- as.matrix(do.call(bdiag, alist)) * 1 / factorial(nvar - 1)

  # Get averages for group and name them
  I <- av_m %*% diffs_mean
  I_perc <- I / sum(I)

  # Total effects
  Tot <- gofs[2:(nvar+1)]

  # Complete df with I and J
  df_compl <- data.frame(I = I, Total = Tot)
  df_compl$J <- with(df_compl, Total - I)
  df_compl <- df_compl[, c("I", "J", "Total")]
  row.names(df_compl) <- names(indep)

  # Percentages
  df_perc <- as.data.frame(apply(df_compl[, -3], MARGIN = 2,
                                 FUN = function(x) return(x / sum(x) * 100)))

  return(list(actual = df_compl, perc = df_perc))
}

#' Get differences of GOF's for a given combination of covariate numbers
#'
#' @keywords internal
perm_diff <- function(perm, names, gofs) {
  ## Construct names of gof models
  p1 <- list()
  for (i in 1:length(perm))
    p1[[i]] <- perm[1:i]
  pdiff <- lapply(p1, function(x) return(x[-1]))
  pdiff[[1]] <- 0

  # Sort both lists per vector
  p1 <- lapply(p1, FUN = sort)
  pdiff <- lapply(pdiff, FUN = sort)

  # Get model names for indices
  p1 <- sapply(p1, FUN = function(x)
    return(do.call(paste0, as.list(c("x", x)))))
  pdiff <- sapply(pdiff, FUN = function(x)
    return(do.call(paste0, as.list(c("x", x)))))

  # Get indices for the names
  p1_ind <- sapply(p1, FUN = function(x)
    return(which(x == names)))
  pdiff_ind <- sapply(pdiff, FUN = function(x)
    return(which(x == names)))
  diff <- gofs[p1_ind] - gofs[pdiff_ind]
  return(diff)
}






