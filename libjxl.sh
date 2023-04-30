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
curl -OL https://github.com/${{ github.repository }}/releases/download/dev/libpng.7z
curl -OL https://github.com/${{ github.repository }}/releases/download/dev/libjpeg.7z
curl -OL https://github.com/${{ github.repository }}/releases/download/dev/brotli.7z
curl -OL https://github.com/${{ github.repository }}/releases/download/dev/highway.7z
7z x *.7z
git clone https://github.com/libjxl/libjxl.git
cd libjxl
rm -rf build && mkdir build && cd build
cmake .. -G Ninja \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DJPEGXL_STATIC=ON \
  -DBUILD_TESTING=OFF \
  -DJPEGXL_EMSCRIPTEN=OFF \
  -DJPEGXL_BUNDLE_LIBPNG=OFF \
  -DJPEGXL_ENABLE_TOOLS=OFF \
  -DJPEGXL_ENABLE_VIEWERS=OFF \
  -DJPEGXL_ENABLE_DOXYGEN=OFF \
  -DJPEGXL_ENABLE_EXAMPLES=OFF \
  -DJPEGXL_ENABLE_MANPAGES=OFF \
  -DJPEGXL_ENABLE_JNI=OFF \
  -DJPEGXL_ENABLE_SKCMS=OFF \
  -DJPEGXL_ENABLE_PLUGINS=OFF \
  -DJPEGXL_ENABLE_DEVTOOLS=OFF \
  -DJPEGXL_ENABLE_BENCHMARK=OFF \
  -DJPEGXL_ENABLE_SJPEG=OFF
ninja -j$MJOBS
ninja install

cd ..