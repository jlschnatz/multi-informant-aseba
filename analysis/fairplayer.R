set.seed(123)
pacman::p_load(stuart, lavaan)
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

list2env(args_list, envir = .GlobalEnv)




combinations(
  data = fairplayer,
  factor.structure = fs,
  capacity = capacity,
  mtmm = mtmm
   )


res <- do.call(build_obj, args_list)

randomsamples(
  data = data,
  factor.structure = fs,
  capacity = capacity,
  mtmm = mtmm,
  mtmm.invariance = "weak",
  analysis.options = analysis_opts,
  objective = res$obj_fun,
  n = 1000,
  cores = 4
) -> rs


semPlot::semPaths(
  rs$final,
  whatLabels = "est",
  layout = "tree", 
  intercepts = F, 
  thresholds = F,
  rotation = 1,
  residuals = T,
  #whatLabels = "est",
  style = "openMx",
  sizeLat = 9,
  sizeLat2 = 6,
  sizeMan = 6,
  sizeMan2 = 4,
  latents = c("ISC", "CIC", "ISP", "CIP"),
  reorder = TRUE,
  #curvature = -4,
  color = list(man = "white")
  ) 

lavaanExtra::nice_fit(rs$final)


library(dynamic)



library(dplyr)
id_excl <- fairplayer[, unique(unlist(fs))] |>
  naniar::miss_case_summary() |>
  filter(pct_miss > 50) |>
  pull(case)

fp <- fairplayer |>
  filter(!row_number()  %in% id_excl) |>
  select(unique(unlist(fs)))

dynamic::DDDFI(
  model = rs$final,
   data = fairplayer,
   estimator = "MLR",
   plot.dfi = TRUE,
   plot.dist = TRUE,
   plot.discrepancy = TRUE,
   scale = "normal",
   MAD = c(0.038, 0.05, 0.1),
   reps = 500
   ) -> dyn


library(ezCutoffs)

dyn


semPlot::semSyntax(rs$final) -> model

ezc <- ezCutoffs(
  model = model, 
  data = fairplayer, 
  normality = "empirical", 
  missing_data = TRUE, 
  ncores = 4
  )

dyn$plot.dfi
dyn$cutoffs 
print(dyn)
print(ezc)

summary(ezc)
plot(ezc)

naniar::miss_case_summary(fairplayer[, unique(unlist(fs))]) |> View()

