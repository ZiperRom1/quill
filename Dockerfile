FROM alpine:latest

ARG GCC_VERSION
ARG MINGW_VERSION
ARG BINUTILS_VERSION
ARG CMAKE_VERSION
ARG QUILL_VERSION
ARG MAX_CPU_CORES

RUN apk add --no-cache bash make gcc=~${GCC_VERSION} g++=~${GCC_VERSION} mingw-w64-gcc=~${MINGW_VERSION} \
    mingw-w64-binutils=~${BINUTILS_VERSION} mingw-w64-headers mingw-w64-winpthreads mingw-w64-crt cmake>${CMAKE_VERSION}

ENV INSTALL_PREFIX=/usr/x86_64-w64-mingw32
ENV CMAKE_TOOLCHAIN=/tmp/mingw-w64-x86_64.cmake
ENV CMAKE_COMMON_OPTION_SHARED="--install-prefix ${INSTALL_PREFIX} -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN} -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON"
ENV CMAKE_COMMON_OPTION_STATIC="--install-prefix ${INSTALL_PREFIX} -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN} -DCMAKE_BUILD_TYPE=Release"

# Copy cmake toolchain from windows cross compiling
COPY examples/mingw-w64-x86_64.cmake /tmp

## Install quill with the given QUILL_VERSION version from https://github.com/odygrd/quill
RUN wget https://github.com/odygrd/quill/archive/refs/tags/v${QUILL_VERSION}.tar.gz \
    -q -O /tmp/quill-${QUILL_VERSION}.tar.gz && \
    cd /tmp && ls && tar -xvzf quill-${QUILL_VERSION}.tar.gz && cd quill-${QUILL_VERSION} && \
    cmake -S . -B build_shared ${CMAKE_COMMON_OPTION_SHARED} && \
    cmake --build build_shared -j ${MAX_CPU_CORES} && cmake --install build_shared && \
    cmake -S . -B build_static ${CMAKE_COMMON_OPTION_STATIC} && \
    cmake --build build_static -j ${MAX_CPU_CORES} && cmake --install build_static && \
    rm -rf /tmp/quill-${QUILL_VERSION}.tar.gz /tmp/quill-${QUILL_VERSION}

WORKDIR /app

COPY . /app

CMD ["/bin/bash"]
