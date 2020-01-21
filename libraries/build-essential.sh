#!/bin/bash
set -e

#sudo apt-get -y install \
#    wget gpg \
#    m4 \
#    make automake automake-1.15 libtool autopoint \
#    gcc g++ \
#    mingw-w64 \
#    gcc-mingw-w64-i686 g++-mingw-w64-i686 \
#    gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 \
#    gfortran-mingw-w64-i686 gfortran-mingw-w64-x86-64 \
#    zip unzip msitools texinfo

apt-get -y install \
    wget gpg \
    m4 \
    make automake automake-1.15 \
    gcc g++ \
    zip unzip msitools texinfo \
    p7zip-full