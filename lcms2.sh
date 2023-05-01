#!/bin/bash

# basic param and command line option to change it

TOP_DIR=$(pwd)

M_CROSS=$TOP_DIR/cross
RUSTUP_LOCATION=$TOP_DIR/rustup_location

# Speed up the process
# Env Var NUMJOBS overrides automatic detection
MJOBS=$(grep -c processor /proc/cpuinfo)


MINGW_TRIPLE="x86_64-w64-mingw32"

export PATH="$M_CROSS/bin:$RUSTUP_LOCATION/.cargo/bin:$PATH"
export PKG_CONFIG="pkgconf --static"
export PKG_CONFIG_LIBDIR="$M_CROSS/opt/lib/pkgconfig"
export RUSTUP_HOME="$RUSTUP_LOCATION/.rustup"
export CARGO_HOME="$RUSTUP_LOCATION/.cargo"

cd $TOP_DIR
curl -OL https://github.com/eko5624/mpv-toolchain/releases/download/2023-04-29/gcc.7z
7z x gcc.7z
mv mpv-winbuild-cmake/build64/install cross
curl -OL https://github.com/${{ github.repository }}/releases/download/dev/libjpeg.7z
curl -OL https://github.com/${{ github.repository }}/releases/download/dev/zlib.7z
7z x *.7z
git clone https://github.com/mm2/Little-CMS.git
cd Little-CMS
./configure \
  CFLAGS='-fno-asynchronous-unwind-tables' \
  --host=$MINGW_TRIPLE \
  --prefix=$TOP_DIR/opt \
  --disable-shared
make -j$MJOBS
make install

cd ..
