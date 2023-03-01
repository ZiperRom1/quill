FROM ubuntu:22.04

WORKDIR /mnt

ENV MINGW=/mingw

ARG CMAKE_VERSION
ARG GCC_VERSION
ARG PKG_CONFIG_VERSION
ARG BINUTILS_VERSION
ARG MINGW_VERSION
ARG QUILL_VERSION
ARG MAX_CPU_CORES

SHELL [ "/bin/bash", "-c" ]

# @todo mingw from https://github.com/mingw-w64/mingw-w64 ?
RUN set -ex \
    \
    # Global compilation lib tools
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade --no-install-recommends -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        ca-certificates \
        gcc \
        g++ \
        zlib1g-dev \
        libssl-dev \
        libgmp-dev \
        libmpfr-dev \
        libmpc-dev \
        libisl-dev \
        libssl3 \
        libgmp10 \
        libmpfr6 \
        libmpc3 \
        libisl23 \
        xz-utils \
        ninja-build \
        texinfo \
        meson \
        gnupg \
        bzip2 \
        patch \
        gperf \
        bison \
        file \
        flex \
        make \
        yasm \
        wget \
        zip \
        git \
    \
    # Download source code for PKG_CONFIG, CMAKE, BINUTILS, MINGW, GCC and NASM
    && wget -q https://pkg-config.freedesktop.org/releases/pkg-config-${PKG_CONFIG_VERSION}.tar.gz -O - | tar -xz \
    && wget -q https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz -O - | tar -xz \
    && wget -q https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz -O - | tar -xJ \
    && wget -q https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/mingw-w64-v${MINGW_VERSION}.tar.bz2 -O - | tar -xj \
    && wget -q https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz -O - | tar -xJ \
    \
    && mkdir -p ${MINGW}/include ${MINGW}/lib/pkgconfig \
    && chmod 0777 -R /mnt ${MINGW} \
    \
    # Install PKG_CONFIG
    && cd pkg-config-${PKG_CONFIG_VERSION} \
    && ./configure \
        --prefix=/usr/local \
        --with-pc-path=${MINGW}/lib/pkgconfig \
        --with-internal-glib \
        --disable-shared \
        --disable-nls \
    && make -j ${MAX_CPU_CORES} \
    && make install \
    && cd .. \
    \
    # Install CMAKE
    && cd cmake-${CMAKE_VERSION} \
    && ./configure \
        --prefix=/usr/local \
        --parallel=${MAX_CPU_CORES} \
    && make -j ${MAX_CPU_CORES} \
    && make install \
    && cd .. \
    \
    # Install BINUTILS
    && cd binutils-${BINUTILS_VERSION} \
    && ./configure \
        --prefix=/usr/local \
        --target=x86_64-w64-mingw32 \
        --disable-shared \
        --enable-static \
        --disable-lto \
        --disable-plugins \
        --disable-multilib \
        --disable-nls \
        --disable-werror \
        --with-system-zlib \
    && make -j ${MAX_CPU_CORES} \
    && make install \
    && cd .. \
    \
    # Install MINGW headers
    && mkdir mingw-w64 \
    && cd mingw-w64 \
    && ../mingw-w64-v${MINGW_VERSION}/mingw-w64-headers/configure \
        --prefix=/usr/local/x86_64-w64-mingw32 \
        --host=x86_64-w64-mingw32 \
        --enable-sdk=all \
    && make install \
    && cd .. \
    \
    # Install GCC
    && mkdir gcc \
    && cd gcc \
    && ../gcc-${GCC_VERSION}/configure \
        --prefix=/usr/local \
        --target=x86_64-w64-mingw32 \
        --enable-languages=c,c++ \
        --disable-shared \
        --enable-static \
        --enable-threads=posix \
        --with-system-zlib \
        --enable-libgomp \
        --enable-libatomic \
        --enable-graphite \
        --disable-libstdcxx-pch \
        --disable-libstdcxx-debug \
        --disable-multilib \
        --disable-lto \
        --disable-nls \
        --disable-werror \
    && make -j ${MAX_CPU_CORES} all-gcc \
    && make install-gcc \
    && cd .. \
    \
    # Install MINGW crt
    && cd mingw-w64 \
    && ../mingw-w64-v${MINGW_VERSION}/mingw-w64-crt/configure \
        --prefix=/usr/local/x86_64-w64-mingw32 \
        --host=x86_64-w64-mingw32 \
        --enable-wildcard \
        --disable-lib32 \
        --enable-lib64 \
    && (make -j ${MAX_CPU_CORES} || make -j ${MAX_CPU_CORES} || make -j ${MAX_CPU_CORES} || make -j ${MAX_CPU_CORES}) \
    && make install \
    && cd .. \
    \
    # Install MINGW winpthreads
    && cd mingw-w64 \
    && ../mingw-w64-v${MINGW_VERSION}/mingw-w64-libraries/winpthreads/configure \
        --prefix=/usr/local/x86_64-w64-mingw32 \
        --host=x86_64-w64-mingw32 \
        --enable-static \
        --disable-shared \
    && make -j ${MAX_CPU_CORES} \
    && make install \
    && cd .. \
    \
    # Recompile GCC
    && cd gcc \
    && make -j ${MAX_CPU_CORES} \
    && make install \
    && cd .. \
    \
    # Clean up downloaded source files
    && rm -r pkg-config-${PKG_CONFIG_VERSION} \
    && rm -r cmake-${CMAKE_VERSION} \
    && rm -r binutils-${BINUTILS_VERSION} \
    && rm -r mingw-w64 mingw-w64-v${MINGW_VERSION} \
    && rm -r gcc gcc-${GCC_VERSION}

ENV INSTALL_PREFIX=/usr/x86_64-w64-mingw32
ENV CMAKE_TOOLCHAIN=/tmp/mingw-w64-x86_64.cmake
ENV CMAKE_COMMON_OPTION_SHARED="--install-prefix ${INSTALL_PREFIX} -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN} -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON"
ENV CMAKE_COMMON_OPTION_STATIC="--install-prefix ${INSTALL_PREFIX} -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN} -DCMAKE_BUILD_TYPE=Release"

# Copy cmake toolchain from windows cross compiling
COPY examples/mingw-w64-x86_64.cmake /tmp

# Install quill with the given QUILL_VERSION version from https://github.com/odygrd/quill
RUN wget https://github.com/odygrd/quill/archive/refs/tags/v${QUILL_VERSION}.tar.gz \
    -q -O /tmp/quill-${QUILL_VERSION}.tar.gz && \
    cd /tmp && ls && tar -xvzf quill-${QUILL_VERSION}.tar.gz && cd quill-${QUILL_VERSION} && \
    cmake -S . -B build_shared ${CMAKE_COMMON_OPTION_SHARED} && \
    cmake --build build_shared -j ${MAX_CPU_CORES} && cmake --install build_shared && \
    cmake -S . -B build_static ${CMAKE_COMMON_OPTION_STATIC} && \
    cmake --build build_static -j ${MAX_CPU_CORES} && cmake --install build_static && \
    rm -rf /tmp/quill-${QUILL_VERSION}.tar.gz /tmp/quill-${QUILL_VERSION}

# Clean ubuntu apt packages
RUN apt-get remove --purge -y file gcc g++ zlib1g-dev libssl-dev libgmp-dev libmpfr-dev libmpc-dev libisl-dev gnupg \
    && apt-get autoremove --purge -y \
    && apt-get clean

WORKDIR /app

COPY . /app

CMD ["/bin/bash"]
