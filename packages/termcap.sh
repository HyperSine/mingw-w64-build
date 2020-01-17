#!/bin/bash

PKG_NAME="termcap"
PKG_VERSION="1.3.1"
PKG_IDENTIFIER=${PKG_NAME}-${PKG_VERSION}

function pkg_download() {
    local PKG_SRC_FILENAME="${PKG_IDENTIFIER}.tar.gz"
    local PKG_SRC_URL="https://ftp.gnu.org/gnu/termcap/${PKG_SRC_FILENAME}"

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" || ! -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} ]]; then
        func_create_directory ${SCRIPT_DOWNLOADS_PATH}
        func_download ${PKG_SRC_URL} ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME}
    fi
}

function pkg_extract() {
    local PKG_SRC_FILENAME="${PKG_IDENTIFIER}.tar.gz"
    local PKG_SOURCE_PATH=${SCRIPT_SOURCES_PATH}/${PKG_IDENTIFIER}

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" || ! -d ${PKG_SOURCE_PATH} ]]; then
        func_create_directory ${SCRIPT_SOURCES_PATH}
        func_extract ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} ${SCRIPT_SOURCES_PATH}
    fi
}

function pkg_configure() {
    local PKG_BUILD=${SCRIPT_OPTION_BUILD}
    local PKG_HOST=${SCRIPT_OPTION_HOST}
    local PKG_SOURCE_PATH=${SCRIPT_SOURCES_PATH}/${PKG_IDENTIFIER}
    local PKG_CONFIGURE_PATH=${SCRIPT_CONFIGURES_PATH}/${PKG_IDENTIFIER}
    local PKG_PREFIX_PATH=${SCRIPT_DEPENDENCIES_PATH}/${PKG_NAME}

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" || ! -x ${PKG_CONFIGURE_PATH}/config.status ]]; then
        func_log_message "Configure" ${PKG_IDENTIFIER}

        func_create_directory ${PKG_CONFIGURE_PATH}
        func_create_directory ${PKG_PREFIX_PATH}

        func_enter_directory ${PKG_CONFIGURE_PATH}
            CC=${PKG_HOST}-gcc \
            RANLIB=${PKG_HOST}-ranlib \
                ${PKG_SOURCE_PATH}/configure \
                    --build=${PKG_BUILD} \
                    --host=${PKG_HOST} \
                    --prefix=${PKG_PREFIX_PATH} \
                    --exec-prefix=${PKG_PREFIX_PATH}
        func_leave_directory
    fi
}

function pkg_build() {
    local PKG_CONFIGURE_PATH=${SCRIPT_CONFIGURES_PATH}/${PKG_IDENTIFIER}

    func_log_message "Build" ${PKG_IDENTIFIER}

    func_enter_directory ${PKG_CONFIGURE_PATH}
        make -j${SCRIPT_OPTION_JOBS} all
        make -j${SCRIPT_OPTION_JOBS} install oldincludedir=""
    func_leave_directory
}

function pkg_final() {
    :
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

