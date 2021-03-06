% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/git.R
\name{install_gitee}
\alias{install_gitee}
\title{Attempts to install a package directly from gitee.}
\usage{
install_gitee(repo)
}
\arguments{
\item{Repository}{address in the format \verb{username/repo[/subdir][@ref|#pull]}.
Alternatively, you can specify subdir and/or ref using the respective parameters (see below);
if both is specified, the values in repo take precedence.}
}
\description{
Attempts to install a package directly from gitee.
}
\examples{
\dontrun{
install_gitee("adv-r/Ipaper")
}
}
