#!/bin/bash

TOP_DIR=$(pwd)

# Speed up the process
# Env Var NUMJOBS overrides automatic detection
MJOBS=$(grep -c processor /proc/cpuinfo)

MACHINE_TYPE=x86_64
MINGW_TRIPLE="x86_64-w64-mingw32"

export MINGW_TRIPLE

export M_ROOT=$(pwd)
export M_SOURCE=$M_ROOT/source
export M_BUILD=$M_ROOT/build
export M_CROSS=$M_ROOT/cross
export RUSTUP_LOCATION=$M_ROOT/RUSTUP_LOCATION

export PATH="$M_CROSS/bin:$RUSTUP_LOCATION/.cargo/bin:$PATH"
export PKG_CONFIG="pkgconf --static"
export PKG_CONFIG_LIBDIR="$M_CROSS/lib/pkgconfig"
export RUSTUP_HOME="$RUSTUP_LOCATION/.rustup"
export CARGO_HOME="$RUSTUP_LOCATION/.cargo"

set -x

# <1> clean
date
rm -rf $M_CROSS

mkdir -p $M_SOURCE
cd $M_SOURCE

# get binutils
wget -c -O binutils-$VER_BINUTILS.tar.bz2 http://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.bz2
tar xjf binutils-2.40.tar.bz2

# get gcc
wget -c -O gcc-13-20230422.tar.xz https://mirrorservice.org/sites/sourceware.org/pub/gcc/snapshots/$VER_GCC/gcc-13-20230422.tar.xz
# tar xJf gcc-$VER_GCC.tar.xz
xz -c -d gcc-$VER_GCC.tar.xz | tar xf -

# get mingw-w64
git clone https://github.com/mingw-w64/mingw-w64.git --branch master --depth 1

mkdir -p $M_BUILD
cd $M_BUILD
rm -rf bc_binutils bc_gcc bc_mingw_crt bc_mingw_headers bc_mingw_winpthreads bc_mingw_gendef

# <2> build
echo "building binutils"
echo "======================="

mkdir bc_binutils
cd bc_binutils
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
make -j$MJOBS || echo "(-) Build Error!"
make install-strip
cd ..
cd $M_CROSS
ln -s $(which pkg-config) bin/$MINGW_TRIPLE-pkg-config
ln -s $(which pkg-config) bin/$MINGW_TRIPLE-pkgconf
cd $M_BUILD

( cd $M_CROSS ; ln -s $MINGW_TRIPLE mingw ; cd $M_BUILD )

echo "building mingw-w64-headers"
echo "======================="

mkdir bc_mingw_headers
cd bc_mingw_headers
$M_SOURCE/mingw-w64/mingw-w64-headers/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE \
  --enable-sdk=all \
  --enable-idl \
  --with-default-msvcrt=msvcrt
make -j$MJOBS || echo "(-) Build Error!"
make install install-strip
cd ..

echo "building gcc"
echo "======================="
mkdir bc_gcc
cd bc_gcc
# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=54412
curl -sL https://salsa.debian.org/mingw-w64-team/gcc-mingw-w64/-/raw/5e7d749d80e47d08e34a17971479d06cd423611e/debian/patches/vmov-alignment.patch
patch -d $M_SOURCE/gcc-13-20230422 -p2 < vmov-alignment.patch
$M_SOURCE/gcc-13-20230422/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS \
  --libdir=$M_CROSS/lib \
  --with-sysroot=$M_CROSS \
  --disable-multilib \
  --enable-languages=c,c++ \
  --disable-nls \
  --disable-shared \
  --disable-win32-registry \
  --with-arch=$MACHINE_TYPE \
  --with-tune=generic \
  --enable-threads=posix \
  --without-included-gettext \
  --enable-lto \
  --enable-checking=release \
  --disable-sjlj-exceptions
make -j$MJOBS all-gcc || echo "(-) Build Error!"
make install-strip-gcc
cd ..

echo "building mingw-w64-crt"
echo "======================="
mkdir bc_mingw_crt
cd bc_mingw_crt
$M_SOURCE/mingw-w64/mingw-w64-crt/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE $MINGW_LIB \
  --with-sysroot=$M_CROSS \
  --with-default-msvcrt=msvcrt-os \
  --enable-lib64 \
  --disable-lib32
make -j$MJOBS || echo "(-) Build Error!"
make install-strip
cd ..

echo "building winpthreads"
echo "======================="
mkdir bc_mingw_winpthreads
cd bc_mingw_winpthreads
$M_SOURCE/mingw-w64/mingw-w64-libraries/winpthreads/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS \
  --disable-shared \
  --enable-static
make -j$MJOBS || echo "(-) Build Error!"
make install-strip
cd ..

echo "building gendef"
echo "======================="
mkdir bc_mingw_gendef
cd bc_mingw_gendef
$M_SOURCE/mingw-w64/mingw-w64-tools/gendef/configure --prefix=$M_CROSS
make -j$MJOBS || echo "(-) Build Error!"
make install-strip
cd ..

echo "building widl"
echo "======================="
mkdir bc_mingw_widl
cd bc_mingw_gendef
$M_SOURCE/mingw-w64/mingw-w64-tools/widl/configure --host=$MINGW_TRIPLE --prefix=$M_CROSS
make -j$MJOBS || echo "(-) Build Error!"
make install-strip
cd ..

echo "building rustup"
echo "======================="
curl -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --target x86_64-pc-windows-gnu --no-modify-path --profile minimal
rustup update
cargo install cargo-c --profile=release-strip --features=vendored-openssl
