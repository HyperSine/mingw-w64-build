# Build MinGW-w64 toolchain on Linux for Windows

## 1. Usage

```
Usage:
    build.sh help
    build.sh toolchain [options...]
        --target=<i686-w64-mingw32|x86_64-w64-mingw32>    Mandatory
        --exceptions-model=<dwarf|sjlj|seh>               Mandatory
        --jobs=<num>                                      Optional, default: 1
        --fetch-only                                      Optional, default: no
        --force-update                                    Optional, default: no
    build.sh MinGW-w64 [options...]
        --arch=<i686-w64-mingw32|x86_64-w64-mingw32>      Mandatory
        --exceptions-model=<dwarf|sjlj|seh>               Mandatory
        --threads-model=<posix|win32>                     Mandatory
        --enable-languages=<langs>                        Mandatory, available languages: c,c++,fortran
        --jobs=<num>                                      Optional, default: 1
        --fetch-only                                      Optional, default: no
        --force-update                                    Optional, default: no
```

## 2. Example

```console
$ sudo ./libraries/build-essential.sh

# to build i686-posix-dwarf
$ ./build.sh toolchain --target=i686-w64-mingw32 --exceptions-model=dwarf --jobs=2
$ ./build.sh MinGW-w64 --arch=i686-w64-mingw32 --exceptions-model=dwarf --threads-model=posix --enable-languages=c,c++,fortran --jobs=2

# to build i686-posix-sjlj
$ ./build.sh toolchain --target=i686-w64-mingw32 --exceptions-model=sjlj --jobs=2
$ ./build.sh MinGW-w64 --arch=i686-w64-mingw32 --exceptions-model=sjlj --threads-model=posix --enable-languages=c,c++,fortran --jobs=2

# to build i686-win32-dwarf
$ ./build.sh toolchain --target=i686-w64-mingw32 --exceptions-model=dwarf --jobs=2
$ ./build.sh MinGW-w64 --arch=i686-w64-mingw32 --exceptions-model=dwarf --threads-model=win32 --enable-languages=c,c++,fortran --jobs=2

# to build i686-win32-sjlj
$ ./build.sh toolchain --target=i686-w64-mingw32 --exceptions-model=sjlj --jobs=2
$ ./build.sh MinGW-w64 --arch=i686-w64-mingw32 --exceptions-model=sjlj --threads-model=win32 --enable-languages=c,c++,fortran --jobs=2

# to build x86_64-posix-seh
$ ./build.sh toolchain --target=x86_64-w64-mingw32 --exceptions-model=seh --jobs=2
$ ./build.sh MinGW-w64 --arch=x86_64-w64-mingw32 --exceptions-model=seh --threads-model=posix --enable-languages=c,c++,fortran --jobs=2

# to build x86_64-posix-sjlj
$ ./build.sh toolchain --target=x86_64-w64-mingw32 --exceptions-model=sjlj --jobs=2
$ ./build.sh MinGW-w64 --arch=x86_64-w64-mingw32 --exceptions-model=sjlj --threads-model=posix --enable-languages=c,c++,fortran --jobs=2

# to build x86_64-win32-seh
$ ./build.sh toolchain --target=x86_64-w64-mingw32 --exceptions-model=seh --jobs=2
$ ./build.sh MinGW-w64 --arch=x86_64-w64-mingw32 --exceptions-model=seh --threads-model=win32 --enable-languages=c,c++,fortran --jobs=2

# to build x86_64-win32-sjlj
$ ./build.sh toolchain --target=x86_64-w64-mingw32 --exceptions-model=sjlj --jobs=2
$ ./build.sh MinGW-w64 --arch=x86_64-w64-mingw32 --exceptions-model=sjlj --threads-model=win32 --enable-languages=c,c++,fortran --jobs=2
```

Artifacts are in `./builds/MinGW-w64/`.
