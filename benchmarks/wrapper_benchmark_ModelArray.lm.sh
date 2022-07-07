#!/bin/bash

# example command:
# bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D test_n50 -f 10000 -S 50 -c 2 -w interactive -M TRUE
# bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 0 -S 30 -c 2 -w vmware -M TRUE
# qsub -l h_vmem=30G wrapper_benchmark_ModelArray.lm.sh -s 1 -D test_n50 -f 100 -S 100 -c 2 -w sge -M TRUE   # this will add ${JOB_ID} to foldername; run at interactive node to determine the memory requirements... # tried 20G, did not run..

source ../benchmarks/config.txt  # flag_where and ModelArray_commitSHA

while getopts s:D:f:S:c:w:O:M:I:P: flag
do
        case "${flag}" in
                s) sample_sec=${OPTARG};;
                # d) d_memrec=${OPTARG};;
                D) dataset_name=${OPTARG};;
                f) num_fixels=${OPTARG};;   # 0 as full
                S) num_subj=${OPTARG};;
                c) num_cores=${OPTARG};;
                w) run_where=${OPTARG};;    # "sge" or "interactive" or "vmware"
                O) overwrite=${OPTARG};;   # "TRUE"
                M) run_memoryProfiler=${OPTARG};;   # "TRUE" or "FALSE"
                I) flag_to_install=${OPTARG};;    # TRUE (to explicitly install ModelArray) or FALSE (not to install and use the installed ModelArray)
                P) copy_index=${OPTARG};;  # e.g., integer 1-10, in case it is run in parallel; 0: only 1 copy and use it
        esac
done

echo "JOB_ID = ${JOB_ID}"

printf -v date '%(%Y%m%d-%H%M%S)T' -1   # $date, in YYYYmmdd-HHMMSS
echo "date variable: ${date}"

ModelArray_commitSHA_short=${ModelArray_commitSHA:0:7}  # first 7 characters in SHA

ModelArrayPaper_commitSHA=`git rev-parse HEAD`
ModelArrayPaper_commitSHA_short=${ModelArrayPaper_commitSHA:0:7}  # first 7 characters in SHA

foldername_jobid="MAsha-${ModelArray_commitSHA_short}.MAPsha-${ModelArrayPaper_commitSHA_short}."
foldername_jobid+="lm.${dataset_name}.nfixel-${num_fixels}.nsubj-${num_subj}.ncore-${num_cores}.${run_where}"

if [[ "$run_memoryProfiler" == "TRUE"  ]]; then
        foldername_jobid="${foldername_jobid}.runMemProfiler"  
else 
        foldername_jobid="${foldername_jobid}.noMemProfiler"
fi

# add ${sample_sec} to the foldername:
foldername_jobid="${foldername_jobid}.s-${sample_sec}sec"

if [  "$run_where" = "sge" ]; then
        folder_benchmark="/cbica/projects/fixel_db/FixelArray_benchmark"
        
        echo "adding date & JOB_ID to foldername"
        foldername_jobid="${foldername_jobid}.${date}.job${JOB_ID}"


elif [[ "$run_where" == "interactive"   ]]; then
        folder_benchmark="/cbica/projects/fixel_db/FixelArray_benchmark"

elif [[ "$run_where" == "vmware"   ]]; then
        folder_benchmark="/home/chenying/Desktop/fixel_project/FixelArray_benchmark"

        echo "adding date to foldername"
        foldername_jobid="${foldername_jobid}.${date}"
fi

folder_jobid="${folder_benchmark}/${foldername_jobid}"
# echo "folder_jobid: ${folder_jobid}"


if [ -d ${folder_jobid} ] && [ "${overwrite}" = "TRUE" ]
then
        echo "removing existing folder:   ${folder_jobid}"
        rm -r ${folder_jobid}
fi
mkdir ${folder_jobid}
echo "output folder:   ${folder_jobid}"
# echo "output foldername for this job: foldername_jobid"

fn_output_txt="${folder_jobid}/output.txt"
# echo "fn_output_txt: ${fn_output_txt}"

# call:
# for memrec:
# bash benchmark_ModelArray.lm.sh -d $d_memrec -D $dataset_name -f $num_fixels -s $num_subj -c $num_cores -w $run_where -o ${folder_jobid} > $fn_output_txt 2>&1
# for wss:
bash benchmark_ModelArray.lm.sh -s $sample_sec -D $dataset_name -f $num_fixels -S $num_subj -c $num_cores -w $run_where -o ${folder_jobid} -M ${run_memoryProfiler} -A ${ModelArray_commitSHA} -a ${ModelArrayPaper_commitSHA} -I ${flag_to_install} -P ${copy_index} > $fn_output_txt 2>&1