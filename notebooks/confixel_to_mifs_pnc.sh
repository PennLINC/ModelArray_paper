#!/bin/bash

# make sure the conda env is correct:
# conda activate test_confixel   # <- only do this when running on Chenying's local vmware!


# ++++++++++++++++++++++++++++++++++++
filename_h5_woext="ltn_FDC_n938_wResults_nfixels-0_20220109-183909"
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