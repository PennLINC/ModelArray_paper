#!/bin/bash

source ../config_global.txt
unset ModelArray_commitSHA  # remove this variable which will later be set in the inputs
unset flag_where  # later: run_where

# activate the appropriate conda env:
source ${conda_sh_file}    # !!! have to source it before running "conda activate <name>"
conda activate ${conda_env}
current_conda_env=`echo $CONDA_DEFAULT_ENV`   # get the current conda enviroment's name
echo "current conda environment: ${current_conda_env}"

while getopts s:D:f:S:c:w:o:M:A:a: flag
do
	case "${flag}" in
		s) sample_sec=${OPTARG};;   # for wss.pl
		# d) d_memrec=${OPTARG};;
		D) dataset_name=${OPTARG};;
		f) num_fixels=${OPTARG};;   # 0 as full
		S) num_subj=${OPTARG};;
		c) num_cores=${OPTARG};;
		w) run_where=${OPTARG};;    # "sge" or "interactive" or "vmware" or "dopamine"
		o) output_folder=${OPTARG};;  # generated in wrapper.sh
		M) run_memoryProfiler=${OPTARG};;   # TRUE or FALSE
		A) ModelArray_commitSHA=${OPTARG};;
		a) ModelArrayPaper_commitSHA=${OPTARG};;
	esac
done

date

echo "sampling every __ sec when memory profiling: $sample_sec"
echo "ModelArray_commitSHA: ${ModelArray_commitSHA}"  
echo "ModelArrayPaper_commitSHA: ${ModelArrayPaper_commitSHA}" 
echo "dataset name: $dataset_name"
echo "num_fixels: $num_fixels"
echo "num_subj: $num_subj"
echo "num_cores: $num_cores"
echo "run_where: $run_where"
echo "output_folder: $output_folder"


fn_R_output="${output_folder}/Routput.txt"
fn_myMemProf="${output_folder}/output_myMemoryProfiler.txt"

echo ""

cmd="Rscript ./memoryProfiling_ModelArray.lm.R $dataset_name $num_fixels $num_subj $num_cores ${ModelArray_commitSHA} ${ModelArrayPaper_commitSHA} > ${fn_R_output}  2>&1 &"
echo $cmd
Rscript ./memoryProfiling_ModelArray.lm.R $dataset_name $num_fixels $num_subj $num_cores ${ModelArray_commitSHA} ${ModelArrayPaper_commitSHA} > ${fn_R_output}  2>&1 &     # cannot run at background if using $cmd to execuate..

parent_id=$!  # get the pid of last execuated command

echo "parent id = ${parent_id}"


if [[ "$run_memoryProfiler" == "TRUE"  ]]; then
	bash myMemoryProfiler.sh -P ${parent_id} -c ${num_cores} -s ${sample_sec} -o ${output_folder} > ${fn_myMemProf} 2>&1
else
	echo "not to call myMemoryProfiler.sh to profile memory"

fi

