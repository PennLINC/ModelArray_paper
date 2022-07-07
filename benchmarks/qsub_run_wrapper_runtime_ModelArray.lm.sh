#!/bin/bash

# This is to submit the job to cubic compute node for running singularity image of ModelArray

while getopts f:S:c:P: flag
do
        case "${flag}" in
                f) num_fixels=${OPTARG};;   # 0 as full
                S) num_subj=${OPTARG};;
                c) num_cores=${OPTARG};;
                P) copy_index=${OPTARG};;  # e.g., integer 1-10, in case it is run in parallel; 0: only 1 copy and use it
        esac
done


h_vmem=30G

cmd="qsub -l h_vmem=${h_vmem} -pe threaded ${num_cores}"
cmd+=" run_wrapper_runtime_ModelArray.lm.sh -f ${num_fixels} -S ${num_subj} -c ${num_cores} -P ${copy_index}"
echo $cmd
$cmd