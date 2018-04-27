#!/usr/bin/env bash

dirpath=$1
tarballPath=$2
pushd ${dirpath}
    if [ ${tarballPath: -3} == "bz2" ]; then
        tar -cjf "$tarballPath" .
    elif [ ${tarballPath: -2} == "gz" ]; then
        tar -czf "$tarballPath" .
    elif [ ${tarballPath: -2} == "xz" ]; then
        tar -cJf "$tarballPath" .
    else
        echo "Unrecognized file extension, end with .bz2, .gz, or .xz"
    fi
popd