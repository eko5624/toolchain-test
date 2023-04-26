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
# export BHT="--host=$MACHINE_TYPE-w64-mingw32"

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

# export CFLAGS=" -g -pipe -fno-leading-underscore "

export CXXFLAGS=$CFLAGS

export PATH=$M_CROSS/bin:$PATH

# export MAKE_OPT="-j 2"

set -x


# <2-2> build script
date

rm -rf $M_TARGET

mkdir -p $M_BUILD
cd $M_BUILD
rm -rf tg_m64 tg_m64_head tg_winpth
rm -rf tg_bin tg_gcc tg_gdb
rm -rf tg_make tg_yasm tg_nasm

date
mkdir tg_m64_head
cd tg_m64_head
$M_SOURCE/mingw-w64-v$VER_MINGW64/mingw-w64-headers/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET/$MINGW_TRIPLE  
	# --with-sysroot=$M_TARGET --enable-sdk=directx
	# --enable-sdk=all   (ddk, directx)
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..

( cd $M_TARGET ; ln -s $MINGW_TRIPLE mingw ; cd $M_BUILD )


mkdir tg_bin
cd tg_bin

if [ "1" == "0" ] ; then
mkdir bfd
cat > bfd/config.cache <<EOF
ac_cv_have_decl_fseeko64=no
ac_cv_have_decl_ftello64=no
ac_cv_func_fseeko64=no
ac_cv_func_ftello64=no
EOF
fi

patch -d $M_SOURCE/binutils-$VER_BINUTILS -p0 < $M_ROOT/patch/binutils-rust.patch
$M_SOURCE/binutils-$VER_BINUTILS/configure $BHT --disable-nls \
  --disable-werror \
  --prefix=$M_TARGET --with-sysroot=$M_TARGET
#  --enable-plugins ( TODO : need remove unused -ldl )
# --with-sysroot=$M_TARGET
# --with-build-sysroot=$M_CROSS
# --enable-64-bit-bfd 
# --disable-multilib 
# make configure-host
make $MAKE_OPT || echo "(-) Build Error!"
make install
patch -d $M_SOURCE/binutils-$VER_BINUTILS -p0 -R < $M_ROOT/patch/binutils-rust.patch
cd ..


date
mkdir tg_m64
cd tg_m64
$M_SOURCE/mingw-w64-v$VER_MINGW64/mingw-w64-crt/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET/$MINGW_TRIPLE $MINGW_LIB
# parallel compile may cause error
# make $MAKE_OPT || echo "(-) Build Error!"
make || echo "(-) Build Error!"
make install
cd ..


date
mkdir tg_winpth
cd tg_winpth
$M_SOURCE/mingw-w64-v$VER_MINGW64/mingw-w64-libraries/winpthreads/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET/$MINGW_TRIPLE $MINGW_LIB
make $MAKE_OPT || echo "(-) Build Error!"
make install
cp $M_TARGET/$MINGW_TRIPLE/bin/libwinpthread-1.dll $M_TARGET/bin/
cd ..


# disable begin
if [ "1" == "1" ] ; then

rm -rf tg_gmp tg_mpfr tg_mpc tg_isl $M_BUILD/for_target

date
mkdir tg_gmp
cd tg_gmp
# ( add limb_64=longlong for mingw arch, line about 3679(old3644) )
$M_SOURCE/gmp-$VER_GMP/configure $BHT --prefix=$M_BUILD/for_target --enable-static --disable-shared
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..


date
mkdir tg_mpfr
cd tg_mpfr
$M_SOURCE/mpfr-$VER_MPFR/configure $BHT --prefix=$M_BUILD/for_target  --with-gmp=$M_BUILD/for_target --enable-static --disable-shared
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..

date
mkdir tg_mpc
cd tg_mpc
$M_SOURCE/mpc-$VER_MPC/configure $BHT --prefix=$M_BUILD/for_target  --with-gmp=$M_BUILD/for_target --enable-static --disable-shared
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..

date
mkdir tg_isl
cd tg_isl
$M_SOURCE/isl-$VER_ISL/configure $BHT --prefix=$M_BUILD/for_target --with-gmp-prefix=$M_BUILD/for_target --enable-static --disable-shared
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..

#date
#mkdir tg_cloog
#cd tg_cloog
#$M_SOURCE/cloog-$VER_CLOOG/configure $BHT --prefix=$M_BUILD/for_target --with-isl=system --with-isl-prefix=$M_BUILD/for_target --with-gmp-prefix=$M_BUILD/for_target --enable-static --disable-shared
#make $MAKE_OPT || echo "(-) Build Error!"
#make install
#cd ..

fi
# disable end

date 
mkdir tg_gcc
cd tg_gcc
patch -d $M_SOURCE/gcc-$VER_GCC/gcc/config/i386 -p1 < $M_ROOT/patch/gcc-intrin.patch
# patch -d $M_SOURCE/gcc-$VER_GCC -p1 < $M_ROOT/patch/gcc-pch.patch
$M_SOURCE/gcc-$VER_GCC/configure $BHT --disable-nls \
  --enable-languages=c,c++,objc,obj-c++ \
  --with-gmp=$M_BUILD/for_target \
  --with-mpfr=$M_BUILD/for_target \
  --with-mpc=$M_BUILD/for_target \
  --with-isl=$M_BUILD/for_target \
  --enable-twoprocess \
  --disable-libstdcxx-pch \
  --disable-win32-registry \
  --enable-threads=posix --enable-libssp \
  --prefix=$M_TARGET --with-sysroot=$M_TARGET

# --with-cloog=$M_BUILD/for_target
# --disable-multilib 
# --with-local-prefix=$M_TARGET
# --enable-twoprocess 
# --with-build-sysroot=$M_CROSS
# --with-sysroot=$M_TARGET
# --disable-libstdcxx-pch --enable-long-long 

# make $MAKE_OPT configure-target-libobjc
# patch -d ./$MINGW_TRIPLE/libobjc/ -p0 < $M_ROOT/patch/gcc-libobjc.patch
make $MAKE_OPT || echo "(-) Build Error!"
# make AS_FOR_TARGET=${AS} LD_FOR_TARGET=${LD}
make install
patch -d $M_SOURCE/gcc-$VER_GCC/gcc/config/i386 -p1 -R < $M_ROOT/patch/gcc-intrin.patch
# patch -d $M_SOURCE/gcc-$VER_GCC -p1 -R < $M_ROOT/patch/gcc-pch.patch
cp $M_TARGET/lib/$LIBGCC_NAME $M_TARGET/bin/
cd ..

date
mkdir tg_gdb
cd tg_gdb
# export LIBS="-lssp -lbcrypt"
$M_SOURCE/gdb-$VER_GDB/configure $BHT --disable-nls \
	--with-gmp=$M_BUILD/for_target \
	--with-libgmp-prefix=$M_BUILD/for_target \
	--with-mpfr=$M_BUILD/for_target \
	--with-mpc=$M_BUILD/for_target \
	--disable-werror \
	--prefix=$M_TARGET
# make $MAKE_OPT configure-gdb
# patch -p0 < $M_ROOT/patch/gdb-makefile.patch
make $MAKE_OPT all-gdb || echo "(-) Build Error!"
make install-gdb
# export LIBS=""
cd ..

date
mkdir tg_make
cd tg_make
$M_SOURCE/make-$VER_MAKE/configure $BHT --prefix=$M_TARGET
# patch -p0 < $M_ROOT/patch/make_path.patch
make $MAKE_OPT || echo "(-) Build Error!"
make install
cp $M_TARGET/bin/make.exe $M_TARGET/bin/mingw32-make.exe
cd ..

date
mkdir tg_pkg-config
cd tg_pkg-config
$M_SOURCE/pkg-config-$VER_PKGCONFIG/configure $BHT --prefix=$M_TARGET \
  --with-internal-glib
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..

date
mkdir tg_yasm
cd tg_yasm
$M_SOURCE/yasm-$VER_YASM/configure $BHT --prefix=$M_TARGET
make $MAKE_OPT || echo "(-) Build Error!"
make install
cd ..

date
mkdir tg_nasm
cd tg_nasm
$M_SOURCE/nasm-$VER_NASM/configure $BHT --prefix=$M_TARGET
make $MAKE_OPT || echo "(-) Build Error!"
make install DESTDIR=$M_TARGET
cd ..

# <2-3> end
( cd $M_TARGET ; rm -f mingw ; cd $M_BUILD )
cd $M_ROOT
date

