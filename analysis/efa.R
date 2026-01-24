pacman::p_load(targets, tibble, tidyr, dplyr, lavaan, haven, polycor, EGAnet)

tar_load(c(fixed_item_assignment, training_data, testing_data))

# remove fully missing observations
training_data <- training_data[rowSums(!is.na(training_data)) > 1, ]
testing_data <- testing_data[rowSums(!is.na(testing_data)) > 1, ]
training_data[, -1] <- lapply(training_data[, -1], as.numeric)
testing_data[, -1] <- lapply(testing_data[, -1], as.numeric)




fit_efa_train <- efa(data = testing_data, ov.names = unlist(fixed_item_assignment$TP), nfactors = 1:10)


psych::fa.parallel(select(testing_data, all_of(unlist(fixed_item_assignment$AB))))


summary(fit_efa_train, nd = 2)


select(training_data, all_of(unlist(fixed_item_assignment$SP))) |> 
  EGA(ordinal.categories = 2) -> fit


bega <- bootEGA(
  data = select(training_data, all_of(unlist(fixed_item_assignment$WD))),
  seed = 1, # set seed for reproducibility
  ordinal.categories = 2,
  plot.typicalStructure = TRUE
)

summary(bega)


dimensionStability(bega)




