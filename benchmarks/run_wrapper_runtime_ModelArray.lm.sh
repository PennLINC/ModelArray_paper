#!/bin/bash

# This is to profile runtime of ModelArray

# `-M FALSE`, so that the memory profiling won't be on
# IF ON A CLUSTER: `-I FALSE`, so that the ModelArray won't be installed again in the singularity image!
# IF ON A CLUSTER: iterating -P of 1,2,3...10 to make sure no same files running at the same time!
# `-s 1` will not be used



main_cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 10 -S 30 -c 4 -w sge -M FALSE -I FALSE"

cmd="${main_cmd} -P 1"