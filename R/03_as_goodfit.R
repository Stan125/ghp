#' Create a goodfit object
#'
#' Takes goodness of fit figures and outputs a goodfit object for further
#' partitioning with \code{\link{part}}.
#'
#' Use this function if you have models and/or goodness of fit figures which are
#' not yet implemented in \code{ghp} but still shall be partitioned with
#' \code{\link{part}}.
#'
#' @param gofs A list with either one or two components, depending on whether
#'   two parameters (e.g. mu and sigma) have to be modeled, or just one (most
#'   cases). The first element is a vector called 'mu' holding the goodness of
#'   fit numbers as a numeric vector. If a second parameter is also modeled, the
#'   second element is called 'sigma'.
#' @param model_ids A character vector of the same length as \code{gofs$mu}. Is
#'   used for indexing the \code{gof} vectors, so it has to be in the right
#'   order compared to gofs.
#' @param expl_names A character vector with the variable or variable group
#'   names.
#' @param npar Number of parameters for which patitioning should be done.
#'   Defaults to 1. Has to have the same length as \code{gofs}
#' @param method Method from which the goodnesses of fit were extracted. Not of
#'   importance for partitioning so it defaults to \code{"unknown"}.
#' @param gof Name of the goodness of fit measure which was extracted from the
#'   model. Is used for \code{\link{plot_ghp}}.
#' @return A gof object (type list), which has the following elements:
#'   \enumerate{\item \strong{gofs}: A list with \code{npar} elements, each
#'   being a vector with the goodness of fits of the models. \item
#'   \strong{model_ids}: A character vector with id's of the models: e.g. "x0",
#'   "x1", ... \item \strong{expl_names}: Names of explanatory variables
#'   (grouped) or names of groups (grouped). \item \strong{npar} Number of
#'   modeled paramateters. Can be 1 or 2. \item \strong{method}: The method used
#'   to compute models. Can be one of "lm" or "gamlss". \item \strong{gof}: A
#'   single character depicting the goodness of fit that was extracted.}
#' @export

goodfit <- function(gofs, model_ids, expl_names, npar = 1,
                    method = "unknown", gof) {

  # Check if lengths are correct
  if (length(gofs$mu) != length(model_ids))
    stop("Lengths of model_ids and gofs vector are not equal")

  # Classes test
  if (!is.list(gofs))
    stop("Gofs have to be a list with max 2 named elements: mu (and sigma)")
  if (!is.character(model_ids) | !is.character(expl_names))
    stop("model_ids/expl_names have to be a character vector")
  if (!is.character(gof) | !is.character(method))
    stop("gof/method have to be character vectors of length 1")

  # Parameters test
  if (npar > 2 | npar < 1)
    stop("npar can only be 1 or 2")
  if (length(gofs) != npar)
    stop("npar and the length of the gof list (not the gof vectors) have to be equal")

  # Cannot have more than two different gofs
  if (length(gofs) > 2)
    stop("This package cannot deal with more than two parameters")

  # If everything was ok then make list and convert to class goodfit
  gof_list <- list(gofs = gofs, model_ids = model_ids, expl_names = expl_names,
       npar = npar, gof = gof)
  class(gof_list) <- "goodfit"

  # Return it
  return(gof_list)
}
