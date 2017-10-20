#' Plot ghp results
#'
#' @import ggplot2
#' @export

plot_ghp <- function(part) {
  # Stop if class is not part
  if (class(part) != "part")
    stop("Result has to be calculated with part()")

  plot <- ggplot(part$result, aes(x = var, y = indep_perc, fill = param)) +
    geom_bar(stat = "identity", position = position_dodge()) +
    labs(x = "Variables", y = "%") +
    ggtitle(paste("Percentages of independent effects on", part$gof)) +
    coord_flip() +
    theme_bw()

  # Return plot
  return(plot)
}
