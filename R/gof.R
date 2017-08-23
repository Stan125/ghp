#' Wrapper function for gof
#'
#' @export

gof <- function(depname, data, method = "lm", gof, npar = 1, group_df = NULL) {
  # Stop if goodness of fit not implemented
  if (method == "lm") {
    available_gofs <- c("AIC", "r.squared", "loglik", "deviance")
  } else if (method == "gamlss") {
    available_gofs <- c("AIC", "deviance")
  }
  if (!gof %in% available_gofs)
    stop("Goodness of Fit not implemented")

  # Stop if method not implemented
  available_methods <- c("lm", "gamlss")
  if (!method %in% available_methods)
    stop("Method not implemented")

  ## Selecting dep and indep of data
  data <- na.omit(data)
  dep <- data[, depname]

  # Transform the independent variables (Grouping happens here)
  indep <- indep_tf(depname, data, group_df)

  # Combinations
  combinations <- acc(length(indep))$combs

  # Empty model
  m0 <- model_fitter(dep, method = method, empty = TRUE)

  # Get non-empty models
  models <- model_fitter(dep, indep, combinations, method, npar)

  # Get gofs
  gofs <- gof_getter(m0, models, gof, npar)

  # Return
  attr(gofs, "gof") <- gof
  return(gofs)
}
