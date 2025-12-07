# Load required packages
library(targets)
library(tarchetypes)

# Set target options
tar_option_set(
  error = "null",
  format = "qs",
  seed = 250925
)

# Source R scripts with custom functions
tar_source()

# Define pipeline
list(
  # Model arguments
  tar_target(
    model_parameters,
    list(
      mtmm = list(
        CI = c("CIC", "CIP"),
        ISC = "ISC",
        ISP = "ISP"
      ),
      mtmm_invariance = "configural",
      capacity = 2,
      analysis_opts = list(
        estimator = "MLR",
        missing = "FIML"
      ),
      n_random = 5000, # should be 5000 on the server
      p_top = 0.9,
      n_cores = 8, # should be higher on the server
      obj_info = list(
        vec = c("rmsea.robust", "srmr", "rel"),
        mat = list(
          name = c("beta", "lvcor"),
          which = list(beta = c("CIP", "CIC"), lvcor = c("ISP", "ISC")),
          side = list(beta = "top", lvcor = "bottom")
        ),
        lower_tail = c(FALSE, FALSE, TRUE, TRUE, FALSE),
        weights = c(1 / 6, 1 / 6, 1 / 3, 1 / 6, 1 / 6)
      ),
      alpha_level = .05
    )
  ),

  # Reliability and agreement CSV files
  tar_file(
    rel_data_file,
    "data/processed/aseba_rel.csv"
  ),
  tar_file(
    agreement_data_file,
    "data/processed/aseba_agr.csv"
  ),

  # Generate cutoff reference
  tar_target(
    cutoff_reference,
    create_cutoff(rel_data_file, agreement_data_file, capacity = 2)
  ),

  # Raw data files
  tar_files(
    raw_sav_files,
    list.files(
      "data/raw",
      full.names = TRUE,
      recursive = TRUE,
      pattern = "\\.sav$"
    ),
    format = "file"
  ),

  # Create merged SAFEchild dataset
  tar_target(
    data_safechild,
    create_safechild(raw_sav_files)
  ),

  # Variable dictionary
  tar_target(
    variable_dictionary,
    create_dictionary(data_safechild)
  ),

  # Attrition
  tar_target(
    attrition_info,
    handle_attrition(data_safechild)
  ),

  # ASEBA data preparation
  tar_target(
    data_aseba,
    create_aseba(data_safechild, attrition_info)
  ),

  # Train-test split
  tar_target(
    data_split,
    split_data(data_aseba)
  ),
  tar_target(
    training_data,
    extract_datasets(data_split, which = "training")
  ),
  tar_target(
    testing_data,
    extract_datasets(data_split, which = "testing")
  ),

  # ASEBA metadata
  tar_file(
    aseba_metadata_file,
    "data/meta/aseba_man_2001_public.xlsx"
  ),
  tar_target(
    meta_cbcl,
    read_meta_aseba(aseba_metadata_file, sheet = "cbcl")
  ),
  tar_target(
    meta_ysr,
    read_meta_aseba(aseba_metadata_file, sheet = "ysr")
  ),

  # Item assignment
  tar_target(
    item_assignment,
    create_item_assignment(meta_ysr, meta_cbcl)
  ),
  tar_target(
    missing_item_info,
    check_item_assignment(item_assignment, training_data)
  ),
  tar_target(
    fixed_item_assignment,
    fix_item_assignment(item_assignment, missing_item_info)
  ),

  # Map over clinical subscales
  tar_map(
    values = tibble::tibble(
      subscale_id = c("AB", "AD", "AP", "RB", "SC", "SP", "TP", "WD")
    ),
    names = "subscale_id",

    # Subset training data
    tar_target(
      training_subset,
      subset_by_scale(training_data, fixed_item_assignment, subscale_id)
    ),

    # Factor structure
    tar_target(
      factor_structure,
      create_factor_strucure(training_subset)
    ),

    # Objective function
    tar_target(
      objective_function,
      build_obj(
        data = training_subset,
        fs = factor_structure,
        capacity = model_parameters$capacity,
        mtmm = model_parameters$mtmm,
        mtmm_invariance = model_parameters$mtmm_invariance,
        analysis_opts = model_parameters$analysis_opts,
        n_random = model_parameters$n_random,
        p_top = model_parameters$p_top,
        cores = model_parameters$n_cores,
        obj_info = model_parameters$obj_info
      )
    ),

    # Construct subtest solution
    tar_target(
      subtest_solution,
      construct_subtest(
        training_subset,
        objective_function,
        n_cores = model_parameters$n_cores,
        capacity = model_parameters$capacity,
        testing = TRUE # set this to false to run bruteforce approach instead of randomsamples
      )
    ),

    # Evaluate MVC
    tar_target(
      mvc_results,
      test_mvc(
        model_output = subtest_solution,
        n_cores = model_parameters$n_cores,
        alpha_level = model_parameters$alpha_level,
        n_rep = 10, #model_parameters$n_rep,
        cutoff_reference = cutoff_reference,
        subscale_id = subscale_id
      )
    ),

    # Test invariance
    tar_target(
      invariance_results,
      test_invariance(
        model_output = subtest_solution,
        capacity = model_parameters$capacity,
        mtmm = model_parameters$mtmm,
        alpha_level = model_parameters$alpha_level,
        mvc_results = mvc_results
      )
    ),

    # Test informant specificness
    tar_target(
      informant_specificness_results,
      test_informant_specificness(
        model_output = subtest_solution,
        subscale_id = subscale_id,
        alpha_level = model_parameters$alpha_level,
        n_rep = 10, # model_parameters$n_rep
        verbose = FALSE,
        mvc_results = mvc_results
      )
    )
  )
)
