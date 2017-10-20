#' Function to do hierarchical partitioning
#'
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
