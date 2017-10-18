#' Internal: Function to fit all model combinations
#'
#' @keywords internal
#' @importFrom gamlss gamlss

model_fitter <- function(dep, indep = NULL, combinations = NULL, method,
                         npar = 1, empty = FALSE) {
  if (method == "lm") {
    if (empty) {
      # Fit empty model
      return(lm(dep ~ 1))
    }
    else if (!empty) {
      # Fit non-empty models
      models <- apply(combinations, MARGIN = 1, FUN = function(x)
        return(lm(dep ~ ., data = selector(indep, x[x > 0]))))
      return(models)
    }
  } else if (method == "gamlss") {
    if (empty) {
      # Fit empty model
      return(gamlss(dep ~ 1, data = NULL, trace = FALSE))
    } else if (!empty) {
      # Fit non-empty models with optional sigma modeling
      if (npar == 1) {
        models <- apply(combinations, MARGIN = 1, FUN = function(x)
          return(gamlss(dep ~ ., data = selector(indep, x[x > 0]), trace = FALSE)))
      } else if (npar == 2) {
        models <- list(
          mu = apply(combinations, MARGIN = 1, FUN = function(x)
            return(gamlss(dep ~ ., data = selector(indep, x[x > 0]), trace = FALSE))),
          sigma = apply(combinations, MARGIN = 1, FUN = function(x)
            return(gamlss(dep ~ 1, sigma.formula = ~ ., trace = FALSE,
                          data = selector(indep, x[x > 0]))))
        )
      }
      return(models)
    }
  }
}

#' Internal: Function to make a dataframe out of selected list parts
#'

selector <- function(list, selection)
  return(as.data.frame(list[selection]))
