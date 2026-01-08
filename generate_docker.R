# Load necessary libraries
suppressMessages({
  library(dockerfiler)
  library(renv)
  library(pak)
})

# Read packages from renv.lock
cli::cli_h1("Dockerfile")
cli::cli_alert_info("Reading renv.lock file...")
lock <- renv::lockfile_read("renv.lock")

# 2. Build the correct identifiers
pkg_identifiers <- sapply(lock$Packages, function(pkg) {
  # Check if it's a GitHub package
  if (!is.null(pkg$RemoteUsername) && !is.null(pkg$RemoteRepo)) {
    base <- paste0(pkg$RemoteUsername, "/", pkg$RemoteRepo)

    # Append the subdirectory if it exists
    if (!is.null(pkg$RemoteSubdir) && pkg$RemoteSubdir != "") {
      return(paste0(base, "/", pkg$RemoteSubdir))
    }
    return(base)
  } else {
    # Default to CRAN package name
    return(pkg$Package)
  }
})

# 3. Query system requirements individually
all_sysreqs <- list()
cli::cli_alert_info("Retrieving system requirements for packages...")
for (id in pkg_identifiers) {
  cli::cli_li("Checking: {.pkg {id}}")
  tryCatch(
    {
      req <- pak::pkg_sysreqs(id, sysreqs_platform = "ubuntu-22.04")
      all_sysreqs[[id]] <- req
    },
    error = function(e) {
      message("  ! Failed for ", id, " (Expected if no SysReqs declared)")
    }
  )
}

# 4. Result Processing
sysreqs <- unique(unlist(
  lapply(all_sysreqs, function(x) x$packages$system_packages),
  use.names = FALSE
))

docker_sysreqs <- paste(
  "apt update -y && apt install -y",
  paste0(sysreqs, collapse = "\t"),
  "&& rm -rf /var/lib/apt/lists/*"
)

opts <- list(
  renv.config.ppm.enabled = TRUE,
  renv.config.pak.enabled = FALSE,
  repos = c(CRAN = 'https://cran.rstudio.com/'),
  download.file.method = 'libcurl',
  Ncpus = 6
)

opts_string <- paste0(
  "options(",
  paste0(names(opts), "=", sapply(opts, deparse), collapse = ","),
  ")"
)

# Build Dockerfile
cli::cli_alert_info("Generating Dockerfile...")
dockerfile <- Dockerfile$new(FROM = "rocker/r-ver:4.5.1")
dockerfile$LABEL("Jan Luca Schnatz", "schnatz@psych.uni-frankfurt.de")
dockerfile$RUN(docker_sysreqs)
dockerfile$RUN("mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/")
dockerfile$RUN(
  sprintf("echo '%s' | tee /usr/local/lib/R/etc/Rprofile.site", opts_string)
)
dockerfile$RUN("R -e 'install.packages(\"remotes\")'")
dockerfile$RUN("R -e 'remotes::install_version(\"renv\", version = \"1.1.4\")'")
dockerfile$WORKDIR("/project")
dockerfile$COPY(".", ".")
dockerfile$RUN("R -e 'renv::restore()'")
dockerfile$RUN("R -e 'targets::tar_make()'")
dockerfile$write()
file.copy("./Dockerfile", "./.devcontainer/Dockerfile")
cli::cli_alert_success("Dockerfile generation completed.")
