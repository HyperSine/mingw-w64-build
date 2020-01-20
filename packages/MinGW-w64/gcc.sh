#!/bin/bash

PKG_NAME="gcc"
PKG_VERSION=${SCRIPT_OPTION_GCC_VERSION}
PKG_IDENTIFIER=${PKG_NAME}-${PKG_VERSION}

function pkg_download() {
    local PKG_SRC_FILENAME="${PKG_IDENTIFIER}.tar.xz"
    local PKG_SIG_FILENAME="${PKG_IDENTIFIER}.tar.xz.sig"
    local PKG_SRC_URL="https://ftp.gnu.org/gnu/gcc/${PKG_IDENTIFIER}/${PKG_SRC_FILENAME}"
    local PKG_SIG_URL="https://ftp.gnu.org/gnu/gcc/${PKG_IDENTIFIER}/${PKG_SIG_FILENAME}"

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
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gcc-4.7-stdthreads.patch
            func_apply_patch -p0 ${PKG_PATCH_PATH}/gcc-5.1-iconv.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gcc-4.8-libstdc++export.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gcc-4.8.2-fix-for-windows-not-minding-non-existant-parent-dirs.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gcc-4.8.2-windows-lrealpath-no-force-lowercase-nor-backslash.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gcc-4.9.1-enable-shared-gnat-implib.mingw.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gcc-5.1.0-make-xmmintrin-header-cplusplus-compatible.patch
            func_apply_patch -p0 ${PKG_PATCH_PATH}/gcc-5.2-fix-mingw-pch.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gcc-5-dwarf-regression.patch
            func_apply_patch -p0 ${PKG_PATCH_PATH}/gcc-5.1.0-fix-libatomic-building-for-threads\=win32.patch
            func_apply_patch -p0 ${PKG_PATCH_PATH}/gcc-9-ktietz-libgomp.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gcc-libgomp-ftime64.patch
            #func_apply_patch -p2 ${PKG_PATCH_PATH}/gcc-9.2.0-use-EH_FRAME_SECTION_NAME.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gcc-libgcc-Makefile-fix-gcc_version.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gcc-disable-multilib.patch

            # this gcc is crossed native compiler. --with-sysroot is meaningless, therefore will not be specified.
            # So does STANDARD_STARTFILE_PREFIX_1
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gcc-disable-STANDARD_STARTFILE_PREFIX_1.patch
            func_apply_patch -p1 ${PKG_PATCH_PATH}/gcc-undef-NATIVE_SYSTEM_HEADER_DIR.patch
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
                --enable-static \
                --enable-shared \
                --disable-multilib \
                --enable-languages=${SCRIPT_OPTION_GCC_ENABLE_LANGUAGES} \
                --enable-libstdcxx-time=yes \
                --enable-threads=${SCRIPT_OPTION_GCC_THREADS_MODEL} \
                --enable-libgomp \
                --enable-libatomic \
                --enable-libphobos \
                --enable-lto \
                --enable-graphite \
                --enable-checking=release \
                --enable-fully-dynamic-string \
                --enable-version-specific-runtime-libs \
                --enable-libstdcxx-filesystem-ts=yes \
                $([[ ${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL} == "dwarf" ]] && echo "--disable-sjlj-exceptions --with-dwarf2") \
                $([[ ${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL} == "sjlj" ]] && echo "--enable-sjlj-exceptions") \
                --disable-libstdcxx-pch \
                --disable-libstdcxx-debug \
                --disable-bootstrap \
                --disable-rpath \
                --disable-win32-registry \
                --disable-nls \
                --disable-werror \
                --disable-symvers \
                --with-gnu-as \
                --with-gnu-ld \
                $([[ $(func_get_arch ${PKG_HOST}) == "i686" ]] && echo "--with-arch=i686 --with-tune=generic") \
                $([[ $(func_get_arch ${PKG_HOST}) == "x86_64" ]] && echo "--with-arch=nocona --with-tune=core2") \
                --with-libiconv-prefix=${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/libiconv \
                --with-gmp=${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/gmp \
                --with-mpfr=${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/mpfr \
                --with-mpc=${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/mpc \
                --with-isl=${SCRIPT_MINGW_W64_DEPENDENCIES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/isl \
                --with-pkgversion="MinGW-W64 $(func_get_arch ${PKG_HOST})-${SCRIPT_OPTION_GCC_THREADS_MODEL}-${SCRIPT_OPTION_GCC_EXCEPTIONS_MODEL}, Built by HyperSine" \
                --with-bugurl="https://sourceforge.net/projects/mingw-w64" \
                LDFLAGS="$([[ $(func_get_arch ${PKG_HOST}) == "i686" ]] && echo "-Wl,--large-address-aware")"
        func_leave_directory
    fi
}

function pkg_build() {
    local PKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}
    local PKG_PREFIX_PATH=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}
    local PKG_TARGET=${SCRIPT_OPTION_TARGET}

    func_log_message "Build" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}

    func_enter_directory ${PKG_CONFIGURE_PATH}
        if [[ ! -L ${PKG_PREFIX_PATH}/mingw ]]; then
            ln -s ${PKG_PREFIX_PATH}/${PKG_TARGET} ${PKG_PREFIX_PATH}/mingw
        fi
        make -j${SCRIPT_OPTION_JOBS} all
        make -j${SCRIPT_OPTION_JOBS} install-strip
        rm -fv ${PKG_PREFIX_PATH}/mingw
    func_leave_directory
}

function pkg_final() {
    local PKG_TARGET=${SCRIPT_OPTION_TARGET}
    local PKG_PREFIX_PATH=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}

    func_log_message "Final" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}

    for FILE in ${PKG_PREFIX_PATH}/lib/gcc/${PKG_TARGET}/${PKG_VERSION}/*.dll; do
        mv -fv \
            ${FILE} \
            ${PKG_PREFIX_PATH}/bin
    done
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
