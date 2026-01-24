pacman::p_load(targets, dplyr, sjlabelled, tidyr, tibble)
tar_load(data_aseba)
tar_load(data_safechild)

id_subj <- as.character(data_aseba$SAFE_ID)
data_safechild <- filter(data_safechild, SAFE_ID %in% id_subj)

# CBK801: gender
# CBK701: age
# CBK222: Race (a-f)
# CBKRE8: Ethnicity (8 categories)

data_descr <- data_safechild |>
  select(
    id_subject = SAFE_ID,
    # Child
    ends_with("CBK801"),
    ends_with("CBK701"),
    ends_with("CBK222"),
    # Parent
    matches("P(10|11)SBK105"), # Relationship to child
    matches("P(10|11)SBK718"), # Sex
    matches("P(10|11)SBK995"), # How long child lived with parent (months)
    matches("P(10|11)SBK005"), # N children in home
    matches("P(10|11)SBK007"), # Married / living with someone
    matches("P(10|11)SBK703"), # Relationship to childs mother
    matches("P(10|11)SBK704"), # Does childs mother live in home
    matches("P(10|11)SBK705"), # Did child mother ever live in home
    matches("P(10|11)SBK706"), # Child age when mom moved out
    matches("P(10|11)SBK708"), # Relationship to childs father
    matches("P(10|11)SBK008"), # Does childs father live in home
    matches("P(10|11)SBK009"), # Did child father ever live in home
    matches("P(10|11)SBK010"), # Child age when father moved out
    matches("P(10|11)SBK677"), # Past 30 day primary living arrangement,
    matches("P(10|11)SBK001"), # Age of parent
    matches("P(10|11)SBKPRC"), # Ethnicity of parent
    matches("P(10|11)SBK068"), # Food stamps
    matches("P(10|11)SBK713"), # Public aid
    matches("P(10|11)SBK071"), # Child support
    matches("P(10|11)SBK072"), # Social security
    matches("P(10|11)SBK076"), # Unemployed
    matches("P(10|11)SBK023"), # Total family income
    matches("P(10|11)SBK888"), # Number of schools attended since kindergarden
  ) |>
  rename(
    # Child
    c10_sex = C10CBK801,
    c11_sex = C11CBK801,
    c10_age = C10CBK701,
    c11_age = C11CBK701,
    c10_ethnicity = C10CBK222,
    c11_ethnicity = C11CBK222,
    # Parent
    p10_relationchild = P10SBK105,
    p11_relationchild = P11SBK105,
    p10_sex = P10SBK718,
    p11_sex = P11SBK718,
    p10_childlivemonth = P10SBK995,
    p11_childlivemonth = P11SBK995,
    p10_nchildhome = P10SBK005,
    p11_nchildhome = P11SBK005,
    p10_married = P10SBK007,
    p11_married = P11SBK007,
    p10_relationchildmother = P10SBK703,
    p11_relationchildmother = P11SBK703,
    p10_motherlivehome = P10SBK704,
    p11_motherlivehome = P11SBK704,
    p10_mothereverlivehome = P10SBK705,
    p11_mothereverlivehome = P11SBK705,
    p10_agemothermove = P10SBK706,
    p11_agemothermove = P11SBK706,
    p10_relationchildfather = P10SBK708,
    p11_relationchildfather = P11SBK708,
    p10_fatherlivehome = P10SBK008,
    p11_fatherlivehome = P11SBK008,
    p10_fathereverlivehome = P10SBK009,
    p11_fathereverlivehome = P11SBK009,
    p10_agefathermove = P10SBK010,
    p11_agefathermove = P11SBK010,
    p10_age = P10SBK001,
    p11_age = P11SBK001,
    p10_foodstamps = P10SBK068,
    p11_foodstamps = P11SBK068,
    p10_publicaid = P10SBK713,
    p11_publicaid = P11SBK713,
    p10_childsupport = P10SBK071,
    p11_childsupport = P11SBK071,
    p10_socialsecurity = P10SBK072,
    p11_socialsecurity = P11SBK072,
    p10_unemployed = P10SBK076,
    p11_unemployed = P11SBK076,
    p10_familyincome = P10SBK023,
    p11_familyincome = P11SBK023,
    p10_ethnicity = P10SBKPRC,
    p11_ethnicity = P11SBKPRC,
    p10_currentliving = P10SBK677,
    p11_currentliving = P11SBK677,
    p10_nschoolattent = P10SBK888,
    p11_nschoolattent = P11SBK888,
  ) 
  mutate(across(
    -c(
      ends_with("age"),
      ends_with("move"),
      ends_with("nchildhome"),
      ends_with("childlivemonth")
    ),
    \(x) forcats::as_factor(x)
  )) |>
  mutate(across(where(is_labelled), as.numeric))


names(data_descr)


age_descr <- data_descr |>
  select(id_subject, matches("^(c|p)(10|11)_age$")) |>
  pivot_longer(
    cols = -id_subject,
    names_to = c("rater", "wave"),
    values_to = "age",
    names_pattern = "(c|p)(\\d{2})"
  ) |>
  summarise(age = mean(age, na.rm = TRUE), .by = c(id_subject, rater)) |>
  summarise(
    m_age = mean(age, na.rm = TRUE),
    sd_age = sd(age, na.rm = TRUE),
    .by = rater
  )

data_aseba


tar_objects()

tar_load(testing_data)
tar_load(training_data)
tar_load(fixed_item_assignment)


library(purrr)

analyze_counts <- function(data, items) {
  data |>
    select(all_of(items)) |>
    mutate(across(everything(), ~unlabel(.x))) |> 
    pivot_longer(everything(), names_to = "item") |>
    count(item, value) |>
    arrange(item) |>
    mutate(pct = n / n(), .by = item) |>
    summarise(
      m_pct = mean(pct, na.rm = TRUE),
      sd_pct = sd(pct, na.rm = TRUE),
      .by = value
    ) |>
    mutate(value = as.factor(as.numeric(value))) |>
    drop_na()
}


library(tinytable)
enframe(
  x = fixed_item_assignment,
  name = "subscale",
  value = "instrument"
) |>
  unnest_longer(instrument) |>
  rename(instrument = instrument_id, item = instrument) |>
  mutate(
    training = map(item, ~ analyze_counts(testing_data, .x)),
    testing = map(item, ~ analyze_counts(training_data, .x))
  ) |>
  select(subscale, instrument, testing, training) |>
  pivot_longer(
    cols = c(training, testing),
    names_to = "sample",
    values_to = "stats"
  ) |>
  unnest(stats) |>
  mutate(across(c(m_pct, sd_pct), ~ round(.x, digits = 1))) |>
  mutate(comb = sprintf("%s (%s)", m_pct, sd_pct)) |>
  select(subscale, instrument, sample, value, comb) |>
  pivot_wider(
    names_from = value,
    values_from = comb,
    names_prefix = "val"
  ) |>
  pivot_wider(
    names_from = sample,
    values_from = c(val0, val1, val2)
  ) |>
  arrange(instrument) |>
  select(subscale, ends_with("training"), ends_with("testing")) |>
  tt() |> 
  group_tt(
    i = list("CBCL" = 1, "YSR" = 9), 
    j = list("Training" = 2:4, "Testing" = 5:7)
  )  -> tab

colnames(tab) <- c("Subscale", rep(c("0: Not true", "1: Somewhat or Someties True", "2: Very True or Often True"), times = 2))

data_aseba$C10YSR001
