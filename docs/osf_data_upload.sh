#!/bin/bash
# This is to tar zip the demo data to be uploaded to OSF
# ref: https://www.cyberciti.biz/faq/how-to-tar-a-file-in-linux-using-command-line/

nsubj=100
folder_main="/home/chenying/Desktop/myProject"

cd ${folder_main}    # so that the full path won't be added in...

tozip_1="FDC/"
tozip_2="cohort_FDC_n${nsubj}.csv"
fn_tar="demo_FDC_n${nsubj}"
#cmd="tar -czvf --xz ${fn_tar}.tar.xz ${tozip_1} ${tozip_2}"   # failed?
cmd="tar -czvf ${fn_tar}.tar.gz ${tozip_1} ${tozip_2}"
#cmd="tar -cjvf ${fn_tar}.tar.bz2 ${tozip_1} ${tozip_2}"   # relatively the same as -czvf...

echo $cmd
$cmd

# to check what's in it:
# tar -ztvf ${fn_tar}.tar.gz