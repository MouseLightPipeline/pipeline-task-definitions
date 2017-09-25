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
app="${10}/dogDescriptor"
mcrRoot=${11}

# Compile derivatives
input_file1="$pipeline_input_root/$tile_relative_path/$tile_name-prob.0.h5"
input_file2="$pipeline_input_root/$tile_relative_path/$tile_name-prob.1.h5"

output_file="$pipeline_output_root/$tile_relative_path/$tile_name"
output_file+="-desc"
output_file_1="$output_file.0.txt"
output_file_2="$output_file.1.txt"

log_path_base="$pipeline_output_root/$tile_relative_path/.log"
log_file_base="dd-${tile_name}"

# Create hidden log folder
mkdir -p ${log_path_base}

# Make sure group can read/write.
chmod ug+rwx ${log_path_base}
chmod o+rx ${log_path_base}

log_file_1="${log_path_base}/${log_file_base}-log.0.txt"
log_file_2="${log_path_base}/${log_file_base}-log.1.txt"

LD_LIBRARY_PATH2=.:${mcrRoot}/runtime/glnxa64 ;
LD_LIBRARY_PATH2=${LD_LIBRARY_PATH2}:${mcrRoot}/bin/glnxa64 ;
LD_LIBRARY_PATH2=${LD_LIBRARY_PATH2}:${mcrRoot}/sys/os/glnxa64;
LD_LIBRARY_PATH2=${LD_LIBRARY_PATH2}:${mcrRoot}/sys/opengl/lib/glnxa64;

cmd1="${app} ${input_file1} ${output_file_1} \"[11 11 11]\" \"[3.405500 3.405500 3.405500]\" \"[4.049845 4.049845 4.049845]\" \"[5 1019 5 1531 5 250]\" 4"

cmd2="${app} ${input_file2} ${output_file_2} \"[11 11 11]\" \"[3.405500 3.405500 3.405500]\" \"[4.049845 4.049845 4.049845]\" \"[5 1019 5 1531 5 250]\" 4"

if [ ${is_cluster_job} -eq 0 ]
then
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH2};

    export MCR_CACHE_ROOT="~/";

    # Channel 0
    eval ${cmd1} &> ${log_file_1}

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
      echo "Completed descriptor for channel 0."
    else
      echo "Failed descriptor for channel 0."
      exit ${exit_code}
    fi

    # Channel 1
    eval ${cmd2} &> ${log_file_2}

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
      echo "Completed descriptor for channel 1."
    else
      echo "Failed descriptor for channel 1."
    fi

    exit ${exit_code}
else
    export MCR_CACHE_ROOT="~/";

   # Channel 0
    err_file_1="${log_path_base}/${log_file_base}.cluster.0.err"

    ssh login1 "echo \"ssh complete\"; source /etc/profile; export LD_LIBRARY_PATH=${LD_LIBRARY_PATH2}; export MCR_CACHE_ROOT=${MCR_CACHE_ROOT}; bsub -K -n 1 -J ml-dg-${tile_name} -oo ${log_file_1} -eo ${err_file_1} -cwd -R\"select[broadwell]\" ${cmd1}"

    exit_code=$?

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
      echo "Completed descriptor for channel 0 (cluster)."
    else
      echo "Failed descriptor for channel 0 (cluster)."
      exit ${exit_code}
    fi

   # Channel 1
    err_file_2="${log_path_base}/${log_file_base}.cluster.1.err"

    ssh login1 "source /etc/profile; export LD_LIBRARY_PATH=${LD_LIBRARY_PATH2}; export MCR_CACHE_ROOT=${MCR_CACHE_ROOT}; bsub -K -n 1 -J ml-dg-${tile_name} -oo ${log_file_2} -eo ${err_file_2} -cwd -R\"select[broadwell]\" ${cmd2}"

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
      echo "Completed descriptor for channel 1 (cluster)."
    else
      echo "Failed descriptor for channel 1 (cluster)."
    fi

    exit ${exit_code}
fi
