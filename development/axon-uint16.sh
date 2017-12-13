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
worker_id=$9
is_cluster_job=${10}

# Custom task arguments defined by task definition
ilastik_project="${11}/axon_uint16.ilp"

IL_PREFIX=/groups/mousebrainmicro/mousebrainmicro/cluster/software/ilastik-1.1.9-Linux

output_format="hdf5"

exit_code=255

# args: channel index, input file base name, output file base name
perform_action () {
    input_file="${2}.${1}.tif"
    output_file="${3}.${1}.h5"

    cmd="${IL_PREFIX}/bin/python ${IL_PREFIX}/ilastik-meta/ilastik/ilastik.py --headless --cutout_subregion=\"[(None,None,None,0),(None,None,None,1)]\" --project=\"${ilastik_project}\" --output_filename_format=\"${output_file}\" --output_format=\"${output_format}\" \"$input_file\""
    eval ${cmd}

    # Store before the next calls change the value.
    exit_code=$?

    if [ -e ${output_file} ]
    then
        chmod 775 ${output_file}
    fi

    if [ -e ${log_file} ]
    then
        chmod 775 ${log_file}
    fi
}

export LD_LIBRARY_PATH=""
export PYTHONPATH=""
export QT_PLUGIN_PATH=${IL_PREFIX}/plugins

if [ ${is_cluster_job} -eq 0 ]
then
    export LAZYFLOW_THREADS=18
    export LAZYFLOW_TOTAL_RAM_MB=200000
else
    export LAZYFLOW_THREADS=4
    export LAZYFLOW_TOTAL_RAM_MB=30000
fi

# Compile derivatives
input_base="${pipeline_input_root}/${tile_relative_path}/${tile_name}-ngc"
output_base="${pipeline_output_root}/${tile_relative_path}/${tile_name}-prob"

for idx in `seq 0 1`;
do
    perform_action ${idx} ${input_base} ${output_base} ${log_root_path}

    if [ ${exit_code} -eq ${expected_exit_code} ]
    then
      echo "Completed classifier for channel 0."
    else
      echo "Failed classifier for channel 0."
      exit ${exit_code}
    fi
done

exit ${exit_code}
