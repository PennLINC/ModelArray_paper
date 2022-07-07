#!/bin/bash

dockerhub_accountname="chenyingzhao"
gear_name="modelarray"
gear_tag="SHA0911c4f_v1"

cmd="docker build -t ${dockerhub_accountname}/${gear_name}:${gear_tag} ."
echo $cmd
#$cmd

cmd="docker push '${dockerhub_accountname}/${gear_name}:${gear_tag}'"
echo $cmd
#$cmd