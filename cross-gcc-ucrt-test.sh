#!/bin/bash
set -e

TOP_DIR=$(pwd)

# Speed up the process
# Env Var NUMJOBS overrides automatic detection
MJOBS=$(grep -c processor /proc/cpuinfo)

CFLAGS="-pipe -O2"
MINGW_TRIPLE="x86_64-w64-mingw32"
export MINGW_TRIPLE
export CFLAGS
export CXXFLAGS=$CFLAGS

export M_ROOT=$(pwd)
export M_SOURCE=$M_ROOT/source
export M_BUILD=$M_ROOT/build
export M_CROSS=$M_ROOT/cross
export RUSTUP_LOCATION=$M_ROOT/rustup_location

export PATH="$M_CROSS/bin:$RUSTUP_LOCATION/.cargo/bin:$PATH"
export PKG_CONFIG="pkgconf --static"
export PKG_CONFIG_LIBDIR="$M_CROSS/lib/pkgconfig"
export RUSTUP_HOME="$RUSTUP_LOCATION/.rustup"
export CARGO_HOME="$RUSTUP_LOCATION/.cargo"

mkdir -p $M_SOURCE
mkdir -p $M_BUILD

echo "gettiong source"
echo "======================="
cd $M_SOURCE
wget -c -O binutils-2.40.tar.bz2 http://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.bz2
tar xjf binutils-2.40.tar.bz2
wget -c -O gcc-13.1.0.tar.xz https://ftp.gnu.org/gnu/gcc/gcc-13.1.0/gcc-13.1.0.tar.xz
xz -c -d gcc-13.1.0.tar.xz | tar xf -
git clone https://github.com/mingw-w64/mingw-w64.git --branch master --depth 1

echo "building gendef"
echo "======================="
cd $M_BUILD
mkdir gendef-build
cd gendef-build
$M_SOURCE/mingw-w64/mingw-w64-tools/gendef/configure --prefix=$M_CROSS
make -j$MJOBS
make install
cd $M_BUILD

echo "building binutils"
echo "======================="
mkdir binutils-build
cd binutils-build
$M_SOURCE/binutils-2.40/configure \
  --target=$MINGW_TRIPLE \
  --prefix=$M_CROSS \
  --with-sysroot=$M_CROSS \
  --disable-multilib \
  --disable-nls \
  --disable-shared \
  --disable-win32-registry \
  --without-included-gettext \
  --enable-lto \
  --enable-plugins \
  --enable-threads
make -j$MJOBS
make install
#cd $M_CROSS/bin
#ln -s $(which pkg-config) $MINGW_TRIPLE-pkg-config
#ln -s $(which pkg-config) $MINGW_TRIPLE-pkgconf
#cd $M_CROSS
#mkdir -p $MINGW_TRIPLE/lib
#ln -s $MINGW_TRIPLE mingw
#cd $MINGW_TRIPLE
#ln -s lib lib64
cd $M_BUILD

echo "building mingw-w64-headers"
echo "======================="
mkdir headers-build
cd headers-build
$M_SOURCE/mingw-w64/mingw-w64-headers/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS \
  --enable-sdk=all \
  --enable-idl \
  --with-default-msvcrt=ucrt
make -j$MJOBS
make install
cd $M_BUILD

echo "building gcc"
echo "======================="
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0005-Windows-Don-t-ignore-native-system-header-dir.patch
cd $M_SOURCE/gcc-13.1.0
patch -p1 -i $M_BUILD/0005-Windows-Don-t-ignore-native-system-header-dir.patch

# do not expect ${prefix}/mingw symlink - this should be superceded by
# 0005-Windows-Don-t-ignore-native-system-header-dir.patch .. but isn't!
sed -i 's#${prefix}/mingw#${prefix}#g' configure

# change hardcoded /mingw prefix to the real prefix .. isn't this rubbish?
# it might work at build time and could be important there but beyond that?!
export MINGW_NATIVE_PREFIX=$M_CROSS/$MINGW_TRIPLE
sed -i "s#/mingw/#${MINGW_NATIVE_PREFIX}/#g" gcc/config/i386/mingw32.h

mkdir gcc-build
cd gcc-build
$M_SOURCE/gcc-13.1.0/configure \
  --target=$MINGW_TRIPLE \
  --prefix=$M_CROSS \
  --with-sysroot=$M_CROSS \
  --disable-multilib \
  --enable-languages=c,c++ \
  --disable-nls \
  --disable-shared \
  --disable-win32-registry \
  --with-arch=x86-64 \
  --with-tune=generic \
  --enable-threads=posix \
  --without-included-gettext \
  --enable-lto \
  --enable-checking=release \
  --disable-sjlj-exceptions
make -j$MJOBS all-gcc
make install-gcc
cd $M_BUILD

echo "building mingw-w64-crt"
echo "======================="
cd $M_SOURCE/mingw-w64/mingw-w64-crt
autoreconf -ivf
mkdir crt-build
cd crt-build
$M_SOURCE/mingw-w64/mingw-w64-crt/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE \
  --with-sysroot=$M_CROSS \
  --with-default-msvcrt=ucrt \
  --enable-lib64 \
  --disable-lib32
make -j$MJOBS
make install
cd $M_BUILD

echo "building winpthreads"
echo "======================="
mkdir winpthreads-build
cd winpthreads-build
$M_SOURCE/mingw-w64/mingw-w64-libraries/winpthreads/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE \
  --disable-shared \
  --enable-static
make -j$MJOBS
make install
cd $M_BUILD

echo "installing gcc final"
echo "======================="
cd gcc-build
make -j$MJOBS
make install
cd $M_SOURCE
