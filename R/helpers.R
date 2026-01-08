#' @title Top percentile of a numeric vector
#' @description Returns the values in the vector that are above the p-th quantile.
#' @param x A numeric vector.
#' @param p A numeric value between 0 and 1 indicating the percentile to consider.
#' @return A numeric vector containing the values that are above the p-th quantile.
top_frac <- function(x, p = 0.95) {
    x <- unclass(na.omit(x))
    q <- quantile(x, probs = p)
    return(x[x >= q])
}

#' @title Get mean and standard deviation of a numeric vector
#' @description Returns the mean and standard deviation of a numeric vector
#' @param x A numeric vector.
#' @param ... Additional arguments passed to the mean and sd functions.
#' @return A named numeric vector containing the mean and standard deviation.
get_m_sd <- function(x, ...) {
    c(mean = mean(x, ...), sd = sd(x, ...))
}

#' @title Spearman-Brown correction
#' @description Computes the Spearman-Brown correction for a given correlation and number of items.
#' @param r A numeric value representing the correlation.
#' @param n1 The original number of items.
#' @param n2 The new number of items.
#' @return A numeric value representing the corrected correlation.
spearman_brown <- function(r, n1, n2) {
    n <- n2 / n1
    rstar <- (n * r) / (1 + (n - 1) * r)
    return(rstar)
}

# Source - https://stackoverflow.com/a
# Posted by Ben
# Retrieved 2025-12-05, License - CC BY-SA 4.0
#' @title Suppress output, messages, and warnings
#' @description Evaluates an expression while suppressing all output, messages, and warnings.
#' @param x An expression to evaluate.
#' @return The result of the evaluated expression, invisibly.
quiet <- function(x) {
    sink(tempfile())
    on.exit(sink())
    invisible(force(suppressWarnings(suppressMessages(x))))
}
