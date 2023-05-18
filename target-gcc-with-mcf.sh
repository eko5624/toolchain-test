#!/bin/bash
set -e

TOP_DIR=$(pwd)

# Speed up the process
# Env Var NUMJOBS overrides automatic detection
MJOBS=$(grep -c processor /proc/cpuinfo)

#CFLAGS="-pipe -O2"
MINGW_TRIPLE="x86_64-w64-mingw32"

export CFLAGS
export CXXFLAGS=$CFLAGS
export MINGW_TRIPLE

export M_ROOT=$(pwd)
export M_SOURCE=$M_ROOT/source
export M_BUILD=$M_ROOT/build
export M_CROSS=$M_ROOT/cross
export M_TARGET=$M_ROOT/target

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

export PATH="$M_CROSS/bin:$PATH"

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

#mcfgthread
git clone https://github.com/lhmouse/mcfgthread.git --branch master --depth 1


echo "building gendef"
echo "======================="
cd $M_BUILD
mkdir gendef-build
cd gendef-build
$M_SOURCE/mingw-w64/mingw-w64-tools/gendef/configure \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_TARGET
make -j$MJOBS
make install
cd $M_BUILD

echo "building mingw-w64-headers"
echo "======================="
mkdir headers-build
cd headers-build
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-headers-git/0001-Allow-to-use-bessel-and-complex-functions-without-un.patch
  
cd $M_SOURCE/mingw-w64
git reset --hard
git clean -fdx
git apply $M_BUILD/headers-build/0001-Allow-to-use-bessel-and-complex-functions-without-un.patch
cd $M_SOURCE/mingw-w64/mingw-w64-headers
touch include/windows.*.h include/wincrypt.h include/prsht.h
$M_SOURCE/mingw-w64/mingw-w64-headers/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET \
  --enable-sdk=all \
  --with-default-win32-winnt=0x603 \
  --with-default-msvcrt=ucrt \
  --enable-idl \
  --without-widl
make -j$MJOBS
make install
rm $M_TARGET/include/pthread_signal.h
rm $M_TARGET/include/pthread_time.h
rm $M_TARGET/include/pthread_unistd.h
cd $M_BUILD

echo "building binutils"
echo "======================="
mkdir binutils-build
cd binutils-build
$M_SOURCE/binutils-2.40/configure \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_TARGET \
  --with-sysroot=$M_TARGET \
  --enable-64-bit-bfd \
  --enable-install-libiberty \
  --enable-plugins \
  --enable-lto \
  --disable-nls \
  --disable-werror \
  --disable-shared
make -j$MJOBS
make install
rm $M_TARGET/lib/bfd-plugins/libdep.a
cd $M_BUILD

echo "building mingw-w64-crt"
echo "======================="
mkdir crt-build

cd crt-build
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-crt-git/0001-Allow-to-use-bessel-and-complex-functions-without-un.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-crt-git/9001-crt-Mark-atexit-as-DATA-because-it-s-always-overridd.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-crt-git/9002-crt-Provide-wrappers-for-exit-in-libmingwex.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-crt-git/9003-crt-Implement-standard-conforming-termination-suppor.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-crt-git/9004-crt-Copy-clock-and-nanosleep-from-winpthreads.patch

cd $M_SOURCE/mingw-w64
git reset --hard
git clean -fdx

#git apply $M_BUILD/crt-build/9001-crt-Mark-atexit-as-DATA-because-it-s-always-overridd.patch
#git apply $M_BUILD/crt-build/9002-crt-Provide-wrappers-for-exit-in-libmingwex.patch
#git apply $M_BUILD/crt-build/9003-crt-Implement-standard-conforming-termination-suppor.patch
#git apply $M_BUILD/crt-build/9004-crt-Copy-clock-and-nanosleep-from-winpthreads.patch
#(cd mingw-w64-crt && automake)

git apply $M_BUILD/crt-build/0001-Allow-to-use-bessel-and-complex-functions-without-un.patch

cd $M_BUILD/crt-build
$M_SOURCE/mingw-w64/mingw-w64-crt/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET \
  --with-default-msvcrt=ucrt \
  --enable-wildcard \
  --disable-dependency-tracking \
  --enable-lib64 \
  --disable-lib32
make -j$MJOBS
make install
# Create empty dummy archives, to avoid failing when the compiler driver
# adds -lssp -lssh_nonshared when linking.
ar rcs $M_TARGET/$MINGW_TRIPLE/lib/libssp.a
ar rcs $M_TARGET/$MINGW_TRIPLE/lib/libssp_nonshared.a
cd $M_BUILD

echo "building mcfgthread"
echo "======================="
cd $M_SOURCE/mcfgthread
git reset --hard
git clean -fdx
autoreconf -ivf
mkdir mcfgthread-build
cd mcfgthread-build
$M_SOURCE/mcfgthread/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET \
  --disable-pch
make -j$MJOBS
make install
cd $M_BUILD

echo "building winpthreads"
echo "======================="
mkdir winpthreads-build
cd winpthreads-build
$M_SOURCE/mingw-w64/mingw-w64-libraries/winpthreads/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET \
  --enable-lib64 \
  --disable-lib32
make -j$MJOBS
make install
cd $M_BUILD

echo "building gmp"
echo "======================="
mkdir gmp-build
cd gmp-build
$M_SOURCE/gmp-6.2.1/configure \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_BUILD/for_target \
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
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_BUILD/for_target \
  --with-gmp=$M_BUILD/for_target \
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
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_BUILD/for_target \
  --with-gmp=$M_BUILD/for_target \
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
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_BUILD/for_target \
  --with-gmp-prefix=$M_BUILD/for_target \
  --enable-static \
  --disable-shared
make -j$MJOBS
make install
cd $M_BUILD

echo "building gcc"
echo "======================="
mkdir gcc-build
cd gcc-build
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0002-Relocate-libintl.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0003-Windows-Follow-Posix-dir-exists-semantics-more-close.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0005-Windows-Don-t-ignore-native-system-header-dir.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0006-Windows-New-feature-to-allow-overriding.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0007-Build-EXTRA_GNATTOOLS-for-Ada.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0008-Prettify-linking-no-undefined.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0011-Enable-shared-gnat-implib.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0012-Handle-spaces-in-path-for-default-manifest.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0014-gcc-9-branch-clone_function_name_1-Retain-any-stdcall-suffix.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0020-libgomp-Don-t-hard-code-MS-printf-attributes.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0021-PR14940-Allow-a-PCH-to-be-mapped-to-a-different-addr.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0140-gcc-diagnostic-color.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0200-add-m-no-align-vector-insn-option-for-i386.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0300-override-builtin-printf-format.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-gcc/0400-gcc-Make-stupid-AT-T-syntax-not-default.patch
curl -OL https://github.com/gcc-mirror/gcc/commit/1c118c9970600117700cc12284587e0238de6bbe.patch

cd $M_SOURCE/gcc-13.1.0
patch -Nbp1 -i $M_BUILD/gcc-build/0002-Relocate-libintl.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0003-Windows-Follow-Posix-dir-exists-semantics-more-close.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0005-Windows-Don-t-ignore-native-system-header-dir.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0006-Windows-New-feature-to-allow-overriding.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0007-Build-EXTRA_GNATTOOLS-for-Ada.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0008-Prettify-linking-no-undefined.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0011-Enable-shared-gnat-implib.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0012-Handle-spaces-in-path-for-default-manifest.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0014-gcc-9-branch-clone_function_name_1-Retain-any-stdcall-suffix.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0020-libgomp-Don-t-hard-code-MS-printf-attributes.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0021-PR14940-Allow-a-PCH-to-be-mapped-to-a-different-addr.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0140-gcc-diagnostic-color.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0200-add-m-no-align-vector-insn-option-for-i386.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0300-override-builtin-printf-format.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0400-gcc-Make-stupid-AT-T-syntax-not-default.patch

# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=109670#c7
# https://github.com/gcc-mirror/gcc/commit/1c118c9970600117700cc12284587e0238de6bbe
patch -R -Nbp1 -i $M_BUILD/gcc-build/1c118c9970600117700cc12284587e0238de6bbe.patch

# do not expect ${prefix}/mingw symlink - this should be superceded by
# 0005-Windows-Don-t-ignore-native-system-header-dir.patch .. but isn't!
#sed -i 's#${prefix}/mingw#${prefix}#g' configure

# change hardcoded /mingw prefix to the real prefix .. isn't this rubbish?
# it might work at build time and could be important there but beyond that?!
#export MINGW_NATIVE_PREFIX=$M_TARGET
#sed -i "s#/mingw/#${MINGW_NATIVE_PREFIX}/#g" gcc/config/i386/mingw32.h

# so libgomp DLL gets built despide static libdl
#export lt_cv_deplibs_check_method='pass_all'

# In addition adaint.c does `#include <accctrl.h>` which pulls in msxml.h, hacky hack:
#CPPFLAGS+=" -DCOM_NO_WINDOWS_H"

$M_SOURCE/gcc-13.1.0/configure \
  --build=x86_64-pc-linux-gnu \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_TARGET \
  --with-native-system-header-dir=$M_TARGET/include \
  --libexecdir=$M_TARGET/lib \
  --with-{gmp,mpfr,mpc,isl}=$M_BUILD/for_target \
  --disable-libssp \
  --disable-rpath \
  --disable-multilib \
  --enable-languages=c,c++ \
  --disable-nls \
  --disable-werror \
  --enable-shared \
  --enable-static \
  --enable-libatomic \
  --disable-libstdcxx-pch \
  --disable-win32-registry \
  --with-tune=generic \
  --enable-threads=mcf \
  --enable-lto \
  --enable-checking=release \
  --with-pkgversion="GCC with MCF thread model"
make -j$MJOBS
make install

cp $M_TARGET/lib/gcc/x86_64-w64-mingw32/13.1.0/liblto_plugin.dll  $M_TARGET//lib/bfd-plugins
cd $M_TARGET/bin
ln -s gcc.exe cc.exe

