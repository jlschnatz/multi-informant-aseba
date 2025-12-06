#### Hypothesis 1: MVC

#library(ezCutoffs)
generate_cutoffs <- function(
  x,
  cores = 4,
  alpha_level = .05,
  data_cutoff,
  scale_id
) {
  model <- suppressMessages(semPlot::semSyntax(x$final))
  data <- as.data.frame(lavaan::lavInspect(x$final, "data"))
  ezc <- ezCutoffs::ezCutoffs(
    model = model,
    data = data,
    normality = "empirical",
    fit_indices = c("rmsea", "srmr"),
    n_rep = 100,
    missing_data = TRUE,
    n_cores = cores,
    alpha_level = alpha_level
  )

  modelfit_cutoff <- ezc$summary[c("rmsea", "srmr"), "Cutoff (alpha = 0.05)"]
  names(modelfit_cutoff) <- c("rmsea", "srmr")
  df_cutoff <- subset(data_cutoff, id == scale_id)
  df_cutoff
  vec_cutoff <- with(df_cutoff, c(agreement, rep(alpha_star, times = 2)))
  names(vec_cutoff) <- c(
    "gamma",
    "phi",
    "omega_cip",
    "omega_cic",
    "omega_isp",
    "omega_isc"
  )
  cutoff <- c(modelfit_cutoff, vec_cutoff)
  return(list(cutoff = cutoff, ezcutoffs_object = ezc))
}


#cuts <- generate_cutoffs(
#  x = rs,
#  cores = 4,
#  alpha_level = .05,
#  clinical_subscale = "Aggressive Behavior"
#)

get_actual <- function(stuartOutput) {
  last_log <- tail(na.omit(stuartOutput$log), n = 1)
  actual_vec <- last_log[, c(-c(1, 2))]
  names(actual_vec) <- c(
    "rmsea",
    "srmr",
    "omega_cic",
    "omega_cip",
    "omega_isc",
    "omega_isp"
  )
  df_param <- parameterestimates(stuartOutput$final, standardized = TRUE)
  actual_mat <- filter(
    .data = df_param,
    (lhs == "CIP" & op == "~" & rhs == "CIC") |
      (lhs == "ISC" & op == "~~" & rhs == "ISP")
  )$std.all
  names(actual_mat) <- c("gamma", "phi")
  actual <- c(unlist(actual_vec), actual_mat)
  return(actual)
}

evaluate_mvc <- function(actual, cutoff) {
  df_results <- tibble(
    criterion = names(cutoff),
    direction = c(
      "lower",
      "lower",
      "higher",
      "lower",
      "higher",
      "higher",
      "higher",
      "higher"
    )
  ) |>
    mutate(
      actual = actual,
      cutoff = cutoff,
      meets = ifelse(direction == "higher", actual > cutoff, actual < cutoff)
    )

  results_vec <- df_results |>
    select(criterion, meets) |>
    tidyr::pivot_wider(names_from = criterion, values_from = meets) |>
    unlist()

  # Initial decision based on model fit criteria
  decision <- "proceed"

  # Check model fit criteria first
  if (!results_vec["srmr"]) {
    if (!results_vec["rmsea"]) {
      cli::cli_alert_danger(
        "Both model fit criteria (RMSEA and SRMR) failed to meet the cutoff."
      )
      cli::cli_alert("Drop clinical subscale.")
      decision <- "drop_subscale"
      return(list(results = df_results, decision = decision))
    }
  } else if (!results_vec["rmsea"]) {
    cli::cli_alert_warning(
      "RMSEA failed to meet the cutoff, but SRMR met the cutoff."
    )
    cli::cli_alert("Model likely overparametrized. Checking gamma and phi.")
  }

  if (!results_vec["phi"]) {
    cli::cli_alert_danger(
      "Latent correlation (phi) between ISC and ISP is too low."
    )
    cli::cli_alert("Consider dropping the informant-specific component.")
    decision <- "drop_is"
  }

  if (!results_vec["gamma"]) {
    cli::cli_alert_warning(
      "Regression coefficient (gamma) between CIP and CIC is too low."
    )
    cli::cli_alert("Consider dropping the cross-informant component.")
    decision <- if (decision == "drop_is") "drop_subscale" else "drop_ci"
  }

  omega_ci <- results_vec[c("omega_cic", "omega_cip")]
  omega_is <- results_vec[c("omega_isc", "omega_isp")]

  if (any(!omega_ci) & any(!omega_is)) {
    cli::cli_alert_danger(
      "Reliabilities for both the cross-informant components (CIC, CIP) and the informant-specific components (ISC, ISP) are below the cutoff."
    )
    cli::cli_alert("Drop clinical subscale.")
    decision <- "drop_subscale"
  } else if (any(!omega_ci)) {
    cli::cli_alert_danger(
      "One or more of the reliabilities for the cross-informant components (CIC, CIP) is below the cutoff."
    )
    cli::cli_alert("Consider dropping the cross-informant component.")
    decision <- if (decision == "drop_is") "drop_subscale" else "drop_ci"
  } else if (any(!omega_is)) {
    cli::cli_alert_danger(
      "One or more of the reliabilities for the informant-specific components (ISC, ISP) is below the cutoff."
    )
    which_fails <- names(omega_is[which(!omega_is)])
    switch(
      which_fails,
      omega_isc = cli::cli_alert("Consider dropping the ISC component."),
      omega_isp = cli::cli_alert("Consider dropping the ISP component.")
    )
    if (which_fails == "omega_isc") {
      decision <- "drop_isc"
    } else {
      decision <- "drop_isp"
    }
    return(list(results = df_results, decision = decision))
  } else {
    cli::cli_alert_success("All reliability criteria met.")
    return(list(results = df_results, decision = decision))
  }
}
