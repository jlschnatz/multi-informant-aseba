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
  # Cores
  tar_target(
    n_cores,
    determine_cores(n_max = 128, buffer = 25)
  ),
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
      n_random = 5000,
      p_top = 0.9,
      n_cores = n_cores,
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
  tar_file(
    raw_sav_files,
    list.files(
      "data/raw",
      full.names = TRUE,
      recursive = TRUE,
      pattern = "\\.sav$"
    )
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
      # AB = Aggressive Behavior
      # AD = Anxious/Depressed
      # AP = Attention Problems
      # RB = Rule-Breaking Behavior
      # SC = Social Problems
      # SP = Somatic Problems
      # TP = Thought Problems
      # WD = Withdrawn/Depressed
    ),

    # Target names will be suffixed with subscale_id
    names = "subscale_id",

    # Subset training data
    tar_target(
      training_subset,
      subset_by_scale(training_data, fixed_item_assignment, subscale_id)
    ),

    # Subset testing data
    tar_target(
      testing_subset,
      subset_by_scale(testing_data, fixed_item_assignment, subscale_id)
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
        cores = 16,
        obj_info = model_parameters$obj_info
      ),
      cue = tar_cue(depend = FALSE)
    ),

    # Construct subtest solution
    tar_target(
      subtest_solution,
      construct_subtest(
        training_subset, # use training data for subset construction
        objective_function,
        n_cores = model_parameters$n_cores,
        capacity = model_parameters$capacity,
        mtmm = model_parameters$mtmm,
        analysis_opts = model_parameters$analysis_opts,
        testing = FALSE # set this to false to run bruteforce approach instead of randomsamples
      ),
      cue = tar_cue(depend = FALSE)
    ),

    # Evaluate MVC on Testing Subset
    tar_target(
      mvc_testing,
      test_mvc(
        model_output = subtest_solution,
        data = testing_subset, # use testing data to test h1
        mtmm = model_parameters$mtmm,
        capacity = model_parameters$capacity,
        objective = objective_function,
        n_cores = model_parameters$n_cores,
        alpha_level = model_parameters$alpha_level,
        n_rep = 5000,
        cutoff_reference = cutoff_reference,
        subscale_id = subscale_id
      )
    ),

    # Test invariance
    tar_target(
      invariance_testing,
      test_invariance(
        model_output = subtest_solution,
        data = testing_subset,
        capacity = model_parameters$capacity,
        mtmm = model_parameters$mtmm,
        alpha_level = model_parameters$alpha_level,
        mvc_results = mvc_testing,
        test_conditionally = FALSE # also test h2 if h1 is not met
      )
    ),

    # Test informant specificness
    tar_target(
      informant_specificity_testing,
      test_informant_specificness(
        model_output = subtest_solution,
        data = testing_subset,
        subscale_id = subscale_id,
        alpha_level = model_parameters$alpha_level,
        n_rep = 5000,
        verbose = TRUE,
        mvc_results = mvc_testing,
        test_conditionally = FALSE
      )
    ),

    # Evaluate MVC on Traaining Subset
    tar_target(
      mvc_training,
      test_mvc(
        model_output = subtest_solution,
        data = training_subset,
        mtmm = model_parameters$mtmm,
        capacity = model_parameters$capacity,
        objective = objective_function,
        n_cores = model_parameters$n_cores,
        alpha_level = model_parameters$alpha_level,
        n_rep = 5000,
        cutoff_reference = cutoff_reference,
        subscale_id = subscale_id
      )
    ),

    # Test invariance on training subset
    tar_target(
      invariance_training,
      test_invariance(
        model_output = subtest_solution,
        data = training_subset, # if I use testing_data almost all models fail
        capacity = model_parameters$capacity,
        mtmm = model_parameters$mtmm,
        alpha_level = model_parameters$alpha_level,
        mvc_results = mvc_training,
        test_conditionally = FALSE # also test h2 if h1 is not met
      )
    ),

    # Test informant specificness
    tar_target(
      informant_specificity_training,
      test_informant_specificness(
        model_output = subtest_solution,
        data = training_subset,
        subscale_id = subscale_id,
        alpha_level = model_parameters$alpha_level,
        n_rep = 5000,
        verbose = TRUE,
        mvc_results = mvc_training,
        test_conditionally = FALSE
      )
    )
  )
)
