options(renv.config.connect.retry = 20L)
options(renv.config.connect.timeout = 60L)
options(renv.download.trace = TRUE)
source("renv/activate.R")

pkgs <- c("targets", "tarchetypes")
not_installed <- !pkgs %in% installed.packages()
if (any(not_installed)) {
  ind <- which(not_installed)
  install.packages(pkgs[ind])
}

rm(list = ls())

library(targets)
library(tarchetypes)
