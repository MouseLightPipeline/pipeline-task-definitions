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
is_cluster_job=$9

# Custom task arguments defined by task definition
ilastik_project="${10}/axon_uint16.ilp"

# Compile derivatives
input_file1="$pipeline_input_root/$tile_relative_path/$tile_name-ngc.0.tif"
input_file2="$pipeline_input_root/$tile_relative_path/$tile_name-ngc.1.tif"

output_file="$pipeline_output_root/$tile_relative_path/$tile_name"
output_file+="-prob"
output_file_1="$output_file.0.h5"
output_file_2="$output_file.1.h5"

log_path_base="$pipeline_output_root/$tile_relative_path/.log"
log_file_base="ax-${tile_name}"

# Create hidden log folder
mkdir -p ${log_path_base}

# Make sure group can read/write.
chmod ug+rwx ${log_path_base}
chmod o+rx ${log_path_base}

log_file_1="${log_path_base}/${log_file_base}-log.0.txt"
log_file_2="${log_path_base}/${log_file_base}-log.1.txt"

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

if [ ${is_cluster_job} -eq 0 ]
then
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
else
    LAZYFLOW_THREADS=4
    LAZYFLOW_TOTAL_RAM_MB=30000

    cluster_exports="export LAZYFLOW_THREADS=${LAZYFLOW_THREADS}; export LAZYFLOW_TOTAL_RAM_MB=${LAZYFLOW_TOTAL_RAM_MB}; LD_LIBRARY_PATH=\"\"; PYTHONPATH=\"\"; QT_PLUGIN_PATH=${IL_PREFIX}/plugins"

    # Channel 0
    err_file_1="${log_path_base}/${log_file_base}.cluster.0.err"

    ssh login1 "source /etc/profile; ${cluster_exports}; bsub -K -n 4 -J ml-ax-${tile_name} -oo ${log_file_1} -eo ${err_file_1} -cwd -R\"select[broadwell]\" ${cmd1}"

    exit_code=$?

    #  Allows any files to flush, particularly cluster error file
    sleep 2s

    if [ -e ${output_file_1} ]
    then
        chmod 775 ${output_file_1}
    fi

    if [ -e ${log_file_1} ]
    then
        chmod 775 ${log_file_1}
    fi

    if [ -e ${err_file_1} ]
    then
        if [ ! -s ${err_file_1} ]
        then
            rm ${err_file_1}
        else
            chmod 775 ${err_file_1}
        fi
    fi

    if [ ${exit_code} -eq ${expected_exit_code} ]
    then
      echo "Completed classifier for channel 0 (cluster)."
    else
      echo "Failed classifier for channel 0 (cluster)."
      exit ${exit_code}
    fi

    # Channel 1
    err_file_2="${log_path_base}/${log_file_base}.cluster.1.err"

    ssh login1 "source /etc/profile; ${cluster_exports}; bsub -K -n 4 -J ml-ax-${tile_name} -oo ${log_file_2} -eo ${err_file_2} -cwd -R\"select[broadwell]\" ${cmd2}"

    exit_code=$?

    sleep 2s

    if [ -e ${output_file_2} ]
    then
        chmod 775 ${output_file_2}
    fi

    if [ -e ${log_file_2} ]
    then
        chmod 775 ${log_file_2}
    fi

    if [ -e ${err_file_2} ]
    then
        if [ ! -s ${err_file_2} ]
        then
            rm ${err_file_2}
        else
            chmod 775 ${err_file_2}
        fi
    fi

    if [ ${exit_code} -eq ${expected_exit_code} ]
    then
      echo "Completed classifier for channel 1 (cluster)."
    else
      echo "Failed classifier for channel 1 (cluster)."
    fi

    exit ${exit_code}
fi
