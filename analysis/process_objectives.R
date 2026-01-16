# Process log data from the brute force solution for each clinical subscale

pacman::p_load(targets, lavaan, stuart)
tar_load(starts_with("subtest_solution"))

prepare_logs <- function(subtest_solution, subscale_id) {
  bf_log <- subtest_solution$log
  n_total <- nrow(bf_log)
  convergence_bool <- with(bf_log, !(is.na(pheromone) | pheromone == 0))
  convergence_rate <- mean(convergence_bool)
  df_log <- bf_log[convergence_bool, ]
  colnames(df_log) <- c(
    "run",
    "pheromone",
    "rmsea.robust",
    "srmr",
    "omega_cic",
    "omega_cip",
    "omega_isc",
    "omega_isp"
  )

  df_log$beta <- sapply(
    subtest_solution$log_mat$beta[convergence_bool],
    \(x) x["CIP", "CIC"]
  )

  df_log$lvcor <- sapply(
    subtest_solution$log_mat$lvcor[convergence_bool],
    \(x) x["ISP", "ISC"]
  )

  df_log$subscale_id <- subscale_id
  df_log <- df_log[, c(
    "subscale_id",
    "run",
    "pheromone",
    "rmsea.robust",
    "srmr",
    "beta",
    "lvcor",
    "omega_cic",
    "omega_cip",
    "omega_isc",
    "omega_isp"
  )]

  best <- tibble::as_tibble(df_log[which.max(df_log$pheromone), ])

  return(list(
    log = tibble::as_tibble(df_log),
    meta = tibble::tibble(
      subscale_id = subscale_id,
      convergence = convergence_rate,
      n = n_total
    ),
    best = best
  ))
}

subscale_ids <- c("AB", "AD", "AP", "RB", "SC", "SP", "TP", "WD")

comb_log <- do.call(
  rbind,
  mapply(
    FUN = function(x, y) prepare_logs(x, y)$log,
    x = mget(sort(ls(pattern = "^subtest_solution_..$"))),
    y = sort(subscale_ids),
    SIMPLIFY = FALSE
  )
)

comb_meta <- do.call(
  rbind,
  mapply(
    FUN = function(x, y) prepare_logs(x, y)$meta,
    x = mget(sort(ls(pattern = "^subtest_solution_..$"))),
    y = sort(subscale_ids),
    SIMPLIFY = FALSE
  )
)

comb_best <- do.call(
  rbind,
  mapply(
    FUN = function(x, y) prepare_logs(x, y)$best,
    x = mget(sort(ls(pattern = "^subtest_solution_..$"))),
    y = sort(subscale_ids),
    SIMPLIFY = FALSE
  )
)

saveRDS(comb_best, "data/processed/objective_criteria_best.rds")
saveRDS(comb_meta, "data/processed/objective_criteria_meta.rds")
saveRDS(comb_log, "data/processed/objective_criteria_log.rds")

