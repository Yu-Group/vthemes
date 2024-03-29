% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-tables.R
\name{pretty_table}
\alias{pretty_table}
\title{Create pretty tables for html and latex outputs.}
\usage{
pretty_table(
  X,
  html = knitr::is_html_output(),
  digits = 3,
  sigfig = TRUE,
  rownames = TRUE,
  caption = "",
  na_disp = "NA",
  bold_function = NULL,
  bold_margin = NULL,
  bold_scheme = TRUE,
  bold_color = NULL,
  html_options = NULL,
  latex_options = NULL,
  return_df = FALSE
)
}
\arguments{
\item{X}{Data frame or data matrix to display in table}

\item{html}{Logical indicating whether the output should be in html format.
If \code{FALSE}, output is in latex format.}

\item{digits}{Number of digits to display for numeric values}

\item{sigfig}{Logical. If \code{TRUE}, \code{digits} refers to the number of
significant figures. If \code{FALSE}, \code{digits} refers to the number of
decimal places.}

\item{rownames}{Logical. Whether or not to show rownames in table. See
\code{\link[DT:datatable]{DT::datatable()}} for details.}

\item{caption}{The table caption.}

\item{na_disp}{Character string to display if NA entry is found in table.}

\item{bold_function}{Optional function or vector of functions
to use for bolding entries, e.g. \code{function(x) x == max(x)} or
\code{function(x) x >= 0.5}.}

\item{bold_margin}{Specifies the margins of X that will be used to evaluate
\code{bold_function} across, i.e., 0 = across entire matrix, 1 = across
rows, and 2 = across columns. Required if \code{bold_function = TRUE}.}

\item{bold_scheme}{Scalar or vector of logicals, indicating whether or not
to apply \code{bold_function} to row if \code{bold_margin} = 1 and to
column if \code{bold_margin} = 1, 2. Default is to apply bolding to all
rows/columns.}

\item{bold_color}{Color of bolded text.}

\item{html_options}{List of additional named arguments to pass to
\code{pretty_DT()}.}

\item{latex_options}{List of additional named arguments to pass to
\code{pretty_kable()}.}

\item{return_df}{Logical. If \code{TRUE}, return data frame that was used
as input into \code{DT::datatable()} in addition to the datatable output.
If \code{FALSE}, only return the datatable output.}
}
\value{
A DT table in html format if \code{html = TRUE} and a kable table in
latex format if \code{html = FALSE}. In addition, if \code{return_df = TRUE}, the
data frame that was used to create the table is returned.
}
\description{
Wrapper function around \code{pretty_DT()} and
\code{ble()} that automatically chooses to return a DT table
or a kable table depending on the output type (html or latex).
Specifically, if the requested output type is "html", a pretty DT table is
returned, and if the requested output type is "latex", a pretty kable table
is returned.
}
