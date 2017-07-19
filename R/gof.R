#' Wrapper function for gof
#'
#' @export

gof <- function(dep, indep, method = "lm", gof) {
  if (method == "lm") {
    gof_lm(dep, indep, gof)
  } else if (method == "glm") {
    gof_glm(dep, indep, gof)
  } else if (method == "gamlss") {
    gof_gamlss(dep, indep, gof)
  } else {
    stop("Method not implemented")
  }
}

#' GOF for lm's
#'
#'

gof_lm <- function(dep, indep, gof = "r.squared") {
  # Stop if goodness of fit not implemented
  available_gofs <- c("AIC", "r.squared", "loglik", "deviance")
  if (!gof %in% available_gofs)
    stop("Goodness of Fit not implemented")

  ## -- Model fitting -- ##
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





