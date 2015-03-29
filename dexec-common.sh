#!/bin/bash

pattern_eq_build_arg="^--build-arg=(.*)$"
pattern_ws_build_arg="^-(-build-arg|b)$"

pattern_eq_arg="^--arg=(.*)$"
pattern_ws_arg="^-(-arg|a)$"

pattern_source_file="^([^-].*)$"

declare -a dexec_build_args
declare -a dexec_args
declare -a dexec_flags
declare -a dexec_sources

dexec_build_path="/tmp/dexec/build"

function dexec_uuid() {
    if [ -x "$(which uuidgen)" ]; then
        uuidgen
    elif [ -f /proc/sys/kernel/random/uuid ]; then
        cat /proc/sys/kernel/random/uuid
    else
        >&2 echo "Unable to generate uuid"
        return 1
    fi
}

function dexec_extract_single_match() {
    local needle="${1}"
    local haystack="${2}"
    printf "%s\n" "${needle}" | sed -E -e s/"${haystack}"/\\1/
}

function dexec_array_contains() {
    local needle="${1}"; shift
    local haystack=("${@}")
    for item in "${haystack[@]}"; do
        if [ "${item}" = "${needle}" ]; then return 0; fi
    done
    return 1
}

function dexec_array_index_of() {
    local needle="${1}"; shift
    local haystack=("${@}")
    for (( i = 0; i < ${#haystack[@]}; i++ )); do
        if [ "${haystack[$i]}" = "${needle}" ]; then echo ${i}; return; fi
    done
    echo -1
}

function dexec_array_first_item_matching() {
    local needle_pattern="${1}"; shift
    local haystack=("${@}")
    for (( i = 0; i < ${#haystack[@]}; i++ )); do
        if echo "${haystack[$i]}" | grep -qEe "${needle_pattern}" ; then echo "${haystack[$i]}"; return; fi
    done
}

function dexec_array_item_after() {
    local needle="${1}"; shift
    local haystack=("${@}")
    if $(dexec_array_contains "${needle}" "${haystack[@]}"); then
        local index_of_flag=$(dexec_array_index_of "${needle}" "${haystack[@]}")
        local index_of_value=$((${index_of_flag} + 1))
        echo "${haystack[index_of_value]}"
    fi
}

function dexec_is_flag_set() {
    local flag="${1}"
    return $(dexec_array_contains "${flag}" "${dexec_flags[@]}")
}

function dexec_parse_params() {
    while [ "$#" -gt 0 ]; do
        local param="${1}"
        if [[ "${param}" =~ ${pattern_eq_build_arg} ]]; then
            dexec_build_args+=("`dexec_extract_single_match "${param}" "${pattern_eq_build_arg}"`")
        elif [[ "${param}" =~ ${pattern_ws_build_arg} ]]; then
            shift; dexec_build_args+=("${1}")
        elif [[ "${param}" =~ ${pattern_eq_arg} ]]; then
            dexec_args+=("`dexec_extract_single_match "${param}" "${pattern_eq_arg}"`")
        elif [[ "${param}" =~ ${pattern_ws_arg} ]]; then
            shift; dexec_args+=("${1}")
        elif [[ "${param}" =~ ${pattern_source_file} ]]; then
            dexec_sources+=("${param}")
        else
            >&2 echo "Invalid argument: ${param}"
            exit 1
        fi
        shift
    done
}
