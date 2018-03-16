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
expected_exit_code=$8
task_id=$9
is_cluster_job=${10}

node ${PWD}/scripts/stage_1.js ${pipeline_input_root} ${pipeline_output_root} ${tile_relative_path} ${tile_name} ${log_root_path} ${expected_exit_code} ${task_id} ${is_cluster_job}
