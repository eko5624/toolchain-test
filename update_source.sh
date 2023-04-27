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

# <3> mingw-w64
if [ ! -d mingw-w64-v$VER_MINGW64 ] ; then
	wget -c -O mingw-w64-v$VER_MINGW64.tar.bz2 http://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v$VER_MINGW64.tar.bz2
	tar xjf mingw-w64-v$VER_MINGW64.tar.bz2
fi

