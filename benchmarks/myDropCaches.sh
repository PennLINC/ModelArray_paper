#!/bin/bash
# set up: change current file's permission: executable; 

# sync; echo 3 > /proc/sys/vm/drop_caches
source /home/chenying/Desktop/personal/thatsit.txt
sync
echo $thatsit | sudo -S sh -c "echo 3 > /proc/sys/vm/drop_caches"
echo "dropping caches: exit = $?"

sleeptime="60"   # sec
echo "sleep for ${sleeptime} sec for dropping caches to take effects..."
sleep $sleeptime