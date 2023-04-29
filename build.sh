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

export MINGW_TRIPLE

set -x

cd $TOP_DIR
git clone https://github.com/madler/zlib.git --branch master --depth 1
cd zlib
curl -OL https://raw.githubusercontent.com/shinchiro/mpv-winbuild-cmake/master/packages/zlib-1-win32-static.patch
patch -p1 -i zlib-1-win32-static.patch

CHOST=$MINGW_TRIPLE \
./configure \
  --prefix=$TOP_DIR/opt \
  --static
make -j$MJOBS
make install

cd ..





