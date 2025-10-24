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
  tar_file(
    aseba_reliability,
    "data/processed/aseba_reliability.csv"
  ),
  tar_file(
    aseba_ci_agreement,
    "data/processed/aseba_ci-agreement.csv"
  ),
  tar_target(
    data_cutoff,
    create_cutoff(aseba_reliability, aseba_ci_agreement, capacity = 2)
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
    generate_dict(data_safe)
  ),
  # Find dropouts
  tar_target(
    dropout,
    find_dropout(data_safe)
  ),
  # Prepare ASEBA data
  tar_target(
    data_aseba,
    prepare_data(data_safe, dropout)
  ),
  # Train-test split
  tar_target(
    split_data,
    finalize_split(data_aseba)
  )
)
