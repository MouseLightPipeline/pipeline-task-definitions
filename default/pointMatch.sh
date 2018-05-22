#!/usr/bin/env bash

# Standard arguments passed to all tasks.
pipeline_input_root=${1}
pipeline_output_root=${2}
tile_relative_path=${3}
tile_name=${4}

# User-defined arguments
project_root=${5}
z_plus_1_relative_path=${6}
expected_exit_code=${7}
task_id=${8}
# Custom task arguments defined by task definition
app="${9}/pointmatch"
mcrRoot=${10}

if [ "$#" -gt 10 ]; then
	pixshift=${11}
	ch=${12}
	maxnumofdesc=${13}
else
	pixshift='[0,0,0]'
	ch=1
	maxnumofdesc=10000
fi


clean_mcr_cache_root () {
    if [ -d ${MCR_CACHE_ROOT} ]
    then
        rm -rf ${MCR_CACHE_ROOT}
    fi
}

# Compile derivatives
input_tile_1="${pipeline_input_root}/${tile_relative_path}"
input_tile_2="${pipeline_input_root}/${z_plus_1_relative_path}"

acq_folder_1="${project_root}/${tile_relative_path}"
acq_folder_2="${project_root}/${z_plus_1_relative_path}"

output_tile="${pipeline_output_root}/${tile_relative_path}"

export LD_LIBRARY_PATH=.:${mcrRoot}/runtime/glnxa64
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/bin/glnxa64
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/sys/os/glnxa64
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/sys/opengl/lib/glnxa64

if [ -d "/scratch/${USER}" ]
then
    export MCR_CACHE_ROOT="/scratch/${USER}/mcr_cache_root.${task_id}"
else
    export MCR_CACHE_ROOT="/groups/mousebrainmicro/home/${USER}/mcr_cache_root.${task_id}"
fi

mkdir -p ${MCR_CACHE_ROOT}

# cmd="${app} ${input_tile_1} ${input_tile_2} ${acq_folder_1} ${acq_folder_2} ${output_tile} ${expected_exit_code}"
cmd="${app} ${input_tile_1} ${input_tile_2} ${acq_folder_1} ${acq_folder_2} ${output_tile} ${pixshift} ${ch} ${maxnumofdesc} ${expected_exit_code}"
echo ${cmd}
eval ${cmd}

# Store before the next calls change the value.
exit_code=$?

if [ ${exit_code} -eq ${expected_exit_code} ]
then
  echo "Completed pointMatch."
else
  echo "Failed pointMatch."
fi

clean_mcr_cache_root
exit ${exit_code}