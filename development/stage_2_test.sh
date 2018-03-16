#!/usr/bin/env bash

# Standard Arguments
pipeline_input_root=$1
pipeline_output_root=$2
tile_relative_path=$3
tile_name=$4

# Optional Arguments
project_name=$5
project_root=$6
log_root_path=$7
adjacent_relative_path=$8
adjacent_tile_name=$9
expected_exit_code=${10}
task_id=${11}
is_cluster_job=${12}

node ${PWD}/scripts/stage_2.js ${project_name} ${project_root} ${pipeline_input_root} ${pipeline_output_root} ${tile_relative_path} ${tile_name} ${log_root_path} ${adjacent_relative_path} ${adjacent_tile_name} ${expected_exit_code} ${task_id} ${is_cluster_job} 
