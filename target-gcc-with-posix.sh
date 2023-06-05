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

#libdl (dlfcn-win32)
git clone https://github.com/dlfcn-win32/dlfcn-win32 --branch master --depth 1

#zlib
wget -c -O zlib-1.2.13.tar.gz https://github.com/madler/zlib/archive/refs/tags/v1.2.13.tar.gz
tar xzf zlib-1.2.13.tar.gz

#zstd
wget -c -O zstd-1.5.5.tar.gz https://github.com/facebook/zstd/archive/refs/tags/v1.5.5.tar.gz
tar xzf zstd-1.5.5.tar.gz

#gperf
wget -c -O gperf-3.1.tar.gz https://ftp.gnu.org/pub/gnu/gperf/gperf-3.1.tar.gz
tar xzf gperf-3.1.tar.gz

#libiconv
wget -c -O libiconv-1.17.tar.gz https://ftp.gnu.org/gnu/libiconv/libiconv-1.17.tar.gz
tar xzf libiconv-1.17.tar.gz

#make
wget -c -O make-4.4.1.tar.gz https://ftp.gnu.org/pub/gnu/make/make-4.4.1.tar.gz
tar xzf make-4.4.1.tar.gz

echo "building binutils"
echo "======================="
cd $M_BUILD
mkdir binutils-build
cd binutils-build
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-binutils/0002-check-for-unusual-file-harder.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-binutils/0003-opcodes-i386-dis-Use-Intel-syntax-by-default.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-binutils/0010-bfd-Increase-_bfd_coff_max_nscns-to-65279.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-binutils/0110-binutils-mingw-gnu-print.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-binutils/0410-windres-handle-spaces.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-binutils/0500-fix-weak-undef-symbols-after-image-base-change.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-binutils/2001-ld-option-to-move-default-bases-under-4GB.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-binutils/2003-Restore-old-behaviour-of-windres-so-that-options-con.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-binutils/3001-try-fix-compare_section-abort.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-binutils/bfd-real-fopen-handle-windows-nul.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-binutils/decorated-symbols-in-import-libs.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-binutils/libiberty-unlink-handle-windows-nul.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-binutils/reproducible-import-libraries.patch
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-binutils/specify-timestamp.patch

cd $M_SOURCE/binutils-2.40
patch -p1 -i $M_BUILD/binutils-build/0002-check-for-unusual-file-harder.patch
patch -p1 -i $M_BUILD/binutils-build/0010-bfd-Increase-_bfd_coff_max_nscns-to-65279.patch
patch -p1 -i $M_BUILD/binutils-build/0110-binutils-mingw-gnu-print.patch
patch -p1 -i $M_BUILD/binutils-build/0003-opcodes-i386-dis-Use-Intel-syntax-by-default.patch
patch -p1 -i $M_BUILD/binutils-build/2001-ld-option-to-move-default-bases-under-4GB.patch
patch -R -p1 -i $M_BUILD/binutils-build/2003-Restore-old-behaviour-of-windres-so-that-options-con.patch
patch -p2 -i $M_BUILD/binutils-build/reproducible-import-libraries.patch
patch -p2 -i $M_BUILD/binutils-build/specify-timestamp.patch
patch -p1 -i $M_BUILD/binutils-build/libiberty-unlink-handle-windows-nul.patch
patch -p1 -i $M_BUILD/binutils-build/bfd-real-fopen-handle-windows-nul.patch
patch -p1 -i $M_BUILD/binutils-build/3001-try-fix-compare_section-abort.patch

cd $M_BUILD/binutils-build
$M_SOURCE/binutils-2.40/configure \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_TARGET \
  --with-sysroot=$M_TARGET \
  --enable-64-bit-bfd \
  --enable-install-libiberty \
  --enable-plugins \
  --enable-lto \
  --enable-nls \
  --disable-rpath \
  --disable-multilib \
  --disable-werror \
  --disable-shared \
  --enable-deterministic-archives
make -j$MJOBS
make install
rm $M_TARGET/lib/bfd-plugins/libdep.a

echo "building mingw-w64-headers"
echo "======================="
cd $M_BUILD
mkdir headers-build
cd headers-build
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-headers-git/0001-Allow-to-use-bessel-and-complex-functions-without-un.patch

cd $M_SOURCE/mingw-w64
git reset --hard
git clean -fdx
git apply $M_BUILD/headers-build/0001-Allow-to-use-bessel-and-complex-functions-without-un.patch
cd $M_SOURCE/mingw-w64/mingw-w64-headers
touch include/windows.*.h include/wincrypt.h include/prsht.h
cd $M_BUILD/headers-build
$M_SOURCE/mingw-w64/mingw-w64-headers/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET/$MINGW_TRIPLE \
  --enable-sdk=all \
  --with-default-win32-winnt=0x603 \
  --with-default-msvcrt=ucrt \
  --enable-idl \
  --without-widl
make -j$MJOBS
make install
rm $M_TARGET/$MINGW_TRIPLE/include/pthread_signal.h
rm $M_TARGET/$MINGW_TRIPLE/include/pthread_time.h
rm $M_TARGET/$MINGW_TRIPLE/include/pthread_unistd.h
cd $M_TARGET
ln -s $MINGW_TRIPLE mingw

echo "building gmp"
echo "======================="
cd $M_BUILD
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

echo "building mpfr"
echo "======================="
cd $M_BUILD
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

echo "building MPC"
echo "======================="
cd $M_BUILD
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

echo "building isl"
echo "======================="
cd $M_BUILD
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

echo "building mingw-w64-crt"
echo "======================="
cd $M_BUILD
mkdir crt-build
cd crt-build
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-crt-git/0001-Allow-to-use-bessel-and-complex-functions-without-un.patch
cd $M_SOURCE/mingw-w64
git reset --hard
git clean -fdx
git apply $M_BUILD/crt-build/0001-Allow-to-use-bessel-and-complex-functions-without-un.patch

cd $M_BUILD/crt-build
$M_SOURCE/mingw-w64/mingw-w64-crt/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET/$MINGW_TRIPLE \
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

echo "building winpthreads"
echo "======================="
cd $M_BUILD
mkdir winpthreads-build
cd winpthreads-build
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-winpthreads-git/0001-Define-__-de-register_frame_info-in-fake-libgcc_s.patch
cd $M_SOURCE/mingw-w64
git apply $M_BUILD/winpthreads-build/0001-Define-__-de-register_frame_info-in-fake-libgcc_s.patch
cd $M_SOURCE/mingw-w64/mingw-w64-libraries/winpthreads
autoreconf -vfi
cd $M_BUILD/winpthreads-build
$M_SOURCE/mingw-w64/mingw-w64-libraries/winpthreads/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET/$MINGW_TRIPLE \
  --disable-shared \
  --enable-static
make -j$MJOBS
make install
mv $M_TARGET/$MINGW_TRIPLE/bin/libwinpthread-1.dll $M_TARGET/bin/

echo "building dlfcn-win32"
echo "======================="
cd $M_BUILD
mkdir libdl-build
cmake -G Ninja -H$M_SOURCE/dlfcn-win32 -B$M_BUILD/libdl-build \
  -DCMAKE_INSTALL_PREFIX=$TOP_DIR/opt \
  -DCMAKE_TOOLCHAIN_FILE=$TOP_DIR/toolchain.cmake \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTS=OFF
ninja -j$MJOBS -C $M_BUILD/libdl-build
ninja install -C $M_BUILD/libdl-build

echo "building zlib"
echo "======================="
cd $M_BUILD
mkdir zlib-build
cd zlib-build
curl -OL https://raw.githubusercontent.com/shinchiro/mpv-winbuild-cmake/master/packages/zlib-1-win32-static.patch
patch -d $M_SOURCE/zlib-1.2.13 -p1 < $M_BUILD/zlib-build/zlib-1-win32-static.patch
CHOST=$MINGW_TRIPLE $M_SOURCE/zlib-1.2.13/configure \
  --prefix=$TOP_DIR/opt \
  --static
make -j$MJOBS
make install

echo "building libiconv"
echo "======================="
cd $M_BUILD
mkdir libiconv-build
cd libiconv-build
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-libiconv/0002-fix-cr-for-awk-in-configure.all.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-libiconv/0003-add-cp65001-as-utf8-alias.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-libiconv/0004-fix-makefile-devel-assuming-gcc.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-libiconv/fix-pointer-buf.patch
cd $M_SOURCE/libiconv-1.17
patch -Nbp1 -i $M_BUILD/libiconv-build/0002-fix-cr-for-awk-in-configure.all.patch
patch -Nbp1 -i $M_BUILD/libiconv-build/fix-pointer-buf.patch
patch -Nbp1 -i $M_BUILD/libiconv-build/0003-add-cp65001-as-utf8-alias.patch
patch -Nbp1 -i $M_BUILD/libiconv-build/0004-fix-makefile-devel-assuming-gcc.patch
make -f Makefile.devel all
cd $M_BUILD/libiconv-build
$M_SOURCE/libiconv-1.17/configure \
  --build=x86_64-pc-linux-gnu \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$TOP_DIR/opt \
  --enable-static \
  --enable-shared \
  --enable-extra-encodings \
  --enable-relocatable \
  --disable-rpath \
  --enable-silent-rules \
  --enable-nls
make -j$MJOBS
make install

cat <<EOF >$TOP_DIR/opt/lib/pkgconfig/iconv.pc
prefix=$TOP_DIR/opt
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: iconv
Description: libiconv
URL: https://www.gnu.org/software/libiconv/
Version: 1.17
Libs: -L${libdir} -liconv
Cflags: -I${includedir}
EOF

echo "building gcc"
echo "======================="
cd $M_BUILD
mkdir gcc-build
cd gcc-build
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gcc/0002-Relocate-libintl.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gcc/0003-Windows-Follow-Posix-dir-exists-semantics-more-close.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gcc/0006-Windows-New-feature-to-allow-overriding.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gcc/0007-Build-EXTRA_GNATTOOLS-for-Ada.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gcc/0008-Prettify-linking-no-undefined.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gcc/0011-Enable-shared-gnat-implib.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gcc/0012-Handle-spaces-in-path-for-default-manifest.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gcc/0014-gcc-9-branch-clone_function_name_1-Retain-any-stdcall-suffix.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gcc/0020-libgomp-Don-t-hard-code-MS-printf-attributes.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gcc/0021-PR14940-Allow-a-PCH-to-be-mapped-to-a-different-addr.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gcc/0022-fix-radix-sort-on-32bit-platforms.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gcc/0140-gcc-diagnostic-color.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gcc/0200-add-m-no-align-vector-insn-option-for-i386.patch
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gcc/0300-override-builtin-printf-format.patch

cd $M_SOURCE/gcc-13.1.0
#git reset --hard
#git clean -fdx
patch -Nbp1 -i $M_BUILD/gcc-build/0002-Relocate-libintl.patch
patch -Nbp1 -i $M_BUILD/gcc-build/0003-Windows-Follow-Posix-dir-exists-semantics-more-close.patch
#patch -Nbp1 -i $M_BUILD/gcc-build/0005-Windows-Don-t-ignore-native-system-header-dir.patch
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
patch -Nbp1 -i $M_BUILD/gcc-build/0022-fix-radix-sort-on-32bit-platforms.patch

# so libgomp DLL gets built despide static libdl
export lt_cv_deplibs_check_method='pass_all'

# In addition adaint.c does `#include <accctrl.h>` which pulls in msxml.h, hacky hack:
CPPFLAGS+=" -DCOM_NO_WINDOWS_H"
cd gcc-build
CFLAGS+=" -I$TOP_DIR/opt/include -Wno-int-conversion" 
CXXFLAGS+=" -Wno-int-conversion" 
LDFLAGS=-pthread
$M_SOURCE/gcc-13.1.0/configure \
  --build=x86_64-pc-linux-gnu \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_TARGET \
  --with-sysroot=$M_TARGET \
  --with-{gmp,mpfr,mpc,isl}=$M_BUILD/for_target \
  --with-tune=generic \
  --with-arch=nocona \
  --enable-checking=release \
  --enable-threads=posix \
  --disable-sjlj-exceptions \
  --disable-libunwind-exceptions \
  --disable-serial-configure \
  --disable-bootstrap \
  --enable-host-shared \
  --disable-default-ssp \
  --disable-rpath \
  --disable-libstdcxx-debug \
  --disable-version-specific-runtime-libs \
  --disable-symvers \
  --enable-shared \
  --enable-static \
  --enable-languages=c,c++ \
  --disable-gold \
  --disable-nls \
  --disable-stage1-checking \
  --disable-win32-registry \
  --disable-multilib \
  --enable-ld \
  --enable-libatomic \
  --enable-libquadmath \
  --enable-lto \
  --enable-fully-dynamic-string \
  --enable-libgomp \
  --enable-graphite \
  --enable-mingw-wildcard \
  --enable-libstdcxx-time \
  --disable-libstdcxx-pch \
  --disable-libstdcxx-backtrace \
  --enable-install-libiberty \
  --enable-__cxa_atexit \
  --without-included-gettext \
  --with-diagnostics-color=auto \
  --enable-clocale=generic \
  --with-libiconv \
  --with-boot-ldflags="-static-libstdc++" \
  --with-stage1-ldflags="-static-libstdc++" \
  --with-pkgversion="GCC with posix thread model"
make -j$MJOBS
make install
mv $M_TARGET/lib/libgcc_s_seh-1.dll $M_TARGET/bin/
cp $M_TARGET/bin/gcc.exe $M_TARGET/bin/cc.exe

echo "building make"
echo "======================="
cd $M_BUILD
mkdir make-build
cd make-build
$M_SOURCE/make-4.4.1/configure \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_TARGET
make -j$MJOBS
make install
cp $M_TARGET/bin/make.exe $M_TARGET/bin/mingw32-make.exe
cd $M_TARGET
rm -f mingw
