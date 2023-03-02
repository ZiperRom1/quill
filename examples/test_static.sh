#!/bin/bash

CURRENT_DIR=$(dirname "${BASH_SOURCE[0]}")
# Set compiler
export CC=/usr/local/bin/x86_64-w64-mingw32-gcc
export CXX=/usr/local/bin/x86_64-w64-mingw32-g++
# Build
cmake -S "${CURRENT_DIR}" -B build_static -DCMAKE_TOOLCHAIN_FILE="${CURRENT_DIR}/mingw-w64-x86_64.cmake"
cmake --build build_static --target example_trivial_static
# Test
EXIT_STATUS=1

if [ -f "./build_static/example_trivial_static.exe" ]; then EXIT_STATUS=0
fi

exit ${EXIT_STATUS}
