#!/bin/bash

set -e

dexec_script_name=$(basename ${0}); pushd $(dirname ${0}) >/dev/null
dexec_script_path=$(pwd -P); popd >/dev/null

source "${dexec_script_path}/dexec-common.sh"

dexec_interpreter="${1}"; shift

function dexec_validate() {
    if [ ${#dexec_sources[@]} -gt 1 ]; then
        >&2 echo "Error: only one source file supported"
        exit 1
    fi
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

function dexec_run() {
    ${dexec_interpreter} ${dexec_sources[*]} "${dexec_args[@]}"
}

function dexec_cleanup() {
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
dexec_run
dexec_cleanup
