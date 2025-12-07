#' @title Evaluate Minimum Viable Criteria (MVC)
#' @param model_output A stuartOutput object
#' @param n_cores The number of cores used to run ezCutoffs()
#' @param alpha_level Type-I error rate (defaults to 0.05)
#' @param n_rep The number of replications in ezCutoffs()
#' @param cutoff_reference A dataframe containing cutoffs for gamma, phi, omega
#' @param subscale_id Character scalar identifying the clinical subscale
#' @return A list containing: `criterion_table`, `criteria_met`,
#'   `all_criteria_met`, and `cutoff_simulation`
test_mvc <- function(
  model_output,
  n_cores,
  alpha_level = .05,
  n_rep = 100,
  cutoff_reference,
  subscale_id
) {
  cutoff_results <- compute_cutoffs(
    model_output = model_output,
    n_cores = n_cores,
    alpha_level = alpha_level,
    n_rep = n_rep,
    cutoff_reference = cutoff_reference,
    subscale_id = subscale_id
  )

  actual_values <- extract_actual_values(model_output)

  comparison_results <- compare_to_cutoffs(
    actual = actual_values,
    cutoffs = cutoff_results$cutoffs
  )

  comparison_results$cutoff_simulation <- cutoff_results$cutoff_simulation

  return(comparison_results)
}


#' @title Compute Cutoffs for MVC Criteria
#' @param model_output A stuartOutput object
#' @param n_cores Number of cores for ezCutoffs()
#' @param alpha_level Type-I error rate
#' @param n_rep The number of replications in ezCutoffs()
#' @param cutoff_reference Dataframe with cutoff values for gamma, phi, omega
#' @param subscale_id ID of subscale (from tar_map)
#' @return List containing `cutoffs` (named numeric vector)
#'   and `cutoff_simulation` (the ezCutoffs object)
compute_cutoffs <- function(
  model_output,
  n_cores = 4,
  alpha_level = .05,
  n_rep = 100,
  cutoff_reference,
  subscale_id
) {
  if (!inherits(model_output, "stuartOutput")) {
    cli::cli_abort(
      "Argument {.arg model_output} must be of class {.field stuartOutput}."
    )
  }

  model_syntax <- quiet(semPlot::semSyntax(model_output$final))
  model_data <- as.data.frame(lavaan::lavInspect(model_output$final, "data"))

  cutoff_simulation <- quiet(
    ezCutoffs::ezCutoffs(
      model = model_syntax,
      data = model_data,
      normality = "empirical",
      fit_indices = c("rmsea", "srmr"),
      n_rep = n_rep,
      missing_data = TRUE,
      n_cores = n_cores,
      alpha_level = alpha_level,
      missing = "FIML",
      estimator = "MLR"
    )
  )

  # RMSEA/SRMR cutoffs
  cutoffs_fit <- sapply(cutoff_simulation$fitDistributions, function(dist) {
    quantile(dist, 1 - alpha_level, names = FALSE, na.rm = TRUE)
  })

  # Gamma / Phi cutoffs
  ref_row <- subset(cutoff_reference, id == subscale_id)
  cutoffs_gamma_phi <- ref_row$agreement
  names(cutoffs_gamma_phi) <- c("gamma", "phi")

  # Omega cutoffs
  cutoffs_omega <- rep(ref_row$alpha_star, times = 2)
  names(cutoffs_omega) <- paste0("omega_", c("cip", "cic", "isp", "isc"))

  cutoffs <- c(cutoffs_gamma_phi, cutoffs_fit, cutoffs_omega)

  return(list(
    cutoffs = cutoffs,
    cutoff_simulation = cutoff_simulation
  ))
}


#' @title Extract Actual Values for MVC Criteria
#' @param model_output A stuartOutput object
#' @return Named numeric vector of actual values
extract_actual_values <- function(model_output) {
  last_log <- tail(na.omit(model_output$log), n = 1)

  actual_fit_indices <- last_log[, -c(1, 2)]
  names(actual_fit_indices) <- c(
    "rmsea",
    "srmr",
    "omega_cic",
    "omega_cip",
    "omega_isc",
    "omega_isp"
  )

  df_params <- lavaan::parameterestimates(
    model_output$final,
    standardized = TRUE
  )

  actual_relations <- subset(
    x = df_params,
    subset = (lhs == "CIP" & op == "~" & rhs == "CIC") |
      (lhs == "ISC" & op == "~~" & rhs == "ISP")
  )$std.all

  names(actual_relations) <- c("gamma", "phi")

  actual <- c(actual_relations, unlist(actual_fit_indices))

  return(actual)
}


#' @title Compare Actual Values to MVC Cutoffs
#' @param actual Named numeric vector of observed values
#' @param cutoffs Named numeric vector of cutoff thresholds
#' @return List with results table, logical vector, and boolean summary
compare_to_cutoffs <- function(actual, cutoffs) {
  criterion_table <- tibble::tibble(criterion = names(cutoffs)) |>
    dplyr::mutate(
      direction = dplyr::case_when(
        criterion %in% c("phi", "srmr", "rmsea") ~ "lower",
        criterion == "gamma" ~ "higher",
        stringr::str_starts(criterion, "omega") ~ "higher",
        TRUE ~ NA_character_
      ),
      actual = actual,
      cutoff = cutoffs,
      meets = ifelse(direction == "higher", actual > cutoff, actual < cutoff)
    )

  criteria_met <- criterion_table$meets
  names(criteria_met) <- criterion_table$criterion

  return(list(
    criterion_table = criterion_table,
    criteria_met = criteria_met,
    all_criteria_met = all(criteria_met)
  ))
}
