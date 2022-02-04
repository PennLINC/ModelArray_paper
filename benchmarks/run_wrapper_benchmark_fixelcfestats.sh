#!/bin/bash

function wait_r_end {
    while :
    do
        pid_r=`ps -aux | grep "[f]ixelcfestats " | awk '{print $2}'`     # [R] is to remove result of grep search; "awk" is to return pid only
        if [ -z "$pid_r" ]; then
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


wait_r_end 600   # in seconds
bash myDropCaches.sh
cmd="bash wrapper_benchmark_fixelcfestats.sh -S 30 -h 100 -t 4 -f TRUE -F FALSE -n FALSE -w vmware -M TRUE -s 1"
echo $cmd
$cmd

wait_r_end 300   # in seconds
bash myDropCaches.sh
cmd="bash wrapper_benchmark_fixelcfestats.sh -S 100 -h 100 -t 4 -f TRUE -F FALSE -n FALSE -w vmware -M TRUE -s 1"
echo $cmd
$cmd

wait_r_end 300   # in seconds
bash myDropCaches.sh
cmd="bash wrapper_benchmark_fixelcfestats.sh -S 300 -h 100 -t 4 -f TRUE -F FALSE -n FALSE -w vmware -M TRUE -s 1"
echo $cmd
$cmd

wait_r_end 300   # in seconds
bash myDropCaches.sh
cmd="bash wrapper_benchmark_fixelcfestats.sh -S 500 -h 100 -t 4 -f TRUE -F FALSE -n FALSE -w vmware -M TRUE -s 1"
echo $cmd
$cmd

# wait_r_end 300   # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_fixelcfestats.sh -S 750 -h 100 -t 4 -f TRUE -F FALSE -n FALSE -w vmware -M TRUE -s 1"
# echo $cmd
# $cmd

# wait_r_end 300   # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_fixelcfestats.sh -S 938 -h 100 -t 4 -f TRUE -F FALSE -n FALSE -w vmware -M TRUE -s 1"
# echo $cmd
# $cmd

# wait_r_end 300   # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_fixelcfestats.sh -S 30 -h 100 -t 1 -f TRUE -F FALSE -n FALSE -w vmware -M TRUE -s 1"
# echo $cmd
# $cmd

# wait_r_end 300   # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_fixelcfestats.sh -S 30 -h 100 -t 2 -f TRUE -F FALSE -n FALSE -w vmware -M TRUE -s 1"
# echo $cmd
# $cmd

# wait_r_end 300   # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_fixelcfestats.sh -S 30 -h 100 -t 3 -f TRUE -F FALSE -n FALSE -w vmware -M TRUE -s 1"
# echo $cmd
# $cmd

# wait_r_end 300   # in seconds
# bash myDropCaches.sh
# cmd="bash wrapper_benchmark_fixelcfestats.sh -S 938 -h 100 -t 1 -f TRUE -F FALSE -n FALSE -w vmware -M TRUE -s 1"
# echo $cmd
# $cmd

wait_r_end 300   # in seconds
bash myDropCaches.sh
cmd="bash wrapper_benchmark_fixelcfestats.sh -S 938 -h 100 -t 2 -f TRUE -F FALSE -n FALSE -w vmware -M TRUE -s 1"
echo $cmd
$cmd 

wait_r_end 300   # in seconds
bash myDropCaches.sh
cmd="bash wrapper_benchmark_fixelcfestats.sh -S 938 -h 100 -t 3 -f TRUE -F FALSE -n FALSE -w vmware -M TRUE -s 1"
echo $cmd
$cmd 


wait_r_end 1
date