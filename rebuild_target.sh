#!/bin/bash

# basic param and command line option to change it

TOP_DIR=$(pwd)

source $TOP_DIR/pkg_ver.sh


MACHINE_TYPE=x86_64
# CFLAGS="-pipe -g"
CFLAGS="-pipe -O0"
MINGW_LIB="--enable-lib64 --disable-lib32"
MINGW_TRIPLE="x86_64-w64-mingw32"
LIBGCC_NAME="libgcc_s_seh-1.dll"

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
	LIBGCC_NAME="libgcc_s_sjlj-1.dll"
fi

export CFLAGS
export MINGW_LIB
export MINGW_TRIPLE

export M_ROOT=$(pwd)
export M_SOURCE=$M_ROOT/source
export M_BUILD=$M_ROOT/build
export M_CROSS=$M_ROOT/cross
export M_TARGET=$M_ROOT/target


# NOTE : must set both --host and --target, otherwise gcc build will failed
export BHT="--host=$MINGW_TRIPLE --target=$MINGW_TRIPLE"

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

export CXXFLAGS=$CFLAGS
export PATH=$M_CROSS/bin:$PATH
export MAKE_OPT="-j 2"

set -e

# <1> clean
date
rm -rf $M_TARGET
mkdir -p $M_BUILD
cd $M_BUILD
rm -rf tg_m64 tg_m64_head tg_winpth
rm -rf tg_bin tg_gcc tg_gdb
rm -rf tg_make tg_yasm tg_nasm

# <2> build
echo "building mingw-w64-headers"
echo "======================="
mkdir tg_m64_head
cd tg_m64_head
$M_SOURCE/mingw-w64-v$VER_MINGW64/mingw-w64-headers/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET/$MINGW_TRIPLE --with-default-msvcrt=ucrt  
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd $M_TARGET
ln -s $MINGW_TRIPLE mingw
cd $M_BUILD

echo "building binutils"
echo "======================="
mkdir tg_bin
cd tg_bin
$M_SOURCE/binutils-$VER_BINUTILS/configure $BHT --disable-nls \
  --disable-werror \
  --prefix=$M_TARGET --with-sysroot=$M_TARGET
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..

echo "building mingw-w64-crt"
echo "======================="
mkdir tg_m64
cd tg_m64
$M_SOURCE/mingw-w64-v$VER_MINGW64/mingw-w64-crt/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET/$MINGW_TRIPLE $MINGW_LIB --with-default-msvcrt=ucrt
make || echo "(-) Build Error!"
make install
cd ..

echo "building gendef"
echo "======================="
mkdir tg_gendef
cd tg_gendef
$M_SOURCE/mingw-w64-v$VER_MINGW64/mingw-w64-tools/gendef/configure \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_TARGET
make -j$MJOBS
make install
cd ..

echo "building gmp"
echo "======================="
mkdir tg_gmp
cd tg_gmp
$M_SOURCE/gmp-$VER_GMP/configure $BHT --prefix=$M_BUILD/for_target --enable-static --disable-shared
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..

echo "building mpfr"
echo "======================="
mkdir tg_mpfr
cd tg_mpfr
$M_SOURCE/mpfr-$VER_MPFR/configure $BHT --prefix=$M_BUILD/for_target  --with-gmp=$M_BUILD/for_target --enable-static --disable-shared
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..

echo "building MPC"
echo "======================="
mkdir tg_mpc
cd tg_mpc
$M_SOURCE/mpc-$VER_MPC/configure $BHT --prefix=$M_BUILD/for_target  --with-gmp=$M_BUILD/for_target --enable-static --disable-shared
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..

echo "building isl"
echo "======================="
mkdir tg_isl
cd tg_isl
$M_SOURCE/isl-$VER_ISL/configure $BHT --prefix=$M_BUILD/for_target --with-gmp-prefix=$M_BUILD/for_target --enable-static --disable-shared
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..

echo "building gcc"
echo "======================="
mkdir tg_gcc
cd tg_gcc
patch -d $M_SOURCE/gcc-$VER_GCC/gcc/config/i386 -p1 < $M_ROOT/patch/gcc-intrin.patch
$M_SOURCE/gcc-$VER_GCC/configure $BHT --disable-nls \
  --disable-bootstrap \
  --enable-languages=c,c++ \
  --with-gmp=$M_BUILD/for_target \
  --with-mpfr=$M_BUILD/for_target \
  --with-mpc=$M_BUILD/for_target \
  --with-isl=$M_BUILD/for_target \
  --enable-twoprocess \
  --disable-libstdcxx-pch \
  --disable-win32-registry \
  --enable-libssp \
  --prefix=$M_TARGET --libexecdir=$M_TARGET/lib --with-sysroot=$M_TARGET
make $MAKE_OPT || echo "(-) Build Error!"
make install
VER=$(cat $M_SOURCE/gcc-$VER_GCC/gcc/BASE-VER)
#mv $M_TARGET/lib/gcc/x86_64-w64-mingw32/lib/libgcc_s.a $M_TARGET/lib/gcc/x86_64-w64-mingw32/$VER/
#mv $M_TARGET/lib/gcc/x86_64-w64-mingw32/libgcc*.dll $M_TARGET/lib/gcc/x86_64-w64-mingw32/$VER/
#rm -rf $M_TARGET/lib/gcc/x86_64-w64-mingw32/lib
#find $M_TARGET/lib/gcc/x86_64-w64-mingw32/$VER -type f -name "*.dll.a" -print0 | xargs -0 -I {} rm {}
cp $M_TARGET/bin/gcc.exe $M_TARGET/bin/cc.exe
cp $M_TARGET/bin/$MINGW_TRIPLE-gcc.exe $M_TARGET/bin/$MINGW_TRIPLE-cc.exe
for f in $M_TARGET/bin/*.exe; do
  strip -s $f
done
for f in $M_TARGET/lib/gcc/x86_64-w64-mingw32/$VER/*.exe; do
  strip -s $f
done
cd ..

echo "building winpthreads"
echo "======================="
mkdir tg_winpth
cd tg_winpth
$M_SOURCE/mingw-w64-v$VER_MINGW64/mingw-w64-libraries/winpthreads/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET/$MINGW_TRIPLE $MINGW_LIB
make $MAKE_OPT || echo "(-) Build Error!"
make install
cp $M_TARGET/$MINGW_TRIPLE/bin/libwinpthread-1.dll $M_TARGET/bin/
cd ..

echo "building make"
echo "======================="
cd $M_SOURCE
wget -c -O make-4.4.1.tar.gz https://ftp.gnu.org/pub/gnu/make/make-4.4.1.tar.gz
tar xzf make-4.4.1.tar.gz
cd $M_BUILD
mkdir make-build
cd make-build
$M_SOURCE/make-4.4.1/configure \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_TARGET
make $MAKE_OPT
make install
cp $M_TARGET/bin/make.exe $M_TARGET/bin/mingw32-make.exe

echo "building pkgconf"
echo "======================="
cd $M_SOURCE
git clone https://github.com/pkgconf/pkgconf --branch pkgconf-1.9.5
cd $M_BUILD
mkdir pkgconf-build
cd pkgconf-build
meson setup . $M_SOURCE/pkgconf \
  --prefix=$M_TARGET \
  --cross-file=$TOP_DIR/cross.meson \
  --buildtype=plain \
  -Dtests=disabled
ninja $MAKE_OPT -C $M_BUILD/pkgconf-build
ninja install -C $M_BUILD/pkgconf-build
cp $M_TARGET/bin/pkgconf.exe $M_TARGET/bin/pkg-config.exe
cp $M_TARGET/bin/pkgconf.exe $M_TARGET/bin/x86_64-w64-mingw32-pkg-config.exe
cd $M_TARGET
rm -rf lib/pkgconfig
rm -rf include/pkgconf
rm -f mingw
rm -rf $M_TARGET/share

