FROM rocker/r-ver:4.5.1
LABEL "Jan Luca Schnatz"="schnatz@psych.uni-frankfurt.de"
RUN apt-get update -y && apt-get -y install make pandoc libnode-dev libxml2-dev libx11-dev git libcurl4-openssl-dev libssl-dev libgit2-dev zlib1g-dev libglpk-dev libjpeg-dev cmake xz-utils libpng-dev libfreetype6-dev libicu-dev libfontconfig1-dev libfribidi-dev libharfbuzz-dev && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN echo "options(renv.config.pak.enabled = TRUE, repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN R -e 'remotes::install_version("renv", version = "1.1.4")'
COPY . .
RUN R -e 'renv::restore()'
RUN R -e 'targets::tar_make()'
