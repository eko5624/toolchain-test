#!/bin/bash
set -e

TOP_DIR=$(pwd)

# Speed up the process
# Env Var NUMJOBS overrides automatic detection
MJOBS=$(grep -c processor /proc/cpuinfo)

CFLAGS="-pipe -O2"
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
#git clone https://github.com/gcc-mirror/gcc.git --branch master --depth 1

#libiconv
wget -c -O libiconv-1.17.tar.gz https://ftp.gnu.org/gnu/libiconv/libiconv-1.17.tar.gz
tar xzf libiconv-1.17.tar.gz

#gdb
wget -c -O gdb-13.1.tar.xz https://ftp.gnu.org/gnu/gdb/gdb-13.1.tar.xz
xz -c -d gdb-13.1.tar.xz | tar xf -

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
#git clone https://github.com/mingw-w64/mingw-w64.git --branch master --depth 1

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

#make
wget -c -O make-4.4.1.tar.gz https://ftp.gnu.org/pub/gnu/make/make-4.4.1.tar.gz
tar xzf make-4.4.1.tar.gz

#m4
wget -c -O m4-1.4.19.tar.xz https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz
xz -c -d m4-1.4.19.tar.xz | tar xf -

#libtool
wget -c -O libtool-2.4.7.tar.xz https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.xz
xz -c -d libtool-2.4.7.tar.xz | tar xf -

#cmake
wget -c -O cmake-3.26.4.tar.gz https://github.com/Kitware/CMake/archive/refs/tags/v3.26.4.tar.gz
tar xzf cmake-3.26.4.tar.gz

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
  --enable-deterministic-archives \
  --disable-{gdb,gdbserver}
make -j$MJOBS
make install
rm $M_TARGET/lib/bfd-plugins/libdep.a

echo "building mingw-w64-headers"
echo "======================="
cd $M_SOURCE
git clone https://github.com/mingw-w64/mingw-w64.git
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
  --prefix=$M_TARGET \
  --enable-sdk=all \
  --with-default-win32-winnt=0x601 \
  --with-default-msvcrt=ucrt \
  --enable-idl \
  --without-widl
make -j$MJOBS
make install
rm $M_TARGET/include/pthread_signal.h
rm $M_TARGET/include/pthread_time.h
rm $M_TARGET/include/pthread_unistd.h
rm -rf $M_SOURCE/mingw-w64
#cd $M_TARGET
#ln -s $MINGW_TRIPLE mingw

echo "building gmp"
echo "======================="
cd $M_BUILD
mkdir gmp-build
cd gmp-build
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-gmp/do-not-use-dllimport.diff
cd $M_SOURCE/gmp-6.2.1
[[ -d ../stash ]] && rm -rf ../stash
mkdir ../stash
cp config.{guess,sub} ../stash
patch -p2 -i $M_BUILD/gmp-build/do-not-use-dllimport.diff
autoreconf -fiv
cp -f ../stash/config.{guess,sub} .
cd $M_BUILD/gmp-build
$M_SOURCE/gmp-6.2.1/configure \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_BUILD/for_target \
  --enable-fat \
  --enable-cxx \
  --enable-static \
  --disable-shared
make -j$MJOBS
make install

echo "building mpfr"
echo "======================="
cd $M_BUILD
mkdir mpfr-build
cd mpfr-build
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-mpfr/patches.diff
cd $M_SOURCE/mpfr-4.2.0
patch -p1 -i $M_BUILD/mpfr-build/patches.diff
autoreconf -fiv
cd $M_BUILD/mpfr-build
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
  --with-mpfr=$M_BUILD/for_target \
  --enable-static \
  --disable-shared
make -j$MJOBS
make install

echo "building isl"
echo "======================="
cd $M_BUILD
mkdir isl-build
cd isl-build
curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-isl/isl-0.14.1-no-undefined.patch
cd $M_SOURCE/isl-0.24
patch -p1 -i $M_BUILD/isl-build/isl-0.14.1-no-undefined.patch
autoreconf -fi
cd $M_BUILD/isl-build
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
cd $M_SOURCE
git clone https://github.com/mingw-w64/mingw-w64.git
cd $M_BUILD
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
git apply $M_BUILD/crt-build/9001-crt-Mark-atexit-as-DATA-because-it-s-always-overridd.patch
git apply $M_BUILD/crt-build/9002-crt-Provide-wrappers-for-exit-in-libmingwex.patch
git apply $M_BUILD/crt-build/9003-crt-Implement-standard-conforming-termination-suppor.patch
git apply $M_BUILD/crt-build/9004-crt-Copy-clock-and-nanosleep-from-winpthreads.patch
(cd mingw-w64-crt && automake)
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
ar rcs $M_TARGET/lib/libssp.a
ar rcs $M_TARGET/lib/libssp_nonshared.a
rm -rf $M_SOURCE/mingw-w64

echo "building gendef"
echo "======================="
cd $M_SOURCE
git clone https://github.com/mingw-w64/mingw-w64.git
cd $M_BUILD
mkdir gendef-build
cd gendef-build
$M_SOURCE/mingw-w64/mingw-w64-tools/gendef/configure \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_TARGET
make -j$MJOBS
make install
rm -rf $M_SOURCE/mingw-w64

echo "building winpthreads"
echo "======================="
cd $M_SOURCE
git clone https://github.com/mingw-w64/mingw-w64.git
cd $M_BUILD
mkdir winpthreads-build
cd winpthreads-build
curl -OL https://raw.githubusercontent.com/lhmouse/MINGW-packages/master/mingw-w64-winpthreads-git/0001-Define-__-de-register_frame_info-in-fake-libgcc_s.patch
cd $M_SOURCE/mingw-w64
git apply $M_BUILD/winpthreads-build/0001-Define-__-de-register_frame_info-in-fake-libgcc_s.patch
cd $M_SOURCE/mingw-w64/mingw-w64-libraries/winpthreads
autoreconf -vfi
cd $M_BUILD/winpthreads-build
unset CC
$M_SOURCE/mingw-w64/mingw-w64-libraries/winpthreads/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET \
  --enable-shared \
  --enable-static
make -j$MJOBS
make install
rm -rf $M_SOURCE/mingw-w64
#cp $M_TARGET/$MINGW_TRIPLE/bin/libwinpthread-1.dll $M_TARGET/bin

#echo "building dlfcn-win32"
#echo "======================="
#cd $M_BUILD
#mkdir libdl-build
#cmake -G Ninja -H$M_SOURCE/dlfcn-win32 -B$M_BUILD/libdl-build \
#  -DCMAKE_INSTALL_PREFIX=$TOP_DIR/opt \
#  -DCMAKE_TOOLCHAIN_FILE=$TOP_DIR/toolchain.cmake \
#  -DBUILD_SHARED_LIBS=OFF \
#  -DCMAKE_BUILD_TYPE=Release \
##  -DBUILD_TESTS=OFF
#ninja -j$MJOBS -C $M_BUILD/libdl-build
#ninja install -C $M_BUILD/libdl-build

#echo "building zlib"
#echo "======================="
#cd $M_BUILD
#mkdir zlib-build
#cd zlib-build
#curl -OL https://raw.githubusercontent.com/shinchiro/mpv-winbuild-cmake/master/packages/zlib-1-win32-static.patch
#patch -d $M_SOURCE/zlib-1.2.13 -p1 < $M_BUILD/zlib-build/zlib-1-win32-static.patch
#CHOST=$MINGW_TRIPLE $M_SOURCE/zlib-1.2.13/configure \
#  --prefix=$TOP_DIR/opt \
#  --static
#make -j$MJOBS
#make install

#echo "building libiconv"
#echo "======================="
#cd $M_BUILD
#mkdir libiconv-build
#cd libiconv-build
#curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-libiconv/0002-fix-cr-for-awk-in-configure.all.patch
#curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-libiconv/0003-add-cp65001-as-utf8-alias.patch
#curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-libiconv/0004-fix-makefile-devel-assuming-gcc.patch
#curl -OL https://raw.githubusercontent.com/msys2/MINGW-packages/master/mingw-w64-libiconv/fix-pointer-buf.patch
#cd $M_SOURCE/libiconv-1.17
#patch -Nbp1 -i $M_BUILD/libiconv-build/0002-fix-cr-for-awk-in-configure.all.patch
#patch -Nbp1 -i $M_BUILD/libiconv-build/fix-pointer-buf.patch
#patch -Nbp1 -i $M_BUILD/libiconv-build/0003-add-cp65001-as-utf8-alias.patch
#patch -Nbp1 -i $M_BUILD/libiconv-build/0004-fix-makefile-devel-assuming-gcc.patch
#make -f Makefile.devel all
#cd $M_BUILD/libiconv-build
#$M_SOURCE/libiconv-1.17/configure \
#  --build=x86_64-pc-linux-gnu \
#  --host=$MINGW_TRIPLE \
#  --target=$MINGW_TRIPLE \
#  --prefix=$TOP_DIR/opt \
#  --enable-static \
#  --enable-shared \
#  --enable-extra-encodings \
#  --enable-relocatable \
#  --disable-rpath \
#  --enable-silent-rules \
#  --enable-nls
#make -j$MJOBS
#make install

#cat <<EOF >$TOP_DIR/opt/lib/pkgconfig/iconv.pc
#prefix=$TOP_DIR/opt
#exec_prefix=${prefix}
#libdir=${exec_prefix}/lib
#includedir=${prefix}/include

#Name: iconv
#Description: libiconv
#URL: https://www.gnu.org/software/libiconv/
#Version: 1.17
#Libs: -L${libdir} -liconv
#Cflags: -I${includedir}
#EOF

echo "building gcc"
echo "======================="
cd $M_BUILD
mkdir gcc-build
cd gcc-build
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0001-Cygwin-avoid-installing-libffi-V2.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0002-Cygwin-use-SysV-ABI-on-x86_64.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0003-Cygwin-MinGW-Do-not-version-lto-plugins.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0004-Cygwin-add-dummy-pthread-tsaware-and-large-address-a.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0005-Cygwin-handle-dllimport-properly-in-medium-model-V2.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0006-Cygwin-MinGW-skip-test.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0007-Cygwin-define-RTS_CONTROL_ENABLE-and-DTR_CONTROL_ENA.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0008-Cygwin-fix-some-implicit-declaration-warnings.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0009-Cygwin-__cxa-atexit.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0010-Cygwin-prevent-modules-from-being-unloaded-before-th.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0011-Cygwin-libgomp-soname.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0012-Cygwin-g-time.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0013-Cygwin-newlib-ftm.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0014-Cygwin-define-STD_UNIX.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0015-libstdc-use-lt_host_flags-for-libstdc-.la.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0016-libstdc-regenerate-src-Makefile.in-for-lt_host_flags.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0017-libstdc-use-a-link-test-to-test-for-Wl-z-relro.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0018-libstdc-regenerate-configure.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0130-libstdc++-in-out.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0140-gcc-8.2.0-diagnostic-color.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0150-Handle-spaces-in-path-for-default-manifest.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0151-makedeps-properly-handle-win-paths.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0152-gcc-9-branch-clone_function_name_1-Retain-any-stdcall-suffix.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0153-libgomp-Don-t-hard-code-MS-printf-attributes.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0154-Windows-New-feature-to-allow-overriding.patch
curl -OL https://raw.githubusercontent.com/msys2/MSYS2-packages/master/mingw-w64-cross-gcc/0155-gcc-config-i386-mingw32.h-Ensure-lmsvcrt-precede-lke.patch

cd $M_SOURCE/gcc-13.1.0

#do not install libiberty
sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
# hack! - some configure tests for header files using "$CPP $CPPFLAGS"
#sed -i "/ac_cpp=/s/\$CPPFLAGS/\$CPPFLAGS -O2/" {libiberty,gcc}/configure

# Cygwin patches
patch -Nbp1 -i $M_BUILD/gcc-build/0004-Cygwin-add-dummy-pthread-tsaware-and-large-address-a.patch

# use built-in SSP with Cygwin 2.10
# FIXME: --disable-libssp should suffice in GCC 8
export gcc_cv_libc_provides_ssp=yes

cd $M_BUILD/gcc-build
$M_SOURCE/gcc-13.1.0/configure \
  --build=x86_64-pc-linux-gnu \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_TARGET \
  --libexecdir=$M_TARGET/lib \
  --with-{gmp,mpfr,mpc,isl}=$M_BUILD/for_target \
  --disable-bootstrap \
  --with-arch=x86-64 \
  --with-tune=generic \
  --enable-languages=c,c++ \
  --enable-shared \
  --enable-static \
  --enable-threads=mcf \
  --enable-graphite \
  --enable-fully-dynamic-string \
  --enable-libstdcxx-filesystem-ts=yes \
  --enable-libstdcxx-time=yes \
  --disable-libstdcxx-pch \
  --disable-libstdcxx-debug \
  --enable-version-specific-runtime-libs \
  --enable-lto \
  --enable-libgomp \
  --disable-multilib \
  --enable-checking=release \
  --disable-rpath \
  --disable-win32-registry \
  --disable-werror \
  --disable-symvers \
  --with-libiconv \
  --with-gnu-as \
  --with-gnu-ld \
  --with-pkgversion="GCC with MCF thread model" \
  LDFLAGS=-pthread
make -j$MJOBS all
make install
mv $M_TARGET/lib/gcc/x86_64-w64-mingw32/lib/libgcc_s.a $M_TARGET/lib/gcc/x86_64-w64-mingw32/13.1.0/
mv $M_TARGET/lib/gcc/x86_64-w64-mingw32/libgcc*.dll $M_TARGET/lib/gcc/x86_64-w64-mingw32/13.1.0/
#cp $M_TARGET/lib/gcc/x86_64-w64-mingw32/13.1.0/*plugin*.dll $M_TARGET/lib/bfd-plugins/
cp $M_TARGET/bin/gcc.exe $M_TARGET/bin/cc.exe
cp $M_TARGET/bin/$MINGW_TRIPLE-gcc.exe $M_TARGET/bin/$MINGW_TRIPLE-cc.exe

echo "building mcfgthread"
echo "======================="
cd $M_SOURCE/mcfgthread
git reset --hard
git clean -fdx
autoreconf -ivf
cd $M_BUILD
mkdir mcfgthread-build
cd mcfgthread-build
CFLAGS+=' -Os -g'
$M_SOURCE/mcfgthread/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_TARGET \
  --disable-pch
make -j$MJOBS
make install
#cp $M_TARGET/$MINGW_TRIPLE/bin/libmcfgthread-1.dll $M_TARGET/bin

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
