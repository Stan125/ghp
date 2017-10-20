#' Step Three: Obtain Goodness of Fit Figures for a set of computed models
#'
#' @param mfits A list with four components:
#'   models: A list with one or two elements. Each element has all possible model fits
#'   in it. Each element represents one distributional parameter
#'   modelids: A character vector with model id's corresponding to the models
#'   in the models element
#'   expl_names: expl_names
#'   npar: Number of parameters
#'   method: One of "lm", "gamlss".
#' @param gof Goodness of fit which should be obtained for all models. Which is available
#'   depends on the method with which the models were computed. Currently:
#'   "AIC", "r.squared", "loglik", "deviance" for "lm" method and "AIC", "deviance" for
#'   "gamlss" method.
#' @return A gof object (type list), which has the following structure
#' @export

gof <- function(mfits, gof) {
  # Obtain gofs
  if (mfits$method == "lm")
    gofs <- gof_lm(mfits, gof)
  if (mfits$method == "gamlss")
    gofs <- gof_gamlss(mfits, gof)

  # Assemble gof list
  gofs_list <- list(gofs = gofs, model_ids = mfits$model_ids,
                    expl_names = mfits$expl_names, npar = mfits$npar,
                    method = mfits$method, gof = gof)

  # Make GOF class
  class(gofs_list) <- "goodfit"

  # Return it
  return(gofs_list)
}

#' Internal: Get GOF's for models computed with "lm" method
#'
#' @keywords internal

gof_lm <- function(mfits, gof) {
  # Stop if goodness of fit not implemented
  available_gofs <- c("AIC", "r.squared", "loglik", "deviance")
  if (!gof %in% available_gofs)
    stop("Goodness of Fit not implemented")

  # Get gofs for mu parameter
  gofs_mu <- gof_getter(mfits$models$mu, gof)

  # Return gofs
  return(list(mu = gofs_mu))
}

#' Internal: Get GOF's for models computed with "gamlss" method
#'
#' @keywords internal

gof_gamlss <- function(mfits, gof) {
  # Stop if goodness of fit not implemented
  available_gofs <- c("AIC", "deviance")
  if (!gof %in% available_gofs)
    stop("Goodness of Fit not implemented")

  # Get gofs for mu parameter
  gofs_mu <- gof_getter(mfits$models$mu, gof)

  # Get GOF's for sigma parameter
  if (mfits$npar == 2)
    gofs_sigma <- gof_getter(mfits$models$sigma, gof)

  # Return list depending on npar
  if (mfits$npar == 1)
    return(list(mu = gofs_mu))
  if (mfits$npar == 2)
    return(list(mu = gofs_mu, sigma = gofs_sigma))
}

#' Function to obtain specific GOF for all given models
#'
#' @keywords internal

gof_getter <- function(models, gof) {
  if (gof == "r.squared")
    gofs <- sapply(models, FUN = function(x) return(summary(x)$r.squared))
  if (gof == "AIC")
    gofs <- sapply(models, FUN = function(x) return(AIC(x)))
  if (gof == "loglik")
    gofs <- sapply(models, FUN = function(x) return(logLik(x)))
  if (gof == "deviance")
    gofs <- sapply(models, FUN = function(x) return(deviance(x)))
  return(gofs)
}
