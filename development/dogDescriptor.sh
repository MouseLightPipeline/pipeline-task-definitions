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

# Custom task arguments defined by task definition
app="${11}/dogDescriptor"
mcrRoot=${12}

exit_code=255

# args: channel index, input file base name, output file base name
perform_action () {
    input_file="${2}.${1}.h5"
    output_file="${3}.${1}.txt"

    cmd="${app} ${input_file} ${output_file} \"[11 11 11]\" \"[3.405500 3.405500 3.405500]\" \"[4.049845 4.049845 4.049845]\" \"[5 1019 5 1531 5 250]\" 4"
    eval ${cmd}

    # Store before the next calls change the value.
    exit_code=$?

    if [ -e ${output_file} ]
    then
        chmod 775 ${output_file}
    fi
}

clean_mcr_cache_root () {
    if [ -d ${MCR_CACHE_ROOT} ]
    then
        rm -rf ${MCR_CACHE_ROOT}
    fi
}

export LD_LIBRARY_PATH=.:${mcrRoot}/runtime/glnxa64
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/bin/glnxa64
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/sys/os/glnxa64
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/sys/opengl/lib/glnxa64

if [ -d "/scratch/\${USER}" ]
then
    export MCR_CACHE_ROOT="/scratch/\${USER}/mcr_cache_root.${task_id}"
else
    export MCR_CACHE_ROOT="~/mcr_cache_root.${task_id}"
fi

mkdir -p ${MCR_CACHE_ROOT}

# Compile derivatives
input_base="${pipeline_input_root}/${tile_relative_path}/${tile_name}-prob"
output_base="${pipeline_output_root}/${tile_relative_path}/${tile_name}-desc"

for idx in `seq 0 1`
do
    perform_action ${idx} ${input_base} ${output_base}

    if [ ${exit_code} -eq ${expected_exit_code} ]
    then
      echo "Completed descriptor for channel ${idx}."
    else
      echo "Failed descriptor for channel ${idx}."
      clean_mcr_cache_root
      exit ${exit_code}
    fi
done

clean_mcr_cache_root

exit ${exit_code}

