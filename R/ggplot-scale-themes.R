#' vmodern color palette (discrete)
#'
#' @description The vmodern theme integrates a slight modification of the
#'   'Dark2' color palette from `RColorBrewer` and the `viridis` palette. The
#'   modified 'Dark2' palette is used unless the number of values exceeds 8 or
#'   if viridis is explicitly requested.
#'
#' @inheritParams viridis::viridis_pal
#' @param viridis Logical indicating whether or not to use the \code{viridis}
#'   scheme.
#'
#' @examples
#' library(scales)
#' show_col(vmodern_pal()(8))
#' show_col(vmodern_pal(viridis = TRUE)(8))
#'
#' @export
vmodern_pal <- function(viridis = FALSE, option = "plasma") {
  f <- function(n) {
    if ((n <= 8) && !viridis) {
      # color palette is a slight modification of
      # RColorBrewer::brewer.pal(n = 8, name = "Dark2")
      pal <- c("#FF9300", "#1B9E77", "#7570B3", "#E7298A",
               "#66A61E", "#E6AB02", "#A6761D", "#666666")[1:n]
    } else {
      pal <- viridisLite::viridis(n, begin = 0, end = 0.95, option = option)
    }
  }
  return(f)
}

#' vmodern color scales
#'
#' @description Modern scale functions (fill and colour/color) for `ggplot2`.
#'   For \code{discrete == FALSE}, the vmodern scale uses the `viridis` color
#'   palette. For \code{discrete == TRUE}, the vmodern color scale returns a
#'   modified version of the `RColorBrewer` 'Dark2' theme if the number of
#'   levels is <= 8. Otherwise, the discrete `viridis` color palette is used.
#'
#' @inheritParams viridis::scale_color_viridis
#' @inheritParams vmodern_pal
#' @param ... Additional arguments to pass to \code{ggplot2::discrete_scale()}
#'   if \code{discrete == TRUE} and to \code{viridis::scale_colour_viridis()}
#'   if \code{discrete == FALSE}.
#'
#' @examples
#' library(ggplot2)
#' ggplot(iris) +
#'   aes(x = Sepal.Length, y = Sepal.Width, color = Petal.Length) +
#'   geom_point() +
#'   scale_color_vmodern(discrete = FALSE)
#' ggplot(iris) +
#'   aes(x = Sepal.Length, fill = Species) +
#'   geom_density() +
#'   scale_fill_vmodern(discrete = TRUE)
#'
#' @name scale_color_vmodern
#' @rdname scale_color_vmodern
#'
NULL


#' @rdname scale_color_vmodern
#'
#' @export
scale_colour_vmodern <- function(discrete = FALSE, viridis = FALSE,
                                 option = "plasma", ...) {
  if (discrete) {
    ggplot2::discrete_scale(
      "colour", "vmodern", vmodern_pal(viridis = viridis, option = option), ...
    )
  } else {
    viridis::scale_colour_viridis(
      discrete = FALSE, option = option, begin = 0, end = 0.95, ...
    )
  }
}


#' @rdname scale_color_vmodern
#'
#' @export
scale_color_vmodern <- scale_colour_vmodern


#' @rdname scale_color_vmodern
#'
#' @export
scale_fill_vmodern <- function(discrete = FALSE, viridis = FALSE,
                               option = "plasma", ...) {
  if (discrete) {
    ggplot2::discrete_scale(
      "fill", "vmodern", vmodern_pal(viridis = viridis, option = option), ...
    )
  } else {
    viridis::scale_fill_viridis(
      discrete = FALSE, option = option, begin = 0, end = 0.95, ...
    )
  }
}

