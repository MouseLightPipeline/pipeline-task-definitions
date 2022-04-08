#!/usr/bin/env bash

# Standard arguments passed to all tasks.
pipeline_input_root=${1}
pipeline_output_root=${2}
tile_relative_path=${3}
# Unused - tile_name=${4}
mouselight_toolbox_path=${5}

# User-defined arguments
app="${mouselight_toolbox_path}/compute_landmarks.sh"
#pythonFolder=${6}

# Fallback exit code in case of error
exit_code=255

# Compile derivatives
#input_file="${pipeline_input_root}/${tile_relative_path}"

#cmd="${pythonFolder}/bin/python ${app} -i ${input_file} -o ${output_file}"
cmd="${app} ${pipeline_input_root} ${pipeline_output_root} ${tile_relative_path}"
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
