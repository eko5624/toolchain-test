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
if [ ! -d gcc-$VER_GCC ] ; then
	wget -c -O gcc-$VER_GCC.tar.xz http://ftp.gnu.org/gnu/gcc/gcc-$VER_GCC/gcc-$VER_GCC.tar.xz
	# tar xJf gcc-$VER_GCC.tar.xz
	xz -c -d gcc-$VER_GCC.tar.xz | tar xf -
fi

# <3> mingw-w64
if [ ! -d mingw-w64-v$VER_MINGW64 ] ; then
	wget -c -O mingw-w64-v$VER_MINGW64.tar.bz2 http://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v$VER_MINGW64.tar.bz2
	tar xjf mingw-w64-v$VER_MINGW64.tar.bz2
fi

# <4> gmp
if [ ! -d gmp-$VER_GMP ] ; then
	wget -c -O gmp-${VER_GMP}.tar.bz2 http://ftp.gnu.org/gnu/gmp/gmp-${VER_GMP}.tar.bz2
	tar xjf gmp-${VER_GMP}.tar.bz2
fi

# <5> mpfr
if [ ! -d mpfr-$VER_MPFR ] ; then
	# wget http://www.mpfr.org/mpfr-current/mpfr-2.4.2.tar.bz2
	wget -c -O mpfr-$VER_MPFR.tar.bz2 http://mpfr.loria.fr/mpfr-$VER_MPFR/mpfr-$VER_MPFR.tar.bz2
	tar xjf mpfr-$VER_MPFR.tar.bz2
fi

# <6> MPC
if [ ! -d mpc-$VER_MPC ] ; then
	wget -c -O mpc-$VER_MPC.tar.gz ftp://ftp.gnu.org/gnu/mpc/mpc-$VER_MPC.tar.gz
	tar xzf mpc-$VER_MPC.tar.gz
fi

# <7> isl
if [ ! -d isl-$VER_ISL ] ; then
	wget -c -O isl-$VER_ISL.tar.bz2 ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-$VER_ISL.tar.bz2
	tar xjf isl-$VER_ISL.tar.bz2
fi
