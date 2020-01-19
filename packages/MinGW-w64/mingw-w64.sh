#!/bin/bash

PKG_NAME="mingw-w64"
PKG_VERSION="v7.0.0"
PKG_IDENTIFIER=${PKG_NAME}-${PKG_VERSION}

function pkg_download() {
    local PKG_SRC_FILENAME="${PKG_IDENTIFIER}.tar.bz2"
    local PKG_SIG_FILENAME="${PKG_IDENTIFIER}.tar.bz2.sig"
    local PKG_SRC_URL="https://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/${PKG_SRC_FILENAME}"
    local PKG_SIG_URL="https://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/${PKG_SIG_FILENAME}"

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" || ! -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} ]]; then
        func_create_directory ${SCRIPT_DOWNLOADS_PATH}
        func_download ${PKG_SRC_URL} ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME}
    fi

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" || ! -f ${SCRIPT_DOWNLOADS_PATH}/${PKG_SIG_FILENAME} ]]; then
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
    local PKG_SOURCE_PATH=${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}
    local PKG_PATCH_PATH=${SCRIPT_MINGW_W64_PATCHES_PATH}/${PKG_NAME}

    if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${PKG_SOURCE_PATH} ]]; then
        rm -rfv ${PKG_SOURCE_PATH}
    fi

    if [[ ! -d ${PKG_SOURCE_PATH} ]]; then
        func_create_directory ${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}

        func_extract ${SCRIPT_DOWNLOADS_PATH}/${PKG_SRC_FILENAME} ${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}

#        func_enter_directory ${PKG_SOURCE_PATH}
#            func_apply_patch -p1 ${PKG_PATCH_PATH}/suppress-Wexpansion-to-defined.patch
#            func_enter_directory ${PKG_SOURCE_PATH}/mingw-w64-crt
#                autoreconf
#            func_leave_directory
#        func_leave_directory
    fi
}

function pkg_configure() {
    # $1 - sub-package name
    case $1 in
        "mingw-w64-headers")
            local SUBPKG_BUILD=${SCRIPT_OPTION_BUILD}
            local SUBPKG_HOST=${SCRIPT_OPTION_HOST}
            local SUBPKG_SOURCE_PATH=${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-headers
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-headers
            local SUBPKG_PREFIX_PATH=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${SCRIPT_OPTION_TARGET}

            if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${SUBPKG_CONFIGURE_PATH} ]]; then
                rm -rfv ${SUBPKG_CONFIGURE_PATH}
            fi

            if [[ ! -x ${SUBPKG_CONFIGURE_PATH}/config.status ]]; then
                func_log_message "Configure" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-headers

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
            local SUBPKG_HOST=${SCRIPT_OPTION_HOST}
            local SUBPKG_SOURCE_PATH=${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-crt
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-crt
            local SUBPKG_PREFIX_PATH=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${SCRIPT_OPTION_TARGET}

            if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${SUBPKG_CONFIGURE_PATH} ]]; then
                rm -rfv ${SUBPKG_CONFIGURE_PATH}
            fi

            if [[ ! -x ${SUBPKG_CONFIGURE_PATH}/config.status ]]; then
                func_log_message "Configure" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-crt

                func_create_directory ${SUBPKG_CONFIGURE_PATH}
                func_create_directory ${SUBPKG_PREFIX_PATH}

                func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                    ${SUBPKG_SOURCE_PATH}/configure \
                        --build=${SUBPKG_BUILD} \
                        --host=${SUBPKG_HOST} \
                        --prefix=${SUBPKG_PREFIX_PATH} \
                        --with-sysroot=${SCRIPT_BUILDS_PATH}/toolchain/${SCRIPT_MINGW_W64_TOOLCHAIN_IDENTIFIER} \
                        "$([[ $(func_get_arch_bits ${SUBPKG_HOST}) == "32" ]] && echo "--enable-lib32" || echo "--disable-lib32")" \
                        "$([[ $(func_get_arch_bits ${SUBPKG_HOST}) == "64" ]] && echo "--enable-lib64" || echo "--disable-lib64")" \
                        --enable-wildcard
                func_leave_directory
            fi
        ;;
        "winpthreads")
            local SUBPKG_BUILD=${SCRIPT_OPTION_BUILD}
            local SUBPKG_HOST=${SCRIPT_OPTION_HOST}
            local SUBPKG_SOURCE_PATH=${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-libraries/winpthreads
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/winpthreads
            local SUBPKG_PREFIX_PATH=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${SCRIPT_OPTION_TARGET}

            if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${SUBPKG_CONFIGURE_PATH} ]]; then
                rm -rfv ${SUBPKG_CONFIGURE_PATH}
            fi

            if [[ ! -x ${SUBPKG_CONFIGURE_PATH}/config.status ]]; then
                func_log_message "Configure" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-libraries/winpthreads

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
        "libmangle")
            local SUBPKG_BUILD=${SCRIPT_OPTION_BUILD}
            local SUBPKG_HOST=${SCRIPT_OPTION_HOST}
            local SUBPKG_SOURCE_PATH=${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-libraries/libmangle
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/libmangle
            local SUBPKG_PREFIX_PATH=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${SCRIPT_OPTION_TARGET}

            if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${SUBPKG_CONFIGURE_PATH} ]]; then
                rm -rfv ${SUBPKG_CONFIGURE_PATH}
            fi

            if [[ ! -x ${SUBPKG_CONFIGURE_PATH}/config.status ]]; then
                func_log_message "Configure" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-libraries/libmangle

                func_create_directory ${SUBPKG_CONFIGURE_PATH}
                func_create_directory ${SUBPKG_PREFIX_PATH}

                func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                    ${SUBPKG_SOURCE_PATH}/configure \
                        --build=${SUBPKG_BUILD} \
                        --host=${SUBPKG_HOST} \
                        --prefix=${SUBPKG_PREFIX_PATH}
                func_leave_directory
            fi
        ;;
        "gendef")
            local SUBPKG_BUILD=${SCRIPT_OPTION_BUILD}
            local SUBPKG_HOST=${SCRIPT_OPTION_HOST}
            local SUBPKG_SOURCE_PATH=${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-tools/gendef
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/gendef
            local SUBPKG_PREFIX_PATH=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}

            if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${SUBPKG_CONFIGURE_PATH} ]]; then
                rm -rfv ${SUBPKG_CONFIGURE_PATH}
            fi

            if [[ ! -x ${SUBPKG_CONFIGURE_PATH}/config.status ]]; then
                func_log_message "Configure" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-tools/gendef

                func_create_directory ${SUBPKG_CONFIGURE_PATH}
                func_create_directory ${SUBPKG_PREFIX_PATH}

                func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                    ${SUBPKG_SOURCE_PATH}/configure \
                        --build=${SUBPKG_BUILD} \
                        --host=${SUBPKG_HOST} \
                        --prefix=${SUBPKG_PREFIX_PATH} \
                        --with-mangle=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${SCRIPT_OPTION_TARGET} \
                        CFLAGS="-g -O2 -Wno-expansion-to-defined"
                func_leave_directory
            fi
        ;;
        "genidl")
            local SUBPKG_BUILD=${SCRIPT_OPTION_BUILD}
            local SUBPKG_HOST=${SCRIPT_OPTION_HOST}
            local SUBPKG_SOURCE_PATH=${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-tools/genidl
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/genidl
            local SUBPKG_PREFIX_PATH=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}

            if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${SUBPKG_CONFIGURE_PATH} ]]; then
                rm -rfv ${SUBPKG_CONFIGURE_PATH}
            fi

            if [[ ! -x ${SUBPKG_CONFIGURE_PATH}/config.status ]]; then
                func_log_message "Configure" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-tools/genidl

                func_create_directory ${SUBPKG_CONFIGURE_PATH}
                func_create_directory ${SUBPKG_PREFIX_PATH}

                func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                    ${SUBPKG_SOURCE_PATH}/configure \
                        --build=${SUBPKG_BUILD} \
                        --host=${SUBPKG_HOST} \
                        --prefix=${SUBPKG_PREFIX_PATH}
                func_leave_directory
            fi
        ;;
        "genpeimg")
            local SUBPKG_BUILD=${SCRIPT_OPTION_BUILD}
            local SUBPKG_HOST=${SCRIPT_OPTION_HOST}
            local SUBPKG_SOURCE_PATH=${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-tools/genpeimg
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/genpeimg
            local SUBPKG_PREFIX_PATH=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}

            if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${SUBPKG_CONFIGURE_PATH} ]]; then
                rm -rfv ${SUBPKG_CONFIGURE_PATH}
            fi

            if [[ ! -x ${SUBPKG_CONFIGURE_PATH}/config.status ]]; then
                func_log_message "Configure" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-tools/genpeimg

                func_create_directory ${SUBPKG_CONFIGURE_PATH}
                func_create_directory ${SUBPKG_PREFIX_PATH}

                func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                    ${SUBPKG_SOURCE_PATH}/configure \
                        --build=${SUBPKG_BUILD} \
                        --host=${SUBPKG_HOST} \
                        --prefix=${SUBPKG_PREFIX_PATH}
                func_leave_directory
            fi
        ;;
        "widl")
            local SUBPKG_BUILD=${SCRIPT_OPTION_BUILD}
            local SUBPKG_HOST=${SCRIPT_OPTION_HOST}
            local SUBPKG_SOURCE_PATH=${SCRIPT_MINGW_W64_SOURCES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-tools/widl
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/widl
            local SUBPKG_PREFIX_PATH=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}

            if [[ ${SCRIPT_OPTION_FORCE_UPDATE} == "yes" && -d ${SUBPKG_CONFIGURE_PATH} ]]; then
                rm -rfv ${SUBPKG_CONFIGURE_PATH}
            fi

            if [[ ! -x ${SUBPKG_CONFIGURE_PATH}/config.status ]]; then
                func_log_message "Configure" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-tools/widl

                func_create_directory ${SUBPKG_CONFIGURE_PATH}
                func_create_directory ${SUBPKG_PREFIX_PATH}

                func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                    ${SUBPKG_SOURCE_PATH}/configure \
                        --build=${SUBPKG_BUILD} \
                        --host=${SUBPKG_HOST} \
                        --prefix=${SUBPKG_PREFIX_PATH}
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
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-headers

            func_log_message "Build" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-headers

            func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                make -j${SCRIPT_OPTION_JOBS} all
                make -j${SCRIPT_OPTION_JOBS} install-strip
            func_leave_directory
        ;;
        "mingw-w64-crt")
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-crt

            func_log_message "Build" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-crt

            func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                make -j${SCRIPT_OPTION_JOBS} all
                make -j${SCRIPT_OPTION_JOBS} install-strip
            func_leave_directory
        ;;
        "winpthreads")
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/winpthreads

            func_log_message "Build" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-libraries/winpthreads

            func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                make -j${SCRIPT_OPTION_JOBS} all
                make -j${SCRIPT_OPTION_JOBS} install-strip
            func_leave_directory
        ;;
        "libmangle")
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/libmangle

            func_log_message "Build" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-libraries/libmangle

            func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                make -j${SCRIPT_OPTION_JOBS} all
                make -j${SCRIPT_OPTION_JOBS} install-strip
            func_leave_directory
        ;;
        "gendef")
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/gendef

            func_log_message "Build" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-tools/gendef

            func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                make -j${SCRIPT_OPTION_JOBS} all
                make -j${SCRIPT_OPTION_JOBS} install-strip
            func_leave_directory
        ;;
        "genidl")
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/genidl

            func_log_message "Build" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-tools/genidl

            func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                make -j${SCRIPT_OPTION_JOBS} all
                make -j${SCRIPT_OPTION_JOBS} install-strip
            func_leave_directory
        ;;
        "genpeimg")
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/genpeimg

            func_log_message "Build" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-tools/genpeimg

            func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                make -j${SCRIPT_OPTION_JOBS} all
                make -j${SCRIPT_OPTION_JOBS} install-strip
            func_leave_directory
        ;;
        "widl")
            local SUBPKG_CONFIGURE_PATH=${SCRIPT_MINGW_W64_CONFIGURES_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/widl

            func_log_message "Build" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-tools/widl

            func_enter_directory ${SUBPKG_CONFIGURE_PATH}
                make -j${SCRIPT_OPTION_JOBS} all
                make -j${SCRIPT_OPTION_JOBS} install-strip
            func_leave_directory
        ;;
        *)
            func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> pkg_configure: unknown sub-packages $1"
        ;;
    esac
}

function pkg_final() {
    # $1 - type
    case $1 in
        "mingw-w64")
            :
        ;;
        "winpthreads")
            local SUBPKG_PREFIX_PATH=${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/${SCRIPT_OPTION_TARGET}

            func_log_message "Final" MinGW-w64/${SCRIPT_MINGW_W64_IDENTIFIER}/${PKG_IDENTIFIER}/mingw-w64-libraries/winpthreads

            mv -fv \
                ${SUBPKG_PREFIX_PATH}/bin/libwinpthread*.dll \
                ${SCRIPT_MINGW_W64_BUILDS_PATH}/${SCRIPT_MINGW_W64_IDENTIFIER}/bin
        ;;
        "libmangle")
            :
        ;;
        "gendef")
            :
        ;;
        "genidl")
            :
        ;;
        "genpeimg")
            :
        ;;
        "widl")
            :
        ;;
        *)
            func_log_failure 1 "FATAL" "${BASH_SOURCE[0]} -> pkg_configure: unknown sub-packages $1"
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
