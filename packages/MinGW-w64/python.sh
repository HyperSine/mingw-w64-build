#!/bin/bash

PKG_NAME="python"
PKG_VERSION="3.7.6"
PKG_IDENTIFIER=${PKG_NAME}-${PKG_VERSION}

function pkg_download() {
    local PKG_HOST=${SCRIPT_OPTION_HOST}
    local PKG_BIN_FILENAME="${PKG_IDENTIFIER}-embed-$(func_get_python_arch ${PKG_HOST}).zip"
    local PKG_BIN_SIG_FILENAME="${PKG_IDENTIFIER}-embed-$(func_get_python_arch ${PKG_HOST}).zip.asc"
    local PKG_BIN_URL="https://www.python.org/ftp/python/${PKG_VERSION}/${PKG_BIN_FILENAME}"
    local PKG_BIN_SIG_URL="https://www.python.org/ftp/python/${PKG_VERSION}/${PKG_BIN_SIG_FILENAME}"

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_BIN_FILENAME} ]]; then
        rm -fv ${SCRIPT_DOWNLOADS_PATH}/${PKG_BIN_FILENAME}
    fi
    if [[ ! -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_BIN_FILENAME} ]]; then
        func_create_directory ${SCRIPT_DOWNLOADS_PATH}
        func_download ${PKG_BIN_URL} ${SCRIPT_DOWNLOADS_PATH}/${PKG_BIN_FILENAME}
    fi

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_BIN_SIG_FILENAME} ]]; then
        rm -fv ${SCRIPT_DOWNLOADS_PATH}/${PKG_BIN_SIG_FILENAME}
    fi
    if [[ ! -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_BIN_SIG_FILENAME} ]]; then
        func_create_directory ${SCRIPT_DOWNLOADS_PATH}
        func_download ${PKG_BIN_SIG_URL} ${SCRIPT_DOWNLOADS_PATH}/${PKG_BIN_SIG_FILENAME}
    fi

    local PKG_DEV_FILENAME="${PKG_IDENTIFIER}-dev-$(func_get_python_arch ${PKG_HOST}).msi"
    local PKG_DEV_SIG_FILENAME="${PKG_IDENTIFIER}-dev-$(func_get_python_arch ${PKG_HOST}).msi.asc"
    local PKG_DEV_URL="https://www.python.org/ftp/python/${PKG_VERSION}/$(func_get_python_arch ${PKG_HOST})/dev.msi"
    local PKG_DEV_SIG_URL="https://www.python.org/ftp/python/${PKG_VERSION}/$(func_get_python_arch ${PKG_HOST})/dev.msi.asc"

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_DEV_FILENAME} ]]; then
        rm -fv ${SCRIPT_DOWNLOADS_PATH}/${PKG_DEV_FILENAME}
    fi
    if [[ ! -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_DEV_FILENAME} ]]; then
        func_create_directory ${SCRIPT_DOWNLOADS_PATH}
        func_download ${PKG_DEV_URL} ${SCRIPT_DOWNLOADS_PATH}/${PKG_DEV_FILENAME}
    fi

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_DEV_SIG_FILENAME} ]]; then
        rm -fv ${SCRIPT_DOWNLOADS_PATH}/${PKG_DEV_SIG_FILENAME}
    fi
    if [[ ! -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_DEV_SIG_FILENAME} ]]; then
        func_create_directory ${SCRIPT_DOWNLOADS_PATH}
        func_download ${PKG_DEV_SIG_URL} ${SCRIPT_DOWNLOADS_PATH}/${PKG_DEV_SIG_FILENAME}
    fi

    func_verify gpg \
        ${SCRIPT_KEYRINGS_PATH}/python-keyring.gpg \
        ${SCRIPT_DOWNLOADS_PATH}/${PKG_BIN_FILENAME} \
        ${SCRIPT_DOWNLOADS_PATH}/${PKG_BIN_SIG_FILENAME}
    func_verify gpg \
        ${SCRIPT_KEYRINGS_PATH}/python-keyring.gpg \
        ${SCRIPT_DOWNLOADS_PATH}/${PKG_DEV_FILENAME} \
        ${SCRIPT_DOWNLOADS_PATH}/${PKG_DEV_SIG_FILENAME}
}

function pkg_extract() {
    local PKG_HOST=${SCRIPT_OPTION_HOST}
    local PKG_BIN_FILENAME="${PKG_IDENTIFIER}-embed-$(func_get_python_arch ${PKG_HOST}).zip"
    local PKG_DEV_FILENAME="${PKG_IDENTIFIER}-dev-$(func_get_python_arch ${PKG_HOST}).msi"
    local PKG_PATCH_PATH=${SCRIPT_MINGW_W64_PATCHES_PATH}/${PKG_NAME}
    local PYTHON_SHORT_IDENTIFIER=${PKG_NAME}$(awk -F. '{print $1$2}' <<< ${PKG_VERSION})

    func_create_directory ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin
    func_extract ${SCRIPT_DOWNLOADS_PATH}/${PKG_BIN_FILENAME} \
        ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin

    func_create_directory ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin/Lib
    func_extract ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin/${PYTHON_SHORT_IDENTIFIER}.zip \
        ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin/Lib

    sed "s|${PYTHON_SHORT_IDENTIFIER}.zip|Lib/|" \
        -i ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin/${PYTHON_SHORT_IDENTIFIER}._pth
    sed "s|#import site|import site|" \
        -i ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin/${PYTHON_SHORT_IDENTIFIER}._pth
    rm -fv ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin/${PYTHON_SHORT_IDENTIFIER}.zip

    func_create_directory ${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_NAME}
    func_extract ${SCRIPT_DOWNLOADS_PATH}/${PKG_DEV_FILENAME} ${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_NAME}
    for file in ${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_NAME}/libs/*.lib; do
        mv -fv ${file} ${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_NAME}/libs/$(awk -F. '{print "lib" $1 ".a"}' <<< $(basename ${file}))
    done

    cp -fv ${PKG_PATCH_PATH}/python-gdb-config.sh ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin
    sed "s|%%PYTHON_PREFIX%%|$(printf '%q\n' "${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin")|" \
        -i ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin/python-gdb-config.sh
    sed "s|%%PYTHON_EXEC_PREFIX%%|$(printf '%q\n' "${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin")|" \
        -i ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin/python-gdb-config.sh
    sed "s|%%PYTHON_INCLUDES%%|-I$(printf '%q\n' "${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_NAME}/include")|" \
        -i ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin/python-gdb-config.sh
    sed "s|%%PYTHON_LIBS%%|-L$(printf '%q\n' "${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_NAME}/libs") -l${PYTHON_SHORT_IDENTIFIER}|" \
        -i ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin/python-gdb-config.sh
}

function pkg_configure() {
    :
}

function pkg_build() {
    :
}

function pkg_final() {
    :
}

function pkg_clean_env() {
    unset -f pkg_clean_env
    unset -f pkg_final
    unset -f pkg_build
    unset -f pkg_configure
    unset -f pkg_download
    unset PKG_IDENTIFIER
    unset PKG_VERSION
    unset PKG_NAME
}

