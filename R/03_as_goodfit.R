#' Convert a normal list to a "goodfit" object
#'
#' @export

as_goodfit <- function(list) {
  # Stop if type is not list
  if (!class(list) == "list")
    stop("Class not list.")

  # Should be of length 6
  if (length(list) != 6)
    stop("Length of object has to be 6.")

  # Should have the following names
  names_list <- c("gofs", "model_ids", "expl_names", "npar", "method",
                  "gof")
  if (!all(names(list) == names_list))
    stop("Names do not match.")

  # Cannot have more than two different gofs
  if (length(list$gofs) > 2)
    stop("This package cannot deal with more than two parameters")

  # If everything was ok then convert to class goodfit
  class(list) <- "goodfit"

  # Return it
  return(list)
}
