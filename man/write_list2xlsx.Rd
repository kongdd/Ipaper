% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/write_list2xlsx.R
\name{write_list2xlsx}
\alias{write_list2xlsx}
\title{write_list2xlsx}
\usage{
write_list2xlsx(x, file, .progress = "none", rowNames = FALSE, show = TRUE)
}
\arguments{
\item{x}{List object to be saved, \code{x} should have names and can't be NULL.}

\item{file}{xlsx file name}

\item{.progress}{name of the progress bar to use, see create_progress_bar.}

\item{rowNames}{a logical value indicating whether the row names are to
be written.}
}
\description{
base function, write list x into fileName with each list in workbook,
write shapefile dbf table into excel *.xlsx
}
