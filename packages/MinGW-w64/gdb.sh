#!/bin/bash

PKG_NAME="gdb"
PKG_VERSION="8.3.1"
PKG_IDENTIFIER=${PKG_NAME}-${PKG_VERSION}

function pkg_download() {
    local PKG_SRC_FILENAME="${PKG_IDENTIFIER}.tar.xz"
    local PKG_SIG_FILENAME="${PKG_IDENTIFIER}.tar.xz.sig"
    local PKG_SRC_URL="https://ftp.gnu.org/gnu/gdb/${PKG_SRC_FILENAME}"
    local PKG_SIG_URL="https://ftp.gnu.org/gnu/gdb/${PKG_SIG_FILENAME}"

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
    local PKG_SOURCE_PATH=${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}
    local PKG_PATCH_PATH=${SCRIPT_MINGW_W64_PATCHES_PATH}/${PKG_NAME}

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${PKG_SOURCE_PATH} ]]; then
        rm -rfv ${PKG_SOURCE_PATH}
    fi

    if [[ ! -d ${PKG_SOURCE_PATH} ]]; then
        func_create_directory ${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}

        func_extract ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} ${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}

        func_enter_directory ${PKG_SOURCE_PATH}
            #func_apply_patch -p1 ${PKG_PATCH_PATH}/gdb-fix-display-tabs-on-mingw.patch      # https://sourceware.org/ml/gdb-patches/2013-11/msg00224.html
            #func_apply_patch -p1 ${PKG_PATCH_PATH}/gdb-mingw-gcc-4.7.patch                  # https://sourceware.org/bugzilla/show_bug.cgi?id=15559
            #func_apply_patch -p1 ${PKG_PATCH_PATH}/gdb-${PKG_VERSION}-mingw-gcc-4.7.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gdb-perfomance.patch                     # https://sourceware.org/bugzilla/show_bug.cgi?id=15412
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gdb-fix-using-gnu-print.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gdb-7.12-dynamic-libs.patch              # https://sourceware.org/bugzilla/show_bug.cgi?id=21078
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gdb-py3-fixes.patch
            #func_apply_patch -p1 ${PKG_PATCH_PATH}/python-configure-path-fixes.patch
            #func_apply_patch -p1 ${PKG_PATCH_PATH}/gdb-fix-tui-with-pdcurses.patch
            #func_apply_patch -p1 ${PKG_PATCH_PATH}/gdb-8.3-lib-order.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gdb-home-is-userprofile.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gdb-8.3.1-fix-const-ptr-issue.patch
        func_leave_directory
    fi
}

function pkg_configure() {
    local PKG_BUILD=${SCRIPT_OPTION_BUILD}
    local PKG_HOST=${SCRIPT_OPTION_HOST}
    local PKG_TARGET=${SCRIPT_OPTION_TARGET}
    local PKG_SOURCE_PATH=${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}
    local PKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}
    local PKG_PREFIX_PATH=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${PKG_CONFIGURE_PATH} ]]; then
        rm -rfv ${PKG_CONFIGURE_PATH}
    fi

    if [[ ! -x ${PKG_CONFIGURE_PATH}/config.status ]]; then
        func_log_message "Configure" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}

        func_create_directory ${PKG_CONFIGURE_PATH}
        func_create_directory ${PKG_PREFIX_PATH}

        func_enter_directory ${PKG_CONFIGURE_PATH}
            ${PKG_SOURCE_PATH}/configure \
                --build=${PKG_BUILD} \
                --host=${PKG_HOST} \
                --target=${PKG_TARGET} \
                --prefix=${PKG_PREFIX_PATH} \
                $([[ $(func_get_arch ${PKG_HOST}) == "x86_64" ]] && echo "--enable-64-bit-bfd") \
                --disable-nls \
                --disable-werror \
                --disable-win32-registry \
                --disable-rpath \
                --disable-install-libbfd \
                --disable-install-libiberty \
                --with-libiconv \
                --with-libiconv-prefix=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER} \
                --with-gmp=${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/gmp \
                --with-mpfr=${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/mpfr \
                --with-libmpfr-prefix=${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/mpfr \
                --with-mpc=${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/mpc \
                --with-isl=${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/isl \
                --with-expat \
                --with-libexpat-prefix=${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/expat \
                --with-lzma \
                --with-liblzma-prefix=${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/xz \
                --with-system-readline \
                --with-system-gdbinit=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/etc/gdbinit \
                --with-python=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin/python-gdb-config.sh \
                --disable-tui \
                --disable-gdbtk \
                CFLAGS="-g -O2 -Wno-expansion-to-defined -I${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/readline/include" \
                CXXFLAGS="-g -O2 -Wno-expansion-to-defined -I${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/readline/include" \
                LDFLAGS="-fstack-protector -L${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/readline/lib $([[ $(func_get_arch ${PKG_HOST}) == "i686" ]] && echo "-Wl,--large-address-aware")"
        func_leave_directory
    fi
}

function pkg_build() {
    local PKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}

    func_log_message "Build" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}

    func_enter_directory ${PKG_CONFIGURE_PATH}
        make -j${SCRIPT_OPTION_JOBS} all
        make -j${SCRIPT_OPTION_JOBS} install
    func_leave_directory
}

function pkg_final() {
    local PKG_HOST=${SCRIPT_OPTION_HOST}
    local PKG_PATCH_PATH=${SCRIPT_MINGW_W64_PATCHES_PATH}/${PKG_NAME}

    func_log_message "Final" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}

    func_create_directory ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/etc
    cp -fv ${PKG_PATCH_PATH}/gdbinit ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/etc
    sed "s|%%GCC_IDENTIFIER%%|gcc-${SCRIPT_OPTION_GCC_VERSION}|" \
        -i ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/etc/gdbinit

    mv -fv \
        ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/bin/gdb.exe \
        ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/bin/gdb.origin.exe
    ${PKG_HOST}-gcc \
        -municode \
        -DUNICODE \
        -D_UNICODE \
        -Wl,-Bstatic \
        ${PKG_PATCH_PATH}/gdb-wrapper.c \
        -o ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/bin/gdb.exe

    rm -fv ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/opt/bin/python-gdb-config.sh
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

