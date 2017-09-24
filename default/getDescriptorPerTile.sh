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
app="${10}/getDescriptorPerTile15b"
mcrRoot=${11}

# Compile derivatives
input_file1="$pipeline_input_root/$tile_relative_path/$tile_name-desc.0.txt"
input_file2="$pipeline_input_root/$tile_relative_path/$tile_name-desc.1.txt"

output_file="$pipeline_output_root/$tile_relative_path/$tile_name"
output_file+="-desc.mat"

log_path_base="$pipeline_output_root/$tile_relative_path/.log"
log_file_base="dt-${tile_name}"

# Create hidden log folder
mkdir -p ${log_path_base}

# Make sure group can read/write.
chmod ug+rwx ${log_path_base}
chmod o+rx ${log_path_base}

log_file="${log_path_base}/${log_file_base}-log.txt"

LD_LIBRARY_PATH=.:${mcrRoot}/runtime/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/bin/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/sys/os/glnxa64;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${mcrRoot}/sys/opengl/lib/glnxa64;

cmd="${app} ${input_file1} ${input_file2} ${output_file}"

err_file="${log_path_base}/${log_file_base}.cluster.err"

if [ ${is_cluster_job} -eq 0 ]
then
    export LD_LIBRARY_PATH;

    eval ${cmd} &> ${log_file}
else
    ssh login1 "source /etc/profile; export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}; bsub -K -n 1 -J ml-gd-${tile_name} -oo ${log_file} -eo ${err_file} -cwd -R\"select[broadwell]\" ${cmd}"
fi

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

if [ -e ${err_file} ]
then
    chmod 775 ${err_file}
fi

if [ ${exit_code} -eq ${expected_exit_code} ]
then
    echo "Completed descriptor merge."
else
    echo "Failed descriptor merge."
fi

exit ${exit_code}
