# Docker file for creating a docker container of the ModelArray only (without ConFixel)
# using the ModelArray commit SHA of the one reported in the manuscript, and make sure the compatible `tidyr` is installed

# Modified upon Dockerfile in ModelArray. Core is config.yml for ModelArray's circle.ci.

# When update this Dockerfile, please update:
# 1. rocker/verse:<R_version>
# 2. commitSHA_modelarray - see towards the end of this file
# 3. ModelArray's dependent R packages - see DESCRIPTION file
    # note: make sure the `tidyr` has the compatible version with the ModelArray version to be installed


## Base image https://hub.docker.com/u/rocker/
FROM rocker/verse:4.1.2

RUN mkdir /home/data
# RUN mkdir /home/ModelArray

## Install libraries 
# ref: .circleci/config.yml from ModelArray:
RUN apt-get update && apt-get install -y --no-install-recommends \
    libhdf5-dev \
    texlive-fonts-recommended


## Install dependent R packages: 
# from CRAN:   # removed base packages from the list (otherwise warning in docker build): methods and parallel
RUN install2.r --error --ncpus -4 \
    matrixStats \
    magrittr \
    dplyr \
    tibble \
    stringr \
    glue \
    doParallel \
    hdf5r \
    mgcv \
    rlang \
    broom \
    pbmcapply \
    pbapply \
    crayon

# tidyr: specific version:
RUN R -e 'install.packages("https://cran.r-project.org/src/contrib/Archive/tidyr/tidyr_1.1.4.tar.gz", repo=NULL, type="source")'  # +++++++++++++++++++++++++++++++++++++++++++


# from Bioc: # first, install BiocManager from CRAN:
RUN install2.r --error BiocManager
RUN R -e 'BiocManager::install("HDF5Array")'
RUN R -e 'BiocManager::install("rhdf5")'
RUN R -e 'BiocManager::install("DelayedArray")'


## install ModelArray (R package)
# please update commit SHA for ModelArray if needed
RUN R -e 'devtools::install_github("PennLINC/ModelArray@0911c4ffbcc737ea9a615f7a663f57bb0b4e174d")'