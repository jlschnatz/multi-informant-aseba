pacman::p_load(dplyr, tidyr, tinytable)

logmeta <- readRDS("data/processed/objective_criteria_meta.rds")
logbest <- readRDS("data/processed/objective_criteria_best.rds")
objfun_param <- readRDS("data/processed/objective_function_param.rds")


tab1 <- logbest |>
  select(subscale_id, pheromone) |>
  inner_join(logmeta) |>
  mutate(convergence = convergence * 100) |>
  mutate(across(c(pheromone, convergence), \(x) round(x, digits = 2))) |>
  tt() |>
  format_tt()

colnames(tab1) <- c("Subscale", "$max(phi)$", "Convergence (%)", "$N$")

print(tab1)

print(tab, "typst")

tab2 <- objfun_param |>
  mutate(across(c(mean, sd), function(x) sprintf("%.2f", round(x, 2)))) |>
  mutate(stat = sprintf("%s (%s)", mean, sd)) |>
  select(subscale_id, criteria, stat) |>
  pivot_wider(names_from = criteria, values_from = stat) |>
  tt(
    escape = FALSE,
    caption = "Test",
    width = 1,
    notes = "_Note_. Values before parentheses indicate mean, values in parentheses standard deviation. RMSEA: Root Mean Squared Error of Approximation, SRMR: Standardized Root Mean Residual, $omega$: Reliability, $beta$: Consistency parameter, $phi$:  latent correlation between the informant-specific factors of the child and parent informants, $gamma$: regression weight of the cross-informant factors between the child and parent informants"
  )


colnames(tab2) <- c("Subscale", "RMSEA", "SRMR", "$omega$", "$gamma$", "$phi$")

print(tab2)
print(tab2, "typst")


objfun_param |>
  mutate(across(c(mean, sd), function(x) sprintf("%.2f", round(x, 2)))) |>
  mutate(stat = sprintf("%s (%s)", mean, sd)) |>
  select(subscale_id, criteria, stat) |>
  pivot_wider(names_from = criteria, values_from = stat) |>
  nice_table(
    x = _,
    caption = "Test",
    note = "Values before parentheses indicate mean, values in parentheses standard deviation. RMSEA: Root Mean Squared Error of Approximation, SRMR: Standardized Root Mean Residual, $omega$: Reliability, $beta$: Consistency parameter, $phi$:  latent correlation between the informant-specific factors of the child and parent informants, $gamma$: regression weight of the cross-informant factors between the child and parent informants; AB: aggressive behavior, AD: anxious/depressed, AP: attention problems, RB: rule-breaking behavior, SC: social problems, TP: thought problems, WD: withdrawn/depressed",
    col_names = c("Subscale", "RMSEA", "SRMR", "$omega$", "$gamma$", "$phi$"),
    format = "typst"
  )
