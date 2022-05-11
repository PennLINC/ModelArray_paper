#!/bin/bash

source ../config_global.txt  # flag_where and ModelArray_commitSHA

# activate the appropriate conda env:
source ${conda_sh_file}    # !!! have to source it before running "conda activate <name>"
conda activate ${conda_env}
current_conda_env=`echo $CONDA_DEFAULT_ENV`   # get the current conda enviroment's name
echo "current conda environment: ${current_conda_env}"


# ++++++++++++++++++++++++++++++++++++++++++++
dataset_name="josiane"
num_fixels=0
num_subj=100
num_cores=4
which_model="lm"    # "lm" or "gam"  # +++
# ++++++++++++++++++++++++++++++++++++++++++++

printf -v date '%(%Y%m%d-%H%M%S)T' -1   # $date, in YYYYmmdd-HHMMSS
echo "date variable: ${date}"


echo "flag_where: ${flag_where}"
echo "ModelArray_commitSHA: ${ModelArray_commitSHA}"
echo "dataset name: $dataset_name"
echo "num_fixels: $num_fixels"
echo "num_subj: $num_subj"
echo "num_cores: $num_cores"
echo "which_model: $which_model"

if [[  "$flag_where" == "vmware"  ]]; then
    folder_main="/home/chenying/Desktop/myProject"
    filename_output="demo_FDC_n${num_subj}_wResults_nfixels-${num_fixels}_${date}"

fi

fn_R_output="${folder_main}/${filename_output}.txt"

cmd="Rscript ./run_walkthru_allFixels.R $dataset_name $num_fixels $num_subj $num_cores $filename_output $ModelArray_commitSHA ${which_model} ${folder_main} > ${fn_R_output} 2>&1 &"
echo $cmd
Rscript ./run_walkthru_allFixels.R $dataset_name $num_fixels $num_subj $num_cores $filename_output $ModelArray_commitSHA ${which_model} ${folder_main} > ${fn_R_output} 2>&1 &