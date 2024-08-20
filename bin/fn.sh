#!/usr/bin/env bash

STEP="----->"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

readonly STEP
readonly RED
readonly GREEN
readonly YELLOW
readonly NC


sc::_::info() {
    echo "       $*"
}

sc::_::warn() {
    echo -e "${YELLOW} !     $*${NC}"
}

sc::_::err() {
    echo -e "${RED} !!    $*${NC}" >&2
}


sc::trap::setup() {
    trap sc::_::fail EXIT SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM
}

sc::trap::teardown() {
    trap - EXIT SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM
}


sc::_::start() {
    set -o errexit
    set -o pipefail

    if [ -n "${BUILDPACK_DEBUG}" ]; then
        set -o xtrace
    fi

    sc::trap::setup
}

sc::_::finish() {
    sc::trap::teardown
    echo
    echo -e "${STEP}${GREEN} All done!${NC}"
    exit 0
}

sc::_::fail() {
    sc::trap::teardown
    echo
    echo -e "${RED}Failed.${NC}" >&2
    exit 1
}


sc::_::step_start() {
    echo "${STEP} $*"
}

sc::_::step_finish() {
    echo -e "${GREEN}       Done.${NC}"
}

sc::_::step_fail() {
    echo -e "${RED}       Failed.${NC}"
}


sc::_::task_start() {
    echo -n "       $*... "
}

sc::_::task_finish() {
    echo "OK."
}

sc::_::task_fail() {
    echo "Failed."

    if [ -n "${1}" ]; then
        sc::_::err "${1}"
    fi
}


sc::_::check_cached_file() {
    local rc
    local cached
    local hash_url
    local hash
    local ref
    local checksum

    rc=1
    cached="${1}"
    hash_url="${2}"

    hash="${hash_url##*.}"

    case "${hash}" in
        "sha1")
            checksum="$( shasum -a 1 "${cached}" | cut -d " " -f 1 )"
            ;;
        "sha256")
            checksum="$( shasum -a 256 "${cached}" | cut -d " " -f 1 )"
            ;;
        "md5")
            checksum="$( md5sum "${cached}" | cut -d " " -f 1 )"
            ;;
        *)
            sc::_::info "Unsupported hash algorithm. Aborting."
            rc=2
            ;;
    esac

    if [ -n "${checksum}" ]; then
        curl --silent --location "${hash_url}" --output "${cached}.${hash}"

        if [ -f "${cached}.${hash}" ]; then
            ref="$( cat "${cached}.${hash}" )"

            if [ "${checksum}" == "${ref}" ]; then
                rc=0
            else
                rm --force "${cached}"
            fi
        fi
    fi

    return "${rc}"
}

sc::_::download() {
    local rc
    local url
    local hash_url
    local cached

    rc=1
    url="${1}"
    hash_url="${2}"
    cached="${3}"

    if curl --silent --location "${url}" --output "${cached}"; then
        sc::_::check_cached_file "${cached}" "${hash_url}"
        rc=0
    fi

    return "${rc}"
}


sc::_::read_env() {
    local env_dir
    local env_vars

    env_dir="${1}"
    env_vars="$( list_env_vars "${env_dir}" )"

    while read -r e
    do
        local value
        value="$( cat "${env_dir}/${e}" )"

        export "${e}=${value}"
    done <<< "${env_vars}"
}

sc::_::list_env_vars() {
    local env_dir
    local env_vars
    local blacklist_regex

    env_dir="${1}"
    env_vars=""
    blacklist_regex="^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH|LD_LIBRARY_PATH)$"

    if [ -d "${env_dir}" ]
    then
        # shellcheck disable=SC2010
        env_vars="$( ls "${env_dir}" \
                        | grep \
                            --invert-match \
                            --extended-regexp \
                            "${blacklist_regex}" )"
    fi

    echo "${env_vars}"
}


readonly -f sc::_::info
readonly -f sc::_::warn
readonly -f sc::_::err

readonly -f sc::_::start
readonly -f sc::_::finish
readonly -f sc::_::fail

readonly -f sc::_::step_start
readonly -f sc::_::step_finish
readonly -f sc::_::step_fail

readonly -f sc::_::task_start
readonly -f sc::_::task_finish
readonly -f sc::_::task_fail

readonly -f sc::_::check_cached_file
readonly -f sc::_::download

readonly -f sc::_::read_env
readonly -f sc::_::list_env_vars
