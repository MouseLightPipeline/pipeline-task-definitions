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

# Compile derivatives
input_file1="$pipeline_input_root/$tile_relative_path/$tile_name-ngc.0.tif"
input_file2="$pipeline_input_root/$tile_relative_path/$tile_name-ngc.1.tif"

output_file="$pipeline_output_root/$tile_relative_path/$tile_name"
output_file+="-prob"
output_file_1="$output_file.0.h5"
output_file_2="$output_file.1.h5"

log_file_1="${log_root_path}.0.log"
log_file_2="${log_root_path}.1.log"

output_format="hdf5"

# Default location on test and production machines.  Can also export IL_PREFIX in worker profile script (typically id.sh).
if [ -z "$IL_PREFIX" ]
then
  if [ "$(uname)" == "Darwin" ]
  then
    IL_PREFIX=/Volumes/Spare/Projects/MouseLight/Classifier/ilastik/ilastik-1.1.8-OSX.app/Contents/ilastik-release
  else
    IL_PREFIX=/groups/mousebrainmicro/mousebrainmicro/cluster/software/ilastik-1.1.9-Linux
  fi
fi

cmd1="${IL_PREFIX}/bin/python ${IL_PREFIX}/ilastik-meta/ilastik/ilastik.py --logfile=${log_file_1} --headless --cutout_subregion=\"[(None,None,None,0),(None,None,None,1)]\" --project=\"${ilastik_project}\" --output_filename_format=\"${output_file_1}\" --output_format=\"${output_format}\" \"$input_file1\""
cmd2="${IL_PREFIX}/bin/python ${IL_PREFIX}/ilastik-meta/ilastik/ilastik.py --logfile=${log_file_2} --headless --cutout_subregion=\"[(None,None,None,0),(None,None,None,1)]\" --project=\"${ilastik_project}\" --output_filename_format=\"${output_file_2}\" --output_format=\"${output_format}\" \"$input_file2\""

export LD_LIBRARY_PATH=""
export PYTHONPATH=""
export QT_PLUGIN_PATH=${IL_PREFIX}/plugins

export LAZYFLOW_THREADS=18
export LAZYFLOW_TOTAL_RAM_MB=200000

# Channel 0
eval ${cmd1}

# Store before the next calls change the value.
exit_code=$?

if [ -e ${output_file_1} ]
then
    chmod 775 ${output_file_1}
fi

if [ -e ${log_file_1} ]
then
    chmod 775 ${log_file_1}
fi

if [ ${exit_code} -eq ${expected_exit_code} ]
then
  echo "Completed classifier for channel 0."
else
  echo "Failed classifier for channel 0."
  exit ${exit_code}
fi

# Channel 1
eval ${cmd2}

exit_code=$?

if [ -e ${output_file_2} ]
then
    chmod 775 ${output_file_2}
fi

if [ -e ${log_file_2} ]
then
    chmod 775 ${log_file_2}
fi

if [ ${exit_code} -eq ${expected_exit_code} ]
then
  echo "Completed classifier for channel 1."
else
  echo "Failed classifier for channel 1."
fi

exit ${exit_code}
