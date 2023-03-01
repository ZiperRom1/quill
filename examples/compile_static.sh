#!/bin/bash

export CC=/usr/local/bin/x86_64-w64-mingw32-gcc
export CXX=/usr/local/bin/x86_64-w64-mingw32-g++

cmake -S . -B build_static -DCMAKE_TOOLCHAIN_FILE="/app/examples/mingw-w64-x86_64.cmake"
cmake --build build_static --target example_trivial_static
