#' @title Wrapper Function to Build Objective Function
#' @description This function prepares the objective matrices,
#' creates a fixed objective function,
#' generates empirical means and standard deviations,
#' and constructs the final objective function.
#' @param data The dataset to be used.
#' @param fs A list defining the factor structure.
#' @param capacity The capacity for the factor structure.
#' @param mtmm A list defining the MTMM structure.
#' @param mtmm_invariance The type of MTMM invariance to be used.
#' @param analysis_opts A list of options for the analysis.
#' @param n_random The number of random samples to be generated for empirical
#' means and standard deviations for the objective function.
#' @param p_top The percentile threshold for filtering the top values
#' for the objective function.
#' @param cores The number of cores to be used for parallel processing.
#' @param obj_info A list containing information about the objective function,
#' including vector and matrix criteria, lower tail settings, and weights.
#' @return A list containing the objective function,
#' empirical means and standard deviations, and the objective matrices.
#'
build_obj <- function(
  data,
  fs,
  capacity,
  mtmm,
  mtmm_invariance,
  analysis_opts,
  n_random,
  p_top,
  cores,
  obj_info
) {
  t1 <- proc.time()

  obj_mat <- make_mats(
    data,
    fs,
    capacity,
    mtmm,
    mtmm_invariance,
    obj_info
  )

  fo <- make_fixed(obj_info, obj_mat)

  msd_df <- get_empirical(
    data,
    fs,
    capacity,
    mtmm,
    mtmm_invariance,
    obj_info,
    cores,
    fo,
    analysis_opts,
    n_random,
    obj_mat,
    p_top
  )

  objective <- make_obj_fn(msd_df, obj_mat = obj_mat)
  t2 <- proc.time()
  out <- list(
    obj_fun = objective,
    obj_dat = msd_df,
    obj_mat = obj_mat,
    timer = t2 - t1
  )
  return(out)
}

#' @title Create Objective Matrices
#' @description Prepares the objective matrices
#' based on the factor structure and MTMM.
#' @param data The dataset to be used.
#' @param fs A list defining the factor structure.
#' @param capacity The capacity for the factor structure.
#' @param mtmm A list defining the MTMM structure.
#' @param mtmm_invariance The type of MTMM invariance to be used.
#' @param obj_info A list containing information about the
#' objective function matrices.
#' @return A list of objective matrices prepared for the analysis.
make_mats <- function(
  data,
  fs,
  capacity,
  mtmm,
  mtmm_invariance,
  obj_info
) {
  if (all(obj_info$mat$name %in% c("lambda", "theta", "psi", "alpha"))) {
    cli::cli_abort("The provided criteria for matrices are not supported.")
  }
  cli::cli_alert_info("Preparing objective matrices for the analysis.")

  # Define objective matrices
  mats_list <- list(
    data = data,
    factor.structure = fs,
    capacity = capacity,
    mtmm = mtmm,
    mtmm.invariance = mtmm_invariance,
    ignore.errors = TRUE,
    matrices = obj_info$mat$name
  )

  obj_mat <- suppressMessages(do.call(stuart::objectivematrices, mats_list))

  # Set the use and side for each matrix based on criteria
  for (m in obj_info$mat$name) {
    mat_ind <- matrix(obj_info$mat$which[[m]], nrow = 1)
    obj_mat[[m]]$use[,] <- FALSE
    obj_mat[[m]]$use[mat_ind] <- TRUE
    obj_mat[[m]]$side[mat_ind] <- obj_info$mat$side[[m]]
  }

  cli::cli_alert_success("Objective matrices prepared successfully.")
  return(obj_mat)
}

#' @title Create Fixed Objective Function
#' @description Creates a fixed objective function based on
#' the provided criteria.
#' @param obj_info A list containing information about the objective function.
#' @param obj_mat A list of objective matrices.
#' @return A fixed objective function that returns zero.
make_fixed <- function(obj_info, obj_mat) {
  # Create a fixed objective function based on the criteria
  obj_fn <- function() {}
  formals(obj_fn) <- sapply(
    X = obj_info$vec,
    FUN = function(x) setNames(alist(x = ), NULL)
  )
  body(obj_fn) <- bquote(return(0))
  environment(obj_fn) <- parent.frame()

  # Create fixed objective
  fo <- stuart::fixedobjective(
    criteria = NULL,
    add = NULL,
    matrices = obj_mat,
    fixed = obj_fn
  )
  return(fo)
}

#' @title Generate Empirical Means and Standard Deviations
#' @description Generates empirical means and standard deviations
#' for the criteria based on random samples.
#' @param data The dataset to be used.
#' @param fs A list defining the factor structure.
#' @param capacity The capacity for the factor structure.
#' @param mtmm A list defining the MTMM structure.
#' @param mtmm_invariance The type of MTMM invariance to be used.
#' @param obj_info A list containing information about the objective function.
#' @param cores The number of cores to be used for parallel processing.
#' @param objective The objective function to be used.
#' @param n_random The number of random samples to be generated for
#' empirical means and standard deviations.
#' @param obj_mat A list of objective matrices.
#' @return A data frame containing the empirical means
#' and standard deviations for the criteria.
get_empirical <- function(
  data,
  fs,
  capacity,
  mtmm,
  mtmm_invariance,
  obj_info,
  cores,
  objective,
  analysis_opts,
  n_random,
  obj_mat,
  p_top
) {
  cli::cli_alert_info(
    "Generating empirical means and standard deviations for the criteria drawn from {n_random} random samples."
  ) # nolint

  rs_list <- list(
    data = data,
    factor.structure = fs,
    capacity = capacity,
    mtmm = mtmm,
    mtmm.invariance = mtmm_invariance,
    objective = objective,
    analysis.options = analysis_opts,
    cores = cores,
    n = n_random
  )

  invisible(
    utils::capture.output({
      rs <- suppressMessages(do.call(stuart::randomsamples, rs_list))
    })
  )

  #invisible(utils::capture.output({
  #  rs <- suppressMessages(stuart::randomsamples(
  #    data = data,
  #    factor.structure = fs,
  #    capacity = capacity,
  #    mtmm = mtmm,
  #    mtmm.invariance = mtmm_invariance,
  #    objective = objective,
  #    analysis.options = analysis_opts,
  #    cores = cores,
  #    n = n_random
  #  ))
  #}))

  # Extract Results for Vector Criteria
  obj_nms <- obj_info$vec
  obj_ind <- match(obj_nms, colnames(rs$log))

  if ("rel" %in% obj_nms) {
    s <- seq(min(obj_ind), max(obj_ind) + length(names(fs)) - 1)
    rel_nms <- paste0("rel", seq_len(length(names(fs))))
    subs <- rs$log[, s]
    names(subs) <- c(obj_nms[-length(obj_nms)], rel_nms)
    rel <- list(rel = rowMeans(subs[, rel_nms]))
    subs <- cbind(subs[, -which(names(subs) %in% rel_nms)], rel)
  } else {
    s <- seq(min(obj_ind), max(obj_ind))
    subs <- rs$log[, s]
    names(subs) <- obj_nms
  }

  # Summarise M, SD for Vector Criteria
  msd1 <- lapply(subs, function(x) get_m_sd(top_frac(x, p = p_top))) # nolint

  # Extract Results for Matrix Criteria
  par_pos <- sapply(obj_mat, function(x) which(x$use))
  l <- rep(list(vector("numeric", n_random)), length(par_pos))
  names(l) <- names(par_pos)
  for (i in names(par_pos)) {
    for (j in seq_len(n_random)) {
      l[[i]][j] <- rs$log_mat[[i]][[j]][par_pos[i]]
    }
  }

  # Summarise M, SD for Matrix Criteria
  msd2 <- lapply(l, function(x) get_m_sd(top_frac(x, p = p_top))) # nolint

  # Combine Results
  msd <- append(msd1, msd2)
  msd_df <- as.data.frame(t(as.data.frame(msd)))
  msd_df$criteria <- rownames(msd_df)
  rownames(msd_df) <- NULL
  msd_df$lower_tail <- obj_info$lower_tail
  msd_df$weights <- obj_info$weights
  allowed <- c("theta", "psi", "alpha", "beta", "lambda", "lvcor") # nolint
  msd_df$type <- with(msd_df, ifelse(criteria %in% allowed, "mat", "vec"))
  cli::cli_alert_success(
    "Empirical means and standard deviations generated successfully."
  ) # nolint
  return(msd_df)
}

#' @title Create Criterion Function
#' @description Creates a criterion function based on the
#' provided criteria, weights, means, standard deviations,
#' and lower tail settings.
#' @param criteria The name of the criteria to be used.
#' @param weight The weight assigned to the criteria.
#' @param mean The mean value for the criteria.
#' @param sd The standard deviation for the criteria.
#' @param lower_tail A logical value indicating whether to use
#' the lower tail of the normal distribution.
#' @param type The type of criteria
#' (either "vec" for vector or "mat" for matrix).
#' @param obj_mat A list of objective matrices
#' (required for matrix types).
#' @return A function that computes the criterion value
#' based on the provided parameters.
make_crit <- function(
  criteria,
  weight,
  mean,
  sd,
  lower_tail,
  type,
  obj_mat = NULL
) {
  q <- criteria
  if (type == "mat") {
    if (is.null(obj_mat)) {
      stop("obj_mat must be provided for matrix types.")
    }
    if (!criteria %in% names(obj_mat)) {
      stop("Criteria not found in obj_mat.")
    }
    ind <- which(obj_mat[[criteria]]$use)
    if (length(ind) > 1) {
      stop(
        "Multiple criteria from the same matrix type are currently not supported."
      ) # nolint
    }
    q <- sprintf("%s[%s]", q, ind)
  }
  if (criteria == "rel") {
    q <- sprintf("mean(%s)", q)
  }
  stri <- glue::glue(
    "function({criteria}) {{\n",
    " {weight} * pnorm({q}, {mean}, {sd}, {lower_tail})\n",
    "}}"
  )

  fn <- eval(parse(text = stri))
  return(fn)
}

#' @title Combine Criterion Functions
#' @description Combines multiple criterion functions
#' into a single function that sums their outputs.
#' @param ... The criterion functions to be combined.
#' @return A function that computes the sum of the outputs
#' of the provided criterion functions.
combine_crit <- function(...) {
  fns <- list(...)
  args <- vapply(fns, function(f) names(formals(f)), character(1))
  bodies <- lapply(X = fns, function(f) body(f)[[2]])
  combined_body <- Reduce(function(x, y) call("+", x, y), bodies)
  new_fn <- as.function(c(alist(... = ), combined_body))
  formals(new_fn) <- as.pairlist(
    setNames(replicate(length(args), quote(expr = )), args)
  )
  return(new_fn) # nolint
}

#' @title Create Objective Function
#' @description Creates an objective function based on the
#' empirical means and standard deviations of the criteria.
#' @param msd_df A data frame containing the
#' empirical means and standard deviations for the criteria.
#' @param obj_mat A list of objective matrices (optional).
#' @return A function that computes the objective value
#' based on the provided empirical means and standard deviations.
#'
make_obj_fn <- function(msd_df, obj_mat = NULL) {
  fns <- with(
    data = msd_df,
    expr = mapply(
      FUN = make_crit,
      criteria,
      weights,
      mean,
      sd,
      lower_tail,
      type,
      MoreArgs = list(obj_mat = obj_mat),
      SIMPLIFY = FALSE
    )
  )

  f <- do.call(combine_crit, fns)
  cli::cli_alert_success("Objective function created successfully.")
  return(f)
}
