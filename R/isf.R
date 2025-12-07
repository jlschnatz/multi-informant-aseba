# —— R Functions to Test Informant Specific Functioning
#' @title Evaluate Informant Specificness
#' @description Tests whether factor structure is specific to informants
#'   (child vs parent) using empirical fit indices and information criteria.
#' @param model_output A stuartOutput object
#' @param subscale_id Character scalar identifying the subscale
#' @param alpha_level Type-I error rate (default 0.05)
#' @param n_rep Number of repetitions for ezCutoffs
#' @param verbose Logical; print progress messages
#' @return A list with elements:
#'   - `fit_results`: dataframe with empirical vs cutoff fit indices and boolean
#'   - `all_fit_notmet`: TRUE if any fit index exceeds cutoff
#'   - `information_criteria`: dataframe with proposed vs comparison ICs and delta
#'   - `all_ic_worse`: TRUE if all comparison ICs are worse
#'   - `cutoff_simulation`: ezCutoffs object
test_informant_specificness <- function(
  model_output,
  subscale_id,
  alpha_level = 0.05,
  n_rep,
  verbose = FALSE
) {
  if (!inherits(model_output, "stuartOutput")) {
    cli::cli_abort(
      "Argument {.arg model_output} must be an object of class {.emph stuartOutput}"
    )
  }

  if (verbose) {
    cli::cli_h1("Testing Informant Specificness")
    cli::cli_h2("Subscale: {subscale_id}")
    cli::cli_ol()
  }

  # Extract item names for child and parent factors
  items_child <- unlist(
    model_output$subtests[c("CIC", "ISC")],
    use.names = FALSE
  )
  items_parent <- unlist(
    model_output$subtests[c("CIP", "ISP")],
    use.names = FALSE
  )

  # Create factor structure: one factor per rater (no informant-specific factor)
  factor_structure <- list(
    Parent = items_parent,
    Child = items_child
  )

  # Extract observed data
  model_data <- as.data.frame(lavaan::lavInspect(model_output$final, "data"))

  # Prepare bruteforce modeling arguments
  bf_args <- list(
    data = model_data,
    factor.structure = factor_structure,
    capacity = 4,
    analysis.options = list(
      estimator = "MLR",
      missing = "FIML"
    )
  )

  # Fit comparison model
  if (verbose) {
    cli::cli_li("Fitting comparison model...")
  }

  comparison_model <- do.call(
    function(...) quiet(stuart::bruteforce(...)),
    bf_args
  )

  # Extract model syntax
  model_syntax <- quiet(semPlot::semSyntax(comparison_model$final))

  # Generate empirical cutoffs
  if (verbose) {
    cli::cli_li("Generating cutoffs for fit indices...")
  }

  cutoff_simulation <- quiet(
    ezCutoffs::ezCutoffs(
      model = model_syntax,
      data = model_data,
      n_rep = n_rep,
      fit_indices = c("rmsea.robust", "srmr"),
      alpha_level = alpha_level,
      normality = "empirical",
      missing_data = TRUE,
      estimator = "MLR",
      missing = "FIML"
    )
  )

  # Compute 1 - alpha quantile cutoffs
  fit_cutoffs <- sapply(cutoff_simulation$fitDistributions, function(dist) {
    quantile(dist, 1 - alpha_level, names = FALSE, na.rm = TRUE)
  })

  # Empirical fit indices
  empirical_fit <- lavaan::fitMeasures(comparison_model$final)[c(
    "rmsea.robust",
    "srmr"
  )]

  # Combine results into dataframe
  fit_results <- data.frame(
    fit_measure = names(empirical_fit),
    empirical = empirical_fit,
    cutoff = fit_cutoffs
  )
  fit_results$fit_met <- with(fit_results, empirical < cutoff)
  all_fit_notmet <- !all(fit_results$fit_met)

  # Exploratory analyses: Information criteria (AIC, BIC, aBIC)
  ic_names <- c("aic", "bic", "bic2")
  information_criteria <- data.frame(
    criteria = ic_names,
    proposed = lavaan::fitMeasures(model_output$final)[ic_names],
    comparison = lavaan::fitMeasures(comparison_model$final)[ic_names]
  )
  # Rename bic2 to abic
  information_criteria$criteria <- ifelse(
    information_criteria$criteria == "bic2",
    "abic",
    information_criteria$criteria
  )
  information_criteria$delta <- information_criteria$proposed -
    information_criteria$comparison
  information_criteria$comparison_worse <- information_criteria$delta < 0
  all_ic_worse <- all(information_criteria$comparison_worse)

  # Combine outputs
  results <- list(
    fit_results = fit_results,
    all_fit_notmet = all_fit_notmet,
    information_criteria = information_criteria,
    all_ic_worse = all_ic_worse,
    cutoff_simulation = cutoff_simulation
  )

  if (verbose) {
    cli::cli_alert_success("Done!")
    cli::cli_rule()
    cli::cli_end()
  }

  return(results)
}
