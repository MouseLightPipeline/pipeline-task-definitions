#!/usr/bin/env bash

# Standard arguments passed to all tasks.
project_name=$1
project_root=$2
pipeline_input_root=$3
pipeline_output_root=$4
tile_relative_path=$5
tile_name=$6
log_root_path=$7
adjacent_relative_path=$8
adjacent_tile_name=$9
expected_exit_code=${10}
task_id=${11}
is_cluster_job=${12}

node ${PWD}/scripts/stage_2.js ${project_name} ${project_root} ${pipeline_input_root} ${pipeline_output_root} ${tile_relative_path} ${tile_name} ${log_root_path} ${adjacent_relative_path} ${adjacent_tile_name} ${expected_exit_code} ${task_id} ${is_cluster_job} 
