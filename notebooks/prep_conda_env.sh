#!/bin/bash

source ../config_global.txt    # to get variable "conda_env" and "rstudio_path"
echo "conda env name: ${conda_env}"

## create a new conda env:
source ~/miniconda3/etc/profile.d/conda.sh    # !!! have to source it before running "conda activate <name>"

conda create --name ${conda_env} python=3.9
conda activate ${conda_env}

## install R (>4.0):    
# ref: https://www.biostars.org/p/498049/
# ref: http://salvatoregiorgi.com/blog/2018/10/16/installing-an-older-version-of-r-in-a-conda-environment/
conda config --add channels conda-forge
conda config --set channel_priority strict
conda search r-base   # will print all available r-base versions to install
conda install -c conda-forge r-base=4.1.2

which R    # where the R is installed: /home/chenying/miniconda3/envs/modelarray_paper/bin/R
R   # you should see it's R 4.1.2

## launch Rstudio:
# ref: https://stackoverflow.com/questions/38534383/how-to-set-up-conda-installed-r-for-use-with-rstudio
${rstudio_path} # do this in a terminal - as this terminal will be only for this rstudio and cannot do else before rstudio is off

# in Rstudio, type: 
# > .libPaths()
# [1] "/home/chenying/miniconda3/envs/modelarray_paper/lib/R/library"
# ^^ success

## install R packages needed by ModelArray:
# in terminal: 
conda search r-devtools
conda install -c conda-forge r-devtools
# note: not to: > install.packages("devtools")       in R: it will take a long time and there will be errors in dependent packages

# install hdf5r before proceeding:   # not to: > install.packages("hdf5r")       in R: there will be errors
conda search r-hdf5r
conda install -c conda-forge r-hdf5r

## try if ModelArray can be installed:
# in Rstudio (launched as above):
# > install.packages("PennLINC/ModelArray")