#!/usr/bin/env bash

# Standard arguments passed to all tasks.
pipeline_input_root=${1}
pipeline_output_root=${2}
tile_relative_path=${3}
tile_name=${4}

# User-defined system arguments
sx=${5}
sy=${6}
sz=${7}
ex=${8}
ey=${8}
ez=${10}

# Custom task arguments defined by task definition
app=${11}
datafile=${12}
dataset=${13}
configFile=${14}

clean_mcr_cache_root () {
    if [ -d ${MCR_CACHE_ROOT} ]
    then
        rm -rf ${MCR_CACHE_ROOT}
    fi
}

# Compile derivatives
inputRange="[${sx},${sy},${sz},${ex},${ey},${ez}]"

output_tile="${pipeline_output_root}/lev-6_chunk-111_111_masked-0_idx-${tile_name}_stxyzendxyz-${sx}_${sy}_${sz}_${ex}_${ey}_${ez}.txt"

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

cmd="${app} ${datafile} ${dataset} \"${inputRange}\" ${output_tile} ${configFile}"
echo ${cmd}

sleep 15

touch ${output_tile}
# eval ${cmd}

# Store before the next calls change the value.
exit_code=$?

if [ ${exit_code} -eq 0 ]
then
  echo "Completed clusterSkel."
else
  echo "Failed clusterSkel."
fi

clean_mcr_cache_root
exit ${exit_code}