#!/bin/bash

## berb-bash-libs general functions
#
# Upstream-Name: berb-bash-libs
# Source: https://github.com/berbascum/berb-bash-libs
#
# Copyright (C) 2024 Berbascum <berbascum@ticv.cat>
# All rights reserved.
#
# BSD 3-Clause License
#
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the <organization> nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#[HEADER_SECTION]
fn_header_info() {
    BIN_TYPE="lib"
    BIN_SRC_TYPE="bash"
    BIN_SRC_EXT="sh"
    BIN_NAME="bbl_general_lib"
    TOOL_VERSION="1.1.0.1"
    TOOL_VERSION_INT="1101"
    TOOL_RELEASE="testing"
    URGENCY='optional'
    TESTED_BASH_VER='5.2.15'
}
#[HEADER_END]


## Config log
fn_bbgl_config_log() {
    ## Prepare log file
    [ -z "${LOG_FULLPATH}" ] && LOG_FULLPATH="${HOME}/logs/${TOOL_NAME}"
    [ ! -d "${LOG_FULLPATH}" ] && mkdir -p "${LOG_FULLPATH}"
    LOG_FILE="${TOOL_NAME}.log"
    echo > "${LOG_FULLPATH}/${LOG_FILE}"
}

#####################
## Print functions ##
#####################
info() {
    if [[ $LOG_LEVEL -le $LOG_LEVEL_INFO ]]; then
        echo "INFO:  $*" | tee -a "${LOG_FULLPATH}/${LOG_FILE}" >&2
    fi
}
INFO() {
    if [[ $LOG_LEVEL -le $LOG_LEVEL_INFO ]]; then
        echo; echo "INFO:  $*" | tee -a "${LOG_FULLPATH}/${LOG_FILE}" >&2
    fi
}
warn() {
    if [[ $LOG_LEVEL -le $LOG_LEVEL_WARN ]]; then
        echo "WARN:  $*" | tee -a "${LOG_FULLPATH}/${LOG_FILE}" >&2
    fi
}
WARN() {
    if [[ $LOG_LEVEL -le $LOG_LEVEL_WARN ]]; then
        echo; echo "WARN:  $*" | tee -a "${LOG_FULLPATH}/${LOG_FILE}" >&2
    fi
}
debug() {
    if [[ $LOG_LEVEL -le $LOG_LEVEL_DEBUG ]]; then
        echo "DEBUG: $*" | tee -a "${LOG_FULLPATH}/${LOG_FILE}" >&2
    fi
}
debug2() {
    if [[ $LOG_LEVEL -le $LOG_LEVEL_DEBUG2 ]]; then
        echo "DEBUG2: $*" | tee -a "${LOG_FULLPATH}/${LOG_FILE}" >&2
    fi
}
DEBUG() {
    if [[ $LOG_LEVEL -le $LOG_LEVEL_DEBUG ]]; then
        echo; echo "DEBUG: $*" | tee -a "${LOG_FULLPATH}/${LOG_FILE}" >&2
    fi
}
abort() {
    if [[ $LOG_LEVEL -le $LOG_LEVEL_ABORT ]]; then
        echo "ABORT: $*" | tee -a "${LOG_FULLPATH}/${LOG_FILE}" >&2
        exit 10 
    fi
}
ABORT() {
    if [[ $LOG_LEVEL -le $LOG_LEVEL_ABORT ]]; then
        echo; echo "ABORT: $*" | tee -a "${LOG_FULLPATH}/${LOG_FILE}" >&2
        exit 10 
    fi
}
error() {
    if [[ $LOG_LEVEL -le $LOG_LEVEL_ERROR ]]; then
        echo "ERROR: $*" | tee -a "${LOG_FULLPATH}/${LOG_FILE}" >&2
        exit 10
    fi
}
ERROR() {
    if [[ $LOG_LEVEL -le $LOG_LEVEL_ERROR ]]; then
        echo; echo "ERROR: $*" | tee -a "${LOG_FULLPATH}/${LOG_FILE}" >&2
        exit 1 
    fi
}
ECHO() { echo; echo "$*"; }
ask() { read -p "$*" answer; }
ASK() { echo; read -p "$*" answer; }
pause() { read -p "$*"; }
PAUSE() { echo; read -p "$*"; }

########################
## loglevel functions ##
########################
fn_bbgl_config_log_level() {
    ## Set the log levels
    readonly LOG_LEVEL_DEBUG2=0
    readonly LOG_LEVEL_DEBUG=1
    readonly LOG_LEVEL_INFO=2
    readonly LOG_LEVEL_WARN=3
    readonly LOG_LEVEL_ABORT=4
    readonly LOG_LEVEL_ERROR=5
    ## Search for the log-level flag in the arguments
    flag_name="log-level" fn_bbgl_check_args_search_flag $@
    [ -n "${FLAG_FOUND_VALUE}" ] && LOG_LEVEL="${FLAG_FOUND_VALUE}"
    ## Set the default log-level if not defined yet
    [ -z "${LOG_LEVEL}" ] && LOG_LEVEL=${LOG_LEVEL_INFO}
    debug "bbl-general: After check_args_LOG_LEVEL = ${LOG_LEVEL}"
}

###########################
### check args functions ##
###########################
fn_bbgl_check_args_search_flag() {
    ## Search for flag in the main script arguments
    [ -n "${flag_name}" ] || error "${FUNCNAME[0]}: flag_name not defined from ${FUNCNAME[1]}"
    debug "bbl-general: flag_name = \"$flag_name\""
    debug "bbl-general: \$@ = \"$@\""
    FLAG_FOUND_VALUE=""
    for flag in $@; do
        flag_found=$(echo "${flag}" | grep "\-\-${flag_name}=")
        if [ -n "${flag_found}" ]; then
            FLAG_FOUND_VALUE=$(echo "${flag_found}" | awk -F'=' '{print $2}')
	        debug "bbl-general: \"${flag_name}\" flag = \"${FLAG_FOUND_VALUE}\" found"
	        break
        fi
    done
}

#######################
## Control functions ##
#######################
fn_bbgl_check_bash_ver() {
    bash_ver=$(bash --version | head -n 1 \
	| awk '{print $4}' | awk -F'(' '{print $1}' | awk -F'.' '{print $1"."$2"."$3}')
    #IFS_BKP=$IFS
    IFS='.' read -r vt_major vt_minor vt_patch <<< "${TESTED_BASH_VER}"
    IFS='.' read -r v_major v_minor v_patch <<< "${bash_ver}"
    IFS=$' \t\n'
    #IFS=$IFS_BKP
    if [[ $v_major -lt $vt_major ]] || \
        ([[ $v_major -eq $vt_major ]] && [[ $v_minor -lt $vt_minor ]]) || \
        ([[ $v_major -eq $vt_major ]] && [[ $v_minor -eq $vt_minor ]] \
	    && [[ $v_patch -lt $vt_patch ]]); then
        clear
        WARN "bbl-general: Bash version detected is lower than the tested version"
        warn "bbl-general: If errors are found, try upgrading bash to \"${TESTED_BASH_VER}\" version"
	    pause "bbl-general: Press Inro to continue"
    else
        INFO "bbl-general: Bash version requirements are fine"
    fi
}

######################
## Config functions ##
######################
fn_bbgl_configura_sudo() { [ "$USER" != "root" ] && SUDO='sudo'; }

fn_ask_write_not_set_vars_in_file() {
    ## Search for empty vars in the device config file
    for var in $(cat "${install_file}"); do
        var_not_set=$(echo "${var}" | grep -v "#" | grep -v "=\"" | grep "=")
	if [ -n "${var_not_set}" ]; then
	   info "bbl-general: var_not_set = $var_not_set"
	   ask "bbl-general: \"${var_not_set}\" name is not configured. Please type it: "
           [ -n "${answer}" ] && sed -i \
	       "s/${var_not_set}/${var_not_set}\"${answer}\"/g" "${install_file}"
	    fi
    done
    source "${dev_info_install_fullpath}/${device_info_filename}"
}

############################################
## FUNCIONS EINA CONF FILE PARSE SECCIONS ##
############################################
fn_bbgl_ifs_2_newline() {
    ## Config ICF to set array with spaced strings on each position value.
    if [ "${1}" == "" ]; then
	    ERROR "bbl-general: fn_bssf_ifs_2_newline param requerit."
    elif [ "${1}" == "activa" ]; then
	    #IFS_BACKUP=$IFS
	    IFS=$'\n'
    elif [ "${1}" == "desactiva" ]; then
	    IFS=$IFS_BACKUP
    fi
}

fn_bssf_menu_fzf() {
    ## Exit if fzf not found
    [[ -z "$(which fzf)" ]] && echo && echo "\"fzf\" util not found." && exit 5
    ## Exit function if arry have length 0
    [[ "${#arr_data[@]}" -eq "0" ]] && return 1
    ## Call menu
    echo
    item="$1"
    fzf_mode="$2"
    echo; echo "bbl-general: Setting fzf for ${fzf_mode} mode..."
    ## Define vars for each fzf mode
    if [ "${fzf_mode}" == "single" ]; then
        menu_title="Please select a \"${item}\" from the list:"
        extra_opt=""
    elif [ "${fzf_mode}" == "multi" ]; then
        menu_title="Please select all the \"${item}\" that you want pressing the \"Tab\" key and then \"Intro\" to confirm:"
        extra_opt='-m'
    else
        echo; echo "bbl-general: fzf mode \"${fzf_mode}\" not implemented!"
    fi
    #item_selected=""
    item_selected=$(printf '%s\n' ${arr_data[@]} \
        | fzf ${extra_opt} --reverse --border=rounded --border-label "${menu_title}" --height ~80%)
    ## Put the selected items in an array on multi selection mode
    #
    if [ "${fzf_mode}" == "multi" ]; then
        IFS_BKP=$IFS && IFS=$'\n' read -r -d '' -a arr_items_selected <<< "${item_selected}"
        IFS=$IFS_BKP
    fi
    # DEBUG # info "arr_items_selected = ${arr_items_selected[@]}"
    # DEBUG # info "lengt arr_item_selected = ${#arr_items_selected[*]}"
    # DEBUG # info "Option selected: \"${item_selected}\""
<< "CALL_SAMPLES"
    arr_data=( "${arr_LIST_FN_PLUGINS[@]}" )
    fn_bssf_menu_fzf "plugin" "single|multi"
    PLUGIN="${item_selected}"
    FN_PLUGIN="fn_plugin_${PLUGIN}"
    ### echo && echo "Plugin selected = \"${PLUGIN}\"" #DEBUG#
    ### echo && echo "Plugin fn selected = \"${FN_PLUGIN}\"" #DEBUG#

    [[ -z "${item_selected}" ]] && echo && echo "Plugin selection failed!" && exit 1

    ## Crida la fn_plugin_ corrsponent a l'opció de pluguin introduida
    echo && echo "Executant funció def de plugin \"${FN_PLUGIN}\""
    eval ${FN_PLUGIN}
CALL_SAMPLES
}

fn_bbgl_parse_file_section() {
    ## v3
    #
    ## This function search for a specified section start and end in a specified file
    ## and evals the code between.
    #
    ## Compatible with "CONFIG FILE SECTIONS" and "BERB BINSRC HEADER"
    #
    ## "BERB BINSRC HEADER" was used before implementing debian packaging in the scripts,
    ## so probably will be deprecated
    #
    ## Configure parser
    section="$2"
    parse_action="$3"
    [ -z "${section}" ] && ERROR "bbl-general: A section name is needed as argument \"2\""
    [ -z "${parse_action}" ] && ERROR "bbl-general: A parse action is needed as argument \"3\""
    ## Configuration of "HEADER_SECTION"
    if [ "$section" == "HEADER_SECTION" ]; then
        ## file_2_parse
        file_2_parse="$1"
        [ ! -f "${file_2_parse}" ] \
            && ERROR "bbl-general: file_2_parse \"${file_2_parse}\" not found"
        ## parse search options
        str_start="#\[${section}\]"
        str_end="#\[HEADER_END\]"
        how_many_vars="$4"
        [ -z "${how_many_vars}" ] \
            && ERROR "bbl-general: A search var mode all|one|first is needed as arg \"4\""
        if [ "${how_many_vars}" == "one" ]; then
            var_2_search="$5"
            [ -z "${var_2_search}" ] \
                && ERROR "bbl-general: A var name as argument \"5\" is required"
        fi
    ## Configuration of any other section than "HEADER_SECTION"
    elif [ "$section" != "HEADER_SECTION" ]; then
        ## file_2_parse try default
        file_2_parse=$(eval \
             "echo \${"${1}"_FULLPATH_FILENAME}")
        ## file_2_parse try alternatives
        if [ ! -f "${file_2_parse}" ]; then
            file_2_parse=$(eval \
                "echo \${"${1}"_LOCAL_CFG_FILE}")
        fi
        ## DEBUG: ##
        #if [ "${section}" == "bblgit-check-ref" ]; then
        #    info "file_2_parse = ${file_2_parse}"
        #    pause "Seccio bblgit-check-ref processant..."
        #fi
        ## If file_2_parse still empty, error
        [ -f "${file_2_parse}" ] \
            || ERROR "file_2_parse ${file_2_parse} not found"
        ## parse search options
        str_start="\[$section\]"
        str_end="\["
    fi
    INFO "bbl-general: Parsing \"${section}\" section: \"${parse_action}\" on \"${file_2_parse}\""
    section_found="0"
    section_end="0"
    arr_vars_found=()
    arr_lines=()
    ## Change IFS to avoid line splitting on spaces in lines
    fn_bbgl_ifs_2_newline activa
    for line in $(cat "${file_2_parse}"); do
        if [ ${section_found} -eq "0" ]; then
            debug2 "bbl-general:  Cercant la secció \"${section}\""
            # section_found=$(echo "${line}" | grep -c "${str_start}")
            section_found=$(echo "${line}" | grep -c "${str_start}")
            if [ ${section_found} -eq "1" ]; then
                debug2 "bbl-general: Trobat Start de secció \"${section}\""
            elif [ ${section_found} -eq "0" ]; then
                debug2 "bbl-general: Encara NO trobada la secció ${section}"
            fi
        fi
        ## Until not yet in section_end, the bellow if statment will search for it
        ## on every line of loop
        ## When section_end found, a break will be performed
        if [ "${section_found}" -eq "1" -a "${section_end}" -ne "1" ]; then
            debug2 "bbl-general: section_end var after 1st check = ${section_end}"
            ## Search section_end pattern in var
            section_end=$(echo "${line}" | grep "^${str_end}" | grep -c -v "${section}")
            debug2 "bbl-general: section_end var search again result = ${section_end}"
            [ "${section_end}" -eq "1" ] \
                && debug2 "bbl-general: section end FOUND after 2nd check: \"${section}\"" && break
            ## When section_end found, curr line (section tag) will not be processed
            ## thanks to grep -v
        fi
        ## Action: "load_section" ##
        if [ "${parse_action}" == "load_section" ]; then
            ## Utilitzat per seccions de config file
            debug2 "bbl-general: line original: ${line}"
            line_filtered=$(echo "${line}" | grep -v '^\[' | grep -v '^#')
            debug2 "bbl-general: line filtered: ${line_filtered}"
            ## Evaluate filtered line if not empty: 
            if [ -n "${line_filtered}" ]; then
                debug2 "bbl-general: Evaluating line: "${line}""
                eval ${line_filtered}
            fi
        ## Action: "ask_empty_vars" ##
        elif [ "${parse_action}" == "ask_empty_vars" ]; then
            ## Utilitzat per seccions de config file
            debug2 "bbl-general: line original: ${line}"
            line_filtered=$(echo "${line}" \
                | grep -v '^\[' | grep -v '^#')
            debug2 "bbl-general: line filtered: ${line}"
            ## Evaluate filtered line if not empty: 
            if [ -n "${line_filtered}" ]; then
                var_not_set=$(echo "${line_filtered}" \
                    | grep -v "#" | grep -v "=\"" | grep "=")
                if [ -n "${var_not_set}" ]; then
                    debug2 "bbl-general: var_not_set = $var_not_set"
                    ASK "bbl-general: \"${var_not_set}\" name is not configured. Please type it: "
                    [ -n "${answer}" ] && sed -i \
                        "s/${var_not_set}/${var_not_set}\"${answer}\"/g" "${file_2_parse}"
                fi
                debug2 "bbl-general: Evaluating line: "${line}""
                eval ${line_filtered}
            fi
        # Action: "search_varnames" ##
        elif [ "${parse_action}" == "search_varnames" ]; then
            # Arg "how_many_vars = one"
            if [ "${how_many_vars}" == "one" ]; then
                ## Check if the varname specified as the fifth fn arg is found
                ## in the specified file and section
                line_filtered=$(echo "${line}" | grep "${var_filter}")
                debug2 "bbl-general: var_filter val: ${var_filter}"
                if [ -n "${line_filtered}" ]; then
                    debug2 "bbl-general: Found var \"${line_filtered}\" using filter \"${var_filter}\""
                    debug2 "             Adding it to \"arr_vars_found\""
                    arr_vars_found+=( "${line_filtered}" )
                    break
                fi
            # Arg "how_many_vars = list"
            elif [ "${how_many_vars}" == "list" ]; then
                ## Check if the varnames in a list from an array are found
                ## in the specified file and section
                ## Start of scan lines loop
                for var_filter in  "${arr_vars_filter[@]}"; do
                    line_filtered=$(echo "${line}" | grep "${var_filter}")
                    debug2 "bbl-general: line val: ${line}"
                    debug2 "             line_filtered val: ${line_filtered}"
                    debug2 "             var_filter val: ${var_filter}"
                    if [ -n "${line_filtered}" ]; then
                        debug2 "bbl-general: Found var \"${line_filtered}\" using filter \"${var_filter}\""
                        debug2 "             Adding it to \"arr_vars_found\""
                        arr_vars_found+=( "${line_filtered}" )
                    fi
                done
            # Arg "how_many_vars = all"
            elif [ "${how_many_vars}" == "all" ]; then
                ## Get all vars in the specified file and section and put them into an array
                line_filtered=$(echo "${line}" \
                    | grep -v '^\[' | grep -v '^#')
                if [ -n "${line_filtered}" ]; then
                    debug2 "bbl-general: Found var \"${line_filtered}\""
                    debug2 "             Adding it to \"arr_vars_found\""
                    arr_lines_found+=( "${line_filtered}" )
                    arr_vars_found+=( "$(echo "${line_filtered}" | grep '=')" )
                fi
            fi
        fi
    done
    ## Print msg if the specified section was not found after looping the entire file
    if [ ${section_found} -eq "0" ]; then
        error "bbl-general: Section ${section} not found in \"${file_2_parse}\" file"
    fi

    ## Restore IFS
    fn_bbgl_ifs_2_newline desactiva

## Final debug
    debug2 "bbl-general: Inici prints després de sectio trobada"
    debug2 "             str_start val: ${str_start}"
    debug2 "             str_end val: ${str_end}"
    debug2 "             section_end val: ${section_end}"
    debug2 "             line val: ${line}"
    debug2 "             var_name val: ${var_name}"
    debug2 "             var_found val: ${var_found}"
    debug2 "             line_filtered val: ${line_filtered}"
    # read -p "Pausa"

<< "CALL_SAMPLES"
    # CALL SAMPLE "load_section":
       ## section="branch-dev-end-consts" && fn_bssf_parse_file_section MAIN_HOME "${section}" "load_section"
    # CALL SAMPLE "search_varnames one":
        file="${bin_main_file_sources}"
        var_filter='LIB_VERSION='
        # Check if the specified varname as arg "5" is found on HEADER_SECTION from the specified file and put them in an array
        section="HEADER_SECTION" && fn_bssf_parse_file_section "${file}" "${section}" "search_varnames" "one" "${var_filter}"
        ## Returns "arr_vars_found" containing the var def line if found
    # CALL SAMPLE "search_varnames all":
        # Get all lines in the HEADER_SECTION and put in two arrays, one with all lines and other filtering only var defs
        file="${bin_main_file_sources}"
        section="HEADER_SECTION" && fn_bssf_parse_file_section "${file}" "${section}" "search_varnames" "all"
        ## Returns "arr_lines_found" containing all lines in section and  "arr_vars_found" containing only var definition lines
    # CALL SAMPLE "search_varnames list":
        # Check if the vars in an array list are found on the HEADER_SECTION from the specified file and put them in an array
        arr_vars_filter=( "${arr_version_varnames_filter_lst[@]}" )
        file="${bin_main_file_sources}"
        section="HEADER_SECTION" && fn_bssf_parse_file_section "${file}" "${section}" "search_varnames" "list" 
        ## Returns "arr_vars_found" containing the var def lines if found

CALL_SAMPLES
}
