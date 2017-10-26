#' Data Transformer
#'
#' Step One: Transforms the independent variables so it can be further used in
#' \code{\link{mfit}}.
#'
#' The existence of this function is based on the ability to provide groups for
#' partitioning in \code{\link{ghp}}. If there were no groups given, this
#' function essentially converts the dataframe to a list with one element per
#' explanatory variable, then puts it into another list and attaches some useful
#' information.
#'
#' @param depname The name of the dependent variable in character form, e.g.
#'   \code{"depvar"}.
#' @param data A data.frame holding all relevant explanatory variables.
#' @param group_df A data.frame object for grouping. One column, \code{varnames}
#'   depicts the explanatory variables in character form. The other one, called
#'   \code{groups} depicts the group each variable belongs to, with the
#'   dependent variable being in the group \code{0}. See the examples section
#'   for an example.
#' @return A list with two elements: \enumerate{ \item \strong{dep}: A vector
#'   with the dependent variable. \item \strong{indep}: A list with either one
#'   vector per variable (ungrouped) as elements, or one data.frame with all
#'   variables belonging to one group as elements. }
#' @examples
#' # Ungrouped
#' indep_tf("Species", iris)
#'
#' # Grouped
#' groupings <- data.frame(varnames = colnames(iris), groups = c("Sepal", "Sepal", "Petal", "Petal", "0"))
#' indep_tf("Species", iris, group_df = groupings)
#' @export

indep_tf <- function(depname, data, group_df = NULL) {
  # Omit NA's
  data <- na.omit(data)

  if (is.null(group_df)) {
    indep <- as.list(data[, !grepl(depname, colnames(data))])
    return(list(dep = data[[depname]], indep = indep))
  } else if (!is.null(group_df)) {
    # Make all columns of groups characters
    group_df <- as.data.frame(apply(group_df, MARGIN = 2, FUN = as.character),
                              stringsAsFactors = FALSE)

    # Obtain unique groups w/o dependent variable
    unique_groups <- as.character(unique(group_df$groups)[unique(group_df$groups) != "0"])

    # Make list with groups as elements
    indep_list <- list()
    for (i in 1:length(unique_groups))
      indep_list[[i]] <- data[, group_df[group_df$groups == unique_groups[i], 1]]

    names(indep_list) <- unique_groups

    return(list(dep = data[[depname]], indep = indep_list))
  }
}
