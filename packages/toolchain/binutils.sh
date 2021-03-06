#!/bin/bash

PKG_NAME="binutils"
PKG_VERSION="2.33.1"
PKG_IDENTIFIER=${PKG_NAME}-${PKG_VERSION}

function pkg_download() {
    local PKG_SRC_FILENAME="${PKG_IDENTIFIER}.tar.xz"
    local PKG_SIG_FILENAME="${PKG_IDENTIFIER}.tar.xz.sig"
    local PKG_SRC_URL="https://ftp.gnu.org/gnu/binutils/${PKG_SRC_FILENAME}"
    local PKG_SIG_URL="https://ftp.gnu.org/gnu/binutils/${PKG_SIG_FILENAME}"

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
        ${SCRIPT_KEYRINGS_PATH}/gnu-keyring.gpg \
        ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} \
        ${SCRIPT_DOWNLOADS_PATH}/${PKG_SIG_FILENAME}
}

function pkg_extract() {
    local PKG_SRC_FILENAME="${PKG_IDENTIFIER}.tar.xz"
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
    local PKG_BUILD=${SCRIPT_OPTION_BUILD}
    local PKG_HOST=${SCRIPT_OPTION_HOST}
    local PKG_TARGET=${SCRIPT_OPTION_TARGET}
    local PKG_SOURCE_PATH=${SCRIPT_TOOLCHAIN_SOURCES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}
    local PKG_CONFIGURE_PATH=${SCRIPT_TOOLCHAIN_CONFIGURES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}
    local PKG_PREFIX_PATH=${SCRIPT_TOOLCHAIN_BUILDS_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${PKG_CONFIGURE_PATH} ]]; then
        rm -rfv ${PKG_CONFIGURE_PATH}
    fi

    if [[ ! -x ${PKG_CONFIGURE_PATH}/config.status ]]; then
        func_log_message "Configure" toolchain/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}

        func_create_directory ${PKG_CONFIGURE_PATH}
        func_create_directory ${PKG_PREFIX_PATH}

        func_enter_directory ${PKG_CONFIGURE_PATH}
            ${PKG_SOURCE_PATH}/configure \
                --build=${PKG_BUILD} \
                --host=${PKG_HOST} \
                --target=${PKG_TARGET} \
                --prefix=${PKG_PREFIX_PATH} \
                --with-sysroot=${SCRIPT_TOOLCHAIN_BUILDS_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER} \
                --disable-silent-rules \
                --disable-maintainer-mode \
                --disable-multilib \
                --enable-lto \
                --enable-plugins \
                --enable-deterministic-archives \
                --disable-werror \
                --with-libiconv-prefix=${PKG_PREFIX_PATH} \
                --with-gmp=${PKG_PREFIX_PATH} \
                --with-mpfr=${PKG_PREFIX_PATH} \
                --with-mpc=${PKG_PREFIX_PATH} \
                --with-isl=${PKG_PREFIX_PATH} \
                --enable-static \
                --enable-shared
        func_leave_directory
    fi
}

function pkg_build() {
    local PKG_CONFIGURE_PATH=${SCRIPT_TOOLCHAIN_CONFIGURES_PATH}/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}

    func_log_message "Build" toolchain/${SCRIPT_TOOLCHAIN_IDENTIFIER}/${PKG_IDENTIFIER}

    func_enter_directory ${PKG_CONFIGURE_PATH}
        make -j${SCRIPT_OPTION_JOBS} all
        make -j${SCRIPT_OPTION_JOBS} install-strip
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
