#!/bin/bash

source config.txt    # to get variable "conda_env"
echo "conda env name: ${conda_env}"

## create a new conda env:
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


