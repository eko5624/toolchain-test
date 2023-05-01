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
export RUSTUP_HOME="$RUSTUP_LOCATION/.rustup"
export CARGO_HOME="$RUSTUP_LOCATION/.cargo"

cd $TOP_DIR
curl -OL https://github.com/eko5624/toolchain-test/releases/download/dev/zlib.7z
7z x *.7z
git clone https://github.com/glennrp/libpng.git
cd libpng
./configure \
  CFLAGS='-fno-asynchronous-unwind-tables' \
  --host=$MINGW_TRIPLE \
  --prefix=$TOP_DIR/opt \
  --disable-shared
make -j$MJOBS
make install
ln -s $TOP_DIR/opt/bin/libpng-config $M_CROSS/bin/libpng-config
ln -s $TOP_DIR/opt/bin/libpng16-config $M_CROSS/bin/libpng16-config

cd ..
