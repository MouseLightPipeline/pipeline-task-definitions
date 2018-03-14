#!/usr/bin/env bash

# Standard arguments passed to all tasks.
project_name=$1
project_root=$2
pipeline_input_root=$3
pipeline_output_root=$4
tile_relative_path=$5
tile_name=$6
log_root_path=$7
expected_exit_code=$8
task_id=$9
is_cluster_job=${10}

node ${PWD}/scripts/stage_1.js ${project_name} ${project_root} ${pipeline_input_root} ${pipeline_output_root} ${tile_relative_path} ${tile_name} ${log_root_path} ${expected_exit_code} ${task_id} ${is_cluster_job} 
