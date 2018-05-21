#!/usr/bin/env bash

# Standard arguments passed to all tasks.
pipeline_input_root=${1}
pipeline_output_root=${2}
tile_relative_path=${3}
tile_name=${4}

# User-defined arguments
app="${5}/lineFix.py"

exit_code=255

# Compile derivatives
input_file="${pipeline_input_root}/${tile_relative_path}"
output_file="${pipeline_output_root}/${tile_relative_path}"

pythonFolder=/groups/mousebrainmicro/home/base/anaconda3/

cmd="${pythonFolder}/bin/python ${app} -i ${input_file} -o ${output_file}"
echo ${cmd}
eval ${cmd}

# Store before the next calls change the value.
exit_code=$?

if [ -e ${output_file} ]
then
    chmod 775 ${output_file}
fi

exit ${exit_code}
