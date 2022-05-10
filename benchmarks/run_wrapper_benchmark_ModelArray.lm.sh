#!/bin/bash

source ../config_global.txt

# activate the appropriate conda env:
source ${conda_sh_file}    # !!! have to source it before running "conda activate <name>"
conda activate ${conda_env}
current_conda_env=`echo $CONDA_DEFAULT_ENV`   # get the current conda enviroment's name
echo "current conda environment: ${current_conda_env}"

function wait_r_end {
    while :
    do
        pid_r=`ps -aux | grep "[R] --no-echo --no-restore" | awk '{print $2}'`     # [R] is to remove result of grep search; "awk" is to return pid only
        if [ -z "$pid_r" ]; then    # after there is no R running
            date
            echo "sleep for $1 sec..."
            sleep $1

            date    # date again before break
            break
        fi
    done
}

# use for correction: # checkout parent.multi and child0.multi
#bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D test_n50 -f 1000 -S 50 -c 4 -w vmware -M TRUE

wait_r_end 60   # in seconds

# wait_r_end 150   # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 0 -S 30 -c 4 -w vmware -M TRUE"
# echo $cmd
# $cmd

# wait_r_end 300  # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 0 -S 100 -c 4 -w vmware -M TRUE"
# echo $cmd
# $cmd

# wait_r_end 300  # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 0 -S 300 -c 4 -w vmware -M TRUE"
# echo $cmd
# $cmd

# wait_r_end 300  # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 0 -S 500 -c 4 -w vmware -M TRUE"
# echo $cmd
# $cmd

# wait_r_end 300  # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 0 -S 750 -c 4 -w vmware -M TRUE"
# echo $cmd
# $cmd

#wait_r_end 300  # in seconds
bash myDropCaches.sh
cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 0 -S 938 -c 4 -w vmware -M TRUE"
echo $cmd
$cmd

# wait_r_end 300   # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 0 -S 30 -c 2 -w vmware -M TRUE"
# echo $cmd
# $cmd

# wait_r_end 300   # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 0 -S 30 -c 1 -w vmware -M TRUE"
# echo $cmd
# $cmd

# wait_r_end 300   # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 0 -S 30 -c 3 -w vmware -M TRUE"
# echo $cmd
# $cmd

# wait_r_end 300   # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 0 -S 938 -c 1 -w vmware -M TRUE"
# echo $cmd
# $cmd

# wait_r_end 300   # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 0 -S 938 -c 2 -w vmware -M TRUE"
# echo $cmd
# $cmd

# wait_r_end 300   # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_ModelArray.lm.sh -s 1 -D josiane -f 0 -S 938 -c 3 -w vmware -M TRUE"
# echo $cmd
# $cmd