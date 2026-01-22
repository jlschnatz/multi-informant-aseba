pacman::p_load(dplyr, tidyr)

logdata <- readRDS("data/processed/objective_criteria_log.rds")
colnames(logdata) <- c(
  "subscale_id",
  "run",
  "pheromone",
  "rmsea.robust",
  "srmr",
  "beta",
  "phi",
  "omega_cic",
  "omega_cip",
  "omega_isc",
  "omega_isp"
)

mvc_data <- readRDS("data/processed/mvc_testing.rds") |>
  select(subscale_id, criterion, cutoff) |>
  mutate(criterion = if_else(criterion == "gamma", "beta", criterion))


logdata |>
  pivot_longer(
    -c(subscale_id, run, pheromone),
    names_to = "criterion",
    values_to = "value"
  ) |>
  full_join(mvc_data, by = join_by(subscale_id, criterion)) |>
  mutate(
    rmsea_ok = any(criterion == "rmsea.robust" & value < cutoff),
    srmr_ok = any(criterion == "srmr" & value < cutoff),
    .by = c(subscale_id, run)
  ) |>
  group_by(subscale_id) |>
  filter(rmsea_ok & srmr_ok) |>
  filter(pheromone == max(pheromone)) |>
  View()
