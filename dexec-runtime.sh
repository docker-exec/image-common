#!/bin/bash

set -e

dexec_script_name=$(basename ${0}); pushd $(dirname ${0}) >/dev/null
dexec_script_path=$(pwd -P); popd >/dev/null

source "${dexec_script_path}/dexec-common.sh"

dexec_compiler="${1}"; shift
dexec_runtime="${1}"; shift
dexec_runtime_extension="${1}"; shift

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
    dexec_build_name=$(echo ${dexec_sources[0]} | sed -E "s/(.*\/)?(.*)\..*$/\2/")
    ${dexec_compiler} "${dexec_build_args[@]}" "${dexec_sources[@]}"
}

function dexec_run() {
    ${dexec_runtime} "${dexec_build_name}" "${dexec_args[@]}"
}

function dexec_cleanup() {
    if [ -f "${dexec_build_name}${dexec_runtime_extension}" ]; then
        rm "${dexec_build_name}${dexec_runtime_extension}"
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
