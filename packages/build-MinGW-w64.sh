#!/bin/bash

SCRIPT_MINGW_W64_IDENTIFIER=$(func_get_arch ${SCRIPT_OPTION_TARGET})-${SCRIPT_OPTION_GCC_THREADS_MODEL}-${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL}

# directories used while building MinGW-w64
SCRIPT_MINGW_W64_PACKAGES_PATH=${SCRIPT_PACKAGES_PATH}/MinGW-w64
SCRIPT_MINGW_W64_SOURCES_PATH=${SCRIPT_SOURCES_PATH}/MinGW-w64
SCRIPT_MINGW_W64_PATCHES_PATH=${SCRIPT_PATCHES_PATH}/MinGW-w64
SCRIPT_MINGW_W64_CONFIGURES_PATH=${SCRIPT_CONFIGURES_PATH}/MinGW-w64
SCRIPT_MINGW_W64_DEPENDENCIES_PATH=${SCRIPT_DEPENDENCIES_PATH}/MinGW-w64
SCRIPT_MINGW_W64_BUILDS_PATH=${SCRIPT_BUILDS_PATH}/MinGW-w64

# the toolchain identifier used while building MinGW-w64
SCRIPT_MINGW_W64_TOOLCHAIN_IDENTIFIER=${SCRIPT_OPTION_TARGET}-${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL}

function build_main() {
    if [[ -f ${SCRIPT_BUILDS_PATH}/toolchain/${SCRIPT_MINGW_W64_TOOLCHAIN_IDENTIFIER}/toolchain.ready ]]; then
        if [[ ! -f ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/MinGW-w64.ready ]]; then
            if [[ -d ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER} ]]; then
                rm -rfv ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}
            fi

            func_load_toolchain ${SCRIPT_MINGW_W64_TOOLCHAIN_IDENTIFIER}

                # shellcheck source=MinGW-w64/libiconv.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/libiconv.sh
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
                    pkg_configure
                    pkg_build
                    pkg_final
                fi
                pkg_clean_env

                # shellcheck source=MinGW-w64/gmp.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/gmp.sh
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
                    pkg_configure
                    pkg_build
                    pkg_final
                fi
                pkg_clean_env

                # shellcheck source=MinGW-w64/mpfr.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/mpfr.sh
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
                    pkg_configure
                    pkg_build
                    pkg_final
                fi
                pkg_clean_env

                # shellcheck source=MinGW-w64/mpc.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/mpc.sh
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
                    pkg_configure
                    pkg_build
                    pkg_final
                fi
                pkg_clean_env

                # shellcheck source=MinGW-w64/isl.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/isl.sh
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
                    pkg_configure
                    pkg_build
                    pkg_final
                fi
                pkg_clean_env

                # shellcheck source=MinGW-w64/mingw-w64.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/mingw-w64.sh
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
                    pkg_configure   "mingw-w64-headers"
                    pkg_build       "mingw-w64-headers"

                    pkg_configure   "mingw-w64-crt"
                    pkg_build       "mingw-w64-crt"

                    pkg_configure   "winpthreads"
                    pkg_build       "winpthreads"

                    pkg_configure   "libmangle"
                    pkg_build       "libmangle"

                    pkg_configure   "gendef"
                    pkg_build       "gendef"

                    pkg_configure   "genidl"
                    pkg_build       "genidl"

                    pkg_configure   "genpeimg"
                    pkg_build       "genpeimg"

                    pkg_configure   "widl"
                    pkg_build       "widl"

                    pkg_final "mingw-w64"
                    pkg_final "winpthreads"
                    pkg_final "libmangle"
                    pkg_final "gendef"
                    pkg_final "genidl"
                    pkg_final "genpeimg"
                    pkg_final "widl"
                fi
                pkg_clean_env

                # shellcheck source=MinGW-w64/binutils.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/binutils.sh
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
                    pkg_configure
                    pkg_build
                    pkg_final
                fi
                pkg_clean_env

                # shellcheck source=MinGW-w64/gcc.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/gcc.sh
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
                    pkg_configure
                    pkg_build
                    pkg_final
                fi
                pkg_clean_env

                # shellcheck source=MinGW-w64/termcap.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/termcap.sh   # required by readline
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == "no" ]]; then
                    pkg_configure
                    pkg_build
                    pkg_final
                fi
                pkg_clean_env

                # shellcheck source=MinGW-w64/expat.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/expat.sh     # required by gdb
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == "no" ]]; then
                    pkg_configure
                    pkg_build
                    pkg_final
                fi
                pkg_clean_env

                # shellcheck source=MinGW-w64/readline.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/readline.sh  # requires termcap, required by gdb
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == "no" ]]; then
                    pkg_configure
                    pkg_build
                    pkg_final
                fi
                pkg_clean_env

                # shellcheck source=MinGW-w64/xz.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/xz.sh  # requires termcap, required by gdb
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == "no" ]]; then
                    pkg_configure
                    pkg_build
                    pkg_final
                fi
                pkg_clean_env

                # shellcheck source=MinGW-w64/python.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/python.sh
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == "no" ]]; then
                    pkg_configure
                    pkg_build
                    pkg_final
                fi
                pkg_clean_env

                # shellcheck source=MinGW-w64/gdb.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/gdb.sh
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == "no" ]]; then
                    pkg_configure
                    pkg_build
                    pkg_final
                fi
                pkg_clean_env

                # shellcheck source=MinGW-w64/make.sh
                source ${SCRIPT_MINGW_W64_PACKAGES_PATH}/make.sh
                pkg_download
                pkg_extract
                if [[ ${SCRIPT_OPTION_FETCH_ONLY} == "no" ]]; then
                    pkg_configure
                    pkg_build
                    pkg_final
                fi
                pkg_clean_env

            func_unload_toolchain

            touch ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/MinGW-w64.ready

            func_log_success "SUCCESS" "MinGW-w64 ${SCRIPT_MINGW_W64_IDENTIFIER} has been built successfully"
        fi
    else
        func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> build_main: toolchain ${SCRIPT_MINGW_W64_TOOLCHAIN_IDENTIFIER} is not found"
    fi
}

function build_pack() {
    func_enter_directory ${SCRIPT_MINGW_W64_BUILDS_PATH}

    zip -9 -r ${SCRIPT_MINGW_W64_IDENTIFIER}.zip ${SCRIPT_MINGW_W64_IDENTIFIER}/

    func_leave_directory
}

function build_clean_env() {
    unset -f build_clean_env
    unset -f build_pack
    unset -f build_main
    unset SCRIPT_MINGW_W64_BUILDS_PATH
    unset SCRIPT_MINGW_W64_CONFIGURES_PATH
    unset SCRIPT_MINGW_W64_PATCHES_PATH
    unset SCRIPT_MINGW_W64_SOURCES_PATH
    unset SCRIPT_MINGW_W64_PACKAGES_PATH
    unset SCRIPT_MINGW_W64_TOOLCHAIN_IDENTIFIER
    unset SCRIPT_MINGW_W64_IDENTIFIER
}
