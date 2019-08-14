#!/usr/bin/env bash

# Standard arguments passed to all tasks.
pipeline_input_root=${1}
pipeline_output_root=${2}
tile_relative_path=${3}
tile_name=${4}


# User-defined arguments
expected_exit_code=${5}
task_id=${6}
config_file=${7}
app="${8}/vesselDescriptor"
mcrRoot=${9}
scratchRoot=${10}

exit_code=255

# args: channel index, input file base name, output file base name
perform_action () {
    input_file="${2}.${1}.tif"
    output_file="${3}.${1}.mat"

    cmd="${app} ${input_file} ${output_file} ${config_file}"
    eval ${cmd}

    # Store before the next calls change the value.
    exit_code=$?

    if [ -e ${output_file} ]
    then
        chmod 775 ${output_file}
    f
}

clean_mcr_cache_root () {
    echo "Clearing cache at ${MCR_CACHE_ROOT}"

    if [ -d ${MCR_CACHE_ROOT} ]
    then
        echo "Found mcr cache root directory"
        rm -rf ${MCR_CACHE_ROOT}
        echo $?
    fi
}

export LD_LIBRARY_PATH=.:${mcrRoot}/runtime/glnxa64
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/bin/glnxa64
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/sys/os/glnxa64
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/sys/opengl/lib/glnxa64

if [ -d "/scratch/${USER}" ]
then
    export MCR_CACHE_ROOT="/scratch/${USER}/mcr_cache_root.${task_id}"
else
    export MCR_CACHE_ROOT="${scratchRoot}/${USER}/mcr_cache_root.${task_id}"
fi

mkdir -p ${MCR_CACHE_ROOT}

# Compile derivatives
input_base="${pipeline_input_root}/${tile_relative_path}/${tile_name}-ngc"
output_base="${pipeline_output_root}/${tile_relative_path}/${tile_name}-desc"

# for idx in `seq 0 1`
for idx in {0..0}
do
    perform_action ${idx} "${input_base}" "${output_base}"

    if [ ${exit_code} -eq ${expected_exit_code} ]
    then
      echo "Completed descriptor for channel ${idx}."
    else
      echo "Failed descriptor for channel ${idx}."
      clean_mcr_cache_root
      exit ${exit_code}
    fi
done
echo "Attempting to clear cache at ${MCR_CACHE_ROOT}"
clean_mcr_cache_root

exit ${exit_code}
