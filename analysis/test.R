pacman::p_load(dplyr, tidyr, tinytable)

objfun_param <- readRDS("data/processed/objective_function_param.rds")

objfun_param |>
  mutate(across(c(mean, sd), function(x) sprintf("%.2f", round(x, 2)))) |>
  mutate(stat = sprintf("%s (%s)", mean, sd)) |>
  select(subscale_id, criteria, stat) |>
  pivot_wider(names_from = criteria, values_from = stat) |>
  tt(escape = FALSE) -> tab

print(tab)

