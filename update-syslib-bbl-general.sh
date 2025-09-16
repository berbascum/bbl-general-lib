#!/bin/bash

lib_name="bbl_general_lib"
lib_src_main_name="${lib_name}_main"
lib_src_main_file_name="${lib_src_main_name}.sh"
lib_sys_dir="/usr/lib/berb-bash-libs"

source ${lib_src_main_file_name} "load_pkg_metadata"

echo "Copying the lib to ${lib_sys_dir}/${lib_src_main_file_name}_${TOOL_VERSION_INT}..."
cat ${lib_src_main_file_name} | sudo tee ${lib_sys_dir}/${lib_src_main_name}_${TOOL_VERSION_INT} >/dev/null
