#!/usr/bin/env bash

# Standard arguments passed to all tasks.
pipeline_input_root=${1}
pipeline_output_root=${2}
tile_relative_path=${3}
tile_name=${4}


# User-defined arguments
expected_exit_code=${5}
task_id=${6}
app=${7}
# app="${7}/compression"
mcrRoot=${8}
compression_lvl=${9}
delete_file=${10}

exit_code=255

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
    export MCR_CACHE_ROOT="/groups/mousebrainmicro/home/${USER}/mcr_cache_root.${task_id}"
fi

mkdir -p ${MCR_CACHE_ROOT}

# Compile derivatives
input_base="${pipeline_input_root}/${tile_relative_path}"
output_base="${pipeline_output_root}/${tile_relative_path}"

cmd="${app} ${input_base} ${output_base} ${compression_lvl} ${delete_file}"
echo ${cmd}
eval ${cmd}

# Store before the next calls change the value.
exit_code=$?

if [ -e ${output_file} ]
then
    chmod 775 ${output_file}
fi

echo "Attempting to clear cache at ${MCR_CACHE_ROOT}"
clean_mcr_cache_root
exit ${exit_code}
