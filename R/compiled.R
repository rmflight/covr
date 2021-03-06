# this does not handle LCOV_EXCL_START ect.
parse_gcov <- function(file) {
  lines <- readLines(file)
  re <- rex::rex(spaces,
    capture(name = "coverage", some_of(digit, "-", "#")),
    ":", spaces,
    capture(name = "line", digits),
    ":"
  )

  res <- rex::re_matches(lines, re)
  res$coverage[res$coverage == "-"] <- NA
  res$coverage[res$coverage == "#####"] <- 0
  res <- res[res$line > 0, ]

  values <- as.numeric(res$coverage)
  names(values) <- paste(sep = ":",
    remove_extension(file),
    res$line,
    NA,
    res$line,
    NA,
    NA,
    NA,
    NA,
    NA)

  class(values) <- "coverage"
  values
}

run_gcov <- function(file) {
  base <- basename(remove_extension(file))
  old_dir <- getwd()
  on.exit(setwd(old_dir))
  setwd(dirname(file))
  gcda <- paste0(base, ".gcda")
  gcno <- paste0(base, ".gcno")
  if (file.exists(gcno) && file.exists(gcda)) {
    system2("gcov", args = basename(file), stdout = NULL)
    parse_gcov(paste0(file, ".gcov"))
  }
}

remove_extension <- function(x) {
  rex::re_substitutes(x, rex::rex(".", except_any_of("."), end), "")
}
