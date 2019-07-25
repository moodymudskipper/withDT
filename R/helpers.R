# replace data.table error message by more relevant one
by_ref_error_fun <- function(e){
  if(grepl("\\.SD is locked",e)) stop("Syntax of assignment by reference is forbidden when `lock` is TRUE")
  else stop(e)
}


# backup class while displaying relevant warning about stripped classes and attributes
backup_class <- function(x){
  class_ <- class(x)
  if("grouped_df" %in% class_){
    warning("grouped_df class and groups attribute were removed")
    class_ <- setdiff(class_, "grouped_df")
  }
  if("rowwise_df" %in% class_){
    warning("rowwise_df class was removed")
    class_ <- setdiff(class_, "rowwise_df")
  }
  class_
}

# restore class and remove ".internal.selfref" attribute, all by ref
restore_attr <- function(x, class_){
  data.table::setattr(x, "class", class_)
  data.table::setattr(x, ".internal.selfref", NULL)
}

# evaluate DT call with correct error handling
# expr should be a call object where the dot symbol is the placeholder for
# the input table
evalDT <- function(expr, dot, lock){
  . <- as.data.table(dot)
  if(lock) data.table::setattr(., ".data.table.locked", TRUE)
  res <- tryCatch(eval(expr), error = by_ref_error_fun)
  if(lock) data.table::setattr(res, ".data.table.locked", NULL)
  res
}

