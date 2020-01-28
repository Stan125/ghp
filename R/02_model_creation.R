#' Model fitter
#'
#' Step Two: Fits all possible model combinations with a certain method given
#' the data.
#'
#' This function is used for computing all possible models to later extract the
#' wanted goodness of fit. This function relies on \code{\link{acc}} to get
#' modelnames which are also attached in the exported list.
#'
#' @param data A list with two elements: \enumerate{ \item \strong{dep}: A
#'   vector with the dependent variable. \item \strong{indep}: A list with
#'   either one vector per variable (ungrouped) as elements, or one data.frame
#'   with all variables belonging to one group as elements. }. Best created by
#'   \code{\link{indep_tf}}.
#' @param method The method with which the models shall be computed. Can be one
#'   of \code{"lm"} (linear models) and \code{"gamlss"}.
#' @param npar Number of distributional parameters for which models should be
#'   computed. Can be one if only the expected value of the dependent variable
#'   should be modeled, or 2 if models for modeling the variance of the
#'   dependent variable should also be computed. \code{npar = 2} is only
#'   possible in combination with \code{method = "gamlss"}.
#' @param ... Additional arguments, passed on to \code{link[gamlss]{gamlss}}.
#' @export
#' @return A list with five components: \enumerate{ \item models: A list
#'   with one or two elements. Each element has all possible model fits in it.
#'   Each element represents one distributional parameter. \item modelids: A
#'   character vector with model id's corresponding to the models. in the models
#'   element \item expl_names: names of explanatory variables (ungrouped case)
#'   or group names (grouped case). \item npar: Number of parameters which are
#'   modeled. \item method: One of "lm", "gamlss". }
mfit <- function(data, method, npar = 1, ...) {
  # Give error when method not supported
  supp_meths <- c("lm", "gamlss")
  if (!method %in% supp_meths)
    stop("Supported methods: 'lm', 'gamlss'!")

  # Obtain possible model combinations
  combinations <- acc(length(data$indep))$combs

  # Use right function to compute models
  if (method == "lm")
    models <-  mfit_lm(data, combinations)
  if (method == "gamlss")
    models <- mfit_gamlss(data, npar, combinations, ...)

  # Create model comb names
  model_ids <- apply(combinations, MARGIN = 1, FUN = function(x)
    return(as.character(x[x > 0])))
  model_ids <- sapply(model_ids, FUN = function(x)
    return(do.call(paste0, as.list(c("x", x)))))
  model_ids <- c("x0", model_ids)

  # Create list to return
  mfits <- list(models = models, model_ids = model_ids,
                expl_names = names(data$indep), method = method,
                npar = npar)

  # Return list
  return(mfits)
}

#' Fit all possible model combinations for "lm" model class
#'
#' @keywords internal

mfit_lm <- function(data, combinations) {
  # Compute models
  m0 <- list(lm(data$dep ~ 1, data = NULL))
  models <- apply(combinations, MARGIN = 1, FUN = function(x)
    return(lm(data$dep ~ ., data = selector(data$indep, x[x > 0]))))

  # Return models
  return(list(mu = c(m0, models)))
}

#' Fit all possible model combinations for "gamlss" model class
#'
#' @importFrom gamlss gamlss
#' @keywords internal

mfit_gamlss <- function(data, npar, combinations, ...) {
  # Suppress warnings of algo not converging or na.omit applied to NULL
  suppressWarnings({
    # Compute models
    m0 <- list(gamlss(data$dep ~ 1,
                      data = NULL, trace = FALSE, ...)) # suppress warning that na is applied to NULL

    # Compute mu models
    models_mu <- apply(combinations, MARGIN = 1, FUN = function(x)
      return(gamlss(data$dep ~ .,
                    data = selector(data$indep, x[x > 0]),
                    trace = FALSE,
                    ...)))

    # Compute Sigma models
    if (npar == 2)
      models_sigma <- apply(combinations, MARGIN = 1, FUN = function(x)
        return(gamlss(data$dep ~ 1, sigma.formula = ~ ., trace = FALSE,
                      data = selector(data$indep, x[x > 0]),
                      ...)))
  })

  # Return models
  if (npar == 1)
    return(list(mu = c(m0, models_mu)))
  if (npar == 2)
    return(list(mu = c(m0, models_mu),
                sigma = c(m0, models_sigma)))
}
