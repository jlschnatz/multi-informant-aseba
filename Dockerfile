FROM rocker/r-ver:4.5.1
USER schnatz
RUN apt-get update -y && apt-get install -y  make libicu-dev pandoc libx11-dev libxml2-dev cmake libcurl4-openssl-dev libssl-dev zlib1g-dev libglpk-dev libjpeg-dev git libpng-dev libfreetype6-dev libfontconfig1-dev libfribidi-dev libharfbuzz-dev && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN echo "options(renv.config.pak.enabled = TRUE, repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN R -e 'remotes::install_version("renv", version = "1.1.4")'
COPY renv.lock renv.lock
RUN --mount=type=cache,id=renv-cache,target=/root/.cache/R/renv R -e 'renv::restore()'
RUN R -e 'targets::tar_make()'
