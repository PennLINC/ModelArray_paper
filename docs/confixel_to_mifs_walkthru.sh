#!/bin/bash
# this is for demo data for walk-thru!

source ../config_global.txt    # to get variable "conda_env"

# activate the conda environment:
source ${conda_sh_file}    # !!! have to source it before running "conda activate <name>"
conda activate ${conda_env}  
current_conda_env=`echo $CONDA_DEFAULT_ENV`   # get the current conda enviroment's name
echo "current conda environment: ${current_conda_env}"

# also temporarily change folder "for_fixelcfestats" as "FDC"

# ++++++++++++++++++++++++++++++++++++
nsubj=100
date_h5="20220512-213911"
analysis_name="results_lm"
# ++++++++++++++++++++++++++++++++++++

filename_h5_woext="demo_FDC_n${nsubj}_wResults_nfixels-0_${date_h5}"

cmd="fixelstats_write"
cmd+=" --index-file FDC/index.mif"
cmd+=" --directions-file FDC/directions.mif"
cmd+=" --cohort-file cohort_FDC_n${nsubj}.csv"
cmd+=" --relative-root /home/chenying/Desktop/myProject"
cmd+=" --analysis-name ${analysis_name}"
cmd+=" --input-hdf5 ${filename_h5_woext}.h5"
cmd+=" --output-dir ${analysis_name}"

echo $cmd
$cmd