
<!-- README.md is generated from README.Rmd. Please edit that file -->
withDT
======

`withDT()` is called to use *data.table* syntax for one call.

Installation
------------

Install with:

``` r
# install.packages("devtools")
devtools::install_github("moodymudskipper/withDT")
```

Assignments by reference
------------------------

An important particularity of `withDT()` is that assignments are never done by reference. Though limiting it avoids the confusion and unintended behaviors that might come with them. The syntax of these assignments is still supported but will return a copy. In order to fail explicitly whenever that syntax is used, the argument `lock` can be set to `TRUE`.

Examples
--------

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
try(iris4 <- withDT(lock=TRUE,iris[, .(meanSW = mean(Sepal.Width)), by = Species][,b:=3]))
#> Error in `[.data.table`(x, ...) : 
#>   .SD is locked. Using := in .SD's j is reserved for possible future use; a tortuously flexible way to modify by group. Use := in j directly to modify by group by reference.
```

Other benefits
--------------

-   Leverage compact *data.table* syntax, and speed to a degree
-   Clearly isolate *data.table* code to avoid confusion due to hybrid syntax
-   Be sure that no `data.table` object is created in calling environment, avoiding potential confusion
-   Keep the class of `x` (regular data frame, tibble or other), with some exceptions detailed below
-   *data.table* is not attached so there is no risk of masking functions from other packages such as *lubridate* (11 conflicting functions), *dplyr* (4 conflicting functions) or *purrr* (1 conflicting function)

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
