#!/bin/bash

TOP_DIR=$(pwd)

source $TOP_DIR/pkg_ver.sh

# Speed up the process
# Env Var NUMJOBS overrides automatic detection
if [[ -n "$NUMJOBS" ]]; then
  MJOBS="$NUMJOBS"
elif [[ -f /proc/cpuinfo ]]; then
  MJOBS=$(grep -c processor /proc/cpuinfo)

MACHINE_TYPE=x86_64
MINGW_TRIPLE="x86_64-w64-mingw32"

export MINGW_TRIPLE

export M_ROOT=$(pwd)
export M_SOURCE=$M_ROOT/source
export M_BUILD=$M_ROOT/build
export M_CROSS=$M_ROOT/cross
export RUSTUP_LOCATION=$M_ROOT/RUSTUP_LOCATION

export BHT="--target=$MINGW_TRIPLE"

export PATH="$M_CROSS/bin:$RUSTUP_LOCATION/.cargo/bin:$PATH"
export PKG_CONFIG="pkgconf --static"
export PKG_CONFIG_LIBDIR="$M_CROSS/lib/pkgconfig"
export RUSTUP_HOME="$RUSTUP_LOCATION/.rustup"
export CARGO_HOME="$RUSTUP_LOCATION/.cargo"

set -x

# <1> clean
date

rm -rf $M_CROSS

mkdir -p $M_BUILD
cd $M_BUILD
rm -rf bc_binutils bc_gcc bc_mingw_crt bc_mingw_headers bc_mingw_winpthreads bc_mingw_gendef

# <2> build
echo "building mingw-w64-headers"
echo "======================="

mkdir bc_mingw_headers
cd bc_mingw_headers
$M_SOURCE/mingw-w64-v$VER_MINGW64/mingw-w64-headers/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE \
  --enable-sdk=all \
  --enable-idl \
  --with-default-msvcrt=msvcrt
make -j$MJOBS || echo "(-) Build Error!"
make install install-strip
cd ..
