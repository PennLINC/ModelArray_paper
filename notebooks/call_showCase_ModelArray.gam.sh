#!/bin/bash

source ../config_global.txt  # flag_where and ModelArray_commitSHA

dataset_name="josiane"
num_fixels=0
num_subj=938
num_cores=4

printf -v date '%(%Y%m%d-%H%M%S)T' -1   # $date, in YYYYmmdd-HHMMSS
echo "date variable: ${date}"


echo "flag_where: ${flag_where}"
echo "ModelArray_commitSHA: ${ModelArray_commitSHA}"
echo "dataset name: $dataset_name"
echo "num_fixels: $num_fixels"
echo "num_subj: $num_subj"
echo "num_cores: $num_cores"

if [[  "$flag_where" == "vmware"  ]]; then
    folder_output_main="/home/chenying/Desktop/fixel_project/data/data_from_josiane/results"
    filename_output="ltn_FDC_n${num_subj}_wResults_nfixels-${num_fixels}_${date}"

fi

fn_R_output="${folder_output_main}/${filename_output}.txt"

cmd="Rscript ./showCase_ModelArray.gam.R $dataset_name $num_fixels $num_subj $num_cores $filename_output $ModelArray_commitSHA > ${fn_R_output} 2>&1 &"
echo $cmd
Rscript ./showCase_ModelArray.gam.R $dataset_name $num_fixels $num_subj $num_cores $filename_output $ModelArray_commitSHA > ${fn_R_output} 2>&1 &