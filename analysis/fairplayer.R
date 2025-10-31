set.seed(123)
library(stuart)
library(lavaan)
source("R/helpers.R")
source("R/objective.R")

args_list <- list(
  data = fairplayer,
  fs = list(
    CIC = names(fairplayer)[83:92],
    CIP = names(fairplayer)[113:122],
    ISC = names(fairplayer)[83:92],
    ISP = names(fairplayer)[113:122]
  ),
  capacity = 2,
  mtmm = list(
    CI = c("CIC", "CIP"),
    ISC = "ISC",
    ISP = "ISP"
  ),
  mtmm_invariance = "configural",
  analysis_opts = list(
    estimator = "MLR",
    missing = "FIML"
  ),
  n_random = 500,
  p_top = 0.9,
  cores = 4,
  obj_info = list(
    vec = c("rmsea.robust", "srmr", "rel"),
    mat = list(
      name = c("beta", "lvcor"),
      which = list(beta = c("CIP", "CIC"), lvcor = c("ISP", "ISC")),
      side = list(beta = "top", lvcor = "bottom")
    ),
    lower_tail = c(FALSE, FALSE, TRUE, TRUE, FALSE),
    weights = c(1 / 6, 1 / 6, 1 / 3, 1 / 6, 1 / 6)
  )
)

#list2env(args_list, envir = .GlobalEnv)





combinations(
  data = fairplayer,
  factor.structure = fs,
  capacity = capacity,
  mtmm = mtmm
   )


res <- do.call(build_obj, args_list)

purrr::exec(build_obj, !!!args_list)

res$obj_fun

bf <- stuart::bruteforce(
  data = data,
  factor.structure = fs,
  capacity = capacity,
  mtmm = mtmm,
  item.invariance = "congeneric",
  mtmm.invariance = "configural",
  analysis.options = analysis_opts,
  objective = res$obj_fun,
  cores = 6
)


randomsamples(
  data = data,
  factor.structure = fs,
  capacity = capacity,
  mtmm = mtmm,
  item.invariance = "congeneric",
  mtmm.invariance = "configural",
  analysis.options = analysis_opts,
  objective = res$obj_fun,
  n = 1000,
  cores = 4
) -> rs

rs$final


semPlot::semSyntax(rs$final) -> model


#### Hypothesis 2: Measurement Invariance

# Core function to apply a regex replacement
generate_invariance <- function(model, pattern, replace) {
  model_vec <- strsplit(model, "\n")[[1]]
  model_vec <- gsub(pattern, replace, model_vec, perl = TRUE)
  paste(model_vec, collapse = "\n")
}

# List of invariance steps: pattern, replacement, and optional dependency
invariance_steps <- list(
  metric = list(
    pattern = "^((CIC|CIP)\\s*=~\\s*)(?!\\d\\*)(\\S+)",
    replace = "\\1(a)*\\3",
    pre = NULL
  ),
  scalar = list(
    pattern = "^(?!CIC|CIP|ISC|ISP)(\\S+) ~ (0\\*1|1)$",
    replace = "\\1 ~ (b)*1",
    pre = "metric"
  ),
  strict = list(
    pattern = "^(?!CIC|CIP|ISC|ISP)(\\S+)\\s*~~\\s*(\\S+)$",
    replace = "\\1 ~~ (c)*\\2",
    pre = "scalar"
  )
)

# Higher-order function to create an invariance function from a step
make_invariance_fn <- function(name, steps) {
  step <- steps[[name]]
  pre_fn <- if (!is.null(step$pre)) make_invariance_fn(step$pre, steps) else NULL
  
  function(model) {
    if (!is.null(pre_fn)) {
      model <- pre_fn(model)
    }
    generate_invariance(model, step$pattern, step$replace)
  }
}

# Create all invariance functions
metric_invariance <- make_invariance_fn("metric", invariance_steps)
scalar_invariance <- make_invariance_fn("scalar", invariance_steps)
strict_invariance <- make_invariance_fn("strict", invariance_steps)


fit_configural <- sem(model, fairplayer) 
fit_weak <- sem(metric_invariance(model), fairplayer)
fit_strong <- sem(scalar_invariance(model), fairplayer)
fit_strict <- sem(strict_invariance(model), fairplayer)

lavTestLRT(fit_configural, fit_weak, fit_strong, fit_strict)

aic <- function(fit) {
  L <- lavaan::logLik(fit)
  p <- lavaan::inspect(fit, "npar")
  -2 * L + 2 * p
}

bic <- function(fit) {
  L <- lavaan::logLik(fit)
  p <- lavaan::inspect(fit, "npar")
  n <- fit@SampleStats@ntotal
  -2 * L + log(n) * p
}

abic <- function(fit) {
  L <- lavaan::logLik(fit)
  p <- lavaan::inspect(fit, "npar")
  n <- fit@SampleStats@ntotal
  -2 * L + (log((n + 2) / 24)) * p
}

compare_inform_criteria <- function(...) {
  fits <- list(...)
  names(fits) <- as.list(substitute(list(...)))[-1L]
  comp_mat <- t(sapply(fits, fitMeasures)[c("aic", "bic", "bic2"), ])
  worse_than_prev <- comp_mat[-1, ] > comp_mat[-nrow(comp_mat), ]
  delta <- comp_mat[-1, ] - comp_mat[-nrow(comp_mat), ]
  agreement <- apply(worse_than_prev, 1, function(x) all(x) | all(!x))
  comp_df <- as.data.frame(comp_mat)
  comp_df$model <- rownames(comp_mat)
  rownames(comp_df) <- NULL
  colnames(comp_df) <- c("model", "aic", "bic", "abic")
  comp_df <- comp_df[, c("model", "aic", "bic", "abic")]
  out <- list(
    comparison = comp_df,
    worse_than_previous = worse_than_prev,
    delta = delta,
    all_agree = agreement
  )
  return(out)
}

compare_inform_criteria(fit_configural, fit_weak, fit_strong, fit_strict)

test_measurement_invariance <- function(model, data) {
  fit_configural <- sem(model, data) 
  fit_weak <- sem(metric_invariance(model), data)
  fit_scalar <- sem(scalar_invariance(model), data)
  fit_strict <- sem(strict_invariance(model), data)
  cli::cli_h1("Measurement Invariance Testing")
  cli::cli_alert("Step 1: Comparison of information criteria (AIC, BIC, aBIC)")
  step1 <- compare_inform_criteria(fit_configural, fit_weak, fit_scalar, fit_strict)
  if(!all(step1$all_agree)) {
    cli::cli_alert_warning("Information criteria do not all agree at each step.")
    cli::cli_alert("Step 2: Chi-square difference tests")
    step2 <- lavaan::lavTestLRT(fit_configural, fit_weak, fit_scalar, fit_strict)
  }
  cli::cli_alert_success("Measurement invariance testing complete.")
  return(list(step1 = step1, step2 = if(exists("step2")) step2 else NULL))
}

test_measurement_invariance(model, fairplayer)

#### Hypothesis 1: MVC

library(ezCutoffs)

generate_cutoffs <- function(model, data, n_cores = 4, alpha_level = .05, clinical_subscale) {
  ezc <- ezCutoffs(
    model = model, 
    data = data, 
    normality = "empirical", 
    missing_data = TRUE, 
    n_cores = n_cores,
    alpha_level = alpha_level
  )
  modelfit_cutoff <- ezc$summary[c("rmsea", "srmr"), "Cutoff (alpha = 0.05)"]
  names(modelfit_cutoff) <- c("rmsea", "srmr")
  df_cutoff <- readr::read_csv("data/processed/aseba_reliability_calc_sb.csv")
  df_cutoff <- filter(df_cutoff, scale == clinical_subscale)
  vec_cutoff <- unlist(df_cutoff[, -1])[c(1, 1, 6, 6, 7, 7)]
  names(vec_cutoff) <- c("gamma", "phi", "omega_cip", "omega_cic", "omega_isp", "omega_isc")
  cutoff <- c(modelfit_cutoff, vec_cutoff)
  return(list(cutoff = cutoff, ezcutoffs_object = ezc))
}

cuts <- generate_cutoffs(
  model = model, 
  data = fairplayer, 
  n_cores = 4, 
  alpha_level = .05, 
  clinical_subscale = "Aggressive Behavior"
)

get_actual <- function(stuartOutput) {
  last_log <- tail(na.omit(stuartOutput$log), n = 1)
  actual_vec <- last_log[, c(-c(1, 2))]
  names(actual_vec) <- c("rmsea", "srmr", "omega_cic", "omega_cip", "omega_isc", "omega_isp")
  df_param <- parameterestimates(stuartOutput$final, standardized = TRUE) 
  actual_mat <- filter(.data = df_param, 
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
    direction = c("lower", "lower", "higher", "lower", "higher", "higher", "higher", "higher")
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
      cli::cli_alert_danger("Both model fit criteria (RMSEA and SRMR) failed to meet the cutoff.")
      cli::cli_alert("Drop clinical subscale.")
      decision <- "drop_subscale"
      return(list(results = df_results, decision = decision))
    }
  } else if (!results_vec["rmsea"]) {
    cli::cli_alert_warning("RMSEA failed to meet the cutoff, but SRMR met the cutoff.")
    cli::cli_alert("Model likely overparametrized. Checking gamma and phi.")
  } 

  if (!results_vec["phi"]) {
    cli::cli_alert_danger("Latent correlation (phi) between ISC and ISP is too low.")
    cli::cli_alert("Consider dropping the informant-specific component.")
    decision <- "drop_is"
  } 
  
  if (!results_vec["gamma"]) {

    cli::cli_alert_warning("Regression coefficient (gamma) between CIP and CIC is too low.")
    cli::cli_alert("Consider dropping the cross-informant component.")
    decision <- if (decision == "drop_is") "drop_subscale" else "drop_ci"
  }

    omega_ci <- results_vec[c("omega_cic", "omega_cip")]
    omega_is <- results_vec[c("omega_isc", "omega_isp")]
    
    if (any(!omega_ci) & any(!omega_is)) {
      cli::cli_alert_danger("Reliabilities for both the cross-informant components (CIC, CIP) and the informant-specific components (ISC, ISP) are below the cutoff.")
      cli::cli_alert("Drop clinical subscale.")
      decision <- "drop_subscale"
    } else if (any(!omega_ci)) {
      cli::cli_alert_danger("One or more of the reliabilities for the cross-informant components (CIC, CIP) is below the cutoff.")
      cli::cli_alert("Consider dropping the cross-informant component.")
      decision <- if(decision == "drop_is") "drop_subscale" else "drop_ci"
    } else if (any(!omega_is)) {
      cli::cli_alert_danger("One or more of the reliabilities for the informant-specific components (ISC, ISP) is below the cutoff.")
      which_fails <- names(omega_is[which(!omega_is)])
      switch(which_fails, 
        omega_isc = cli::cli_alert("Consider dropping the ISC component."), 
        omega_isp = cli::cli_alert("Consider dropping the ISP component.")
      )
      if(which_fails == "omega_isc") {
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



evaluate_mvc(actual, cutoff) 


#### Hypothesis 3


rs$final |> summary()
