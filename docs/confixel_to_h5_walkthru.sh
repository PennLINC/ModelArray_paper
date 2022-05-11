#!/bin/bash
# this is to use ConFixel to convert .mif files into a .h5 file
# this is for demo data for walk-thru!

source ../config_global.txt    # to get variable "conda_env"

# activate the conda environment:
source ${conda_sh_file}    # !!! have to source it before running "conda activate <name>"
conda activate ${conda_env}   
current_conda_env=`echo $CONDA_DEFAULT_ENV`   # get the current conda enviroment's name
echo "current conda environment: ${current_conda_env}"

nsubj=100
cmd="confixel"
cmd+=" --index-file FDC/index.mif"
cmd+=" --directions-file FDC/directions.mif"
cmd+=" --cohort-file cohort_FDC_n${nsubj}.csv"
cmd+=" --relative-root /home/chenying/Desktop/myProject"  # this has to be a full path instead of "~/Desktop/myProject"
cmd+=" --output-hdf5 demo_FDC_n${nsubj}.h5"

echo $cmd
$cmd