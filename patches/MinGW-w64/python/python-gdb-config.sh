#!/bin/bash

if [[ $2 == "--prefix" ]]; then
    echo '%%PYTHON_PREFIX%%'
elif [[ $2 == "--exec-prefix" ]]; then
    echo '%%PYTHON_EXEC_PREFIX%%'
elif [[ $2 = "--includes" || $2 = "--cflags" ]]; then
    echo '%%PYTHON_INCLUDES%%'
elif [[ $2 = "--libs" || $2 = "--ldflags" ]]; then
    echo '%%PYTHON_LIBS%%'
else
    >&2 echo "$(basename $0): unknown option $2"
fi
