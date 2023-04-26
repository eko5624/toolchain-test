#!/bin/bash

# update source code


TOP_DIR=$(pwd)

source $TOP_DIR/pkg_ver.sh


if [ ! -d $TOP_DIR/source ] ; then
	mkdir $TOP_DIR/source || exit 0
	echo "create directory source"
fi

cd $TOP_DIR/source

# <1> binutils
if [ ! -d binutils-$VER_BINUTILS ] ; then
	wget -c -O binutils-$VER_BINUTILS.tar.bz2 http://ftp.gnu.org/gnu/binutils/binutils-$VER_BINUTILS.tar.bz2
	tar xjf binutils-$VER_BINUTILS.tar.bz2
fi

# <2> gcc
if [ ! -d gcc-13-20230422 ] ; then
	wget -c -O gcc-13-20230422.tar.xz https://mirrorservice.org/sites/sourceware.org/pub/gcc/snapshots/$VER_GCC/gcc-$VER_GCC.tar.xz
	# tar xJf gcc-$VER_GCC.tar.xz
	xz -c -d gcc-$VER_GCC.tar.xz | tar xf -
fi

# <3> gdb
if [ ! -d gdb-$VER_GDB ] ; then
	wget -c -O gdb-$VER_GDB.tar.xz http://ftp.gnu.org/gnu/gdb/gdb-$VER_GDB.tar.xz
	# tar xJf gdb-$VER_GDB.tar.xz
	xz -c -d gdb-$VER_GDB.tar.xz | tar xf -
fi

# <4> mingw-w64
if [ ! -d mingw-w64-v$VER_MINGW64 ] ; then
	wget -c -O mingw-w64-v$VER_MINGW64.tar.bz2 http://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v$VER_MINGW64.tar.bz2
	tar xjf mingw-w64-v$VER_MINGW64.tar.bz2
fi

# <5> gmp
if [ ! -d gmp-$VER_GMP ] ; then
	wget -c -O gmp-${VER_GMP}.tar.bz2 http://ftp.gnu.org/gnu/gmp/gmp-${VER_GMP}.tar.bz2
	tar xjf gmp-${VER_GMP}.tar.bz2
fi

# <6> mpfr
if [ ! -d mpfr-$VER_MPFR ] ; then
	# wget http://www.mpfr.org/mpfr-current/mpfr-2.4.2.tar.bz2
	wget -c -O mpfr-$VER_MPFR.tar.bz2 http://mpfr.loria.fr/mpfr-$VER_MPFR/mpfr-$VER_MPFR.tar.bz2
	tar xjf mpfr-$VER_MPFR.tar.bz2
fi

# <7> MPC
if [ ! -d mpc-$VER_MPC ] ; then
	wget -c -O mpc-$VER_MPC.tar.gz http://ftp.gnu.org/gnu/mpc/mpc-$VER_MPC.tar.gz
	tar xzf mpc-$VER_MPC.tar.gz
fi

# <8> isl
if [ ! -d isl-$VER_ISL ] ; then
	wget -c -O isl-$VER_ISL.tar.bz2 ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-$VER_ISL.tar.bz2
	tar xjf isl-$VER_ISL.tar.bz2
fi

# <9> cloog
#if [ ! -d cloog-$VER_CLOOG ] ; then
#	wget -c -O cloog-$VER_CLOOG.tar.gz ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-$VER_CLOOG.tar.gz
#	tar xzf cloog-$VER_CLOOG.tar.gz
#fi

# <21> make
if [ ! -d make-$VER_MAKE ] ; then
	wget -c -O make-$VER_MAKE.tar.gz http://ftp.gnu.org/pub/gnu/make/make-$VER_MAKE.tar.gz
	tar xzf make-$VER_MAKE.tar.gz
fi

# <22> pkg-config
if [ ! -d pkg-config-$VER_PKGCONFIG ] ; then
	wget -c -O pkg-config-$VER_PKGCONFIG.tar.gz https://pkgconfig.freedesktop.org/releases/pkg-config-$VER_PKGCONFIG.tar.gz
	tar xzf pkg-config-$VER_PKGCONFIG.tar.gz
fi

# <23> yasm
if [ ! -d yasm-$VER_YASM ] ; then
	wget -c -O yasm-$VER_YASM.tar.gz http://www.tortall.net/projects/yasm/releases/yasm-$VER_YASM.tar.gz
	tar xzf yasm-$VER_YASM.tar.gz
fi

# <24> nasm
if [ ! -d nasm-$VER_NASM ] ; then
	wget -c -O nasm-$VER_NASM.tar.gz http://www.nasm.us/pub/nasm/releasebuilds/$VER_NASM/nasm-$VER_NASM.tar.gz
	tar xzf nasm-$VER_NASM.tar.gz
fi

