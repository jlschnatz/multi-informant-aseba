FROM rocker/r-ver:4.5.1
LABEL "Jan Luca Schnatz"="schnatz@psych.uni-frankfurt.de"
RUN apt update -y && apt install -y make	libicu-dev	pandoc	libxml2-dev	cmake	libx11-dev	git	libcurl4-openssl-dev	libssl-dev	libgit2-dev	zlib1g-dev	libglpk-dev	libjpeg-dev	libpng-dev && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN echo 'options(renv.config.ppm.enabled=TRUE,renv.config.pak.enabled=FALSE,repos=c(CRAN = "https://cran.rstudio.com/"),download.file.method="libcurl",Ncpus=6)' | tee /usr/local/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN R -e 'remotes::install_version("renv", version = "1.1.4")'
WORKDIR /project
COPY . .
RUN R -e 'renv::restore()'
RUN R -e 'targets::tar_make()'
