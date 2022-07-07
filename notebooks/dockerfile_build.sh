#!/bin/bash

dockerhub_accountname="chenyingzhao"
gear_name="modelarray"
gear_tag="SHA0911c4f_v1"

## build:
cmd="docker build -t ${dockerhub_accountname}/${gear_name}:${gear_tag} ."
echo $cmd
#$cmd

## check if the built docker file is good:
cmd="docker run --rm -it ${dockerhub_accountname}/${gear_name}:${gear_tag} R"
echo $cmd
#$cmd

## push:
cmd="docker push '${dockerhub_accountname}/${gear_name}:${gear_tag}'"
echo $cmd
#$cmd

## after pushing to DockerHub, pulling it on the cluster:
# cd ~
cmd="singularity pull docker://${dockerhub_accountname}/${gear_name}:${gear_tag}"
echo $cmd