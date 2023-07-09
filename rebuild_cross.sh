#!/bin/bash

# basic param and command line option to change it

TOP_DIR=$(pwd)

source $TOP_DIR/pkg_ver.sh

MACHINE_TYPE=x86_64
# CFLAGS="-pipe -g"
CFLAGS="-pipe -O0"
MINGW_LIB="--enable-lib64 --disable-lib32"
MINGW_TRIPLE="x86_64-w64-mingw32"

if [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
	echo "$0 [ 64d | 64r | 32d | 32r ]"
	exit 0
fi

if [ "$1" == "64r" ] || [ "$1" == "32r" ] ; then
	CFLAGS="-pipe -O2"
fi

if [ "$1" == "32r" ] || [ "$1" == "32d" ] ; then
	MACHINE_TYPE=i686
	MINGW_LIB="--enable-lib32 --disable-lib64"
	MINGW_TRIPLE="i686-w64-mingw32"
fi

export CFLAGS
export MINGW_LIB
export MINGW_TRIPLE

export M_ROOT=$(pwd)
export M_SOURCE=$M_ROOT/source
export M_BUILD=$M_ROOT/build
export M_CROSS=$M_ROOT/cross

export BHT="--target=$MINGW_TRIPLE"

export CXXFLAGS=$CFLAGS

export PATH=$M_CROSS/bin:$PATH

export MAKE_OPT="-j 2"

set -e

# <1> clean
date
rm -rf $M_CROSS
mkdir -p $M_BUILD
cd $M_BUILD
rm -rf bc_bin bc_gcc bc_m64 bc_m64_head bc_winpth

# <2> build
echo "building mingw-w64-headers"
echo "======================="
mkdir bc_m64_head
cd bc_m64_head
$M_SOURCE/mingw-w64-v$VER_MINGW64/mingw-w64-headers/configure \
	--host=$MINGW_TRIPLE --prefix=$M_CROSS/$MINGW_TRIPLE --with-default-msvcrt=ucrt
   	# --with-sysroot=$M_CROSS --enable-sdk=directx
	# --enable-sdk=all   (ddk, directx)
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd $M_CROSS
ln -s $MINGW_TRIPLE mingw
cd $M_BUILD

echo "building binutils"
echo "======================="
mkdir bc_bin
cd bc_bin
$M_SOURCE/binutils-$VER_BINUTILS/configure $BHT --disable-nls \
  --disable-multilib \
  --prefix=$M_CROSS --with-sysroot=$M_CROSS
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..

echo "building gcc-initial"
echo "======================="
mkdir bc_gcc
cd bc_gcc
patch -d $M_SOURCE/gcc-$VER_GCC/gcc/config/i386 -p1 < $M_ROOT/patch/gcc-intrin.patch
$M_SOURCE/gcc-$VER_GCC/configure $BHT --disable-nls \
  --disable-multilib \
  --enable-languages=c,c++ \
  --disable-libstdcxx-pch \
  --prefix=$M_CROSS \
  --with-sysroot=$M_CROSS \
  --enable-threads=posix
make $MAKE_OPT all-gcc || echo "(-) Build Error!"
make install-gcc
cd ..

echo "building mingw-w64-crt"
echo "======================="
mkdir bc_m64
cd bc_m64
$M_SOURCE/mingw-w64-v$VER_MINGW64/mingw-w64-crt/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE $MINGW_LIB --with-default-msvcrt=ucrt
make || echo "(-) Build Error!"
make install
cd ..

echo "building mcfgthread"
echo "======================="
cd $M_SOURCE
git clone https://github.com/lhmouse/mcfgthread.git
cd mcfgthread
autoreconf -ivf
cd $M_BUILD
mkdir bc_mcfgthread
cd bc_mcfgthread
$M_SOURCE/mcfgthread/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..

echo "building winpthreads"
echo "======================="
mkdir bc_winpth
cd bc_winpth
$M_SOURCE/mingw-w64-v$VER_MINGW64/mingw-w64-libraries/winpthreads/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE $MINGW_LIB
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..

echo "installing gcc-final"
echo "======================="
cd bc_gcc
make $MAKE_OPT || echo "(-) Build Error!"
make install
patch -d $M_SOURCE/gcc-$VER_GCC/gcc/config/i386 -p1 -R < $M_ROOT/patch/gcc-intrin.patch
rm -f $M_CROSS/mingw
rm -rf $M_BUILD
cd $M_ROOT
