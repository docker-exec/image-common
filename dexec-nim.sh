#!/bin/bash

set -e

dexec_script_name=$(basename ${0}); pushd $(dirname ${0}) >/dev/null
dexec_script_path=$(pwd -P); popd >/dev/null

source "${dexec_script_path}/dexec-common.sh"

dexec_default_build_name="$(dexec_uuid)"
dexec_default_output_flag="-o:"
dexec_default_output_pattern="-o\:(.+)"

dexec_compiler=$(eval echo -e "${1}"); shift
dexec_build_name="${dexec_default_build_name}"

function dexec_validate() {
    return 0
}

function dexec_setup() {
    pushd ${dexec_build_path} >/dev/null
    tmp_dir=/tmp/$(dexec_uuid)
    mkdir -p ${tmp_dir}
    shopt -s dotglob
    cp -r ${dexec_build_path}/* ${tmp_dir}
    shopt -u dotglob
    pushd ${tmp_dir} >/dev/null
    for source in "${dexec_sources[@]}"; do
        sed -Ee '/^#!.*dexec/d' "${source}" > "${source}_tmp" && mv "${source}_tmp" "${source}"
    done
}

function dexec_build() {
    local output_arg="$(dexec_array_first_item_matching "${dexec_default_output_pattern}.+" "${dexec_build_args[@]}")"
    if [ ! -z "${output_arg}" ]; then
        dexec_build_name="$(sed -Ee s/"${dexec_default_output_pattern}"/\1/ <<<"${output_arg}")"
    else
        dexec_build_args+=("${dexec_default_output_flag}${dexec_build_name}")
    fi
    ${dexec_compiler} "${dexec_build_args[@]}" "${dexec_sources[@]}"
}

function dexec_run() {
    if [ -x ${dexec_build_name} ]; then
        ./${dexec_build_name} "${dexec_args[@]}"
    else
        return 1
    fi
}

function dexec_cleanup() {
    if [ -f "${dexec_build_name}" ]; then
        rm "${dexec_build_name}"
    fi
    if [ -d "nimcache" ]; then
        rm -rf "nimcache"
    fi
    popd >/dev/null
    if [ -w "${dexec_build_path}" ]; then
        for source in "${dexec_sources[@]}"; do
            cp "${source}" "${tmp_dir}"
        done
        diff -Naur "${dexec_build_path}" ${tmp_dir} | patch >/dev/null
    fi
    popd >/dev/null
}

dexec_parse_params "${@}"
dexec_validate
dexec_setup
dexec_build
dexec_run
dexec_cleanup
