#!/usr/bin/env bats

source "${BATS_TEST_DIRNAME}/../dexec-common.sh"

@test "dexec_uuid returns a uuid" {
    local result=$(dexec_uuid)
    local uuid_pattern="[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12}"
    echo $result | grep -Ee "${uuid_pattern}"
}

@test "dexec_array_contains returns true for array containing target item without space" {
    local some_array=('apple' 'misc fruit' 'pear' 'banana')
    run dexec_array_contains "banana" "${some_array[@]}"

    [ ${status} -eq 0 ]
}

@test "dexec_array_contains returns true for array containing target item with space" {
    local some_array=('apple' 'misc fruit' 'pear' 'banana')
    run dexec_array_contains "misc fruit" "${some_array[@]}"

    [ ${status} -eq 0 ]
}

@test "dexec_array_contains returns false for array not containing target item" {
    local some_array=('apple' 'misc fruit' 'pear' 'banana')
    run dexec_array_contains "orange" "${some_array[@]}"

    [ ${status} -eq 1 ]
}

@test "dexec_array_index_of returns the expected index for item in array" {
    local some_array=('apple' 'misc fruit' 'pear' 'banana')
    local result="$(dexec_array_index_of "pear" "${some_array[@]}")"

    [ ${result} -eq 2 ]
}

@test "dexec_array_index_of returns -1 for item not in array" {
    local some_array=('apple' 'misc fruit' 'pear' 'banana')
    local result="$(dexec_array_index_of "bear" "${some_array[@]}")"

    [ ${result} -eq -1 ]
}

@test "dexec_array_first_item_matching returns the first item matching a pattern" {
    local some_array=('apple' 'misc fruit' 'pear' 'banana' 'starfruit')
    local result="$(dexec_array_first_item_matching 'ar' "${some_array[@]}")"
    >&2 echo $result

    [ "${result}" = 'pear' ]
}

@test "dexec_array_first_item_matching returns nothing when no items match a pattern" {
    local some_array=('apple' 'misc fruit' 'pear' 'banana' 'starfruit')
    local result="$(dexec_array_first_item_matching 'orang' "${some_array[@]}")"

    [ -z "${result}" ]
}

@test "dexec_array_item_after returns the next item when item and next item present" {
    local some_array=('apple' 'misc fruit' 'pear')
    local result="$(dexec_array_item_after 'misc fruit' "${some_array[@]}")"

    [ "${result}" = 'pear' ]
}

@test "dexec_array_item_after returns nothing when item present and next item not present" {
    local some_array=('apple' 'misc fruit' 'pear')
    local result="$(dexec_array_item_after 'pear' "${some_array[@]}")"

    [ -z "${result}" ]
}

@test "dexec_array_item_after returns nothing when item not present" {
    local some_array=('apple' 'misc fruit' 'pear')
    local result="$(dexec_array_item_after 'bear' "${some_array[@]}")"

    [ -z "${result}" ]
}

@test "dexec_is_flag_set returns false when flag is not set" {
    run dexec_is_flag_set "y"
    dexec_flags=("k")

    [ ${status} -eq 1 ]
}

@test "dexec_is_flag_set returns true when flag is set" {
    dexec_flags=("k")
    run dexec_is_flag_set "k"

    [ ${status} -eq 0 ]
}

@test "dexec_parse_params parses build argument params" {
    local params=('--build-arg=value1' '--build-arg' 'value2' '-b' 'value3')
    dexec_parse_params "${params[@]}"

    [ ${#dexec_build_args[@]} -eq 3 ]
}

@test "dexec_parse_params parses execution argument params" {
    local params=('--arg=value1' '--arg' 'value2' '-a' 'value3')
    dexec_parse_params "${params[@]}"

    [ ${#dexec_args[@]} -eq 3 ]
}

@test "dexec_parse_params parses source file params" {
    local params=('anything.cpp' 'spaced filename.cpp')
    dexec_parse_params "${params[@]}"

    [ ${#dexec_sources[@]} -eq 2 ]
}
