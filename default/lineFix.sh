#!/usr/bin/env bash

# Standard arguments passed to all tasks.
pipeline_input_root=${1}
pipeline_output_root=${2}
tile_relative_path=${3}
# Unused - tile_name=${4}

# User-defined arguments
app="${5}/lineFix.py"
pythonFolder=${6}

exit_code=255

# Compile derivatives
#input_file="${pipeline_input_root}/${tile_relative_path}"

#cmd="${pythonFolder}/bin/python ${app} -i ${input_file} -o ${output_file}"
cmd="${pythonFolder}/bin/python ${app} -i ${pipeline_input_root} -p ${tile_relative_path} -o ${pipeline_output_root}"
echo "${cmd}"
eval "${cmd}"

# Store before the next calls change the value.
exit_code=$?

# Make the output file group-writable
output_file="${pipeline_output_root}/${tile_relative_path}"
if [ -e "${output_file}" ]
then
    chmod 775 "${output_file}"
fi

exit ${exit_code}
