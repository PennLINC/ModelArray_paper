#!/bin/bash

source ../config_global.txt    # to get variable "conda_env" and "ConFixel_commitSHA"

echo ${conda_env}

# activate the conda environment:
source ~/miniconda3/etc/profile.d/conda.sh    # !!! have to source it before running "conda activate <name>"
conda activate ${conda_env}

# checkout to a specific commit SHA:
cd ../../confixel_for_paper/ConFixel
echo "the commit SHA to use: ${ConFixel_commitSHA}"

git checkout ${ConFixel_commitSHA}
current_commitSHA=`git rev-parse HEAD`
echo "after checking out, the current commit SHA is: ${current_commitSHA}"

# now, install ConFixel:
pip uninstall -y ConFixel  # yes to remove all installed funcs
pip install -e .

# try confixel:
confixel