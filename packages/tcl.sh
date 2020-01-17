#!/bin/bash

PKG_NAME="tcl"
PKG_VERSION="8.6.10"
PKG_IDENTIFIER=${PKG_NAME}${PKG_VERSION}

function pkg_download() {
    local PKG_SRC_FILENAME="${PKG_IDENTIFIER}-src.tar.gz"
    local PKG_SRC_URL="https://sourceforge.net/projects/tcl/files/Tcl/${PKG_VERSION}/${PKG_SRC_FILENAME}"
    local PKG_SRC_CHECKSUM="5196dbf6638e3df8d5c87b5815c8c2b758496eb6f0e41446596c9a4e638d87ed"

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" || ! -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} ]]; then
        func_create_directory ${SCRIPT_DOWNLOADS_PATH}
        func_download ${PKG_SRC_URL} ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME}
    fi

    func_verify sha256sum \
        ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} \
        ${PKG_SRC_CHECKSUM}
}

function pkg_extract() {
    local PKG_SRC_FILENAME="${PKG_IDENTIFIER}-src.tar.gz"
    local PKG_SOURCE_PATH=${SCRIPT_SOURCES_PATH}/${PKG_IDENTIFIER}
    local PKG_PATCH_PATH=${SCRIPT_PATCHES_PATH}/${PKG_NAME}

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" || ! -d ${PKG_SOURCE_PATH} ]]; then
        func_create_directory ${SCRIPT_SOURCES_PATH}

        func_extract ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} ${SCRIPT_SOURCES_PATH}

        func_enter_directory ${PKG_SOURCE_PATH}
            func_apply_patch -p1 ${PKG_PATCH_PATH}/001-fix-relocation.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/002-fix-forbidden-colon-in-paths.mingw.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/004-use-system-zlib.mingw.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/005-no-xc.mingw.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/006-proper-implib-name.mingw.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/007-install.mingw.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/008-tcl-8.5.14-hidden.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/009-fix-using-gnu-print.patch

            find ./ -type f \( -name "tcl.m4" -o -name "configure*" \) -print0 | xargs -0 sed -i 's/-static-libgcc//g'

            func_enter_directory $PWD/win
                autoreconf -fi
            func_leave_directory
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
            CFLAGS="-I${SCRIPT_DEPENDENCIES_PATH}/${PKG_HOST}/zlib/include -L${SCRIPT_DEPENDENCIES_PATH}/${PKG_HOST}/zlib/lib" \
            CXXFLAGS="-I${SCRIPT_DEPENDENCIES_PATH}/${PKG_HOST}/zlib/include -L${SCRIPT_DEPENDENCIES_PATH}/${PKG_HOST}/zlib/lib" \
            LDFLAGS="-L${SCRIPT_DEPENDENCIES_PATH}/${PKG_HOST}/zlib/lib" \
            ${PKG_SOURCE_PATH}/win/configure \
                --build=${PKG_BUILD} \
                --host=${PKG_HOST} \
                --prefix=${PKG_PREFIX_PATH} \
                --disable-threads \
                --enable-shared \
                $([[ $(func_get_arch ${PKG_HOST}) == "x86_64" ]] && echo "--enable-64bit")
        func_leave_directory
    fi
}

function pkg_build() {
    local PKG_HOST=${SCRIPT_OPTION_HOST}
    local PKG_CONFIGURE_PATH=${SCRIPT_CONFIGURES_PATH}/${PKG_HOST}/${PKG_IDENTIFIER}

    func_log_message "Build" "${PKG_HOST}/${PKG_IDENTIFIER}"

    func_enter_directory ${PKG_CONFIGURE_PATH}
        make -j${SCRIPT_OPTION_JOBS} all
        make -j${SCRIPT_OPTION_JOBS} install
    func_leave_directory
}

function pkg_final() {
    local PKG_HOST=${SCRIPT_OPTION_HOST}
    local PKG_SOURCE_PATH=${SCRIPT_SOURCES_PATH}/${PKG_IDENTIFIER}
    local PKG_PREFIX_PATH=${SCRIPT_DEPENDENCIES_PATH}/${PKG_HOST}/${PKG_NAME}
    local MINGW_OPT_PATH=${SCRIPT_OPTION_MINGW_ROOT_PATH}/opt

    func_log_message "Deploy" "${PKG_HOST}/${PKG_IDENTIFIER}"

    func_create_directory ${MINGW_OPT_PATH}
    cp -rfv ${PKG_PREFIX_PATH}/* ${MINGW_OPT_PATH}
    cp -fv ${MINGW_OPT_PATH}/bin/tclsh86.exe ${MINGW_OPT_PATH}/bin/tclsh.exe
    cp -fv ${MINGW_OPT_PATH}/lib/libtcl86.dll.a ${MINGW_OPT_PATH}/lib/libtcl.dll.a
    cp -fv ${MINGW_OPT_PATH}/lib/tclConfig.sh ${MINGW_OPT_PATH}/lib/tcl8.6/tclConfig.sh
    func_create_directory ${MINGW_OPT_PATH}/include/tcl-private/generic
    func_create_directory ${MINGW_OPT_PATH}/include/tcl-private/win
    find ${PKG_SOURCE_PATH}/generic ${PKG_SOURCE_PATH}/win -name "*.h" -exec cp -pv '{}' ${MINGW_OPT_PATH}/include/tcl-private/'{}' ';'
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

