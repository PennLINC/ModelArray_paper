#!/bin/bash
# this is to use ConFixel to convert .mif files into a .h5 file

source ../config_global.txt    # to get variable "conda_env"

# activate the conda environment:
source ~/miniconda3/etc/profile.d/conda.sh    # !!! have to source it before running "conda activate <name>"
conda activate ${conda_env}   

# also temporarily change folder "for_fixelcfestats" as "FDC"

nsubj=938
cmd="confixel"
cmd+=" --index-file index_and_directions_files/index.mif"
cmd+=" --directions-file index_and_directions_files/directions.mif"
cmd+=" --cohort-file df_example_n${nsubj}.csv"
cmd+=" --relative-root /home/chenying/Desktop/fixel_project/data/data_from_josiane"
cmd+=" --output-hdf5 ltn_FDC_n${nsubj}_confixel.h5"

echo $cmd
$cmd