#!/bin/bash

# Terminate if error
set -e

readonly SCRIPT_ROOT_PATH=$(cd "$(dirname $0)" && pwd)
readonly SCRIPT_LIBRARIES_PATH=${SCRIPT_ROOT_PATH}/libraries
readonly SCRIPT_KEYRINGS_PATH=${SCRIPT_ROOT_PATH}/keyrings
readonly SCRIPT_DOWNLOADS_PATH=${SCRIPT_ROOT_PATH}/downloads
readonly SCRIPT_PACKAGES_PATH=${SCRIPT_ROOT_PATH}/packages
readonly SCRIPT_SOURCES_PATH=${SCRIPT_ROOT_PATH}/sources
readonly SCRIPT_PATCHES_PATH=${SCRIPT_ROOT_PATH}/patches
readonly SCRIPT_CONFIGURES_PATH=${SCRIPT_ROOT_PATH}/configures
readonly SCRIPT_DEPENDENCIES_PATH=${SCRIPT_ROOT_PATH}/dependencies
readonly SCRIPT_BUILDS_PATH=${SCRIPT_ROOT_PATH}/builds

function show_help() {
    echo "Usage:"
    echo "    build.sh help"
    echo "    build.sh toolchain [options...]"
    echo "        --target=<i686-w64-mingw32|x86_64-w64-mingw32>    Mandatory"
    echo "        --exceptions-model=<dwarf|sjlj|seh>               Mandatory"
    echo "        --jobs=<num>                                      Optional, default: 1"
    echo "        --fetch-only                                      Optional, default: no"
    echo "        --force-update                                    Optional, default: no"
    echo "    build.sh MinGW-w64 [options...]"
    echo "        --arch=<i686-w64-mingw32|x86_64-w64-mingw32>      Mandatory"
    echo "        --exceptions-model=<dwarf|sjlj|seh>               Mandatory"
    echo "        --threads-model=<posix|win32>                     Mandatory"
    echo "        --enable-languages=<langs>                        Mandatory, available languages: c,c++,fortran"
    echo "        --jobs=<num>                                      Optional, default: 1"
    echo "        --fetch-only                                      Optional, default: no"
    echo "        --force-update                                    Optional, default: no"
}

# shellcheck source=libraries/functions.sh
source ${SCRIPT_LIBRARIES_PATH}/functions.sh

case $1 in
    "help")
        show_help
    ;;
    "toolchain")
        SCRIPT_OPTION_BUILD=$(gcc -dumpmachine)
        SCRIPT_OPTION_HOST=${SCRIPT_OPTION_BUILD}
        SCRIPT_OPTION_TARGET=
        SCRIPT_OPTION_FETCH_ONLY=no
        SCRIPT_OPTION_FORCE_UPDATE=no
        SCRIPT_OPTION_JOBS=1
        SCRIPT_OPTION_GCC_VERSION="9.2.0"
        SCRIPT_OPTION_GCC_ENABLE_LANGUAGES="c,c++,fortran,lto"
        SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL=
        SCRIPT_OPTION_GCC_THREADS_MODEL="win32"

        for arg in ${@:2}; do
            case $arg in
                --target=*)
                    SCRIPT_OPTION_TARGET=${arg#*=}
                    case ${SCRIPT_OPTION_TARGET} in
                        "i686-w64-mingw32") true;;
                        "x86_64-w64-mingw32") true;;
                        *) func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> invalid argument: $arg";;
                    esac
                ;;
                --exceptions-model=*)
                    SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL=${arg#*=}
                    case ${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL} in
                        "dwarf") true;;
                        "sjlj") true;;
                        "seh") true;;
                        *) func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> invalid argument: $arg";;
                    esac
                ;;
                --jobs=*)
                    SCRIPT_OPTION_JOBS=${arg#*=}
                    if [[ ! ${SCRIPT_OPTION_JOBS} =~ ^[1-9][0-9]*$ ]]; then
                        func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> invalid argument: $arg"
                    fi
                ;;
                --fetch-only)
                    SCRIPT_OPTION_FETCH_ONLY=yes
                ;;
                --force-update)
                    SCRIPT_OPTION_FORCE_UPDATE=yes
                ;;
                *)
                    func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> unknown argument: $arg"
                ;;
            esac
        done

        if [[ -z ${SCRIPT_OPTION_TARGET} ]]; then
            func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> a mandatory parameter \"--target\" is missing"
        fi
        if [[ -z ${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL} ]]; then
            func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> a mandatory parameter \"--exceptions-model\" is missing"
        fi

        if [[ ${SCRIPT_OPTION_TARGET} == "i686-w64-mingw32" && ${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL} == "dwarf" ]]; then
            true
        elif [[ ${SCRIPT_OPTION_TARGET} == "i686-w64-mingw32" && ${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL} == "sjlj" ]]; then
            true
        elif [[ ${SCRIPT_OPTION_TARGET} == "x86_64-w64-mingw32" && ${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL} == "sjlj" ]]; then
            true
        elif [[ ${SCRIPT_OPTION_TARGET} == "x86_64-w64-mingw32" && ${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL} == "seh" ]]; then
            true
        else
            func_log_failure 1 "FATAL" \
                "${BASH_SOURCE[0]} -> \"--exceptions-model=${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL}\" is not supported for \"--target=${SCRIPT_OPTION_TARGET}\""
        fi

        # shellcheck source=packages/build-toolchain.sh
        source ${SCRIPT_PACKAGES_PATH}/build-toolchain.sh
        build_main
        build_clean_env
    ;;
    "MinGW-w64")
        SCRIPT_OPTION_BUILD=$(gcc -dumpmachine)
        SCRIPT_OPTION_HOST=
        SCRIPT_OPTION_TARGET=
        SCRIPT_OPTION_FETCH_ONLY=no
        SCRIPT_OPTION_FORCE_UPDATE=no
        SCRIPT_OPTION_JOBS=1
        SCRIPT_OPTION_GCC_VERSION="9.2.0"
        SCRIPT_OPTION_GCC_ENABLE_LANGUAGES=
        SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL=
        SCRIPT_OPTION_GCC_THREADS_MODEL=

        for arg in ${@:2}; do
            case $arg in
                --arch=*)
                    SCRIPT_OPTION_HOST=${arg#*=}
                    SCRIPT_OPTION_TARGET=${SCRIPT_OPTION_HOST}
                    case ${SCRIPT_OPTION_HOST} in
                        "i686-w64-mingw32") true;;
                        "x86_64-w64-mingw32") true;;
                        *) func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> invalid argument: $arg";;
                    esac
                ;;
                --exceptions-model=*)
                    SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL=${arg#*=}
                    case ${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL} in
                        "dwarf") true;;
                        "sjlj") true;;
                        "seh") true;;
                        *) func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> invalid argument: $arg";;
                    esac
                ;;
                --threads-model=*)
                    SCRIPT_OPTION_GCC_THREADS_MODEL=${arg#*=}
                    case ${SCRIPT_OPTION_GCC_THREADS_MODEL} in
                        "posix") true;;
                        "win32") true;;
                        *) func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> invalid argument: $arg";;
                    esac
                ;;
                --enable-languages=*)
                    SCRIPT_OPTION_GCC_ENABLE_LANGUAGES=${arg#*=}

                    SCRIPT_OPTION_GCC_ENABLE_LANGUAGES_ARRAY=
                    IFS=',' read -r -a SCRIPT_OPTION_GCC_ENABLE_LANGUAGES_ARRAY <<< ${SCRIPT_OPTION_GCC_ENABLE_LANGUAGES}
                    if [[ ${#SCRIPT_OPTION_GCC_ENABLE_LANGUAGES_ARRAY[@]} == 0 ]]; then
                        func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> no languages is specified in parameter \"$arg\""
                    fi
                    for language in ${SCRIPT_OPTION_GCC_ENABLE_LANGUAGES_ARRAY}; do
                        case ${language} in
                            "c") true;;
                            "c++") true;;
                            "fortran") true;;
                            *) func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> invalid/unsupported language \"${language}\" in parameter \"$arg\"";;
                        esac
                    done
                    unset language
                    unset SCRIPT_OPTION_GCC_ENABLE_LANGUAGES_ARRAY

                    SCRIPT_OPTION_GCC_ENABLE_LANGUAGES="${SCRIPT_OPTION_GCC_ENABLE_LANGUAGES},lto"
                ;;
                --jobs=*)
                    SCRIPT_OPTION_JOBS=${arg#*=}
                    if [[ ! ${SCRIPT_OPTION_JOBS} =~ ^[1-9][0-9]*$ ]]; then
                        func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> invalid argument: $arg"
                    fi
                ;;
                --fetch-only)
                    SCRIPT_OPTION_FETCH_ONLY=yes
                ;;
                --force-update)
                    SCRIPT_OPTION_FORCE_UPDATE=yes
                ;;
                *)
                    func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> unknown argument: $arg"
                ;;
            esac
        done

        if [[ -z ${SCRIPT_OPTION_HOST} ]]; then
            func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> a mandatory parameter \"--arch\" is missing"
        fi
        if [[ -z ${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL} ]]; then
            func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> a mandatory parameter \"--exceptions-model\" is missing"
        fi
        if [[ -z ${SCRIPT_OPTION_GCC_THREADS_MODEL} ]]; then
            func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> a mandatory parameter \"--threads-model\" is missing"
        fi
        if [[ -z ${SCRIPT_OPTION_GCC_ENABLE_LANGUAGES} ]]; then
            func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> a mandatory parameter \"--enable-languages\" is missing"
        fi

        if [[ ${SCRIPT_OPTION_HOST} == "i686-w64-mingw32" && ${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL} == "dwarf" ]]; then
            true
        elif [[ ${SCRIPT_OPTION_HOST} == "i686-w64-mingw32" && ${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL} == "sjlj" ]]; then
            true
        elif [[ ${SCRIPT_OPTION_HOST} == "x86_64-w64-mingw32" && ${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL} == "sjlj" ]]; then
            true
        elif [[ ${SCRIPT_OPTION_HOST} == "x86_64-w64-mingw32" && ${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL} == "seh" ]]; then
            true
        else
            func_log_failure 1 "FATAL" \
                "${BASH_SOURCE[0]} -> \"--exceptions-model=${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL}\" is not supported for \"--arch=${SCRIPT_OPTION_HOST}\""
        fi

        # shellcheck source=packages/build-MinGW-w64.sh
        source ${SCRIPT_PACKAGES_PATH}/build-MinGW-w64.sh
        build_main
        build_pack
        build_clean_env
    ;;
    *)
        func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> unknown build type $1"
    ;;
esac
