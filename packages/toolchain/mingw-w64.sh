#!/bin/bash

PKG_NAME="mingw-w64"
PKG_VERSION="v7.0.0"
PKG_IDENTIFIER=${PKG_NAME}-${PKG_VERSION}

function pkg_download() {
    local PKG_SRC_FILENAME="${PKG_IDENTIFIER}.tar.bz2"
    local PKG_SIG_FILENAME="${PKG_IDENTIFIER}.tar.bz2.sig"
    local PKG_SRC_URL="https://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/${PKG_SRC_FILENAME}"
    local PKG_SIG_URL="https://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/${PKG_SIG_FILENAME}"

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} ]]; then
        rm -fv ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME}
    fi
    if [[ ! -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} ]]; then
        func_create_directory ${SCRIPT_DOWNLOADS_PATH}
        func_download ${PKG_SRC_URL} ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME}
    fi

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_SIG_FILENAME} ]]; then
        rm -fv ${SCRIPT_DOWNLOADS_PATH}/${PKG_SIG_FILENAME}
    fi
    if [[ ! -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_SIG_FILENAME} ]]; then
        func_create_directory ${SCRIPT_DOWNLOADS_PATH}
        func_download ${PKG_SIG_URL} ${SCRIPT_DOWNLOADS_PATH}/${PKG_SIG_FILENAME}
    fi

    func_verify gpg \
        ${SCRIPT_KEYRINGS_PATH}/mingw-w64-keyring.gpg \
        ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} \
        ${SCRIPT_DOWNLOADS_PATH}/${PKG_SIG_FILENAME}
}

function pkg_extract() {
    local PKG_SRC_FILENAME="${PKG_IDENTIFIER}.tar.bz2"
    local PKG_SOURCE_PATH=${SCRIPT_TOOLCHAIN_SOURCES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${PKG_SOURCE_PATH} ]]; then
        rm -rfv ${PKG_SOURCE_PATH}
    fi
    if [[ ! -d ${PKG_SOURCE_PATH} ]]; then
        func_create_directory ${SCRIPT_TOOLCHAIN_SOURCES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}
        func_extract ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} ${SCRIPT_TOOLCHAIN_SOURCES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}
    fi
}

function pkg_configure() {
    # $1 - sub-package name
    case $1 in
        "mingw-w64-headers")
            local SUBPKG_BUILD=${SCRIPT_OPTION_BUILD}
            local SUBPKG_HOST=${SCRIPT_OPTION_HOST}
            local SUBPKG_SOURCE_PATH=${SCRIPT_TOOLCHAIN_SOURCES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-headers
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_TOOLCHAIN_CONFIGURES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-headers
            local SUBPKG_PREFIX_PATH=${SCRIPT_TOOLCHAIN_BUILDS_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${SCRIPT_OPTION_TARGET}

            if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${SUBPKG_CONFIGURE_PATH} ]]; then
                rm -rfv ${SUBPKG_CONFIGURE_PATH}
            fi

            if [[ ! -x ${SUBPKG_CONFIGURE_PATH}/config.status ]]; then
                func_log_message "Configure" toolchain/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-headers

                func_create_directory ${SUBPKG_CONFIGURE_PATH}
                func_create_directory ${SUBPKG_PREFIX_PATH}

                func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                    ${SUBPKG_SOURCE_PATH}/configure \
                        --build=${SUBPKG_BUILD} \
                        --host=${SUBPKG_HOST} \
                        --prefix=${SUBPKG_PREFIX_PATH} \
                        --enable-sdk=all \
                        --enable-secure-api
                func_leave_directory
            fi
        ;;
        "mingw-w64-crt")
            local SUBPKG_BUILD=${SCRIPT_OPTION_BUILD}
            local SUBPKG_HOST=${SCRIPT_OPTION_TARGET}
            local SUBPKG_SOURCE_PATH=${SCRIPT_TOOLCHAIN_SOURCES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-crt
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_TOOLCHAIN_CONFIGURES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-crt
            local SUBPKG_PREFIX_PATH=${SCRIPT_TOOLCHAIN_BUILDS_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${SCRIPT_OPTION_TARGET}

            if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${SUBPKG_CONFIGURE_PATH} ]]; then
                rm -rfv ${SUBPKG_CONFIGURE_PATH}
            fi

            if [[ ! -x ${SUBPKG_CONFIGURE_PATH}/config.status ]]; then
                func_log_message "Configure" toolchain/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-crt

                func_create_directory ${SUBPKG_CONFIGURE_PATH}
                func_create_directory ${SUBPKG_PREFIX_PATH}

                func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                    ${SUBPKG_SOURCE_PATH}/configure \
                        --build=${SUBPKG_BUILD} \
                        --host=${SUBPKG_HOST} \
                        --prefix=${SUBPKG_PREFIX_PATH} \
                        --disable-multilib \
                        --enable-wildcard
                func_leave_directory
            fi
        ;;
        "winpthreads")
            local SUBPKG_BUILD=${SCRIPT_OPTION_BUILD}
            local SUBPKG_HOST=${SCRIPT_OPTION_TARGET}
            local SUBPKG_SOURCE_PATH=${SCRIPT_TOOLCHAIN_SOURCES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-libraries/winpthreads
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_TOOLCHAIN_CONFIGURES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/winpthreads
            local SUBPKG_PREFIX_PATH=${SCRIPT_TOOLCHAIN_BUILDS_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${SCRIPT_OPTION_TARGET}

            if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${SUBPKG_CONFIGURE_PATH} ]]; then
                rm -rfv ${SUBPKG_CONFIGURE_PATH}
            fi

            if [[ ! -x ${SUBPKG_CONFIGURE_PATH}/config.status ]]; then
                func_log_message "Configure" toolchain/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-libraries/winpthreads

                func_create_directory ${SUBPKG_CONFIGURE_PATH}
                func_create_directory ${SUBPKG_PREFIX_PATH}

                func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                    ${SUBPKG_SOURCE_PATH}/configure \
                        --build=${SUBPKG_BUILD} \
                        --host=${SUBPKG_HOST} \
                        --prefix=${SUBPKG_PREFIX_PATH} \
                        --enable-static \
                        --enable-shared
                func_leave_directory
            fi
        ;;
        *)
            func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> pkg_configure: unknown sub-packages $1"
        ;;
    esac
}

function pkg_build() {
    # $1 - sub-package name
    case $1 in
        "mingw-w64-headers")
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_TOOLCHAIN_CONFIGURES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-headers

            func_log_message "Build" toolchain/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-headers

            func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                make -j${SCRIPT_OPTION_JOBS} all
                make -j${SCRIPT_OPTION_JOBS} install-strip
            func_leave_directory
        ;;
        "mingw-w64-crt")
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_TOOLCHAIN_CONFIGURES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-crt

            func_log_message "Build" toolchain/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-crt

            func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                make -j${SCRIPT_OPTION_JOBS} all
                make -j${SCRIPT_OPTION_JOBS} install-strip
            func_leave_directory
        ;;
        "winpthreads")
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_TOOLCHAIN_CONFIGURES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/winpthreads

            func_log_message "Build" toolchain/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-libraries/winpthreads

            func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                make -j${SCRIPT_OPTION_JOBS} all
                make -j${SCRIPT_OPTION_JOBS} install-strip
            func_leave_directory
        ;;
        *)
            func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> pkg_build: unknown sub-packages $1"
        ;;
    esac
}

function pkg_final() {
    # $1 - sub-package name
    case $1 in
        "mingw-w64-headers")
            local SUBPKG_PREFIX_PATH=${SCRIPT_TOOLCHAIN_BUILDS_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${SCRIPT_OPTION_TARGET}

            func_enter_directory "$(dirname ${SUBPKG_PREFIX_PATH})"
                if [[ -L ./mingw ]]; then
                    rm -f ./mingw
                fi
                ln -s ./${SCRIPT_OPTION_TARGET} ./mingw
            func_leave_directory
        ;;
        "mingw-w64-crt")
            :
        ;;
        "winpthreads")
            :
        ;;
        *)
            func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> pkg_build: unknown sub-packages $1"
        ;;
    esac
}

function pkg_clean_env() {
    unset -f pkg_clean_env
    unset -f pkg_final
    unset -f pkg_build
    unset -f pkg_configure
    unset -f pkg_extract
    unset -f pkg_download
    unset PKG_IDENTIFIER
    unset PKG_VERSION
    unset PKG_NAME
}
