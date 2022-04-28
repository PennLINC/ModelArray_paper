#!/bin/bash

source ../config_global.txt    # to get variable "conda_env"

# activate the conda environment:
source ~/miniconda3/etc/profile.d/conda.sh    # !!! have to source it before running "conda activate <name>"
conda activate ${conda_env}  

# also temporarily change folder "for_fixelcfestats" as "FDC"

# ++++++++++++++++++++++++++++++++++++
filename_h5_woext="ltn_FDC_n938_wResults_nfixels-0_20220204-140019"
# ++++++++++++++++++++++++++++++++++++

cmd="fixelstats_write"
cmd+=" --index-file index_and_directions_files/index.mif"
cmd+=" --directions-file index_and_directions_files/directions.mif"
cmd+=" --cohort-file df_example_n938.csv"
cmd+=" --relative-root /home/chenying/Desktop/fixel_project/data/data_from_josiane"
cmd+=" --analysis-name gam_allOutputs"
cmd+=" --input-hdf5 results/${filename_h5_woext}.h5"
cmd+=" --output-dir results/${filename_h5_woext}"

echo $cmd
$cmd