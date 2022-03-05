#' Get list of aesthetics to add to ggplot.
#'
#' @description Helper function to ignore \code{NULL} inputs when adding
#'   aesthetics to a ggplot.
#'
#' @param x_str Character string specifying the name of the data column to plot
#'   on the x-axis.
#' @param y_str Character string specifying the name of the data column to plot
#'   on the y-axis.
#' @param color_str Character string specifying the name of the data column to
#'   use for the color aesthetic.
#' @param fill_str Character string specifying the name of the data column to
#'   use for the fill aesthetic.
#' @param group_str Character string specifying the name of the data column to
#'   use for the group aesthetic.
#' @param linetype_str Character string specifying the name of the data column
#'   to use for the linetype aesthetic.
#'
#' @return A [ggplot2::aes()] object.
#'
#' @export
get_aesthetics <- function(x_str = NULL, y_str = NULL,
                           color_str = NULL, fill_str = NULL,
                           group_str = NULL, linetype_str = NULL) {
  aes_list <- list()
  if (!is.null(x_str)) {
    aes_list$x <- substitute(.data[[x_str]], list(x_str = x_str))
  }
  if (!is.null(y_str)) {
    aes_list$y <- substitute(.data[[y_str]], list(y_str = y_str))
  }
  if (!is.null(color_str)) {
    aes_list$color <- substitute(.data[[color_str]],
                                 list(color_str = color_str))
  }
  if (!is.null(fill_str)) {
    aes_list$fill <- substitute(.data[[fill_str]], list(fill_str = fill_str))
  }
  if (!is.null(linetype_str)) {
    aes_list$linetype <- substitute(as.factor(.data[[linetype_str]]),
                                    list(linetype_str = linetype_str))
  }
  if (!is.null(group_str)) {
    aes_list$group <- substitute(.data[[group_str]],
                                 list(group_str = group_str))
  }
  return(do.call(ggplot2::aes, aes_list))
}

