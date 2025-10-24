# Load necessary libraries
library(dockerfiler)

dockerfile <- dock_from_renv(
  lockfile = "renv.lock",
  FROM = "rocker/r-ver",
  sysreqs = TRUE,
  use_pak = TRUE,
  renv_version = "1.1.4",
  user = "schnatz"
  )

dockerfile$RUN("R -e 'targets::tar_make()'")
dockerfile$write()
