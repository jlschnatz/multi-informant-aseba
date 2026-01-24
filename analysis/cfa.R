pacman::p_load(targets, tibble, tidyr, dplyr, lavaan, haven)

tar_load(c(fixed_item_assignment, training_data, testing_data))

# remove fully missing observations
training_data <- training_data[rowSums(!is.na(training_data)) > 1, ]
testing_data <- testing_data[rowSums(!is.na(testing_data)) > 1, ]
training_data[, -1] <- lapply(training_data[, -1], as.numeric)
testing_data[, -1] <- lapply(testing_data[, -1], as.numeric)



create_modelsyntax <- function(
  fixed_item_assignment,
  rater = c("CBCL", "YSR")
) {
  rater <- match.arg(rater)
  paste(
    names(fixed_item_assignment),
    " =~ ",
    sapply(fixed_item_assignment, function(x) {
      paste(x[[rater]], collapse = " + ")
    }),
    collapse = "\n"
  )
}

mod_cbcl <- create_modelsyntax(fixed_item_assignment, "CBCL")
mod_ysr <- create_modelsyntax(fixed_item_assignment, "YSR")

# Fit CFA Models with MLR and FIML

fit_ysr_train <- cfa(
  model = mod_ysr,
  data = training_data,
  estimator = "MLR", 
  missing = "FIML"
)

summary(fit_ysr_train, fit = TRUE)


fit_ysr_test <- update(fit_ysr_train, data = testing_data)

fit_cbcl_train <- cfa(
  model = mod_cbcl,
  data = training_data,
  estimator = "MLR",
  missing = "FIML"
)

fit_cbcl_test <- update(fit_cbcl_train, data = testing_data)


