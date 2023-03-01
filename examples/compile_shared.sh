#!/bin/bash

export CC=/usr/local/bin/x86_64-w64-mingw32-gcc
export CXX=/usr/local/bin/x86_64-w64-mingw32-g++

cmake -S . -B build_shared -DCMAKE_TOOLCHAIN_FILE="/app/examples/mingw-w64-x86_64.cmake" -DBUILD_SHARED_LIBS=ON
cmake --build build_shared --target example_trivial_shared