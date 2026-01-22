#!/usr/bin/env bash
exec > >(tee -a pipeline.log) 2>&1
set -e

export R_LIBS_USER="$HOME/R/library"
mkdir -p "$R_LIBS_USER"

export R_PROFILE_USER="$HOME/.Rprofile"
cat > "$R_PROFILE_USER" <<'EOF'
options(
  renv.config.ppm.enabled = TRUE,
  renv.config.pak.enabled = FALSE,
  repos = c(CRAN = "https://cran.rstudio.com/"),
  download.file.method = "libcurl",
  Ncpus = 32
)
EOF

R -e 'if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")'
R -e 'if (!requireNamespace("renv", quietly = TRUE)) remotes::install_version("renv", version = "1.1.4")'
R -e 'if (!requireNamespace("targets", quietly = TRUE)) remotes::install_version("targets", version = "1.11.4")'
R -e 'if (!requireNamespace("tarchetypes", quietly = TRUE)) remotes::install_version("tarchetypes", version = "0.13.2")'
R -e 'renv::restore()'
R -e 'targets::tar_make()'
