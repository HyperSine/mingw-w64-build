#!/bin/bash

function func_log_message() {
    # $1 - header
    # $2 - message
    local COLOR_LIGHT_BLUE="\033[1;34m"
    local COLOR_NONE="\033[0m"
    echo -e "[${COLOR_LIGHT_BLUE}$1${COLOR_NONE}] $2"
}

function func_log_success() {
    # $1 - header
    # $2 - message
    local COLOR_LIGHT_GREEN="\033[1;32m"
    local COLOR_NONE="\033[0m"
    echo -e "[${COLOR_LIGHT_GREEN}$1${COLOR_NONE}] $2"
}

function func_log_failure() {
    # $1 - exit code
    # $2 - header
    # $3 - message
    local COLOR_LIGHT_RED="\033[1;31m"
    local COLOR_NONE="\033[0m"
    >&2 echo -e "[${COLOR_LIGHT_RED}$2${COLOR_NONE}] $3"
    exit $1
}

function func_create_directory() {
    mkdir -p $1
}

function func_create_empty_directory() {
    if [[ -d $1 ]]; then
        rm -rf $1
    fi
    mkdir -p $1
}

function func_push_to_path_env() {
    # $1 - path to be pushed to ${PATH} environment variable
    PATH="$1:${PATH}"
}

function func_pop_from_path_env() {
    local IFS=":"
    local ITEMS=
    read -a ITEMS <<< "${PATH}"
    echo ${ITEMS[0]}
    ITEMS=("${ITEMS[@]:1}")
    PATH=$(echo "${ITEMS[*]}")
}

function func_get_arch() {
    # $1 - HOST
    case $1 in
        "i686-w64-mingw32") echo "i686";;
        "x86_64-w64-mingw32") echo "x86_64";;
        *) func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> func_get_arch: unknown host $1";;
    esac
}

function func_get_arch_bits() {
    # $1 - HOST
    case $1 in
        "i686-w64-mingw32") echo 32;;
        "x86_64-w64-mingw32") echo 64;;
        *) func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> func_get_arch_bits: unknown host $1";;
    esac
}

function func_get_python_arch() {
    # $1 - HOST
    case $1 in
        "i686-w64-mingw32") echo "win32";;
        "x86_64-w64-mingw32") echo "amd64";;
        *) func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> func_get_python_arch: unknown host $1";;
    esac
}

function func_enter_directory() {
    # $1 - directory name
    func_log_message "Enter direcotry" $1
    pushd $1 > /dev/null
}

function func_leave_directory() {
    func_log_message "Leave direcotry" $PWD
    popd > /dev/null
}

function func_download() {
    # $1 - download URL
    # $2 - save path
    func_log_message "Download" $1
    wget $1 -O $2
}

function func_verify() {
    # $1 - verifier
    case $1 in
        "gpg")
            # $2 - keyring path
            # $3 - file path
            # $4 - sig file path
            if gpg --verify --no-default-keyring --keyring $2 $4 $3; then
                func_log_success "SUCCESS" "Good signature for $3"
            else
                func_log_failure $? "FATAL" "Bad signature for $3"
            fi
        ;;
        "sha256sum")
            # $2 - file path
            # $3 - checksum
            if echo "$3 $2" | sha256sum -c; then
                func_log_success "SUCCESS" "Good checksum for $2"
            else
                func_log_failure $? "FATAL" "Bad checksum for $2"
            fi
        ;;
        "sha512sum")
            # $2 - file path
            # $3 - checksum
            if echo "$3 $2" | sha512sum -c; then
                func_log_success "SUCCESS" "Good checksum for $2"
            else
                func_log_failure $? "FATAL" "Bad checksum for $2"
            fi
        ;;
        *)
            func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> func_verify: unknown verifier $1"
        ;;
    esac
}

function func_extract() {
    # $1 - zipped file path
    # $2 - path that zipped file is extracted to
    case $1 in
        *.msi)
            func_log_message "Extract" "$(basename $1)"
            msiextract --directory $2 $1
        ;;
        *.tar.bz2)
            func_log_message "Extract" "$(basename $1)"
            tar -xjf $1 --directory $2
        ;;
        *.tar.gz)
            func_log_message "Extract" "$(basename $1)"
            tar -xzf $1 --directory $2
        ;;
        *.tar.xz)
            func_log_message "Extract" "$(basename $1)"
            tar -xf $1 --directory $2
        ;;
        *.zip)
            func_log_message "Extract" "$(basename $1)"
            unzip $1 -d $2
        ;;
        *)
            func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> func_extract: cannot extract $1"
        ;;
    esac
}

function func_apply_patch() {
    func_log_message "Apply patch" "${@: -1}"
    patch "${@:1:$#-1}" < "${@: -1}"
}

function func_load_toolchain() {
    # $1 - toolchain identifier
    func_push_to_path_env ${SCRIPT_BUILDS_PATH}/toolchain/$1/bin
}

function func_unload_toolchain() {
    func_pop_from_path_env > /dev/null
}
