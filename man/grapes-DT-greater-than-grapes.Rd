% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DT_pipe.R
\name{\%DT>\%}
\alias{\%DT>\%}
\title{Pipe a data.table one liner}
\usage{
lhs \%DT>\% rhs
}
\arguments{
\item{lhs}{A data.frame}

\item{rhs}{A data.table call starting with "."}
}
\description{
Inspired by \code{magrittr::`\%>\%` }, allows one to use \emph{data.table} syntax on
a non \emph{data.table} data frame and return an object of the same class as the
input. It is especially useful when used in a in a \emph{magrittr} / \emph{tidyverse}
pipe chain.
}
\details{
Unlike with \emph{magrittr} only the first dot is subtituted, so \code{.()} can still
be used in the call.

\code{\%DT>\%} is more efficient than \code{withDT}, their use cases overlap but they
are different in that \code{\%DT>\%} will allow \emph{data.table} syntax on a single
table while an expression fed to \code{withDT()} can contain several data frames
that we all be treated as \emph{data.table} objects.
}
\examples{
\dontrun{
  library(tidyverse)
  iris \%>\%
    as_tibble() \%DT>\%
    .[, .(meanSW = mean(Sepal.Width)), by = Species][
      ,Species := as.character(Species)] \%>\%
    filter(startsWith(Species,"v"))
}
}
