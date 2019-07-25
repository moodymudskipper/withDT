#' Pipe a data.table one liner
#'
#' Inspired by ``magrittr::`%>%` ``, allows one to use *data.table* syntax on
#' a non *data.table* data frame and return an object of the same class as the
#' input. It is especially useful when used in a in a *magrittr* / *tidyverse*
#' pipe chain.
#'
#' Unlike with *magrittr* only the first dot is subtituted, so `.()` can still
#' be used in the call.
#'
#' `%DT>%` is more efficient than `withDT`, their use cases overlap but they
#' are different in that `%DT>%` will allow *data.table* syntax on a single
#' table while an expression fed to `withDT()` can contain several data frames
#' that we all be treated as *data.table* objects.
#'
#' @param lhs A data.frame
#' @param rhs A data.table call starting with "."
#' @export
#' @examples
#' \dontrun{
#'   library(tidyverse)
#'   iris %>%
#'     as_tibble() %DT>%
#'     .[, .(meanSW = mean(Sepal.Width)), by = Species][
#'       ,Species := as.character(Species)] %>%
#'     filter(startsWith(Species,"v"))
#' }
`%DT>%` <- function(lhs ,rhs) {
  if(!is.data.frame(lhs))
    stop("lhs must be a data frame")
  rhs <- substitute(rhs)
  # make sure call has the right format
  if(substr(deparse(rhs)[1],1,2) != ".[")
     stop("rhs should be of the form `.[i, j, ...]`")
  # backup class and check for grouped_df and rowwise_df classes
  class_ <- backup_class(lhs)
  # evaluate the call and trigger error if withDT.lock
  # is TRUE and syntax of assignment by ref is used
  res <- evalDT(expr = rhs, dot = lhs, lock = getOption("withDT.lock"))
  # set back original class and remove ".internal.selfref" attribute
  restore_attr(res, class_)
  res
}
