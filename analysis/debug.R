# debug mvc_training_SP (which failed to evaluate)
library(targets)

dplyr::filter(tar_meta(fields = "error", complete_only = TRUE), name == "mvc_training_SP")$error

tar_load(subtest_solution_SP)
subtest_solution <- subtest_solution_SP
tar_load(training_subset_SP)
training_subset <- training_subset_SP
tar_load(model_parameters)
tar_load(objective_function_SP)
objective_function <- objective_function_SP
tar_load(cutoff_reference)
subscale_id <- "SP"

tar_load_globals()
# _target.R line 264-276:

test_mvc(
  model_output = subtest_solution,
  data = training_subset,
  mtmm = model_parameters$mtmm,
  capacity = model_parameters$capacity,
  objective = objective_function,
  n_cores = model_parameters$n_cores,
  alpha_level = model_parameters$alpha_level,
  n_rep = 1000,
  cutoff_reference = cutoff_reference,
  subscale_id = subscale_id
)
