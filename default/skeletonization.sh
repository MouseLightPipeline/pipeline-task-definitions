#!/usr/bin/env bash

# Standard arguments passed to all tasks.
# Unused -  pipeline_input_root=${1}
pipeline_output_root=${2}
tile_relative_path=${3}
tile_name=${4}

# System paramete sdefined by task definition
task_id=${5}
sx=${6}
sy=${7}
sz=${8}
ex=${9}
ey=${10}
ez=${11}

# Custom task literal arguments defined by task definition
datafile=${12}
dataset=${13}
configFile=${14}
app=${15}
mcrRoot=${16}
scratchRoot=${17}

clean_mcr_cache_root () {
    if [ -d "${MCR_CACHE_ROOT}" ]
    then
        rm -rf "${MCR_CACHE_ROOT}"
    fi
}

# Compile derivatives

# Values passed to application are interlaced (start/end x, start/end y, start/end z)
inputRange="[${sx},${ex},${sy},${ey},${sz},${ez}]"

# Values in output file name are not.
output_tile="${pipeline_output_root}/${tile_relative_path}/lev-6_chunk-111_111_masked-0_idx-${tile_name}_stxyzendxyz-${sx}_${sy}_${sz}_${ex}_${ey}_${ez}.txt"

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

mkdir -p "${MCR_CACHE_ROOT}"

cmd="${app} ${datafile} ${dataset} \"${inputRange}\" ${output_tile} ${configFile}"

echo "${cmd}"

eval "${cmd}"

# Store before the next calls change the value.
exit_code=$?

if [ ${exit_code} -eq 0 ]
then
  echo "Completed skeletonization."
else
  echo "Failed clusterSkel."
fi

clean_mcr_cache_root

exit ${exit_code}