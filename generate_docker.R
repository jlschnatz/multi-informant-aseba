# Load necessary libraries
suppressMessages({
library(dockerfiler)
library(renv)
library(pak)
})

# Read packages from renv.lock
cli::cli_h1("Dockerfile")
cli::cli_alert_info("Reading renv.lock file...")
lock <- lockfile_read("renv.lock")$Packages

# Get package names or GitHub repos sources
pkgs <- vapply(
  X = lock, 
  FUN = function(x) {
    if(!is.null(x$RemoteRepo)){
      repo <- paste0(x$RemoteUsername, "/", x$RemoteRepo)
      return(repo)
    } else {
      x$Package
    }
  }, 
  FUN.VALUE = character(1), 
  USE.NAMES = FALSE
  )

# Get system requirements for the packages using pak
cli::cli_alert_info("Retrieving system requirements for packages...")
pak_sysreqs <- pkg_sysreqs(pkgs, sysreqs_platform = "debian")

# Build Dockerfile
cli::cli_alert_info("Generating Dockerfile...")
dockerfile <- Dockerfile$new(FROM = "rocker/r-ver:4.5.1")
dockerfile$LABEL("Jan Luca Schnatz", "schnatz@psych.uni-frankfurt.de")
dockerfile$RUN(compact_sysreqs(pak_sysreqs$install_scripts) )
dockerfile$RUN("mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/")
dockerfile$RUN("echo \"options(renv.config.pak.enabled = TRUE, repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 6)\" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site")
dockerfile$RUN("R -e 'install.packages(\"remotes\")'")
dockerfile$RUN("R -e 'remotes::install_version(\"renv\", version = \"1.1.4\")'")  
dockerfile$COPY(".", ".")
dockerfile$RUN("R -e 'renv::restore()'")
dockerfile$RUN("R -e 'targets::tar_make()'")
dockerfile$write()
cli::cli_alert_success("Dockerfile generation completed.")