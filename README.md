
<!-- README.md is generated from README.Rmd. Please edit that file -->
withDT
======

*withDT* features 2 functions, `withDT()` and `` %DT>%`() `` which make *data.table* syntax available for single calls without further class or attribute housekeeping.

-   `withDT()` is called to use *data.table* syntax for one call.
-   `%DT>%` is a pipe that allows to insert *data.table* calls in *magrittr* pipe chains.

Some benefits are :

-   Leverage compact *data.table* syntax, and speed to a degree
-   Clearly isolate *data.table* code to avoid confusion due to hybrid syntax
-   Be sure that no `data.table` object is created in calling environment, avoiding potential confusion
-   Keep the class of `x` (regular data frame, tibble or other), with some exceptions detailed below
-   *data.table* is not attached so there is no risk of masking functions from other packages such as *lubridate* (11 conflicting functions), *dplyr* (4 conflicting functions) or *purrr* (1 conflicting function)

We believe this package can help integrating some powerful *data.table* features in any workflow with minimal confusion.

Installation
------------

Install with:

``` r
# install.packages("devtools")
devtools::install_github("moodymudskipper/withDT")
```

Assignments by reference
------------------------

An important particularity of `withDT()` is that assignments are never done by reference. Though limiting it avoids the confusion and unintended behaviors that might come with them.

The syntax of these assignments is still supported but will return a copy. In order to fail explicitly whenever that syntax is used, the argument `lock` can be set to `TRUE` the `withDT.lock` option can be set with `options(withDT.lock = TRUE)`.

Examples
--------

### `withDT()`

``` r
library(withDT)
```

We can use standard *data.table* syntax and the output will have the same class as the input.

``` r
iris2 <- withDT(iris[, .(meanSW = mean(Sepal.Width)), by = Species][,cbind(.SD, a =3)])
iris2
#>      Species meanSW a
#> 1     setosa  3.428 3
#> 2 versicolor  2.770 3
#> 3  virginica  2.974 3
class(iris2)
#> [1] "data.frame"
```

The following also works, but wouldn't have the same output with standard *data.table* code due to the way assignments by reference are handled.

However we think in these cases the behavior of `withDT()` is more likely to be expected.

``` r
iris3 <- withDT(iris[, .(meanSW = mean(Sepal.Width)), by = Species][,a:=3])
identical(iris2,iris3)
#> [1] TRUE
```

We see that `iris` wasn't modified

``` r
class(iris)
#> [1] "data.frame"
names(iris)
#> [1] "Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width" 
#> [5] "Species"
```

To trigger an error when this syntax is used we can set `lock` to `TRUE`.

``` r
iris4 <- withDT(lock=TRUE,iris[, .(meanSW = mean(Sepal.Width)), by = Species][,b:=3])
#> Error in value[[3L]](cond): Syntax of assignment by reference is forbidden when `lock` is TRUE
```

### `%DT>%`

The `%DT>%` pipe is another way to use *data.table*'s power and syntax. It can in fact be more efficient than `withDT()`.

It can be used on simple calls :

``` r
iris %DT>% .[, .(meanSW = mean(Sepal.Width)), by = Species]
#>      Species meanSW
#> 1     setosa  3.428
#> 2 versicolor  2.770
#> 3  virginica  2.974
```

Or be used as part of a pipe chain using *magrittr* 's operator `%>%`, for example we can mix *data.table* and *tidyverse* operations by doing:

``` r
library(tibble)
library(dplyr, warn.conflicts = FALSE)
#> Warning: package 'dplyr' was built under R version 3.6.1
iris %>%
  as_tibble() %DT>%
  .[, .(meanSW = mean(Sepal.Width)), by = Species][
    ,Species := as.character(Species)] %>%
  filter(startsWith(Species,"v"))
#> # A tibble: 2 x 2
#>   Species    meanSW
#>   <chr>       <dbl>
#> 1 versicolor   2.77
#> 2 virginica    2.97
```

Some caveats
------------

-   Copies are created for every call of `[`, which might be costly in some cases, if optimization is necessary we suggest using `data.table::setDT()` followed by idiomatic *data.table* syntax
-   Attributes other than class are stripped
-   Classes `grouped_df` and `rowwise_df`, created respectively by `dplyr::group_by()` and `dplyr::rowwise()` are stripped
-   When using syntax of assignment by reference and `lock` is `FALSE` (default), some expressions won't be equivalent to the data.table code, see examples
-   At the moment `withDT()` fails in markdown unless we assign it to the global environment.

A workaround to the latter is to include the following chunk at the top of your document :

    ```{r, echo = FALSE}
    environment(withDT) <- .GlobalEnv
    ```
