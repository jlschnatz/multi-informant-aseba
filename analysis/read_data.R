# Preregistration: https://doi.org/10.17605/OSF.IO/FERJ5

# Deviation from preregistration because of integer overflow
set.seed(250925192132 %% .Machine$integer.max)

# Load libraries
pacman::p_load(
  readr,
  dplyr,
  stringr,
  haven,
  purrr,
  readxl
)


# Write wrapper function

handle_attrition <- function(x) {
  data <- readRDS(x)
  is_missing <- with(data, is.na(C10ASSDAT) & is.na(C11ASSDAT) & is.na(P10ASSDAT) & is.na(P11ASSDAT))
  n_dropout <- sum(is_missing)
  out <- list(
    n_dropout = n_dropout,
     total = nrow(data), 
     prop_dropout = n_dropout / nrow(data),
    id_dropout = data$SAFE_ID[is_missing]
    )
  saveRDS(out, file = "data/processed/dropout_info.rds")
  return(out)
}

dropout <- handle_attrition("data/processed/data_proc_safechild.rds")


create_aseba <- function(data, dropout) {
  data_aseba <- data |> 
    filter(!SAFE_ID %in% dropout$id_dropout) |> 
    dplyr::select(
      SAFE_ID,
      dplyr::matches("^C\\d{2}AYS\\d{2,3}[a-zA-Z]?$"),
      dplyr::matches("^P\\d{2}CBP\\d{2,3}[a-zA-Z]?$")
    ) |>
    dplyr::rename_with(~gsub("AYS", "YSR", .x), matches("AYS")) |>
    dplyr::rename_with(~gsub("CBP", "CBCL", .x), matches("CBP"))

  return(data_aseba)
}

split_data <- function(data, seed) {
  set.seed(seed)
  data_wave10 <- dplyr::select(data, c(SAFE_ID, matches("(C|P)10"))) |>
    dplyr::rename_with(~ gsub("^C10", "", .x), dplyr::matches("^C10")) |>
    dplyr::rename_with(~ gsub("^P10", "", .x), dplyr::matches("^P10"))

  data_wave11 <- dplyr::select(data, c(SAFE_ID, matches("(C|P)11"))) |>
    dplyr::rename_with(~ gsub("^C11", "", .x), dplyr::matches("^C11")) |>
    dplyr::rename_with(~ gsub("^P11", "", .x), dplyr::matches("^P11"))

  id_half1 <- sample(data$SAFE_ID, size = nrow(data)/2, replace = FALSE)
  id_half2 <- setdiff(data$SAFE_ID, id_half1)

  wave10_half1 <- dplyr::filter(data_wave10, SAFE_ID %in% id_half1)
  wave10_half2 <- dplyr::filter(data_wave10, SAFE_ID %in% id_half2)
  wave11_half1 <- dplyr::filter(data_wave11, SAFE_ID %in% id_half1)
  wave11_half2 <- dplyr::filter(data_wave11, SAFE_ID %in% id_half2)
  training_set <- dplyr::bind_rows(wave10_half1, wave11_half2)
  test_set <- dplyr::bind_rows(wave10_half2, wave11_half1)
  out <- list(
    training_set = training_set,
    test_set = test_set
  )
  return(out)
}



# Read in data
data_safe <- read_rds("data/processed/data_proc_safechild.rds")

data_aseba <- create_aseba(data_safe, dropout)

split_data <- split_data(data_aseba, seed = 250925192132 %% .Machine$integer.max)



training_set <- split_data$training_set
test_set <- split_data$test_set



write_rds(training_set, "data/processed/data_training.rds", compress = "gz")
write_rds(test_set, "data/processed/data_testing.rds", compress = "gz")






meta_ysr <- read_excel("data/meta/aseba_man_2001.xlsx", sheet = "ysr") |>
    mutate(id = toupper(paste0("YSR", str_pad(id, width = 3, side = "left", pad = "0")))) |>
    mutate(instrument = "YSR")
meta_cbcl <- read_excel("data/meta/aseba_man_2001.xlsx", sheet = "cbcl") |>
  mutate(id = toupper(paste0("CBCL", str_pad(id, width = 3, side = "left", pad = "0")))) |>
  mutate(instrument = "CBCL")






create_item_assignment <- function(ysr, cbcl) {
  scale_map <- list(
  "Anxious/Depressed"      ~ "AD",
  "Withdrawn/Depressed"    ~ "WD",
  "Somatic Complaints"     ~ "SC",
  "Social Problems"        ~ "SP",
  "Thought Problems"       ~ "TP",
  "Attention Problems"     ~ "AP",
  "Rule-Breaking Behavior" ~ "RB",
  "Aggressive Behavior"    ~ "AB"
  )
  nested_items <- dplyr::bind_rows(ysr, cbcl) |>
    dplyr::filter(!is.na(scale), scale != "Other Problems") |>
    dplyr::mutate(id_scale = dplyr::case_match(scale, !!!scale_map, .default = NA_character_)) |>
    split(~id_scale) |>
    purrr::map(~split(.x$id, .x$instrument))
  return(nested_items)
}


nested_items <- dplyr::bind_rows(meta_ysr, meta_cbcl) |>
  dplyr::filter(!is.na(scale), scale != "Other Problems") |>
  dplyr::mutate(id_scale = dplyr::case_match(scale, !!!scale_map, .default = NA_character_)) |>
  split(~id_scale) |>
  purrr::map(~split(.x$id, .x$instrument))


jsonlite::write_json(nested_items, "data/meta/aseba_items_nested.json", pretty = TRUE, auto_unbox = TRUE)



unlist(nested_items[[1]], use.names = FALSE) %in% names(training_set)

names(training_set)

names(training_set)[grepl("CBCL", names(training_set))]

count(meta_ysr, scale)
count(meta_cbcl, scale) 


notin <- which(!c(meta_cbcl$id, meta_ysr$id) %in% names(training_set))

setdiff(c(meta_cbcl$id, meta_ysr$id), names(training_set))

names(training_set)[notin]



names(training_set) %in% c(meta_cbcl$id, meta_ysr$id)


meta_ysr |>
  filter(id == "YSR058") 

bind_rows(meta_ysr, meta_cbcl) |>
  filter(scale == "Attention Problems") 
  count(scale)


names(training_set)

meta_cbcl$id

match(meta_cbcl$id, names(training_set))


