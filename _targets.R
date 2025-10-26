# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)

# Set target options:
tar_option_set(
  packages = c("tibble"), # Packages that your targets need for their tasks.
  format = "qs", # Optionally set the default storage format. qs is fast.
  seed = 250925192132 %% .Machine$integer.max
  #
  # Pipelines that take a long time to run may benefit from
  # optional distributed computing. To use this capability
  # in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs. For example, the following
  # sets a controller that scales up to a maximum of two workers
  # which run as local R processes. Each worker launches when there is work
  # to do and exits if 60 seconds pass with no tasks to run.
  #
  #   controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
  #
  # Alternatively, if you want workers to run on a high-performance computing
  # cluster, select a controller from the {crew.cluster} package.
  # For the cloud, see plugin packages like {crew.aws.batch}.
  # The following example is a controller for Sun Grid Engine (SGE).
  #
  #   controller = crew.cluster::crew_controller_sge(
  #     # Number of workers that the pipeline can scale up to:
  #     workers = 10,
  #     # It is recommended to set an idle time so workers can shut themselves
  #     # down if they are not running tasks.
  #     seconds_idle = 120,
  #     # Many clusters install R as an environment module, and you can load it
  #     # with the script_lines argument. To select a specific verison of R,
  #     # you may need to include a version string, e.g. "module load R/4.3.2".
  #     # Check with your system administrator if you are unsure.
  #     script_lines = "module load R"
  #   )
  #
  # Set other options as needed.
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  # Reliability and Agreement CSV files
  tar_file(
    rel_file,
    "data/processed/aseba_rel.csv"
  ),
  tar_file(
    agr_file,
    "data/processed/aseba_agr.csv"
  ),
  tar_target(
    data_cutoff,
    create_cutoff(rel_file, agr_file, capacity = 2),
  ),
  # SAV-files of raw data
  tar_files(
    sav_files,
    list.files("data/raw", full.names = TRUE, recursive = TRUE, pattern = "\\.sav$"),
    format = "file"
  ),
  # Create merged safechild datase
  tar_target(
    data_safe,
    create_safechild(sav_files)
  ),
  # Generate variable dictionary
  tar_target(
    dict,
    create_dictionary(data_safe)
  ),
  # Find attrition
  tar_target(
    dropout,
    handle_attrition(data_safe)
  ),
  # Prepare ASEBA data
  tar_target(
    data_aseba,
    create_aseba(data_safe, dropout)
  ),
  # Train-test split
  tar_target(
    split_list,
    split_data(data_aseba)
  ),
  tar_target(
    training_set,
    extract_datasets(split_list, which = "training")
  ),
  tar_target(
    test_set,
    extract_datasets(split_list, which = "testing")
  ),
  # Read in ASEBA metadata (manual from 2001)
  tar_file(file_meta_aseba, "data/meta/aseba_man_2001.xlsx"),
  tar_target(
    meta_cbcl,
    read_meta_aseba(file_meta_aseba, sheet = "cbcl")
  ),
  tar_target(
    meta_ysr,
    read_meta_aseba(file_meta_aseba, sheet = "ysr")
  ),
  # Create item assignment  
  tar_target(
    item_assignment,
    create_item_assignment(meta_ysr, meta_cbcl)
  ),
  tar_target(
    missing_items,
    check_item_assignment(item_assignment, training_set)
  ),
  tar_target(
    item_assignment_fixed,
    fix_item_assignment(item_assignment, missing_items)
  ),
  tar_target(
    test,
    f(item_assignment_fixed, training_set),
    pattern = map(item_assignment_fixed)
  )
  # ...
)
