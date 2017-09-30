#!/usr/bin/env bash

# Standard arguments passed to all tasks.
project_name=$1
project_root=$2
pipeline_input_root=$3
pipeline_output_root=$4
tile_relative_path=$5
tile_name=$6
log_root_path=$7
z_minus_1_relative_path=$8
z_minus_1_tile_name=$9
expected_exit_code=${10}
is_cluster_job=${11}

# Custom task arguments defined by task definition
app="${12}/dogDescriptor"
mcrRoot=${13}

# Compile derivatives
input_tile_1="${pipeline_input_root}/${z_minus_1_relative_path}"
input_tile_2="${pipeline_input_root}/${tile_relative_path}"

acq_folder_1="${project_root}/${z_minus_1_relative_path}"
acq_folder_2="${project_root}/${tile_relative_path}"

output_tile="${pipeline_output_root}/${tile_relative_path}"

log_path_base="$pipeline_output_root/$tile_relative_path/.log"
log_file_base="dd-${tile_name}"

# Create hidden log folder
mkdir -p ${log_path_base}

# Make sure group can read/write.
chmod ug+rwx ${log_path_base}
chmod o+rx ${log_path_base}

log_file_1="${log_path_base}/${log_file_base}-log.0.txt"
log_file_2="${log_path_base}/${log_file_base}-log.1.txt"

# Various issues with this already existing in some accounts and not others, ssh conflicts to cluster depending on the
# environment, etc.  Call it LD_LIBRARY_PATH2 for now and insert it as LD_LIBRARY_PATH at appropriate time.
LD_LIBRARY_PATH2=.:${mcrRoot}/runtime/glnxa64 ;
LD_LIBRARY_PATH2=${LD_LIBRARY_PATH2}:${mcrRoot}/bin/glnxa64 ;
LD_LIBRARY_PATH2=${LD_LIBRARY_PATH2}:${mcrRoot}/sys/os/glnxa64;
LD_LIBRARY_PATH2=${LD_LIBRARY_PATH2}:${mcrRoot}/sys/opengl/lib/glnxa64;

cmd="${app} ${input_tile_1} ${input_tile_2} ${acq_folder_1} ${acq_folder_2} ${output_tile} ${expected_exit_code}"

if [ ${is_cluster_job} -eq 0 ]
then
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH2};

    export MCR_CACHE_ROOT="~/";

    eval ${cmd} &> ${log_file_1}

    # Store before the next calls change the value.
    exit_code=$?

    if [ -e ${log_file_1} ]
    then
        chmod 775 ${log_file_1}
    fi

    if [ ${exit_code} -eq ${expected_exit_code} ]
    then
      echo "Completed pointMatch 0."
    else
      echo "Failed pointMatch 0."
      exit ${exit_code}
    fi
else
    export MCR_CACHE_ROOT="~/";

   # Channel 0
    err_file="${log_path_base}/${log_file_base}.cluster.0.err"

    ssh login1 "source /etc/profile; export LD_LIBRARY_PATH=${LD_LIBRARY_PATH2}; export MCR_CACHE_ROOT=${MCR_CACHE_ROOT}; bsub -K -n 1 -J ml-dg-${tile_name} -oo ${log_file_1} -eo ${err_file} -cwd -R\"select[broadwell]\" ${cmd}"

    exit_code=$?

    sleep 2s

    if [ -e ${log_file_1} ]
    then
        chmod 775 ${log_file_1}
    fi

    if [ -e ${err_file} ]
    then
        if [ ! -s ${err_file} ]
        then
            rm ${err_file}
        else
            chmod 775 ${err_file}
        fi
    fi

    if [ ${exit_code} -eq ${expected_exit_code} ]
    then
      echo "Completed pointMatch (cluster)."
    else
      echo "Failed pointMatch (cluster)."
      exit ${exit_code}
    fi
fi
