#!/bin/bash

# basic param and command line option to change it

TOP_DIR=$(pwd)

M_CROSS=$TOP_DIR/cross
RUSTUP_LOCATION=$TOP_DIR/rustup_location

# Speed up the process
# Env Var NUMJOBS overrides automatic detection
MJOBS=$(grep -c processor /proc/cpuinfo)

MINGW_TRIPLE="x86_64-w64-mingw32"

# export PATH="$M_CROSS/bin:$RUSTUP_LOCATION/.cargo/bin:$PATH"
export PKG_CONFIG="pkgconf --static"
export PKG_CONFIG_LIBDIR="$M_CROSS/opt/lib/pkgconfig"
export RUSTUP_HOME="$RUSTUP_LOCATION/.rustup"
export CARGO_HOME="$RUSTUP_LOCATION/.cargo"

cd $TOP_DIR
curl -OL https://github.com/eko5624/mpv-toolchain/releases/download/2023-04-29/gcc.7z
7z x gcc.7z
mv mpv-winbuild-cmake/build64/install cross
git clone https://github.com/madler/zlib.git
cd zlib
curl -OL https://raw.githubusercontent.com/shinchiro/mpv-winbuild-cmake/master/packages/zlib-1-win32-static.patch
patch -p1 -i zlib-1-win32-static.patch

CHOST=$MINGW_TRIPLE \
./configure --prefix=$TOP_DIR/opt --static
make -j$MJOBS
make install

cd ..
