# Build MinGW-w64 toolchain on Linux for Windows

__Don’t count your chickens before they hatch !!!__

So far, it is still under development. Only some parts work. 

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
        --host=<i686-w64-mingw32|x86_64-w64-mingw32>      Mandatory
        --target=<i686-w64-mingw32|x86_64-w64-mingw32>    Mandatory
        --exceptions-model=<dwarf|sjlj|seh>               Mandatory
        --threads-model=<posix|win32>                     Mandatory
        --enable-languages=<langs>                        Mandatory, available languages: c,c++,fortran
        --jobs=<num>                                      Optional, default: 1
        --fetch-only                                      Optional, default: no
        --force-update                                    Optional, default: no
```

## 2. Example

```console
$ ./build.sh toolchain --target=i686-w64-mingw32 --exceptions-model=dwarf --jobs=2
$ ./build.sh MinGW-w64 --host=i686-w64-mingw32 --target=i686-w64-mingw32 --exceptions-model=dwarf --threads-model=posix --enable-languages=c,c++,fortran --jobs=2
```

