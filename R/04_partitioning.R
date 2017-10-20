#' Step Four: Do hierarchical partitioning
#'
#' @importFrom tibble add_column
#' @export

part <- function(gofs_list) {
  # Stop if gofs do not have class "goodfit"
  if (class(gofs_list) != "goodfit")
    stop("Please use as_goodfit() to convert your gof's to goodfit class")

  # Partiton for first param
  part_mu <- part_core(gofs_list$gofs$mu, gofs_list$expl_names,
                       gofs_list$model_ids)
  part_mu <- add_column(part_mu, param = "mu", .after = 1)

  # If available partition for second param
  if (gofs_list$npar == 2) {
    part_sigma <- part_core(gofs_list$gofs$sigma, gofs_list$expl_names,
                            gofs_list$model_ids)
    part_sigma <- add_column(part_sigma, param = "sigma", .after = 1)
  }

  # Assemble results dataframe
  if (gofs_list$npar == 1)
    results <- part_mu
  if (gofs_list$npar == 2)
    results <- rbind(part_mu, part_sigma)

  # Assemble part class
  part <- list(results = results, npar = gofs_list$npar,
               method = gofs_list$method, gof = gofs_list$gof)
  class(part) <- "part"

  # Return the class object
  return(part)
}

#' Core function of part(). Does the partitioning.
#'
#' @importFrom combinat permn
#' @importFrom tibble tibble
#' @import Matrix
#' @keywords internal

part_core <- function(gofs_vector, expl_names, model_ids) {
  # How many variables/groups?
  nvar <- length(expl_names)

  # Get all permutations and sort them
  perms <- permn(nvar)
  firsts <- sapply(perms, FUN = function(x) return(x[1]))
  sort_order <- sort(firsts, index.return = TRUE)$ix
  perms <- perms[sort_order]

  # Differences for each permutation and each modeled parameter
  diffs <- lapply(perms, FUN = function(x)
    return(perm_diff(x, model_ids, gofs_vector)))

  # Get mean per grouping
  diffs_mean <- sapply(diffs, mean)

  # Make averaging matrices
  alist <- lapply(vector("list", nvar), FUN = function(x)
    return(as.matrix(t(rep(1, factorial(nvar - 1))))))
  av_m <- as.matrix(do.call(bdiag, alist)) * 1 / factorial(nvar - 1)

  # Get averages for group
  I <- as.numeric(av_m %*% diffs_mean)

  # Get joint effects
  Tot <- gofs_vector[2:(nvar+1)]
  J <- Tot - I

  # Create and return tibble
  tib <- tibble(var = expl_names, indep_effects = I,
                joint_effects = J, total_effects = Tot,
                indep_perc = I / sum(I), joint_perc = J / sum(J))

  return(tib)
}

#' Get differences of GOF's for a given combination of covariate numbers
#'
#' @keywords internal
perm_diff <- function(perm, model_ids, gofs_vector) {
  ## Construct names of gof models
  p1 <- lapply(1:length(perm), FUN = function(x)
    return(perm[1:x]))
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
    return(which(x == model_ids)))
  pdiff_ind <- sapply(pdiff, FUN = function(x)
    return(which(x == model_ids)))
  diff <- gofs_vector[p1_ind] - gofs_vector[pdiff_ind]
  return(diff)
}
