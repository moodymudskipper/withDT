.onLoad <- function(libname, pkgname) {
  op <- options()
  op.withDT <- list(
    withDT.name = "Antoine Fabri",
    withDT.desc.author = "Antoine Fabri <antoine.fabri@gmail.com> [aut, cre]",
    withDT.desc.license = "GPL-3",
    withDT.lock = FALSE)
  toset <- !(names(op.withDT) %in% names(op))
  if (any(toset)) options(op.withDT[toset])
  invisible()
}
