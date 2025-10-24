#' Compute DFI cutoffs using ezCutoffs package
#' @param lavfit A lavaan model object
#' @param data A data frame used to fit the lavaan model
#' @param n_rep Number of replications for ezCutoffs
#' @param alpha Significance level for cutoff computation
#' @param filename Optional filename to save the output RDS file
#' @param seed Random seed for reproducibility
#' @return A list containing the ezCutoffs object and the computed cutoffs 
#' 
get_dfi <- function(lavfit, data, n_rep, alpha, filename = NULL, seed) {
  set.seed(seed)
  model <- semPlot::semSyntax(lavfit)
  ezc <- ezCutoffs::ezCutoffs(
    model = model,
    data = data,
    n_rep = n_rep,
    fit_indices = c("rmsea", "srmr"),
    normality = "empirical", 
    alpha_level = alpha
  )
  cutoff <- ezc$summary[, ncol(ezc$summary)]
  names(cutoff) <- rownames(ezc$summary)
  out <- list(ezc_obj = ezc, cutoff = cutoff)
  if (!is.null(filename)) saveRDS(out, file = filename)
  return(out)
}


