#' A modern ggplot theme
#'
#' @param base_family Base font family.
#' @param size_preset One of "small", "medium", "large", "xlarge", or
#'   "{some number of x's}large" indicating the default sizes for plot text and
#'   titles. If \code{NULL}, defaults to values specified explicitly by
#'   \code{axis_title_size}, \code{axis_text_size}, \code{legend_title_size},
#'   \code{legend_text_size}, \code{strip_text_size}, \code{title_size}.
#' @param bg_color Color for plot background.
#' @param strip_bg_color Color for strip background (for
#'   \code{ggplot2::facet_grid()} and \code{ggplot2::facet_wrap()}).
#' @param grid_color Color of panel grid major axes or \code{NULL} if want no
#'   major grid lines.
#' @param axis_line_width Width of x and y axes lines.
#' @param show_ticks Logical; whether or not to show axes tick marks.
#' @param x_text_angle Logical; whether or not to angle x text at 45 degrees.
#' @param axis_title_size Font size of axis title. Ignored if \code{size_theme}
#'   not \code{NULL}.
#' @param axis_text_size Font size of axis text. Ignored if \code{size_theme}
#'   not \code{NULL}.
#' @param legend_title_size Font size of legend title. Ignored if
#'   \code{size_theme} not \code{NULL}.
#' @param legend_text_size Font size of legend text/key. Ignored if
#'   \code{size_theme} not \code{NULL}.
#' @param strip_text_size Font size of strip text. Ignored if \code{size_theme}
#'   not \code{NULL}.
#' @param title_size Font size of plot title. Ignored if \code{size_theme}
#'   not \code{NULL}.
#' @param ... Additional arguments to pass to \code{ggplot2::theme()}
#'
#' @return A \code{ggplot2::theme()} object.
#'
#' @examples
#' require(ggplot2)
#' ggplot(iris) +
#'   aes(x = Sepal.Length, y = Sepal.Width) +
#'   geom_point() +
#'   theme_vmodern()
#'
#' @export
theme_vmodern <- function(base_family = "",
                          size_preset = NULL,
                          bg_color = "grey98",
                          strip_bg_color = "#2c3e50",
                          grid_color = "grey90",
                          axis_line_width = 1,
                          show_ticks = TRUE,
                          x_text_angle = FALSE,
                          axis_title_size = 10, axis_text_size = 7,
                          legend_title_size = 10, legend_text_size = 8,
                          strip_text_size = 9, title_size = 12,
                          ...) {

  if (!is.null(size_preset)) {
    if (!(size_preset %in% c("small", "medium", "large")) &&
        !(stringr::str_detect(size_preset, ".*large$") &&
          identical(
            unique(
              strsplit(stringr::str_replace(size_preset, "large$", ""), "")[[1]]
            ),
            "x"
          ))) {
      stop("Unknown size_preset. size_preset must be one of 'small', 'medium', ",
           "'large', 'xlarge', 'xxlarge', or '{some number of x's}large'.")
    }
    num_x <- stringr::str_count(size_preset, "x")
    axis_title_size <- dplyr::case_when(
      size_preset == "small" ~ 10,
      size_preset == "medium" ~ 14,
      TRUE ~ 18 + num_x * 2
    )
    axis_text_size <- dplyr::case_when(
      size_preset == "small" ~ 7,
      size_preset == "medium" ~ 10,
      TRUE ~ 14 + num_x * 2
    )
    legend_title_size <- axis_title_size
    legend_text_size <- dplyr::case_when(
      size_preset == "small" ~ 8,
      size_preset == "medium" ~ 10,
      TRUE ~ 14 + num_x * 2
    )
    strip_text_size <- dplyr::case_when(
      size_preset == "small" ~ 9,
      size_preset == "medium" ~ 12,
      TRUE ~ 16 + num_x * 2
    )
    title_size <- dplyr::case_when(
      size_preset == "small" ~ 12,
      size_preset == "medium" ~ 16,
      TRUE ~ 20 + num_x * 2
    )
  }

  thm <- ggplot2::theme_grey(base_family = base_family) +
    ggplot2::theme(
      axis.title = ggplot2::element_text(size = axis_title_size, face = "bold"),
      axis.text = ggplot2::element_text(size = axis_text_size),
      axis.line = ggplot2::element_line(size = axis_line_width, color = "black"),
      axis.ticks = ggplot2::element_line(
        size = ifelse(show_ticks, ggplot2::rel(1), 0), colour = "black"
      ),
      axis.text.x = ggplot2::element_text(
        angle = ifelse(x_text_angle, 45, 0),
        hjust = ifelse(x_text_angle, 1, 0.5)
      ),
      panel.grid.major = ggplot2::element_line(
        colour = grid_color, size = ggplot2::rel(0.5)
      ),
      panel.grid.minor = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = bg_color),
      strip.background = ggplot2::element_rect(
        fill = strip_bg_color, color = strip_bg_color
      ),
      strip.text = ggplot2::element_text(
        size = strip_text_size, color = "white", face = "bold"
      ),
      legend.key = ggplot2::element_rect(fill = "grey98"),
      legend.text = ggplot2::element_text(size = legend_text_size),
      legend.title = ggplot2::element_text(
        size = legend_title_size, face = "bold"
      ),
      plot.title = ggplot2::element_text(size = title_size, face = "bold")
    ) +
    ggplot2::theme(...)

  return(thm)
}


#' Blank axis themes for ggplot.
#'
#' @description Removes text and formatting from x and/or y-axes.
#'
#' @return A ggplot theme object.
#'
#' @examples
#' require(ggplot2)
#'
#' # blank x-axis theme
#' ggplot(iris) +
#'   aes(x = Sepal.Length, fill = Species) +
#'   geom_density() +
#'   theme_blank_x()
#'
#' # blank y-axis theme
#' ggplot(iris) +
#'   aes(x = Sepal.Length, fill = Species) +
#'   geom_density() +
#'   theme_blank_y()
#'
#' # blank x- and y-axes theme
#' ggplot(iris) +
#'   aes(x = Sepal.Length, fill = Species) +
#'   geom_density() +
#'   theme_blank_xy()
#'
#' @name theme_blank
#' @rdname theme_blank
#'
NULL


#' @rdname theme_blank
#'
#' @export
theme_blank_x <- function() {
  ggplot2::theme(axis.line.x = ggplot2::element_blank(),
                 axis.title.x = ggplot2::element_blank(),
                 axis.text.x = ggplot2::element_blank(),
                 axis.ticks.x = ggplot2::element_blank(),
                 panel.grid.major.x = ggplot2::element_blank())
}


#' @rdname theme_blank
#'
#' @export
theme_blank_y <- function() {
  ggplot2::theme(axis.line.y = ggplot2::element_blank(),
                 axis.title.y = ggplot2::element_blank(),
                 axis.text.y = ggplot2::element_blank(),
                 axis.ticks.y = ggplot2::element_blank(),
                 panel.grid.major.y = ggplot2::element_blank())
}


#' @rdname theme_blank
#'
#' @export
theme_blank_xy <- function() {
  ggplot2::theme(axis.line = ggplot2::element_blank(),
                 axis.title = ggplot2::element_blank(),
                 axis.text = ggplot2::element_blank(),
                 axis.ticks = ggplot2::element_blank(),
                 panel.grid.major = ggplot2::element_blank())
}





