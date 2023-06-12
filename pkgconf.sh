#!/bin/bash

# basic param and command line mingwion to change it
set -e

TOP_DIR=$(pwd)
export M_ROOT=$(pwd)
export M_SOURCE=$M_ROOT/source
export M_BUILD=$M_ROOT/build
export M_CROSS=$M_ROOT/cross

# Speed up the process
# Env Var NUMJOBS overrides automatic detection
MJOBS=$(grep -c processor /proc/cpuinfo)

export MINGW_TRIPLE="x86_64-w64-mingw32"

export PATH="$M_CROSS/bin:$RUSTUP_LOCATION/.cargo/bin:$PATH"
export PKG_CONFIG="pkgconf --static"
export PKG_CONFIG_LIBDIR="$TOP_DIR/opt/lib/pkgconfig"

export CFLAGS="-I$TOP_DIR/opt/include"
export CPPFLAGS="-I$TOP_DIR/opt/include"
export LDFLAGS="-L$TOP_DIR/opt/lib"

mkdir -p $M_SOURCE
mkdir -p $M_BUILD

echo "building pkgconf"
echo "======================="
cd $M_SOURCE
git clone https://github.com/pkgconf/pkgconf --branch pkgconf-1.9.5
cd $M_BUILD
mkdir pkgconf-build
cd pkgconf-build
meson $M_SOURCE/pkgconf
  --prefix=$TOP_DIR/opt \
  --cross-file=$TOP_DIR/cross.meson \
  --buildtype=plain \
  -Dtests=false
ninja -j$MJOBS -C $M_BUILD/pkgconf-build
ninja install -C $M_BUILD/pkgconf-build
