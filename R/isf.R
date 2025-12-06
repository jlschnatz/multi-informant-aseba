# —— R Functions to Test Informant Specific Functioning

test_informant_specificness <- function(
  x,
  scale_id,
  alpha = .05,
  n_rep,
  verbose = FALSE
) {
  if (!inherits(x, "stuartOutput")) {
    cli::cli_abort(
      "Argument {.arg x} must be an object of class {.emph stuartOutput}"
    )
  }

  if (verbose) {
    cli::cli_h1("Testing Informant Specificness")
    cli::cli_h2("Subscale: {scale_id}")
    cli::cli_ol()
  }
  # extract item names for child and parent factor
  child <- unlist(x$subtests[c("CIC", "ISC")], use.names = FALSE)
  parent <- unlist(x$subtests[c("CIP", "ISP")], use.names = FALSE)

  # create factor structure such only one factor per rater (no informant specific factor)
  fs <- list(
    P = parent,
    C = child
  )
  # extract data from lavaan fit
  dat <- as.data.frame(lavaan::lavInspect(x$final, "data"))

  # modeling args
  bf_list <- list(
    data = dat,
    factor.structure = fs,
    capacity = 4,
    analysis.options = list(
      estimator = "MLR",
      missing = "FIML"
    )
  )

  # fit model
  if (verbose) {
    cli::cli_li("Fitting comparison model...")
  }
  stuart_bf <- do.call(
    function(...) quiet(stuart::bruteforce(...)),
    bf_list
  )

  # extract model syntax
  model_syntax <- quiet(semPlot::semSyntax(stuart_bf$final))

  # run ezCutoffs to generate to create empirically based fit indices cutoffs
  if (verbose) {
    cli::cli_li("Generating cutoffs for fit indices...")
  }
  ezc <- quiet(ezCutoffs::ezCutoffs(
    model = model_syntax,
    data = dat,
    n_rep = n_rep,
    fit_indices = c("rmsea.robust", "srmr"),
    alpha_level = alpha,
    normality = "empirical",
    missing_data = TRUE,
    estimator = "MLR",
    missing = "FIML"
  ))

  # cutoffs computed via 1 - alpha quantile
  cutoffs <- sapply(ezc$fitDistributions, function(x) {
    quantile(x, 1 - alpha, names = FALSE)
  })

  # empirical fit indices for RMSEA and SRMR
  empirical <- lavaan::fitMeasures(stuart_bf$final)[c("rmsea.robust", "srmr")]

  # combine results into dataframe
  df_fit <- data.frame(cutoffs, empirical)
  df_fit$fitmeasure <- rownames(df_fit)
  df_fit <- df_fit[, c("fitmeasure", "empirical", "cutoffs")]
  rownames(df_fit) <- NULL
  df_fit$fit_met <- with(df_fit, empirical < cutoffs)
  all_notmet <- !all(df_fit$fit_met)

  ## Exploratory Analyses: Using Information Criteria (AIC, BIC, aBIC)

  inform_criteria <- c("aic", "bic", "bic2")

  # combine into dataframe
  df_ic <- data.frame(
    criteria = inform_criteria,
    proposed = lavaan::fitMeasures(x$final)[inform_criteria],
    comparison = lavaan::fitMeasures(stuart_bf$final)[inform_criteria]
  )

  rownames(df_ic) <- NULL
  df_ic$criteria <- with(df_ic, ifelse(criteria == "bic2", "abic", criteria))
  df_ic$delta_pc <- with(df_ic, proposed - comparison)
  df_ic$comparison_worse <- with(df_ic, delta_pc < 0)

  out <- list(
    df_fit = df_fit,
    all_fit_notmet = all_notmet,
    df_ic = df_ic,
    all_ic_worse = all(df_ic$comparison_worse),
    ezc = ezc
  )

  if (verbose) {
    cli::cli_alert_success("Done!")
    cli::cli_rule()
    cli::cli_end()
  }
  return(out)
}
