if (!"pacman" %in% installed.packages()) install.packages("pacman")
pacman::p_load(haven, labelled, dplyr, purrr, readr)

sav_files <- list.files("data/raw", full.names = TRUE, recursive = TRUE, pattern = "\\.sav$")
data_list <- lapply(sav_files, function(x) select(read_sav(x), -CASEID))
data_full <- reduce(data_list, left_join, by = join_by(SAFE_ID))

write_rds(data_full, "data/processed/data_proc_safechild.rds")

dict <- generate_dictionary(data_full, details = "full") |>
  lookfor_to_long_format() |>
  convert_list_columns_to_character()

write_tsv(dict, "data/meta/data_dict_safechild.tsv")