#!/bin/bash

SCRIPT_TOOLCHAIN_IDENTIFIER=${SCRIPT_OPTION_TARGET}-${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL}

# directories used while building toolchain
SCRIPT_TOOLCHAIN_PACKAGES_PATH=${SCRIPT_PACKAGES_PATH}/toolchain
SCRIPT_TOOLCHAIN_SOURCES_PATH=${SCRIPT_SOURCES_PATH}/toolchain
SCRIPT_TOOLCHAIN_PATCHES_PATH=${SCRIPT_PATCHES_PATH}/toolchain
SCRIPT_TOOLCHAIN_CONFIGURES_PATH=${SCRIPT_CONFIGURES_PATH}/toolchain
SCRIPT_TOOLCHAIN_DEPENDENCIES_PATH=${SCRIPT_DEPENDENCIES_PATH}/toolchain
SCRIPT_TOOLCHAIN_BUILDS_PATH=${SCRIPT_ROOT_PATH}/builds/toolchain

function build_main() {
    if [[ ! -f ${SCRIPT_TOOLCHAIN_BUILDS_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/toolchain.ready ]]; then
        if [[ -d ${SCRIPT_TOOLCHAIN_BUILDS_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER} ]]; then
            rm -rfv ${SCRIPT_TOOLCHAIN_BUILDS_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}
        fi

        # shellcheck source=toolchain/libiconv.sh
        source ${SCRIPT_TOOLCHAIN_PACKAGES_PATH}/libiconv.sh
        pkg_download
        pkg_extract
        if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
            pkg_configure
            pkg_build
            pkg_final
        fi
        pkg_clean_env

        # shellcheck source=toolchain/gmp.sh
        source ${SCRIPT_TOOLCHAIN_PACKAGES_PATH}/gmp.sh
        pkg_download
        pkg_extract
        if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
            pkg_configure
            pkg_build
            pkg_final
        fi
        pkg_clean_env

        # shellcheck source=toolchain/mpfr.sh
        source ${SCRIPT_TOOLCHAIN_PACKAGES_PATH}/mpfr.sh
        pkg_download
        pkg_extract
        if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
            pkg_configure
            pkg_build
            pkg_final
        fi
        pkg_clean_env

        # shellcheck source=toolchain/mpc.sh
        source ${SCRIPT_TOOLCHAIN_PACKAGES_PATH}/mpc.sh
        pkg_download
        pkg_extract
        if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
            pkg_configure
            pkg_build
            pkg_final
        fi
        pkg_clean_env

        # shellcheck source=toolchain/isl.sh
        source ${SCRIPT_TOOLCHAIN_PACKAGES_PATH}/isl.sh
        pkg_download
        pkg_extract
        if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
            pkg_configure
            pkg_build
            pkg_final
        fi
        pkg_clean_env

        # shellcheck source=toolchain/mingw-w64.sh
        source ${SCRIPT_TOOLCHAIN_PACKAGES_PATH}/mingw-w64.sh
        pkg_download
        pkg_extract
        if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
            pkg_configure   "mingw-w64-headers"
            pkg_build       "mingw-w64-headers"
            pkg_final       "mingw-w64-headers"
        fi
        pkg_clean_env

        # shellcheck source=toolchain/binutils.sh
        source ${SCRIPT_TOOLCHAIN_PACKAGES_PATH}/binutils.sh
        pkg_download
        pkg_extract
        if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
            pkg_configure
            pkg_build
            pkg_final
        fi
        pkg_clean_env

        # shellcheck source=toolchain/gcc.sh
        source ${SCRIPT_TOOLCHAIN_PACKAGES_PATH}/gcc.sh
        pkg_download
        pkg_extract
        if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
            pkg_configure
            pkg_build all-gcc install-strip-gcc
            pkg_final
        fi
        pkg_clean_env

        # shellcheck source=toolchain/mingw-w64.sh
        source ${SCRIPT_TOOLCHAIN_PACKAGES_PATH}/mingw-w64.sh
        if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
            func_load_toolchain ${SCRIPT_TOOLCHAIN_IDENTIFIER}
                pkg_configure   "mingw-w64-crt"
                pkg_build       "mingw-w64-crt"
                pkg_final       "mingw-w64-crt"

                pkg_configure   "winpthreads"
                pkg_build       "winpthreads"
                pkg_final       "winpthreads"
            func_unload_toolchain
        fi
        pkg_clean_env

        # shellcheck source=toolchain/gcc.sh
        source ${SCRIPT_TOOLCHAIN_PACKAGES_PATH}/gcc.sh
        if [[ ${SCRIPT_OPTION_FETCH_ONLY} == 'no' ]]; then
            pkg_configure
            pkg_build all install-strip
            pkg_final
        fi
        pkg_clean_env

        touch ${SCRIPT_TOOLCHAIN_BUILDS_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/toolchain.ready

        func_log_success "SUCCESS" "toolchain ${SCRIPT_TOOLCHAIN_IDENTIFIER} has been built successfully"
    fi
}

function build_clean_env() {
    unset -f build_clean_env
    unset -f build_main
    unset SCRIPT_TOOLCHAIN_BUILDS_PATH
    unset SCRIPT_TOOLCHAIN_CONFIGURES_PATH
    unset SCRIPT_TOOLCHAIN_PATCHES_PATH
    unset SCRIPT_TOOLCHAIN_SOURCES_PATH
    unset SCRIPT_TOOLCHAIN_PACKAGES_PATH
    unset SCRIPT_TOOLCHAIN_IDENTIFIER
}
