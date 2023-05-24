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

export M_ROOT=$(pwd)
export M_SOURCE=$M_ROOT/source
export M_BUILD=$M_ROOT/build
export M_CROSS=$M_ROOT/cross

export PATH="$M_CROSS/bin:$RUSTUP_LOCATION/.cargo/bin:$PATH"

mkdir -p $M_SOURCE
mkdir -p $M_BUILD

echo "gettiong source"
echo "======================="
cd $M_SOURCE

#binutils
wget -c -O binutils-2.40.tar.bz2 http://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.bz2
tar xjf binutils-2.40.tar.bz2

#gcc
wget -c -O gcc-13.1.0.tar.xz https://ftp.gnu.org/gnu/gcc/gcc-13.1.0/gcc-13.1.0.tar.xz
xz -c -d gcc-13.1.0.tar.xz | tar xf -

#libiconv
wget -c -O libiconv-1.17.tar.gz https://ftp.gnu.org/gnu/libiconv/libiconv-1.17.tar.gz
tar xzf libiconv-1.17.tar.gz

#gmp
wget -c -O gmp-6.2.1.tar.bz2 https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.bz2
tar xjf gmp-6.2.1.tar.bz2

#mpfr
wget -c -O mpfr-4.2.0.tar.bz2 https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.0.tar.bz2
tar xjf mpfr-4.2.0.tar.bz2

#MPC
wget -c -O mpc-1.3.1.tar.gz https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz
tar xzf mpc-1.3.1.tar.gz

#isl
wget -c -O isl-0.24.tar.bz2 https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.24.tar.bz2
tar xjf isl-0.24.tar.bz2

#mingw-w64
git clone https://github.com/mingw-w64/mingw-w64.git --branch master --depth 1

echo "building gmp"
echo "======================="
mkdir gmp-build
cd gmp-build
$M_SOURCE/gmp-6.2.1/configure \
  --prefix=$M_BUILD/for_cross \
  --enable-static \
  --disable-shared
make -j$MJOBS
make install
cd $M_BUILD

echo "building mpfr"
echo "======================="
mkdir mpfr-build
cd mpfr-build
$M_SOURCE/mpfr-4.2.0/configure \
  --prefix=$M_BUILD/for_cross \
  --with-gmp=$M_BUILD/for_cross \
  --enable-static \
  --disable-shared
make -j$MJOBS
make install
cd $M_BUILD

echo "building MPC"
echo "======================="
mkdir mpc-build
cd mpc-build
$M_SOURCE/mpc-1.3.1/configure \
  --prefix=$M_BUILD/for_cross \
  --with-gmp=$M_BUILD/for_cross \
  --enable-static \
  --disable-shared
make -j$MJOBS
make install
cd $M_BUILD

echo "building isl"
echo "======================="
mkdir isl-build
cd isl-build
$M_SOURCE/isl-0.24/configure \
  --prefix=$M_BUILD/for_cross \
  --with-gmp-prefix=$M_BUILD/for_cross \
  --enable-static \
  --disable-shared
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
  --with-mpc=$M_BUILD/for_cross \
  --with-mpfr=$M_BUILD/for_cross \
  --with-gmp=$M_BUILD/for_cross \
  --with-isl=$M_BUILD/for_cross \
  --enable-static \
  --disable-shared \
  --disable-multilib \
  --disable-nls \
  --disable-lto \
  --enable-ld
make -j$MJOBS
make install
cd $M_CROSS
ln -s $MINGW_TRIPLE mingw
cd $M_BUILD

echo "building mingw-w64-headers"
echo "======================="
mkdir headers-build
cd headers-build
$M_SOURCE/mingw-w64/mingw-w64-headers/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE \
  --enable-sdk=all \
  --enable-idl \
  --with-default-msvcrt=ucrt
make -j$MJOBS
make install
cd $M_BUILD

echo "building gcc-initial"
echo "======================="
mkdir gcc-build
cd gcc-build
$M_SOURCE/gcc-13.1.0/configure \
  --target=$MINGW_TRIPLE \
  --prefix=$M_CROSS \
  --with-sysroot=$M_CROSS \
  --disable-multilib \
  --disable-libssp \
  --disable-libgomp \
  --disable-libgcc \
  --disable-libstdc++-v3 \
  --disable-libatomic \
  --disable-libquadmath \
  --enable-languages=c,c++ \
  --disable-nls \
  --disable-shared \
  --disable-win32-registry \
  --disable-libstdcxx-pch \
  --with-tune=generic \
  --with-{gmp,mpfr,mpc,isl}=$M_BUILD/for_cross \
  --enable-threads=posix \
  --enable-fully-dynamic-string \
  --with-gnu-ld \
  --with-gnu-as \
  --with-libiconv \
  --with-system-zlib \
  --without-included-gettext \
  --disable-lto \
  --enable-checking=release \
  --disable-sjlj-exceptions
make -j$MJOBS
make install
cd $M_BUILD

echo "building gendef"
echo "======================="
cd $M_BUILD
mkdir gendef-build
cd gendef-build
$M_SOURCE/mingw-w64/mingw-w64-tools/gendef/configure --prefix=$M_CROSS
make -j$MJOBS
make install
cd $M_BUILD

echo "building widl"
echo "======================="
cd $M_BUILD
mkdir widl-build
cd widl-build
$M_SOURCE/mingw-w64/mingw-w64-tools/widl/configure \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_TARGET
make -j$MJOBS
make install
cd $M_BUILD

echo "building genidl"
echo "======================="
cd $M_BUILD
mkdir genidl-build
cd genidl-build
$M_SOURCE/mingw-w64/mingw-w64-tools/genidl/configure \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_TARGET
make -j$MJOBS
make install
cd $M_BUILD

echo "building mingw-w64-crt"
echo "======================="
cd $M_SOURCE/mingw-w64/mingw-w64-crt

export CC=$M_CROSS/bin/$MINGW_TRIPLE-gcc
export CXX=$M_CROSS/bin/$MINGW_TRIPLE-g++
export AR=$M_CROSS/bin/$MINGW_TRIPLE-ar
export RANLIB=$M_CROSS/bin/$MINGW_TRIPLE-ranlib
export AS=$M_CROSS/bin/$MINGW_TRIPLE-as
export DLLTOOL=$M_CROSS/bin/$MINGW_TRIPLE-dlltool

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
  --enable-static \
  --enable-lib64 \
  --disable-lib32
make -j$MJOBS
make install
cd $M_BUILD

echo "building gcc-final"
echo "======================="
cd gcc-build
$M_SOURCE/gcc-13.1.0/configure \
  --target=$MINGW_TRIPLE \
  --prefix=$M_CROSS \
  --with-sysroot=$M_CROSS \
  --with-{gmp,mpfr,mpc,isl}=$M_BUILD/for_cross \
  --disable-multilib \
  --disable-nls \
  --disable-libssp \
  --disable-lto \
  --enable-languages=c,c++ \
  --disable-shared \
  --enable-static \
  --disable-win32-registry \
  --disable-libstdcxx-pch \
  --disable-symvers \
  --with-arch=x86-64 \
  --with-tune=generic \
  --enable-threads=posix \
  --enable-fully-dynamic-string \
  --with-gnu-ld \
  --with-gnu-as \
  --without-included-gettext \
  --without-newlib \
  --enable-checking=release \
  --disable-sjlj-exceptions
make -j$MJOBS
make install
cd $M_BUILD

echo "building libiconv"
echo "======================="
mkdir libiconv-build
cd libiconv-build
$M_SOURCE/libiconv-1.17/configure \
  --prefix=$M_CROSS \ 
  --build=x86_64-pc-linux-gnu \
  --host=$MINGW_TRIPLE \
  --enable-extra-encodings \
  --enable-static \
  --disable-shared \
  --disable-nls \
  --with-gnu-ld
make -j$MJOBS
make install


