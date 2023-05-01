#!/bin/bash

# basic param and command line option to change it

export TOP_DIR=$(pwd)
export M_CROSS=$TOP_DIR/cross
export RUSTUP_LOCATION=$TOP_DIR/rustup_location

# Speed up the process
# Env Var NUMJOBS overrides automatic detection
MJOBS=$(grep -c processor /proc/cpuinfo)


export MINGW_TRIPLE="x86_64-w64-mingw32"

export PATH="$M_CROSS/bin:$RUSTUP_LOCATION/.cargo/bin:$PATH"
export PKG_CONFIG="pkgconf --static"
export PKG_CONFIG_LIBDIR="$M_CROSS/opt/lib/pkgconfig"

CC=$M_CROSS/bin/$MINGW_TRIPLE-gcc
CXX=$M_CROSS/bin/$MINGW_TRIPLE-g++
AR=$M_CROSS/bin/$MINGW_TRIPLE-ar
RANLIB=$M_CROSS/bin/$MINGW_TRIPLE-ranlib
AS=$M_CROSS/bin/$MINGW_TRIPLE-as
LD=$M_CROSS/bin/$MINGW_TRIPLE-ld
STRIP=$M_CROSS/bin/$MINGW_TRIPLE-strip
NM=$M_CROSS/bin/$MINGW_TRIPLE-nm
DLLTOOL=$M_CROSS/bin/$MINGW_TRIPLE-dlltool
WINDRES=$M_CROSS/bin/$MINGW_TRIPLE-windres

cd $TOP_DIR
curl -OL https://github.com/eko5624/toolchain-test/releases/download/toolchain/gcc-toolchain-12-20230421.7z
7z x gcc-toolchain-12-20230421.7z
git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git
cd libjpeg-turbo
rm -rf build && mkdir build && cd build
cmake .. -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$TOP_DIR/opt \
  -DCMAKE_TOOLCHAIN_FILE=$TOP_DIR/toolchain.cmake \
  -DENABLE_SHARED=OFF \
  -DENABLE_STATIC=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_ENABLE_EXPORTS=ON
ninja -j$MJOBS
ninja install

cd ..
