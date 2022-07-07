#!/bin/bash

# This is to profile runtime of ModelArray

# `-M FALSE`, so that the memory profiling won't be on
# IF ON A CLUSTER: `-I FALSE`, so that the ModelArray won't be installed again in the singularity image!
# IF ON A CLUSTER: iterating -P of 1,2,3...10 to make sure no same files running at the same time!
# `-s 1` will not be used


while getopts f:S:c:P: flag
do
        case "${flag}" in
                f) num_fixels=${OPTARG};;   # 0 as full
                S) num_subj=${OPTARG};;
                c) num_cores=${OPTARG};;
                P) copy_index=${OPTARG};;  # e.g., integer 1-10, in case it is run in parallel; 0: only 1 copy and use it
        esac
done


main_cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f ${num_fixels} -S ${num_subj} -c ${num_cores} -w sge -O FALSE -M FALSE -I FALSE"

cmd="${main_cmd} -P ${copy_index}"
echo $cmd
$cmd