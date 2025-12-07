#' Fit MTMM Model (Stuart)
#'
#' Fits the model using the stuart package logic you provided.
#'
#' @param data The subsetted dataframe.
#' @param subscale_id Character scalar identifying the subscale
construct_subtest <- function(data, objective, n_cores = 4, capacity = 2) {
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

  # 4. Run Model
  do.call(
    function(...) quiet(stuart::randomsamples(...)),
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
