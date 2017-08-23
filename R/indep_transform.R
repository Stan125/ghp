#' Internal: Transform the independent variables for obtaining goodness of fit
#'

indep_tf <- function(depname, data, group_df = NULL) {
  if (is.null(group_df)) {
    indep <- as.list(data[, !grepl(depname, colnames(data))])
    return(indep)
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

    return(indep_list)
  }
}
