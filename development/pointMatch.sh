#!/usr/bin/env bash

# Standard arguments passed to all tasks.
project_name=$1
project_root=$2
pipeline_input_root=$3
pipeline_output_root=$4
tile_relative_path=$5
tile_name=$6
log_root_path=$7
z_plus_1_relative_path=$8
z_plus_1_tile_name=$9
expected_exit_code=${10}
task_id=${11}
is_cluster_job=${12}

# Custom task arguments defined by task definition
app="${13}/pointmatch"
mcrRoot=${14}

clean_mcr_cache_root() {
    if [ -d ${MCR_CACHE_ROOT} ]
    then
        rm -rf ${MCR_CACHE_ROOT};
    fi
}

# Compile derivatives
input_tile_1="${pipeline_input_root}/${tile_relative_path}"
input_tile_2="${pipeline_input_root}/${z_plus_1_relative_path}"

acq_folder_1="${project_root}/${tile_relative_path}"
acq_folder_2="${project_root}/${z_plus_1_relative_path}"

output_tile="${pipeline_output_root}/${tile_relative_path}"

export LD_LIBRARY_PATH=.:${mcrRoot}/runtime/glnxa64 ;
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/bin/glnxa64 ;
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/sys/os/glnxa64;
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/sys/opengl/lib/glnxa64;

if [ -d "/scratch/\${USER}" ]
then
    export MCR_CACHE_ROOT="/scratch/\${USER}/mcr_cache_root.${task_id}";
else
    export MCR_CACHE_ROOT="~/mcr_cache_root.${task_id}";
fi

mkdir -p ${MCR_CACHE_ROOT}

cmd="${app} ${input_tile_1} ${input_tile_2} ${acq_folder_1} ${acq_folder_2} ${output_tile} ${expected_exit_code}"

eval ${cmd}

# Store before the next calls change the value.
exit_code=$?

if [ ${exit_code} -eq ${expected_exit_code} ]
then
  echo "Completed pointMatch."
else
  echo "Failed pointMatch."
fi

clean_mcr_cache_root;
exit ${exit_code}
