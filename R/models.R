#' Fit MTMM Model (Stuart)
#'
#' Fits the model using the stuart package logic you provided.
#'
#' @param data The subsetted dataframe.
#' @param objective A list containing the objective function details.
#' @param n_cores Number of cores to use for parallel processing.
#' @param capacity Integer scalar indicating the capacity of the subtest.
#' @param mtmm Character scalar indicating the MTMM design.
#' @param subscale_id Character scalar identifying the subscale.
#' @param analysis_opts A list of additional analysis options.
#' @param testing Logical scalar indicating whether to use random sampling (TRUE) or bruteforce (FALSE).
#' @return The fitted model object.
construct_subtest <- function(
  data,
  objective,
  n_cores = 4,
  capacity = 2,
  mtmm,
  analysis_opts,
  testing = TRUE
) {
  if (!is.data.frame(data)) {
    cli::cli_abort("Input must be a dataframe")
  }

  data <- as.data.frame(data)

  cbcl_items <- grep("^CBCL", names(data), value = TRUE)
  ysr_items <- grep("^YSR", names(data), value = TRUE)

  fs <- list(
    CIC = ysr_items,
    CIP = cbcl_items,
    ISC = ysr_items,
    ISP = cbcl_items
  )

  args <- list(
    data = data,
    factor.structure = fs,
    capacity = capacity,
    mtmm = mtmm,
    cores = n_cores,
    objective = objective$obj_fun,
    analysis.options = analysis_opts
  )

  # if testing = FALSE, use bruteforce approach (for server run)
  if (testing) {
    subtest_fn <- function(...) quiet(stuart::randomsamples(...))
    args$n <- 100
  } else {
    cli::cli_alert_info("Running bruteforce to find subtest.")
    subtest_fn <- function(...) quiet(stuart::bruteforce(...))
  }

  # Run Model
  do.call(
    subtest_fn,
    args = args
  )
}