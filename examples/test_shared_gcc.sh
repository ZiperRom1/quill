#!/bin/bash

CURRENT_DIR=$(dirname "${BASH_SOURCE[0]}")
# Build
cmake -S "${CURRENT_DIR}" -B build_shared_gcc -DBUILD_SHARED_LIBS=ON
cmake --build build_shared_gcc --target example_trivial_shared
# Test
EXIT_STATUS=1

if [ -f "./build_shared_gcc/example_trivial_shared" ]; then EXIT_STATUS=0
fi

exit ${EXIT_STATUS}
