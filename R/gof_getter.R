#' Internal function to get GOF of all fitted models (including the intercept model)
#'
#'
#'
gof_getter <- function(m0, models, gof, npar = 1) {
  if (npar == 1) {
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
    return(gofs)
  } else if (npar == 2) {
    if (gof == "AIC") {
      gofs <- sapply(models$mu, FUN = AIC)
      gofs <- c(AIC(m0), gofs)
      # Do the same for sigma parameters
      gofs_sigma <- sapply(models$sigma, FUN = AIC)
      gofs_sigma <- c(AIC(m0), gofs_sigma)
    } else if (gof == "deviance") {
      gofs <- sapply(models$mu, FUN = deviance)
      gofs <- c(deviance(m0), gofs)
      # Do the same for sigma parameters
      gofs_sigma <- sapply(models$sigma, FUN = deviance)
      gofs_sigma <- c(deviance(m0), gofs_sigma)
    }
    return(list(mu = gofs, sigma = gofs_sigma))
  }
}
