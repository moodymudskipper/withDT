#' Use data.table syntax for one call
#'
#' @details
#' An important particularity of `withDT()` is that assignments are never done by
#' reference. Though limiting it avoids the confusion and unintended behaviors
#' that might come with them. The syntax of these assignments is still supported
#' but will return a copy. In order to fail explicitly whenever that syntax is used, the
#' argument `lock` can be set to `TRUE`.
#'
#' Other benefits of this function are :
#' - Leverage compact *data.table* syntax, and speed to a degree
#' - Clearly isolate *data.table* code to avoid confusion due to hybrid syntax
#' - Be sure that no `data.table` object is created in calling environment, avoiding
#'   potential confusion
#' - Keep the class of `x` (regular data frame, tibble or other), with some
#'   exceptions detailed below
#'
#' Some caveats are:
#' * Copies are created for every call of `[`, which might be costly in some
#'   cases, if optimization is the goal we suggest using `data.table::setDT()`
#'   followed by idiomatic *data.table* syntax
#' * Attributes other than class are stripped
#' * Classes `grouped_df` and `rowwise_df`, created respectively
#'   by `dplyr::group_by()` and `dplyr::rowwise()` are stripped
#' * When using syntax of assignment by reference and `lock` is `FALSE` (default),
#'   some expressions won't be equivalent to the data.table code, see examples
#'   However we think in these cases the behavior of `withDT()` is more likely
#'   to be expected
#' - *data.table* is not attached so there is no risk of masking functions from
#' other packages such as *lubridate* (11 conflicting functions),
#' *dplyr* (4 conflicting functions) or *purrr* (1 conflicting function)
#'
#' @param expr an expression where `[` will forward its arguments to
#' ``data.Table:::`[.data.table` `` if `x` inherits from data.frame
#' @param lock wether to lock the intermediate data.table so syntax of assignment
#'   by reference is forbidden.
#' @import data.table
#' @export
#'
#' @examples
#' iris2 <- withDT(iris[, .(meanSW = mean(Sepal.Width)), by = Species][,cbind(.SD, a =3)])
#' iris2
#' class(iris2)
#' # can be also done as follows, which wouldn't have the same output with standard
#' # data.table code due to assignment by reference
#' iris3 <- withDT(iris[, .(meanSW = mean(Sepal.Width)), by = Species][,a:=3])
#' identical(iris2,iris3)
#' # iris wasn't modified
#' class(iris)
#' names(iris)
#' # but wouldn't work with lock == TRUE
#' try(iris4 <- withDT(lock=TRUE,iris[, .(meanSW = mean(Sepal.Width)), by = Species][,b:=3]))
withDT <- function(expr, lock = getOption("withDT.lock")){
  eval(substitute(expr), list(`[` = get("dt_bracket", asNamespace("withDT"))))
}

dt_bracket <- function(x, ...) {
  if(data.table::is.data.table(x) || !inherits(x, "data.frame")) {
    # if x is a data.table OR nor a data frame it should be executed normally
    x[...]
  } else {
    class_ <- backup_class(x)
    res <- evalDT(substitute(.[...]), dot = x, lock = get("lock",parent.frame()))
    restore_attr(res, class_)
    res
  }
}
