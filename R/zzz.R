#' Base S7 class
#'
#' @keywords internal
#' @export
S7_object <- new_class(
  name = "S7_object",
  parent = NULL,
  constructor = function() {
    .Call(S7_object_)
  },
  validator = function(self) {
    if (typeof(self) != "S4") {
      "Underlying data is corrupt"
    }
  }
)
methods::setOldClass("S7_object")

#' @export
`$.S7_object` <- function(x, name) {
  if (typeof(x) %in% c("list", "environment")) {
    NextMethod()
  } else {
    msg <- sprintf(
      "Can't get S7 properties with `$`. Did you mean `%s@%s`?",
      deparse1(substitute(x)),
      name
    )
    stop(msg, call. = FALSE)
  }
}
#' @export
`$<-.S7_object` <- function(x, name, value) {
  if (typeof(x) %in% c("list", "environment")) {
    NextMethod()
  } else {
    msg <- sprintf(
      "Can't set S7 properties with `$`. Did you mean `...@%s <- %s`?",
      name,
      deparse1(substitute(value))
    )
    stop(msg, call. = FALSE)
  }
}

#' @export
`[.S7_object` <- function(x, ..., drop = TRUE) {
  check_subsettable(x)
  NextMethod()
}
#' @export
`[<-.S7_object` <- function(x, ..., value) {
  check_subsettable(x)
  NextMethod()
}

#' @export
`[[.S7_object` <- function(x, ...) {
  check_subsettable(x, allow_env = TRUE)
  NextMethod()
}
#' @export
`[[<-.S7_object` <- function(x, ..., value) {
  check_subsettable(x, allow_env = TRUE)
  NextMethod()
}

check_subsettable <- function(x, allow_env = FALSE) {
  allowed_types <- c("list", if (allow_env) "environment")
  if (!typeof(x) %in% allowed_types) {
    stop("S7 objects are not subsettable.", call. = FALSE)
  }
  invisible(TRUE)
}

S7_generic <- new_class(
  name = "S7_generic",
  properties = list(
    name = class_character,
    methods = class_environment,
    dispatch_args = class_character
  ),
  parent = class_function
)
methods::setOldClass(c("S7_generic", "function", "S7_object"))
is_generic <- function(x) inherits(x, "S7_generic")

S7_method <- new_class("S7_method",
  parent = class_function,
  properties = list(
    generic = S7_generic,
    signature = class_list
  )
)
methods::setOldClass(c("S7_method", "function", "S7_object"))


# Create generics for double dispatch base Ops
base_ops <- lapply(setNames(, group_generics()$Ops), new_generic, dispatch_args = c("x", "y"))

#' @export
Ops.S7_object <- function(e1, e2) {
  base_ops[[.Generic]](e1, e2)
}


.onAttach <- function(libname, pkgname) {
  env <- as.environment(paste0("package:", pkgname))
  env[[".conflicts.OK"]] <- TRUE
}

.onLoad <- function(...) {
  convert <<- S7_generic(convert, name = "convert", dispatch_args = c("from", "to"))

  class_numeric <<- new_union(class_integer, class_double)
  class_atomic <<- new_union(class_logical, class_numeric, class_complex, class_character, class_raw)
  class_vector <<- new_union(class_atomic, class_expression, class_list)
}
