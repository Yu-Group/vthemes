#' Create pretty kable tables with custom bolding options.
#'
#' @description Make pretty kable tables and enable easy bolding of cells in
#'   kable (across rows, columns, or the entire table).
#'
#' @param X Data frame or data matrix to display in table
#' @param digits Number of digits to display for numeric values
#' @param sigfig Logical. If \code{TRUE}, \code{digits} refers to the number of
#'   significant figures. If \code{FALSE}, \code{digits} refers to the number of
#'   decimal places.
#' @param escape Boolean; whether to escape special characters when producing
#'   HTML or LaTeX tables. When escape = FALSE, you have to make sure that
#'   special characters will not trigger syntax errors in LaTeX or HTML.
#' @param align A character vector indicating the column alignment, e.g., 'c'.
#'   For further details, see [knitr::kable()].
#' @param caption The table caption.
#' @param format One of "html" or "latex", indicating the output format.
#' @param na_disp Character string to display if NA entry is found in table.
#' @param bold_function Optional function or vector of functions
#'   to use for bolding entries, e.g. \code{function(x) x == max(x)} or
#'   \code{function(x) x >= 0.5}.
#' @param bold_margin Specifies the margins of X that will be used to evaluate
#'   \code{bold_function} across, i.e., 0 = across entire matrix, 1 = across
#'   rows, and 2 = across columns. Required if \code{bold_function = TRUE}.
#' @param bold_scheme Scalar or vector of logicals, indicating whether or not
#'   to apply \code{bold_function} to row if \code{bold_margin} = 1 and to
#'   column if \code{bold_margin} = 1, 2. Default is to apply bolding to all
#'   rows/columns.
#' @param bold_color Color of bolded text.
#' @param full_width Logical. Whether or not table should have full width. See
#'   [kableExtra::kable_styling()] for details.
#' @param position Character string determining how to position table on page;
#'   possible values inclue "left", "right", "center", "float_left",
#'   "float_right". See [kableExtra::kable_styling()] for details.
#' @param font_size A numeric input for table font size. See
#'   [kableExtra::kable_styling()] for details.
#' @param fixed_thead Logical. Whether or not table header should be fixed at
#'   top. See [kableExtra::kable_styling()] for details.
#' @param scroll Logical. If \code{TRUE}, add scroll box. Only used if
#'   \code{format = "html"}.
#' @param scroll_width A character string indicating width of the scroll box,
#'   e.g., "50px", "100%". See [kableExtra::scroll_box()] for details.
#' @param scroll_height A character string indicating height of the scroll box,
#'   e.g. "100px". See [kableExtra::scroll_box()] for details.
#' @param return_df Logical. If \code{TRUE}, return data frame that was used
#'   as input into \code{knitr::kable()} in addition to the kable output.
#'   If \code{FALSE}, only return the kable output.
#' @param ... Additional arguments to pass to [knitr::kable()].
#'
#' @returns If \code{return_df = FALSE}, returns a kable object. Otherwise,
#'   returns a list of two:
#' \describe{
#' \item{kable}{A kable object.}
#' \item{df}{A data frame that was used as input into \code{knitr::kable()}.}
#' }
#'
#' @examples
#' # Show iris data table
#' pretty_kable(iris, align = "c", caption = "Iris Data Table")
#'
#' # Bold max value of each numeric column of Iris data in red
#' pretty_kable(iris, caption = "Iris Data Table", scroll = TRUE,
#'             bold_function = function(x) x == max(x), bold_margin = 2,
#'             bold_scheme = c(TRUE, TRUE, TRUE, TRUE, FALSE),
#'             bold_color = "red")
#'
#' # Bold min value of each row in Iris data
#' pretty_kable(iris %>% dplyr::select(-Species), sigfig = TRUE,
#'             caption = "Iris Data Table", format = "latex",
#'             scroll = TRUE, na_disp = "NA",
#'             bold_function = function(x) x == min(x), bold_margin = 1,
#'             bold_scheme = TRUE, bold_color = "black")
#' @export
pretty_kable <- function(X, digits = 3, sigfig = TRUE, escape = FALSE,
                         align = "c", caption = "",
                         format = c("html", "latex"), na_disp = "NA",
                         bold_function = NULL, bold_margin = NULL,
                         bold_scheme = T, bold_color = NULL,
                         full_width = NULL, position = "center",
                         font_size = NULL, fixed_thead = F,
                         scroll = F, scroll_width = NULL, scroll_height = NULL,
                         return_df = FALSE, ...) {
  if (sigfig) {
    dig_format <- "g"
  } else {
    dig_format <- "f"
  }
  format <- match.arg(format)

  options(knitr.kable.NA = na_disp)

  # error checking
  if (!is.null(bold_function)) {
    if (is.null(bold_margin)) {
      stop("bold_margin must be specified to bold entries in table.")
    } else if (bold_margin == 0) {
      if (length(bold_scheme) == 1) {
        bold_scheme <- rep(bold_scheme, ncol(X))
      } else if (length(bold_scheme) != ncol(X)) {
        stop("bold_scheme must be a scalar or vector of length ncol(X).")
      }
      if ((length(bold_function) != 1) || !is.function(bold_function)) {
        stop("bold_function should be a function.")
      }
    } else if (bold_margin == 1) {
      if (length(bold_scheme) == 1) {
        bold_scheme <- rep(bold_scheme, nrow(X))
      } else if (length(bold_scheme) != nrow(X)) {
        stop("bold_scheme must be a scalar or vector of length nrow(X).")
      }
      if (!(length(bold_function) %in% c(1, nrow(X)))) {
        stop(
          paste0("bold_function must be a function or vector of functions ",
                 "of length ", nrow(X))
        )
      }
    } else if (bold_margin == 2) {
      if (length(bold_scheme) == 1) {
        bold_scheme <- rep(bold_scheme, ncol(X))
      } else if (length(bold_scheme) != ncol(X)) {
        stop("bold_scheme must be a scalar or vector of length ncol(X).")
      }
      if (!(length(bold_function) %in% c(1, ncol(X)))) {
        stop(
          paste0("bold_function must be a function or vector of functions ",
                 "of length ", ncol(X))
        )
      }
    } else {
      stop("bold_margin must be NULL, 0, 1, or 2.")
    }
  }

  X <- as.data.frame(X, row.names = rownames(X))

  # bold entries according to bold_function if specified
  if (is.null(bold_function)) {
    kable_df <- X

  } else {

    if (bold_margin == 0) {
      kable_df <- X
      int_cols <- sapply(X, is.integer)
    } else if (bold_margin == 1) {
      kable_df <- as.data.frame(t(X))
      int_cols <- apply(X, 1, is.integer)
    } else if (bold_margin == 2) {
      kable_df <- X
      int_cols <- sapply(X, is.integer)
    }

    kable_cols <- colnames(kable_df)
    if (bold_margin == 0) {
      cell_hlt <- bold_function(kable_df[, bold_scheme, drop = FALSE])
      cell_hlt_idx <- which(cell_hlt, arr.ind = TRUE)

      kable_df <- kable_df %>%
        dplyr::mutate(
          dplyr::across(
            tidyselect::all_of(kable_cols[bold_scheme & int_cols]),
            function(x) {
              dplyr::case_when(
                is.na(x) ~ na_disp,
                TRUE ~ kableExtra::cell_spec(x, bold = FALSE, format = format)
              )
            }
          ),
          dplyr::across(
            tidyselect::all_of(kable_cols[bold_scheme & !int_cols]),
            function(x) {
              dplyr::case_when(
                is.na(x) ~ na_disp,
                TRUE ~ kableExtra::cell_spec(
                  formatC(x, digits = digits, format = dig_format, flag = "#"),
                  bold = FALSE, format = format
                )
              )
            }
          )
        )

      for (i in 1:nrow(cell_hlt_idx)) {
        row_idx <- cell_hlt_idx[i, "row"]
        col_idx <- cell_hlt_idx[i, "col"]
        col_name <- kable_cols[bold_scheme][col_idx]
        if (int_cols[bold_scheme][col_idx]) {
          kable_df[row_idx, col_name] <- kableExtra::cell_spec(
            X[row_idx, col_name],
            color = bold_color, bold = TRUE, format = format
          )
        } else {
          kable_df[row_idx, col_name] <- kableExtra::cell_spec(
            formatC(X[row_idx, col_name], digits = digits,
                    format = dig_format, flag = "#"),
            color = bold_color, bold = TRUE, format = format
          )
        }
      }
    } else if (length(bold_function) == 1) {
      kable_df <- kable_df %>%
        dplyr::mutate(
          dplyr::across(
            tidyselect::all_of(kable_cols[bold_scheme & int_cols]),
            function(x) {
              dplyr::case_when(
                is.na(x) ~ na_disp,
                bold_function(x) ~ kableExtra::cell_spec(
                  x, color = bold_color, bold = TRUE, format = format
                ),
                TRUE ~ kableExtra::cell_spec(x, bold = FALSE, format = format)
              )
            }
          ),
          dplyr::across(
            tidyselect::all_of(kable_cols[bold_scheme & !int_cols]),
            function(x) {
              dplyr::case_when(
                is.na(x) ~ na_disp,
                bold_function(x) ~ kableExtra::cell_spec(
                  formatC(x, digits = digits, format = dig_format, flag = "#"),
                  color = bold_color, bold = TRUE, format = format
                ),
                TRUE ~ kableExtra::cell_spec(
                  formatC(x, digits = digits, format = dig_format, flag = "#"),
                  bold = FALSE, format = format
                )
              )
            }
          )
        )
    } else {
      for (j in 1:ncol(kable_df)) {
        if (bold_scheme[j]) {
          x <- kable_df[, j]
          if (int_cols[j]) {
            # for integers columns
            kable_df[, j] <- dplyr::case_when(
              is.na(x) ~ na_disp,
              bold_function(x) ~ kableExtra::cell_spec(
                x, color = bold_color, bold = TRUE, format = format
              ),
              TRUE ~ kableExtra::cell_spec(x, bold = FALSE, format = format)
            )
          } else {
            # for numeric columns
            kable_df[, j] <- dplyr::case_when(
              is.na(x) ~ na_disp,
              bold_function(x) ~ kableExtra::cell_spec(
                formatC(x, digits = digits, format = dig_format, flag = "#"),
                color = bold_color, bold = TRUE, format = format
              ),
              TRUE ~ kableExtra::cell_spec(
                formatC(x, digits = digits, format = dig_format, flag = "#"),
                bold = FALSE, format = format
              )
            )
          }
        }
      }
    }

    if (bold_margin == 1) {
      kable_df <- as.data.frame(t(kable_df))
    }
  }

  # format numeric columns
  kable_df <- kable_df %>%
    dplyr::mutate(
      dplyr::across(
        where(is.numeric) & !where(is.integer),
        function(x) {
          ifelse(
            is.na(x), na_disp,
            kableExtra::cell_spec(
              formatC(x, digits = digits, format = dig_format, flag = "#"),
              format = format
            )
          )
        }
      )
    ) %>%
    dplyr::mutate(
      dplyr::across(
        where(is.integer),
        function(x) {
          ifelse(is.na(x), na_disp, kableExtra::cell_spec(x, format = format))
        }
      )
    )
  rownames(kable_df) <- rownames(X)
  colnames(kable_df) <- colnames(X)

  # make kable
  kable_out <- knitr::kable(kable_df, align = align, booktabs = T,
                            format = format, linesep = "", caption = caption,
                            escape = escape, ...) %>%
    kableExtra::kable_styling(latex_options = c("HOLD_position", "striped"),
                              bootstrap_options = c("striped", "hover"),
                              full_width = full_width,
                              position = position,
                              font_size = font_size,
                              fixed_thead = fixed_thead)

  if (scroll & (format == "html")) {
    kable_out <- kable_out %>%
      kableExtra::scroll_box(width = scroll_width, height = scroll_height)
  }

  if (return_df) {
    return(list(kable = kable_out, df = kable_df))
  } else {
    return(kable_out)
  }
}

#' Create pretty datatable with custom bolding options.
#'
#' @param X Data frame or data matrix to display in table
#' @param digits Number of digits to display for numeric values
#' @param sigfig Logical. If \code{TRUE}, \code{digits} refers to the number of
#'   significant figures. If \code{FALSE}, \code{digits} refers to the number of
#'   decimal places.
#' @param escape Logical. Whether or not to escape HTML entities in table. See
#'   [DT::datatable()] for details.
#' @param rownames Logical. Whether or not to show rownames in table. See
#'   [DT::datatable()] for details.
#' @param caption The table caption.
#' @param na_disp Character string to display if NA entry is found in table.
#' @param bold_function Optional function or vector of functions
#'   to use for bolding entries, e.g. \code{function(x) x == max(x)} or
#'   \code{function(x) x >= 0.5}.
#' @param bold_margin Specifies the margins of X that will be used to evaluate
#'   \code{bold_function} across, i.e., 0 = across entire matrix, 1 = across
#'   rows, and 2 = across columns. Required if \code{bold_function = TRUE}.
#' @param bold_scheme Scalar or vector of logicals, indicating whether or not
#'   to apply \code{bold_function} to row if \code{bold_margin} = 1 and to
#'   column if \code{bold_margin} = 1, 2. Default is to apply bolding to all
#'   rows/columns.
#' @param bold_color Color of bolded text.
#' @param grouped_header A (named) character vector with `colspan` as values.
#'   For example, `c(" " = 1, "title" = 2)` can be used to create a new header
#'   row for a 3-column table with "title" spanning across column 2 and 3. Used
#'   to group columns.
#' @param grouped_subheader A character vector with the names of the columns
#'   below the grouped header row.
#' @param options See \code{options} argument in [DT::datatable()].
#' @param return_df Logical. If \code{TRUE}, return data frame that was used
#'   as input into \code{DT::datatable()} in addition to the datatable output.
#'   If \code{FALSE}, only return the datatable output.
#' @param ... Additional arguments to pass to [DT::datatable()].
#'
#' @returns If \code{return_df = FALSE}, returns a datatable object. Otherwise,
#'   returns a list of two:
#' \describe{
#' \item{dt}{A datatable object.}
#' \item{df}{A data frame that was used as input into \code{DT::datatable()}.}
#' }
#'
#' @examples
#' # Show iris data table
#' pretty_DT(iris, caption = "Iris Data Table")
#'
#' # Bold max value of each numeric column of Iris data in red
#' pretty_DT(iris, caption = "Iris Data Table",
#'          bold_function = function(x) x == max(x), bold_margin = 2,
#'          bold_scheme = c(TRUE, TRUE, TRUE, TRUE, FALSE), bold_color = "red")
#'
#' # Bold min value of each row in Iris data
#' pretty_DT(iris %>% dplyr::select(-Species),
#'          sigfig = TRUE, caption = "Iris Data Table",
#'          na_disp = "NA", bold_function = function(x) x == min(x),
#'          bold_margin = 1, bold_scheme = TRUE, bold_color = "black")
#'
#' # Add grouped column header
#' pretty_DT(iris[, c(5, 1:4)],
#'           rownames = FALSE,
#'           grouped_header = c(" " = 1, "Sepal" = 2, "Petal" = 2))
#' pretty_DT(iris[, c(5, 1:4)],
#'           rownames = FALSE,
#'           grouped_header = c(" " = 1, "Sepal" = 2, "Petal" = 2),
#'           grouped_subheader = c("Species", "Length", "Width", "Length", "Width"))
#' pretty_DT(iris[, c(5, 1:4)],
#'           rownames = FALSE,
#'           grouped_header = c(" " = 1, "Sepal" = 2, " " = 2),
#'           grouped_subheader = c("Species", "Length", "Width", "Petal.Length", "Petal.Width"))
#' @export
pretty_DT <- function(X, digits = 3, sigfig = T,
                      escape = F, rownames = TRUE, caption = "", na_disp = "NA",
                      bold_function = NULL, bold_margin = NULL,
                      bold_scheme = T, bold_color = NULL,
                      grouped_header = NULL, grouped_subheader = NULL,
                      options = list(), return_df = FALSE, ...) {

  if (sigfig) {
    dig_format <- "g"
  } else {
    dig_format <- "f"
  }
  format <- "html"

  if (!("columnDefs" %in% names(options))) {  # make default center alignment
    if (rownames) {
      targets <- 1:ncol(X)
    } else {
      targets <- 0:(ncol(X) - 1)
    }
    options[["columnDefs"]] <- list(list(className = "dt-center",
                                         targets = targets))
  }

  # error checking
  if (!is.null(bold_function)) {
    if (is.null(bold_margin)) {
      stop("bold_margin must be specified to bold entries in table.")
    } else if (bold_margin == 0) {
      if (length(bold_scheme) == 1) {
        bold_scheme <- rep(bold_scheme, ncol(X))
      } else if (length(bold_scheme) != ncol(X)) {
        stop("bold_scheme must be a scalar or vector of length ncol(X).")
      }
      if ((length(bold_function) != 1) || !is.function(bold_function)) {
        stop("bold_function should be a function.")
      }
    } else if (bold_margin == 1) {
      if (length(bold_scheme) == 1) {
        bold_scheme <- rep(bold_scheme, nrow(X))
      } else if (length(bold_scheme) != nrow(X)) {
        stop("bold_scheme must be a scalar or vector of length nrow(X).")
      }
      if (!(length(bold_function) %in% c(1, nrow(X)))) {
        stop(
          paste0("bold_function must be a function or vector of functions ",
                 "of length ", nrow(X))
        )
      }
    } else if (bold_margin == 2) {
      if (length(bold_scheme) == 1) {
        bold_scheme <- rep(bold_scheme, ncol(X))
      } else if (length(bold_scheme) != ncol(X)) {
        stop("bold_scheme must be a scalar or vector of length ncol(X).")
      }
      if (!(length(bold_function) %in% c(1, ncol(X)))) {
        stop(
          paste0("bold_function must be a function or vector of functions ",
                 "of length ", ncol(X))
        )
      }
    } else {
      stop("bold_margin must be NULL, 0, 1, or 2.")
    }
  }

  X <- as.data.frame(X, row.names = rownames(X))

  # bold entries according to bold_function if specified
  if (is.null(bold_function)) {
    dt_df <- X

  } else {

    if (bold_margin == 0) {
      dt_df <- X
      int_cols <- sapply(X, is.integer)
    } else if (bold_margin == 1) {
      dt_df <- as.data.frame(t(X))
      int_cols <- apply(X, 1, is.integer)
    } else if (bold_margin == 2) {
      dt_df <- X
      int_cols <- sapply(X, is.integer)
    }

    dt_cols <- colnames(dt_df)
    if (bold_margin == 0) {
      cell_hlt <- bold_function(dt_df[, bold_scheme, drop = FALSE])
      cell_hlt_idx <- which(cell_hlt, arr.ind = TRUE)

      dt_df <- dt_df %>%
        dplyr::mutate(
          dplyr::across(
            tidyselect::all_of(dt_cols[bold_scheme & int_cols]),
            function(x) {
              dplyr::case_when(
                is.na(x) ~ na_disp,
                TRUE ~ kableExtra::cell_spec(x, bold = FALSE, format = format)
              )
            }
          ),
          dplyr::across(
            tidyselect::all_of(dt_cols[bold_scheme & !int_cols]),
            function(x) {
              dplyr::case_when(
                is.na(x) ~ na_disp,
                TRUE ~ kableExtra::cell_spec(
                  formatC(x, digits = digits, format = dig_format, flag = "#"),
                  bold = FALSE, format = format
                )
              )
            }
          )
        )

      for (i in 1:nrow(cell_hlt_idx)) {
        row_idx <- cell_hlt_idx[i, "row"]
        col_idx <- cell_hlt_idx[i, "col"]
        col_name <- dt_cols[bold_scheme][col_idx]
        if (int_cols[bold_scheme][col_idx]) {
          dt_df[row_idx, col_name] <- kableExtra::cell_spec(
            X[row_idx, col_name],
            color = bold_color, bold = TRUE, format = format
          )
        } else {
          dt_df[row_idx, col_name] <- kableExtra::cell_spec(
            formatC(X[row_idx, col_name], digits = digits,
                    format = dig_format, flag = "#"),
            color = bold_color, bold = TRUE, format = format
          )
        }
      }
    } else if (length(bold_function) == 1) {
      dt_df <- dt_df %>%
        dplyr::mutate(
          dplyr::across(
            tidyselect::all_of(dt_cols[bold_scheme & int_cols]),
            function(x) {
              dplyr::case_when(
                is.na(x) ~ na_disp,
                bold_function(x) ~ kableExtra::cell_spec(
                  x, color = bold_color, bold = TRUE, format = format
                ),
                TRUE ~ kableExtra::cell_spec(x, bold = FALSE, format = format)
              )
            }
          ),
          dplyr::across(
            tidyselect::all_of(dt_cols[bold_scheme & !int_cols]),
            function(x) {
              dplyr::case_when(
                is.na(x) ~ na_disp,
                bold_function(x) ~ kableExtra::cell_spec(
                  formatC(x, digits = digits, format = dig_format, flag = "#"),
                  color = bold_color, bold = TRUE, format = format
                ),
                TRUE ~ kableExtra::cell_spec(
                  formatC(x, digits = digits, format = dig_format, flag = "#"),
                  bold = FALSE, format = format
                )
              )
            }
          )
        )
    } else {
      for (j in 1:ncol(dt_df)) {
        if (bold_scheme[j]) {
          x <- dt_df[, j]
          if (int_cols[j]) {
            # for integers columns
            dt_df[, j] <- dplyr::case_when(
              is.na(x) ~ na_disp,
              bold_function(x) ~ kableExtra::cell_spec(
                x, color = bold_color, bold = TRUE, format = format
              ),
              TRUE ~ kableExtra::cell_spec(x, bold = FALSE, format = format)
            )
          } else {
            # for numeric columns
            dt_df[, j] <- dplyr::case_when(
              is.na(x) ~ na_disp,
              bold_function(x) ~ kableExtra::cell_spec(
                formatC(x, digits = digits, format = dig_format, flag = "#"),
                color = bold_color, bold = TRUE, format = format
              ),
              TRUE ~ kableExtra::cell_spec(
                formatC(x, digits = digits, format = dig_format, flag = "#"),
                bold = FALSE, format = format
              )
            )
          }
        }
      }
    }

    if (bold_margin == 1) {
      dt_df <- as.data.frame(t(dt_df))
    }
  }

  # format numeric columns
  dt_df <- dt_df %>%
    dplyr::mutate(
      dplyr::across(
        where(is.numeric) & !where(is.integer),
        function(x) {
          ifelse(
            is.na(x), na_disp,
            kableExtra::cell_spec(
              formatC(x, digits = digits, format = dig_format, flag = "#"),
              format = "html"
            )
          )
        }
      )
    ) %>%
    dplyr::mutate(
      dplyr::across(
        where(is.integer),
        function(x) {
          ifelse(is.na(x), na_disp, kableExtra::cell_spec(x, format = "html"))
        }
      )
    )
  dt_df[is.na(dt_df)] <- na_disp
  rownames(dt_df) <- rownames(X)
  colnames(dt_df) <- colnames(X)

  # make datatable
  if (is.null(grouped_header)) {
    dt_out <- DT::datatable(dt_df, escape = escape, caption = caption,
                            rownames = rownames, options = options, ...)
  } else {
    grouped_header_expand <- rep(names(grouped_header), times = grouped_header)
    if (is.null(grouped_subheader)) {
      grouped_subheader <- colnames(X)
    }

    sketch <- htmltools::withTags(
      htmltools::tags$table(
        class = "display",
        htmltools::tags$thead(
          htmltools::tags$tr(
            purrr::pmap(
              list(grouped_header,
                   names(grouped_header),
                   1:length(grouped_header)),
              function(ghead_span, ghead_id, i) {
                if (ghead_id == " ") {
                  idx <- cumsum(grouped_header)[i]
                  lapply(
                    (idx - ghead_span + 1):idx,
                    function(x) {
                      htmltools::tags$th(rowspan = 2, grouped_subheader[x])
                    }
                  )
                } else {
                  htmltools::tags$th(
                    colspan = ghead_span, class = "th-group-header", ghead_id
                  )
                }
              }
            )
          ),
          htmltools::tags$tr(
            purrr::map(
              grouped_subheader[grouped_header_expand != " "],
              function(gsubhead) {
                htmltools::tags$th(class = "th-group-subheader", gsubhead)
              }
            )
          )
        )
      )
    )
    dt_out <- DT::datatable(dt_df, escape = escape, caption = caption,
                            rownames = rownames, options = options,
                            container = sketch, ...)
  }

  if (return_df) {
    return(list(dt = dt_out, df = dt_df))
  } else {
    return(dt_out)
  }
}

#' Create pretty tables for html and latex outputs.
#'
#' @description Wrapper function around `pretty_DT()` and
#'   `ble()` that automatically chooses to return a DT table
#'   or a kable table depending on the output type (html or latex).
#'   Specifically, if the requested output type is "html", a pretty DT table is
#'   returned, and if the requested output type is "latex", a pretty kable table
#'   is returned.
#'
#' @inheritParams pretty_DT
#' @param html Logical indicating whether the output should be in html format.
#'   If \code{FALSE}, output is in latex format.
#' @param html_options List of additional named arguments to pass to
#'   `pretty_DT()`.
#' @param latex_options List of additional named arguments to pass to
#'   `pretty_kable()`.
#'
#' @returns A DT table in html format if `html = TRUE` and a kable table in
#'   latex format if `html = FALSE`. In addition, if `return_df = TRUE`, the
#'   data frame that was used to create the table is returned.
#'
#' @export
pretty_table <- function(X, html = knitr::is_html_output(),
                        digits = 3, sigfig = TRUE,
                        rownames = TRUE, caption = "", na_disp = "NA",
                        bold_function = NULL, bold_margin = NULL,
                        bold_scheme = TRUE, bold_color = NULL,
                        html_options = NULL, latex_options = NULL,
                        return_df = FALSE) {
  if (html) {
    tab_args <- list(X = X, digits = digits, sigfig = sigfig,
                     rownames = rownames, caption = caption, na_disp = na_disp,
                     bold_function = bold_function, bold_margin = bold_margin,
                     bold_scheme = bold_scheme, bold_color = bold_color,
                     return_df = return_df)
    tab <- do.call(pretty_DT, args = c(tab_args, html_options))
  } else {
    tab_args <- list(X = X, digits = digits, sigfig = sigfig,
                     row.names = rownames, caption = caption, na_disp = na_disp,
                     bold_function = bold_function, bold_margin = bold_margin,
                     bold_scheme = bold_scheme, bold_color = bold_color,
                     return_df = return_df, format = "latex")
    tab <- do.call(pretty_kable, args = c(tab_args, latex_options))
  }
  return(tab)
}
