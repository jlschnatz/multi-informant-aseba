pacman::p_load(dplyr, tidyr)
source("R/helpers.R")

rel <- read.csv("data/processed/aseba_reliability.csv")
agr <- read.csv("data/processed/aseba_ci-agreement.csv")
print(rel)

comb <- inner_join(
  agr,
  rel,
  by = c("scale")
)


# n_cbcl n_ysr alpha_cbcl alpha_ysr
capacity <- 2

comb |> 
  pivot_longer(
    cols = -c(scale, agreement),
    names_to = c(".value", "instrument"),
    names_sep = "_"
  ) |>
  mutate(alpha_star = spearman_brown(alpha, n, capacity)) |>
  pivot_wider(
    names_from = instrument,
    values_from = c(n, alpha, alpha_star)
  ) |>
  mutate(across(
    starts_with("alpha"),
    ~ round(.x, 3)
  )) -> rel_wide


write.csv(
  x = rel_wide,
  file = "data/processed/aseba_reliability_calc_sb.csv",
  row.names = FALSE
  )


