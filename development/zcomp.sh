#!/usr/bin/env bash

project_name=$1
project_root=$2
pipeline_input_root=$3
pipeline_output_root=$4
tile_relative_path=$5
tile_name=$6
log_root_path=$7
z_minus_1_relative_path=$8
z_minus_1_tile_name=$9
expected_exit_code=${10}
worker_id=${11}
is_cluster_job=${12}

echo $1
echo $2
echo $3
echo $4
echo $5
echo $6
echo $7
echo $8
echo $9
echo ${10}
echo ${11}

DUR=$(($RANDOM % 10 + 4))

sleep ${DUR}

exit 0
