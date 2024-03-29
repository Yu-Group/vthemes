#' vmodern color palette (discrete)
#'
#' @description The vmodern theme integrates a slight modification of the
#'   'Dark2' color palette from `RColorBrewer`, the `viridis` palette, and other
#'   custom color palettes.
#'
#' @param palette Name of the color palette. Must be one of "high_contrast",
#'   "viridis", "bright_contrast", "bright_contrast2", "muted", "muted2".
#' @param viridis_option A character string indicating the color map option to
#'   use for viridis. Options are "magma" (or "A"), "inferno" (or "B"),
#'   "plasma" (or "C"), "viridis" (or "D"), "cividis" (or "E"), "rocket"
#'   (or "F"), "mako" (or "G"), "turbo" (or "H").
#'
#' @examples
#' library(scales)
#' show_col(vmodern_pal()(8))
#' show_col(vmodern_pal(palette = "viridis")(8))
#'
#' @export
vmodern_pal <- function(palette = "high_contrast", viridis_option = "plasma") {
  palette_choices <- c("high_contrast", "viridis", "bright_contrast",
                       "bright_contrast2", "muted", "muted2")
  palette <- match.arg(palette, choices = palette_choices)
  f <- function(n) {
    max_n <- dplyr::case_when(
      palette == "high_contrast" ~ 8,
      palette == "bright_contrast" ~ 4,
      palette == "bright_contrast2" ~ 5,
      palette == "muted" ~ 6,
      palette == "muted2" ~ 7,
      palette == "viridis" ~ Inf
    )
    if (n > max_n) {
      warning("Number of levels is greater than number of colors in requested palette. Using viridis color palette instead.")
    }
    if ((n <= max_n) && (palette == "high_contrast")) {
      # color palette is a slight modification of
      # RColorBrewer::brewer.pal(n = 8, name = "Dark2")
      pal <- c("#FF9300", "#1B9E77", "#7570B3", "#E7298A",
               "#66A61E", "#E6AB02", "#A6761D", "#666666")[1:n]
    } else if ((n <= max_n) && (palette == "bright_contrast")) {
      pal <- c("orange", "#71beb7", "#218a1e", "#cc3399")[1:n]
    } else if ((n <= max_n) && (palette == "bright_contrast2")) {
      pal <- c("black", "orange", "#71beb7", "#218a1e", "#cc3399")[1:n]
    } else if ((n <= max_n) && (palette == "muted")) {
      pal <- c("#ff9902", "#4a86e8", "#a64d79",
               "#6caa52", "#674ea7", "#0f459f")[1:n]
    } else if ((n <= max_n) && (palette == "muted2")) {
      pal <- c("black", "#ff9902", "#4a86e8", "#a64d79",
               "#6caa52", "#674ea7", "#0f459f")[1:n]
    } else {
      pal <- viridisLite::viridis(n, begin = 0, end = 0.95,
                                  option = viridis_option)
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
scale_colour_vmodern <- function(discrete = FALSE, palette = "high_contrast",
                                 viridis_option = "plasma", ...) {
  dots_list <- list(...)
  if (identical(dots_list, list())) {
    dots_list <- NULL
  }

  if (discrete) {
    R.utils::doCall(
      ggplot2::discrete_scale,
      args = dots_list,
      alwaysArgs = list(
        aesthetics = "colour",
        scale_name = "vmodern",
        palette = vmodern_pal(palette = palette,
                              viridis_option = viridis_option)
      )
    )
  } else {
    R.utils::doCall(
      viridis::scale_colour_viridis,
      args = dots_list,
      alwaysArgs = list(
        discrete = FALSE,
        option = viridis_option,
        begin = 0,
        end = 0.95
      )
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
scale_fill_vmodern <- function(discrete = FALSE, palette = "high_contrast",
                               viridis_option = "plasma", ...) {
  dots_list <- list(...)
  if (identical(dots_list, list())) {
    dots_list <- NULL
  }

  if (discrete) {
    R.utils::doCall(
      ggplot2::discrete_scale,
      args = dots_list,
      alwaysArgs = list(
        aesthetics = "fill",
        scale_name = "vmodern",
        palette = vmodern_pal(palette = palette,
                              viridis_option = viridis_option)
      )
    )
  } else {
    R.utils::doCall(
      viridis::scale_fill_viridis,
      args = dots_list,
      alwaysArgs = list(
        discrete = FALSE,
        option = viridis_option,
        begin = 0,
        end = 0.95
      )
    )
  }
}

