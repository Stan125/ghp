#' Hierarchical Partitioning
#'
#' Core function of the \code{ghp} package. Gives the ability to fit all
#' possible models and then find out what influence certain variables or groups
#' of variables have on a specified goodness of fit.
#'
#' This function computes the hierarchical partitioning in four steps:
#' \enumerate{\item Transforming the data (necessary because of the ability to
#' specify groups of variables), \code{\link{indep_tf}} \item Fitting of all
#' possible models \code{\link{mfit}} \item Obtaining the wanted goodness-of-fit
#' figures \code{\link{gof}} \item Do hierarchical partitioning
#' \code{\link{part}}} Afterwards, you can plot the results with
#' \code{\link{plot_ghp}}
#'
#' @param npar Number of distributional parameters for which hierarchical
#'   partitioning should be done.
#' @inheritParams indep_tf
#' @inheritParams mfit
#' @inheritParams gof
#' @examples
#' # Dataset
#' india <- ghp::india
#'
#' # Linear models: Partitioning of r.squared
#' results_lm <- ghp(depname = "stunting", india, method = "lm", gof = "r.squared")
#' results_lm
#'
#' # GAMLSS models: Partitioning of deviance (npar = 2)
#' results_gamlss <- ghp("stunting", india, method = "gamlss", gof = "deviance", npar = 2)
#' results_gamlss
#' @export

ghp <- function(depname, data, gof = "r.squared", method = "lm", npar = 1,
                group_df = NULL) {

  # Step One: Transform DF
  working_data <- indep_tf(depname, data, group_df)

  # Step Two: Model Creation
  mfits <- mfit(working_data, method, npar)

  # Step Three: GOF obtaining
  gofs_list <- gof(mfits, gof)

  # Step Four: Partitioning
  part <- part(gofs_list)

  # Return results
  return(part)
}
