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

  if (gof == "r.squared") {
    gofs <- sapply(models, FUN = function(x) return(summary(x)$r.squared))
    gofs <- c(summary(m0)$r.squared, gofs) # plus empty model
  } else if (gof == "AIC") {
    gofs <- sapply(models, FUN = function(x) return(AIC(x)))
    gofs <- c(AIC(m0), gofs) # plus empty model
  } else if (gof == "loglik") {
    gofs <- sapply(models, FUN = function(x) return(logLik(x)))
    gofs <- c(logLik(m0), gofs) # plus empty model
  } else if (gof == "deviance") {
    gofs <- sapply(models, FUN = function(x) return(deviance(x)))
    gofs <- c(deviance(m0), gofs) # plus empty model
  }

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

  if (gof == "AIC") {
    gofs <- sapply(models_mu, FUN = AIC)
    gofs <- c(AIC(m0), gofs)
    # Do the same for sigma parameters
    if (npar == 2) {
      gofs_sigma <- sapply(models_sigma, FUN = AIC)
      gofs_sigma <- c(AIC(m0), gofs_sigma)
    }
  } else if (gof == "deviance") {
    gofs <- sapply(models_mu, FUN = deviance)
    gofs <- c(deviance(m0), gofs)
    if (npar == 2) {
      gofs_sigma <- sapply(models_sigma, FUN = deviance)
      gofs_sigma <- c(deviance(m0), gofs_sigma)
    }
  }

  # What to return?
  if (npar == 1) {
    attr(gofs, "gof") <- gof
    return(gofs)
  }
  if (npar == 2) {
    attr(gofs, "gof") <- gof
    attr(gofs_sigma, "gof") <- gof
    return(list(mu = gofs, sigma = gofs_sigma))
  }
}

