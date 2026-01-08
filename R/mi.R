#' Fit Invariance Models
#' @param model_output An object of class `stuartOutput`
#' @param data A dataframe of the testing dats.
#' @param capacity The capacity for the factor structure.
#' @param mtmm A list specifying the MTMM structure.
#' @param mtmm_invariance A string specifying the level of invariance to be tested.
fit_mi <- function(
  model_output,
  data,
  capacity,
  mtmm,
  mtmm_invariance
) {
  #data <- as.data.frame(lavaan::lavInspect(model_output$final, "data"))
  data <- as.data.frame(data)
  fs <- model_output$subtests
  bf_list <- list(
    data = data,
    factor.structure = fs,
    capacity = capacity,
    mtmm = mtmm,
    mtmm.invariance = mtmm_invariance,
    analysis.options = list(
      estimator = "MLR",
      missing = "FIML"
    )
  )
  bf <- suppressMessages(do.call(
    stuart::bruteforce,
    bf_list
  ))

  if (is.null(bf[["final"]])) {
    cli::cli_alert_warning(
      "Model could not be fit for invariance level: {mtmm_invariance}"
    )
  }
  return(bf[["final"]])
}

#' Compare Invariance Models Using Information Criteria and LRT
#' @param model_output An object of class `stuartOutput`
#' @param data A dataframe of the testing dats.
#' @param capacity The capacity for the factor structure.
#' @param mtmm A list specifying the MTMM structure.
#' @param alpha_level The type-1 error rate
#' @param mvc_results The output of test_mvc() function
#' @param test_conditionally Logical defaults to TRUE
#' @return A list containing the fitted models, comparison table, LRT results, and overview of decisions.
test_invariance <- function(
  model_output,
  data,
  capacity,
  mtmm,
  alpha_level,
  mvc_results,
  test_conditionally = TRUE
) {
  if (isFALSE(mvc_results$all_criteria_met) & test_conditionally) {
    return(NULL)
  }
  invariance_levels <- c("configural", "weak", "strong", "strict")
  fits <- lapply(
    invariance_levels,
    function(level) {
      fit_mi(
        model_output = model_output,
        data = data,
        capacity = capacity,
        mtmm = mtmm,
        mtmm_invariance = level
      )
    }
  )
  names(fits) <- invariance_levels
  # test if any model failed to fit
  if (any(sapply(fits, is.null))) {
    id_failed <- which(sapply(fits, is.null))
    # if a model failed, remove it and all subsequent models
    fits <- fits[seq_len(min(id_failed) - 1)]
    # if it failed at the second model, return error (cannot compare)
    if (length(fits) < 2) {
      cli::cli_alert_danger(
        "At least two models must be successfully fitted for comparison."
      )
      return(NULL)
    }
  }
  comp_mat <- t(sapply(fits, lavaan::fitMeasures)[c("aic", "bic", "bic2"), ])
  worse_than_prev <- comp_mat[-1, ] > comp_mat[-nrow(comp_mat), ]
  if (is.vector(worse_than_prev)) {
    worse_than_prev <- matrix(worse_than_prev, nrow = 1)
    rownames(worse_than_prev) <- names(fits)[2]
    colnames(worse_than_prev) <- colnames(comp_mat)
  }

  delta <- comp_mat[-1, ] - comp_mat[-nrow(comp_mat), ]
  if (is.vector(delta)) {
    delta <- matrix(delta, nrow = 1)
    rownames(delta) <- names(fits)[2]
    colnames(delta) <- colnames(comp_mat)
  }
  agreement <- apply(worse_than_prev, 1, function(x) all(x) | all(!x))
  comp_df <- as.data.frame(comp_mat)
  comp_df$model <- rownames(comp_mat)
  rownames(comp_df) <- NULL
  colnames(comp_df) <- c("aic", "bic", "abic", "model")
  comp_df <- comp_df[, c("model", "aic", "bic", "abic")]
  lrt <- suppressWarnings(broom::tidy(do.call(lavaan::anova, unname(fits))))
  lrt[["term"]] <- names(fits)
  lrt <- lrt[, c("term", "df", "statistic", "Chisq.diff", "Df.diff", "p.value")]
  colnames(lrt) <- c("term", "df", "chisq", "delta_chisq", "delta_df", "p")
  which_used <- vector("character", length(agreement))
  decision <- vector("character", length(agreement))
  for (i in seq_len(length(agreement))) {
    if (!agreement[i]) {
      which_used[i] <- "lrt"
      pval <- subset(lrt, term == names(agreement)[i])$p
      if (pval < alpha_level) {
        decision[i] <- "reject"
        if (i == length(agreement)) {
          break
        }
        decision[(i + 1):length(decision)] <- NA
        which_used[(i + 1):length(which_used)] <- NA
        break
      } else {
        which_used[i] <- "lrt"
        decision[i] <- "corroborate"
      }
    } else if (all(worse_than_prev[i, ])) {
      which_used[i] <- "ic"
      decision[i] <- "reject"
      if (i == length(agreement)) {
        break
      }
      decision[(i + 1):length(decision)] <- NA
      which_used[(i + 1):length(which_used)] <- NA
      break
    } else {
      which_used[i] <- "ic"
      decision[i] <- "corroborate"
    }
  }

  overview <- tibble::tibble(
    model = names(agreement),
    which_used = which_used,
    decision = decision
  )

  out <- list(
    models = tibble::tibble(model = names(fits), fit = fits),
    comparison = tibble::as_tibble(comp_df),
    worse_than_previous = tibble::as_tibble(worse_than_prev),
    delta = tibble::as_tibble(delta),
    all_agree = agreement,
    lrt = lrt,
    overview = overview
  )

  return(out)
}
