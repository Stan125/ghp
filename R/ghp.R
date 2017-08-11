#' Function to do hierarchical partitioning
#'
#' @export
#'

ghp <- function(dep, indep, gof = "r.squared", method = "lm", npar = 1) {
  gofs <- gof(dep, indep, method, gof, npar)
  if (npar == 1) {
    results <- part(gofs, indep)
  } else if (npar == 2 & method == "gamlss") {
    results <- list(mu = part(gofs$mu, indep),
                    sigma = part(gofs$sigma, indep))
  } else if (npar > 2) {
    stop("More than two modeled parameters currently not supported")
  } else if (npar == 2 & method != "gamlss") {
    stop("par = 2 can only be specified in combination with gamlss")
  }
  return(results)
}

#' Function to get all possible combinations for a set of covariates
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
n_combs <- function(n, r)
  return(factorial(n) / (factorial(n - r) * factorial(r)))


#' Plot ghp results
#'
#' @import ggplot2
#' @export

plot_ghp <- function(result) {
  perc <- result$perc
  plot <- ggplot(as.data.frame(perc), aes(x = row.names(perc), y = I)) +
    geom_bar(stat = "identity") +
    labs(x = "Variables", y = "%") +
    ggtitle(paste("Percentages of independent effects on", attr(result, "gof"))) +
    coord_flip() +
    theme_bw()
  return(plot)
}
