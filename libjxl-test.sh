#!/bin/bash

# basic param and command line option to change it
set -e

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

export CC=$M_CROSS/bin/$MINGW_TRIPLE-gcc
export CXX=$M_CROSS/bin/$MINGW_TRIPLE-g++
export AR=$M_CROSS/bin/$MINGW_TRIPLE-ar
export RANLIB=$M_CROSS/bin/$MINGW_TRIPLE-ranlib
export AS=$M_CROSS/bin/$MINGW_TRIPLE-as
export LD=$M_CROSS/bin/$MINGW_TRIPLE-ld
export STRIP=$M_CROSS/bin/$MINGW_TRIPLE-strip
export NM=$M_CROSS/bin/$MINGW_TRIPLE-nm
export DLLTOOL=$M_CROSS/bin/$MINGW_TRIPLE-dlltool
export WINDRES=$M_CROSS/bin/$MINGW_TRIPLE-windres

export CFLAGS="-static-libgcc -static-libstdc++ -I$TOP_DIR/opt/include"
export CXXFLAGS="-static-libgcc -static-libstdc++ -I$TOP_DIR/opt/include"
export LDFLAGS="-static-libgcc -static-libstdc++ -L$TOP_DIR/opt/lib"

echo "building brotli"
echo "======================="
cd $TOP_DIR
git clone https://github.com/google/brotli.git
cd brotli
rm -rf build && mkdir build && cd build
cmake .. -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$TOP_DIR/opt \
  -DCMAKE_TOOLCHAIN_FILE=$TOP_DIR/toolchain.cmake \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DBROTLI_EMSCRIPTEN=OFF
ninja -j$MJOBS
ninja install
cd $TOP_DIR

echo "building highway"
echo "======================="
git clone https://github.com/google/highway.git
cd highway
rm -rf build && mkdir build && cd build
cmake .. -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$TOP_DIR/opt \
  -DCMAKE_TOOLCHAIN_FILE=$TOP_DIR/toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTING=OFF \
  -DCMAKE_GNUtoMS=OFF \
  -DHWY_CMAKE_ARM7=OFF \
  -DHWY_ENABLE_CONTRIB=OFF \
  -DHWY_ENABLE_EXAMPLES=OFF \
  -DHWY_ENABLE_INSTALL=ON \
  -DHWY_WARNINGS_ARE_ERRORS=OFF
ninja -j$MJOBS
ninja install
cd $TOP_DIR

echo "building zlib"
echo "======================="
git clone https://github.com/madler/zlib.git
cd zlib
curl -OL https://raw.githubusercontent.com/shinchiro/mpv-winbuild-cmake/master/packages/zlib-1-win32-static.patch
patch -p1 -i zlib-1-win32-static.patch

CHOST=$MINGW_TRIPLE \
./configure --prefix=$TOP_DIR/opt --static
make -j$MJOBS
make install
cd $TOP_DIR

echo "building libpng"
echo "======================="
git clone https://github.com/glennrp/libpng.git
cd libpng
export CFLAGS='-fno-asynchronous-unwind-tables'
autoreconf -ivf
./configure \
  --host=$MINGW_TRIPLE \
  --prefix=$TOP_DIR/opt \
  --disable-shared
make -j$MJOBS
make install
ln -s $TOP_DIR/opt/bin/libpng-config $M_CROSS/bin/libpng-config
ln -s $TOP_DIR/opt/bin/libpng16-config $M_CROSS/bin/libpng16-config
cd $TOP_DIR

echo "building libjpeg"
echo "======================="
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
cd $TOP_DIR

echo "building lcms2"
echo "======================="
git clone https://github.com/mm2/Little-CMS.git
cd Little-CMS
./configure \
  --host=$MINGW_TRIPLE \
  --prefix=$TOP_DIR/opt \
  --disable-shared
make -j$MJOBS
make install
cd $TOP_DIR

echo "building libjxl"
echo "======================="
git clone https://github.com/libjxl/libjxl.git
cd libjxl
rm -rf build && mkdir build && cd build
cmake .. -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$TOP_DIR/opt \
  -DCMAKE_TOOLCHAIN_FILE=$TOP_DIR/toolchain.cmake \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
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
  -DJPEGXL_ENABLE_SJPEG=OFF \
  -DCMAKE_CXX_FLAGS='${CMAKE_CXX_FLAGS} -Wa,-muse-unaligned-vector-move' \
  -DCMAKE_C_FLAGS='${CMAKE_C_FLAGS} -Wa,-muse-unaligned-vector-move'
ninja -j$MJOBS
ninja install
cd $TOP_DIR
