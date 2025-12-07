#' Fit MTMM Model (Stuart)
#'
#' Fits the model using the stuart package logic you provided.
#'
#' @param data The subsetted dataframe.
#' @param subscale_id Character scalar identifying the subscale
construct_subtest <- function(
  data,
  objective,
  n_cores = 4,
  capacity = 2,
  testing = TRUE
) {
  if (!is.data.frame(data)) {
    cli::cli_abort("Input must be a dataframe")
  }

  cbcl_items <- grep("^CBCL", names(data), value = TRUE)
  ysr_items <- grep("^YSR", names(data), value = TRUE)

  fs <- list(
    CIC = ysr_items,
    CIP = cbcl_items,
    ISC = ysr_items,
    ISP = cbcl_items
  )

  mtmm <- list(
    CI = c("CIC", "CIP"),
    ISC = "ISC",
    ISP = "ISP"
  )

  if (testing) {
    f <- function(...) quiet(stuart::randomsamples(...))
  } else {
    cli::cli_alert_info("Running bruteforce to find subtest.")
    f <- function(...) quiet(stuart::bruteforce(...))
  }

  # 4. Run Model
  do.call(
    f,
    args = list(
      data = data,
      factor.structure = fs,
      capacity = capacity,
      mtmm = mtmm,
      n = 100,
      cores = n_cores,
      objective = objective$obj_fun,
      analysis.options = list(estimator = "MLR", missing = "FIML")
    )
  )
}
