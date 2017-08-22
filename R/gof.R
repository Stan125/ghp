#' Wrapper function for gof
#'
#' @export

gof <- function(depname, data, method = "lm", gof, npar = 1) {
  if (method == "lm") {
    gof_lm(depname, data, gof)
  } else if (method == "glm") {
    gof_glm(depname, data, gof)
  } else if (method == "gamlss") {
    gof_gamlss(depname, data, gof, npar)
  } else {
    stop("Method not implemented")
  }
}

#' GOF for lm's
#'
#'

gof_lm <- function(depname, data, gof = "r.squared") {
  # Stop if goodness of fit not implemented
  available_gofs <- c("AIC", "r.squared", "loglik", "deviance")
  if (!gof %in% available_gofs)
    stop("Goodness of Fit not implemented")

  ## Selecting dep and indep of data
  dep <- data[, depname]
  indep <- data[, !grepl(depname, colnames(data))]

  ## -- Model fitting -- ##

  # Combinations
  combinations <- acc(ncol(indep))$combs

  # Empty model
  m0 <- lm(dep ~ 1)

  # All other models
  models <- apply(combinations, MARGIN = 1, FUN = function(x)
    return(lm(dep ~ ., data = as.data.frame(indep[, x[x > 0]]))))

  # Get gofs for all models
  gofs <- gof_getter(m0, models, gof)

  # Attach gof
  attr(gofs, "gof") <- gof
  return(gofs)
}

#' GOF for gamlss
#'
#' @importFrom gamlss gamlss

gof_gamlss <- function(depname, data, gof = "deviance", npar = 1) {
  # Stop if goodness of fit not implemented
  available_gofs <- c("AIC", "deviance")
  if (!gof %in% available_gofs)
    stop("Goodness of Fit not implemented")

  ## -- Model fitting -- ##

  ## Selecting dep and indep of data
  data <- na.omit(data)
  dep <- data[, depname]
  indep <- data[, !grepl(depname, colnames(data))]

  # Combinations
  combinations <- acc(ncol(indep))$combs

  # Empty model
  m0 <- gamlss(dep ~ 1, data = NULL, trace = FALSE)

  # Models for mu
  models_mu <- apply(combinations, MARGIN = 1, FUN = function(x)
    return(gamlss(dep ~ ., data = as.data.frame(indep[, x[x > 0]]),
                  trace = FALSE)))

  # Do the same for other parameters if npar > 1
  if (npar == 2)
    models_sigma <- apply(combinations, MARGIN = 1, FUN = function(x)
      return(gamlss(dep ~ 1, sigma.formula = ~ ., trace = FALSE,
                    data = as.data.frame(indep[, x[x > 0]]))))

  # Get gofs
  if (npar == 1)
    gofs <- gof_getter(m0, models_mu, gof)
  else if (npar == 2)
    gofs <- gof_getter(m0, list(mu = models_mu, sigma = models_sigma),
                       gof, npar)

  # What to return?
  if (npar == 1) {
    attr(gofs, "gof") <- gof
    return(gofs)
  }
  if (npar == 2) {
    attr(gofs, "gof") <- gof
    return(gofs)
  }
}

