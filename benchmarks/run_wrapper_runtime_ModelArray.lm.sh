#!/bin/bash

# This is to profile runtime of ModelArray

# make sure `-M` is `FALSE`, so that the memory profiling won't be on
# `-s 1` will not be used


cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 10 -S 30 -c 4 -w sge -M FALSE"