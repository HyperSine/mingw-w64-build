#!/bin/bash

PKG_NAME="bzip2"
PKG_VERSION="1.0.6"
PKG_IDENTIFIER=${PKG_NAME}-${PKG_VERSION}

function pkg_download() {
    local PKG_SRC_FILENAME="${PKG_IDENTIFIER}.tar.gz"
    local PKG_SRC_URL="https://sourceforge.net/projects/bzip2/files/${PKG_SRC_FILENAME}"

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" || ! -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} ]]; then
        func_create_directory ${SCRIPT_DOWNLOADS_PATH}
        func_download ${PKG_SRC_URL} ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME}
    fi
}

function pkg_extract() {
    local PKG_SRC_FILENAME="${PKG_IDENTIFIER}.tar.gz"
    local PKG_SOURCE_PATH=${SCRIPT_SOURCES_PATH}/${PKG_IDENTIFIER}
    local PKG_PATCH_PATH=${SCRIPT_PATCHES_PATH}/${PKG_NAME}

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" || ! -d ${PKG_SOURCE_PATH} ]]; then
        func_create_directory ${SCRIPT_SOURCES_PATH}

        func_extract ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} ${SCRIPT_SOURCES_PATH}

        func_enter_directory ${PKG_SOURCE_PATH}
            patch -p1 -i ${PKG_PATCH_PATH}/bzip2-1.0.4-bzip2recover.patch
            patch -p0 -i ${PKG_PATCH_PATH}/bzip2-1.0.6-autoconfiscated.patch
            patch -p1 -i ${PKG_PATCH_PATH}/bzip2-use-cdecl-calling-convention.patch
            patch -p1 -i ${PKG_PATCH_PATH}/bzip2-1.0.5-slash.patch
            chmod +x ./autogen.sh
            ./autogen.sh
        func_leave_directory
    fi
}

function pkg_configure() {
    local PKG_BUILD=${SCRIPT_OPTION_BUILD}
    local PKG_HOST=${SCRIPT_OPTION_HOST}
    local PKG_SOURCE_PATH=${SCRIPT_SOURCES_PATH}/${PKG_IDENTIFIER}
    local PKG_CONFIGURE_PATH=${SCRIPT_CONFIGURES_PATH}/${PKG_HOST}/${PKG_IDENTIFIER}
    local PKG_PREFIX_PATH=${SCRIPT_DEPENDENCIES_PATH}/${PKG_HOST}/${PKG_NAME}

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" || ! -x ${PKG_CONFIGURE_PATH}/config.status ]]; then
        func_log_message "Configure" ${PKG_HOST}/${PKG_IDENTIFIER}

        func_create_directory ${PKG_CONFIGURE_PATH}
        func_create_directory ${PKG_PREFIX_PATH}

        func_enter_directory ${PKG_CONFIGURE_PATH}
            ${PKG_SOURCE_PATH}/configure \
                --build=${PKG_BUILD} \
                --host=${PKG_HOST} \
                --prefix=${PKG_PREFIX_PATH} \
                --disable-static \
                --enable-shared
        func_leave_directory
    fi
}

function pkg_build() {
    local PKG_HOST=${SCRIPT_OPTION_HOST}
    local PKG_CONFIGURE_PATH=${SCRIPT_CONFIGURES_PATH}/${PKG_HOST}/${PKG_IDENTIFIER}

    func_log_message "Build" ${PKG_HOST}/${PKG_IDENTIFIER}

    func_enter_directory ${PKG_CONFIGURE_PATH}
        make -j${SCRIPT_OPTION_JOBS} all
        make -j${SCRIPT_OPTION_JOBS} install
    func_leave_directory
}

function pkg_final() {
    local PKG_HOST=${SCRIPT_OPTION_HOST}
    local PKG_PREFIX_PATH=${SCRIPT_DEPENDENCIES_PATH}/${PKG_HOST}/${PKG_NAME}
    local MINGW_OPT_PATH=${SCRIPT_OPTION_MINGW_ROOT_PATH}/opt

    func_log_message "Deploy" "${PKG_HOST}/${PKG_IDENTIFIER}"

    func_create_directory ${MINGW_OPT_PATH}
    cp -rfv ${PKG_PREFIX_PATH}/* ${MINGW_OPT_PATH}
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

