#!/bin/bash

# basic param and command line option to change it

TOP_DIR=$(pwd)

M_CROSS=$TOP_DIR/cross
RUSTUP_LOCATION=$TOP_DIR/rustup_location

# Speed up the process
# Env Var NUMJOBS overrides automatic detection
MJOBS=$(grep -c processor /proc/cpuinfo)


MINGW_TRIPLE="x86_64-w64-mingw32"

export PATH="$M_CROSS/bin:$PATH"
export PKG_CONFIG="pkgconf --static"
export PKG_CONFIG_LIBDIR="$M_CROSS/opt/lib/pkgconfig"

cd $TOP_DIR
git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git
cd libjpeg-turbo
rm -rf build && mkdir build && cd build
cmake .. -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$TOP_DIR/opt \
  -DCMAKE_TOOLCHAIN_FILE=$TOP_DIR/toolchain.cmake \
  -DENABLE_SHARED=OFF \
  -DENABLE_STATIC=ON \
  -DCMAKE_BUILD_TYPE=Release
ninja -j$MJOBS
ninja install

cd ..
