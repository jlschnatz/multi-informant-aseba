#' Create a safe child dataset by merging multiple .sav files
#' @param files A character vector of file paths to .sav files
#' @return A data frame containing the merged data
create_safechild <- function(files) {
  data_list <- lapply(files, function(x) {
    dplyr::select(haven::read_sav(x), -CASEID)
  })
  data_full <- purrr::reduce(
    data_list,
    dplyr::left_join,
    by = dplyr::join_by(SAFE_ID)
  )
  return(data_full)
}

#' Generate a dictionary from the dataset
#' @param x A data frame (from SAV format)
#' @return A data frame containing the variable dictionary
create_dictionary <- function(x) {
  dict <- labelled::generate_dictionary(x, details = "full") |>
    labelled::lookfor_to_long_format() |>
    labelled::convert_list_columns_to_character()
  return(dict)
}

#' Attrition analysis to find dropouts of follow-up waves (10th and 11th) of the SAFE child study
#' @param data A data frame containing the SAFE child dataset
#' @return A list with handle_attrition statistics (number and proportion of dropouts, and their IDs)
handle_attrition <- function(data) {
  is_missing <- with(
    data,
    is.na(C10ASSDAT) & is.na(C11ASSDAT) & is.na(P10ASSDAT) & is.na(P11ASSDAT)
  )
  n_dropout <- sum(is_missing)
  out <- list(
    n_dropout = n_dropout,
    total = nrow(data),
    prop_dropout = n_dropout / nrow(data),
    id_dropout = data$SAFE_ID[is_missing]
  )
  return(out)
}

#' Prepare ASEBA data by filtering out dropouts and selecting relevant variables
#' @param data A data frame containing the SAFE child dataset (from create_safechild() function)
#' @param attrition A list containing attrition information (from handle_attrition() function)
#' @return A data frame containing the prepared ASEBA data
create_aseba <- function(data, attrition) {
  data_aseba <- data |>
    dplyr::filter(!SAFE_ID %in% attrition$id_dropout) |>
    dplyr::select(
      SAFE_ID,
      dplyr::matches("^C\\d{2}AYS\\d{2,3}[a-zA-Z]?$"),
      dplyr::matches("^P\\d{2}CBP\\d{2,3}[a-zA-Z]?$")
    ) |>
    dplyr::rename_with(~ gsub("AYS", "YSR", .x), matches("AYS")) |>
    dplyr::rename_with(~ gsub("CBP", "CBCL", .x), matches("CBP"))
  return(data_aseba)
}

#' Split the ASEBA data into training and test sets
#' @param data A data frame containing the prepared ASEBA data (from create_aseba() function)
#' @return A list containing the training and test datasets
split_data <- function(data) {
  data_wave10 <- dplyr::select(data, c(SAFE_ID, matches("(C|P)10"))) |>
    dplyr::rename_with(~ gsub("^C10", "", .x), dplyr::matches("^C10")) |>
    dplyr::rename_with(~ gsub("^P10", "", .x), dplyr::matches("^P10"))

  data_wave11 <- dplyr::select(data, c(SAFE_ID, matches("(C|P)11"))) |>
    dplyr::rename_with(~ gsub("^C11", "", .x), dplyr::matches("^C11")) |>
    dplyr::rename_with(~ gsub("^P11", "", .x), dplyr::matches("^P11"))

  id_half1 <- sample(data$SAFE_ID, size = nrow(data) / 2, replace = FALSE)
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

#' Extract training or test dataset from the split data
#' @param data A list containing the split datasets (from split_data() function)
#' @param which A character string specifying which dataset to extract ("training" or "testing")
#' @return A data frame containing the requested dataset
extract_datasets <- function(data, which = c("training", "testing")) {
  which <- match.arg(which)
  out <- switch(which, training = data$training_set, testing = data$test_set)
  return(out)
}

#' Create cutoff values for Minimum Viable Criteria (MVC) based on reliability and agreement data
#' @param file1 A character string specifying the path to the reliability CSV file
#' @param file2 A character string specifying the path to the agreement CSV file
#' @param capacity An integer specifying the capacity for Spearman-Brown formula (default is 2)
#' @return A data frame containing the cutoff values
create_cutoff <- function(file1, file2, capacity = 2) {
  rel <- read.csv(file1)
  agr <- read.csv(file2)
  comb <- dplyr::inner_join(agr, rel, by = c("id", "scale"))
  comb |>
    tidyr::pivot_longer(
      cols = -c(id, scale, agreement),
      names_to = c(".value", "instrument"),
      names_sep = "_"
    ) |>
    dplyr::mutate(alpha_star = spearman_brown(alpha, n, capacity)) |>
    dplyr::mutate(dplyr::across(dplyr::starts_with("alpha"), ~ round(.x, 3)))
}

#' Read in ASEBA metadata from an Excel file
#' @param file A character string specifying the path to the Excel file
#' @param sheet A character string specifying the sheet name ("cbcl" or "ysr")
#' @return A data frame containing the ASEBA metadata
read_meta_aseba <- function(file, sheet = c("cbcl", "ysr")) {
  sheet <- match.arg(sheet)
  meta <- readxl::read_excel(file, sheet = sheet) |>
    dplyr::mutate(
      id = toupper(paste0(
        sheet,
        stringr::str_pad(id, width = 3, side = "left", pad = "0")
      ))
    ) |>
    dplyr::mutate(instrument = toupper(sheet))
  return(meta)
}

#' Create item assignment for ASEBA scales
#' @param ysr A data frame containing YSR metadata (from read_meta_aseba() function)
#' @param cbcl A data frame containing CBCL metadata (from read_meta_aseba() function)
#' @return A nested list containing item assignments for each scale and instrument
create_item_assignment <- function(ysr, cbcl) {
  scale_map <- list(
    "Anxious/Depressed" ~ "AD",
    "Withdrawn/Depressed" ~ "WD",
    "Somatic Complaints" ~ "SC",
    "Social Problems" ~ "SP",
    "Thought Problems" ~ "TP",
    "Attention Problems" ~ "AP",
    "Rule-Breaking Behavior" ~ "RB",
    "Aggressive Behavior" ~ "AB"
  )
  nested_items <- dplyr::bind_rows(ysr, cbcl) |>
    dplyr::filter(!is.na(scale), scale != "Other Problems") |>
    dplyr::mutate(
      id_scale = dplyr::case_match(
        scale,
        !!!scale_map,
        .default = NA_character_
      )
    ) |>
    split(~id_scale) |>
    purrr::map(~ split(.x$id, .x$instrument))
  return(nested_items)
}

#' Check for missing items in the data compared to the manual
#' @param item_assignment A nested list containing item assignments for each scale and instrument (from create_item_assignment() function)
#' @param training_set A data frame containing the training dataset
#' @return A character vector containing the IDs of missing items
check_item_assignment <- function(item_assignment, training_set) {
  missing_items <- setdiff(
    unlist(item_assignment, use.names = FALSE),
    names(training_set)[-1]
  )
  return(missing_items)
}

#' Fix item assignment by removing items not present in the training set
#' @param item_assignment A nested list containing item assignments for each scale and instrument (from create_item_assignment() function)
#' @param training_set A data frame containing the training dataset
#' @return A nested list containing the fixed item assignments
fix_item_assignment <- function(item_assignment, missing_items) {
  fixed_assignment <- purrr::map(item_assignment, function(x) {
    purrr::map(x, function(ids) {
      setdiff(ids, missing_items)
    })
  })
  return(fixed_assignment)
}

#' Subset Data by Scale ID
#'
#' This function takes the full training set and the nested assignment list,
#' finds the specific items for the requested scale (e.g., "AB"), and
#' returns the subsetted dataframe.
#'
#' @param data A dataframe (your training_set).
#' @param assignments A named nested list (your item_assignment_fixed).
#' @param scale_id A character string representing the scale to extract (e.g., "AB").
#'
#' @return A dataframe containing only the columns relevant to the scale.
subset_by_scale <- function(data, assignments, scale_id) {
  if (!scale_id %in% names(assignments)) {
    cli::cli_abort(
      "Error: Scale ID '{scale_id}' was expected but not found in the assignment list."
    )
  }

  scale_items <- assignments[[scale_id]]
  target_columns <- c(scale_items$CBCL, scale_items$YSR)
  subset_df <- subset(data, select = target_columns)
  return(subset_df)
}

#' Generate Factor Structure
#' @param data A dataframe with the ID column and all column belonging to a clinical subscale
#' @return A list with the defined factor structure
create_factor_strucure <- function(data) {
  cbcl_items <- grep("^CBCL", names(data), value = TRUE)
  ysr_items <- grep("^YSR", names(data), value = TRUE)
  fs <- list(
    CIC = ysr_items,
    CIP = cbcl_items,
    ISC = ysr_items,
    ISP = cbcl_items
  )
  return(fs)
}

#' Fit MTMM Model (Stuart)
#'
#' Fits the model using the stuart package logic you provided.
#'
#' @param data The subsetted dataframe.
#' @param scale_id Included for error context (optional but recommended).
construct_subtest <- function(data, objective) {
  if (!is.data.frame(data)) {
    cli::cli_abort("Input must be a dataframe")
  }

  cbcl_items <- grep("^CBCL", names(data), value = TRUE)
  ysr_items <- grep("^YSR", names(data), value = TRUE)

  fs <- list(
    CIC = ysr_items,
    CIP = cbcl_items,
    ISC = ysr_items,
    ISP = cbcl_items
  )

  mtmm <- list(
    CI = c("CIC", "CIP"),
    ISC = "ISC",
    ISP = "ISP"
  )

  # 4. Run Model
  do.call(
    suppressMessages(stuart::randomsamples),
    args = list(
      data = data,
      factor.structure = fs,
      capacity = 2,
      mtmm = mtmm,
      n = 100,
      cores = 8,
      objective = objective$obj_fun
    )
  )
}