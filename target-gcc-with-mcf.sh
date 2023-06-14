#!/bin/bash
set -e

TOP_DIR=$(pwd)

# Speed up the process
# Env Var NUMJOBS overrides automatic detection
MJOBS=$(grep -c processor /proc/cpuinfo)

#CFLAGS="-pipe -O2"
#export CFLAGS
#export CXXFLAGS=$CFLAGS
MINGW_TRIPLE="x86_64-w64-mingw32"
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
#wget -c -O gdb-13.1.tar.xz https://ftp.gnu.org/gnu/gdb/gdb-13.1.tar.xz
#xz -c -d gdb-13.1.tar.xz | tar xf -

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

#mman-win32
git clone https://github.com/alitrack/mman-win32 --branch master --depth 1

#zlib
wget -c -O zlib-1.2.13.tar.gz https://github.com/madler/zlib/archive/refs/tags/v1.2.13.tar.gz
tar xzf zlib-1.2.13.tar.gz

#zstd
#wget -c -O zstd-1.5.5.tar.gz https://github.com/facebook/zstd/archive/refs/tags/v1.5.5.tar.gz
#tar xzf zstd-1.5.5.tar.gz

#gperf
#wget -c -O gperf-3.1.tar.gz https://ftp.gnu.org/pub/gnu/gperf/gperf-3.1.tar.gz
#tar xzf gperf-3.1.tar.gz

#make
wget -c -O make-4.4.1.tar.gz https://ftp.gnu.org/pub/gnu/make/make-4.4.1.tar.gz
tar xzf make-4.4.1.tar.gz

#pkgconf
git clone https://github.com/pkgconf/pkgconf --branch pkgconf-1.9.5

#m4
#wget -c -O m4-1.4.19.tar.xz https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz
#xz -c -d m4-1.4.19.tar.xz | tar xf -

#libtool
#wget -c -O libtool-2.4.7.tar.xz https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.xz
#xz -c -d libtool-2.4.7.tar.xz | tar xf -

#cmake
#wget -c -O cmake-3.26.4.tar.gz https://github.com/Kitware/CMake/archive/refs/tags/v3.26.4.tar.gz
#tar xzf cmake-3.26.4.tar.gz

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

echo "building mman-win32"
echo "======================="
cd $M_BUILD
mkdir mman-build
cmake -G Ninja -H$M_SOURCE/mman-win32 -B$M_BUILD/mman-build \
  -DCMAKE_INSTALL_PREFIX=$TOP_DIR/mman \
  -DCMAKE_TOOLCHAIN_FILE=$TOP_DIR/toolchain.cmake \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTS=OFF
ninja -j$MJOBS -C $M_BUILD/mman-build
ninja install -C $M_BUILD/mman-build

echo "building binutils"
echo "======================="
cd $M_BUILD
mkdir binutils-build
cd $M_SOURCE/binutils-2.40
# fix ld/ldlang.c (version >= 2.40)
#### See bug reported here: https://sourceware.org/bugzilla/show_bug.cgi?id=30079
patch -ulbf ld/ldlang.c << EOF
@@ -651,3 +651,4 @@
       /* Find the correct node to append this section.  */
-      if (compare_section (sec->spec.sorted, section, (*tree)->section) < 0)
+      if (sec && sec->spec.sorted != none && sec->spec.sorted != by_none
+         && compare_section (sec->spec.sorted, section, (*tree)->section) < 0)
        tree = &((*tree)->left);
EOF
# avoid linking with -lc which doesn't exist with MinGW-w64 (version >= 2.39)
sed -i.bak -e "s/-Wl,-lc,--as-needed/-Wl,--as-needed/" bfd/configure opcodes/configure
cd $M_BUILD/binutils-build
$M_SOURCE/binutils-2.40/configure \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_TARGET \
  --with-sysroot=$M_TARGET \
  --with-{gmp,mpfr,mpc,isl}=$M_BUILD/for_target \
  --enable-install-libiberty \
  --enable-plugins \
  --enable-lto \
  --enable-nls \
  --disable-rpath \
  --disable-multilib \
  --disable-werror \
  --enable-shared \
  --enable-host-shared \
  --enable-serial-configure \
  --disable-bootstrap \
  CFLAGS="-I$TOP_DIR/mman/include -march=nocona -msahf -mtune=generic -O2" \
  CXXFLAGS="-I$TOP_DIR/mman/include -march=nocona -msahf -mtune=generic -O2" \
  LDFLAGS="-Wl,--no-insert-timestamp -Wl,-no-undefined -Wl,--allow-multiple-definition -Wl,--as-needed -lmman" \
  AR=$M_CROSS/bin/$MINGW_TRIPLE-ar
make -j$MJOBS
make install
# remove .la files
rm -f $(find $M_TARGET -name '*.la')
# remove .dll.a file from plugin folder (version >= 2.36)
rm $M_TARGET/lib/bfd-plugins/*.dll.a

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

# fix mingw-w64-libraries/winpthreads/src/thread.c (version >= 9.0.0)
patch -ulf mingw-w64-libraries/winpthreads/src/thread.c << EOF
@@ -27,2 +27,3 @@
 #include <malloc.h>
+#include <string.h>
 #include <signal.h>
EOF

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

echo "building dlfcn-win32"
echo "======================="
cd $M_BUILD
mkdir libdl-build
cmake -G Ninja -H$M_SOURCE/dlfcn-win32 -B$M_BUILD/libdl-build \
  -DCMAKE_INSTALL_PREFIX=$TOP_DIR/dlfcn-win32 \
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
cd $M_SOURCE/gcc-13.1.0
VER=$(cat gcc/BASE-VER)

# fix missing syslog in libssp/ssp.c
sed -i.bak -e "s?#ifdef HAVE_SYSLOG_H?#if 0 //&?" libssp/ssp.c
# fix plugin install location in gcc/c/Make-lang.in and gcc/cp/Make-lang.in (version >= 9.2.0)
sed -i.bak -e "s?\(\$(DESTDIR)\)/\(\$(plugin_resourcesdir)\)?\1\2?" gcc/c/Make-lang.in gcc/cp/Make-lang.in
# fix missing sys/wait.h fixincludes/fixincl.c (version >= 9.3.0)
patch -ulbf fixincludes/fixincl.c << EOF
@@ -28,4 +28,12 @@
 #ifndef SEPARATE_FIX_PROC
+#ifdef _WIN32
+#include <Windows.h>
+#define wait(p) Sleep(0)
+#include <fcntl.h>
+#define pipe(fds) _pipe(fds, 4096, _O_BINARY)
+#define fork() -1
+#else
 #include <sys/wait.h>
 #endif
+#endif

EOF
# fix missing pipe in fixincludes/procopen.c (version >= 9.3.0)
patch -ulbf fixincludes/procopen.c << EOF
@@ -50,2 +50,7 @@
 #include "server.h"
+#ifdef _WIN32
+#include <fcntl.h>
+#define pipe(fds) _pipe(fds, 4096, _O_BINARY)
+#define fork() -1
+#endif

EOF
# fix missing kill/alarm in fixincludes/server.c (version >= 9.3.0)
patch -ulbf fixincludes/server.c << EOF
@@ -50,2 +50,6 @@
 #include "server.h"
+#ifdef _WIN32
+#define kill(pid,sig) -1
+#define alarm(n) 0
+#endif

EOF
# fix printf format issues with MinGW-w64 >= 8.0.0 (version >= 10.2.0)
####See also: https://sourceforge.net/p/mingw-w64/bugs/853/
####See also: https://github.com/msys2/MINGW-packages-dev/blob/master/mingw-w64-gcc-git/0020-libgomp-Don-t-hard-code-MS-printf-attributes.patch
sed -i.bak -e "s/^\(\s*#\s*\)include <inttypes\.h>.*$/&\n\1ifdef __MINGW32__\n\1undef HAVE_INTTYPES_H\n\1endif/" libgomp/target.c libgomp/oacc-parallel.c
# avoid looking for libiberty.a in a pic subdirectory
sed -i.bak -e "s?pic/\(libiberty\.a\)?\1?g" $(grep -l "pic/libiberty\.a" */Makefile.in)
# fix missing .exe extension of mkoffload in in gcc/lto-wrapper.c (version >= 10.2.0)
#### bug reported: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=98145
patch -ulbf gcc/lto-wrapper.cc << EOF
@@ -548,4 +548,10 @@
 /* Parse STR, saving found tokens into PVALUES and return their number.
-   Tokens are assumed to be delimited by ':'.  If APPEND is non-null,
-   append it to every token we find.  */
+   Tokens are assumed to be delimited by ':' (or ';' on Windows).
+   If APPEND is non-null, append it to every token we find.  */
+
+#ifdef _WIN32
+#define PATH_LIST_SEPARATOR ';'
+#else
+#define PATH_LIST_SEPARATOR ':'
+#endif

@@ -558,3 +564,3 @@

-  curval = strchr (str, ':');
+  curval = strchr (str, PATH_LIST_SEPARATOR);
   while (curval)
@@ -562,3 +568,3 @@
       num++;
-      curval = strchr (curval + 1, ':');
+      curval = strchr (curval + 1, PATH_LIST_SEPARATOR);
     }
@@ -567,3 +573,3 @@
   curval = str;
-  nextval = strchr (curval, ':');
+  nextval = strchr (curval, PATH_LIST_SEPARATOR);
   if (nextval == NULL)
@@ -581,3 +587,3 @@
       curval = nextval + 1;
-      nextval = strchr (curval, ':');
+      nextval = strchr (curval, PATH_LIST_SEPARATOR);
       if (nextval == NULL)
@@ -816,2 +822,8 @@

+#ifdef _WIN32
+#define BIN_EXT ".exe"
+#else
+#define BIN_EXT ""
+#endif
+
 static char *
@@ -827,6 +839,6 @@
   char *suffix
-    = XALLOCAVEC (char, sizeof ("/accel//mkoffload") + strlen (target));
+    = XALLOCAVEC (char, sizeof ("/accel//mkoffload" BIN_EXT) + strlen (target));
   strcpy (suffix, "/accel/");
   strcat (suffix, target);
-  strcat (suffix, "/mkoffload");
+  strcat (suffix, "/mkoffload" BIN_EXT);

EOF
# fix missing getpagesize() in libbacktrace/mmapio.c (version >= 11.1.0)
mv libbacktrace/mmapio.c libbacktrace/mmapio.c.bak
cat > libbacktrace/mmapio.c << EOF
#ifdef _WIN32
#include <windows.h>
int getpagesize (void);
int getpagesize (void)
{
  SYSTEM_INFO sysinfo;
  GetSystemInfo(&sysinfo);
  return sysinfo.dwPageSize;
}
#endif
EOF
cat libbacktrace/mmapio.c.bak >> libbacktrace/mmapio.c
# fix precompiled header mapping issues in gcc/config/i386/host-mingw32.cc (version >= 12.2.0)
#### see also: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=105858
#### see also: https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/0010-Fix-using-large-PCH.patch
#### see also: https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/0021-PR14940-Allow-a-PCH-to-be-mapped-to-a-different-addr.patch
patch -ulbf gcc/config/i386/host-mingw32.cc << EOF
@@ -143,3 +137,2 @@
   OSVERSIONINFO version_info;
-  int r;

@@ -177,21 +170,20 @@

-  /* Retry five times, as here might occure a race with multiple gcc's
-     instances at same time.  */
-  for (r = 0; r < 5; r++)
-   {
-      mmap_addr = MapViewOfFileEx (mmap_handle, FILE_MAP_COPY, 0, offset,
-                                  size, addr);
-      if (mmap_addr == addr)
-       break;
-      if (r != 4)
-        Sleep (500);
-   }
-
-  if (mmap_addr != addr)
+  /* Try mapping the file at \`addr\`.  */
+  mmap_addr = MapViewOfFileEx (mmap_handle, FILE_MAP_COPY, 0, offset,
+                              size, addr);
+  if (mmap_addr == NULL)
     {
-      w32_error (__FUNCTION__, __FILE__, __LINE__, "MapViewOfFileEx");
-      CloseHandle(mmap_handle);
-      return  -1;
+      /* We could not map the file at its original address, so let the
+        system choose a different one. The PCH can be relocated later.  */
+      mmap_addr = MapViewOfFileEx (mmap_handle, FILE_MAP_COPY, 0, offset,
+                                  size, NULL);
+      if (mmap_addr == NULL)
+       {
+         w32_error (__FUNCTION__, __FILE__, __LINE__, "MapViewOfFileEx");
+         CloseHandle(mmap_handle);
+         return  -1;
+       }
     }

+  addr = mmap_addr;
   return 1;
EOF
# fix libgo/sysinfo.c (version >= 11-20220409)
patch -ulbf libgo/sysinfo.c << EOF
@@ -19,3 +19,7 @@
 #include <ucontext.h>
+#ifdef _WIN32
+#include <winsock2.h>
+#else
 #include <netinet/in.h>
+#endif
 /* <netinet/tcp.h> needs u_char/u_short, but <sys/bsd_types> is only
@@ -29,3 +33,5 @@
 #endif
+#ifndef _WIN32
 #include <netinet/tcp.h>
+#endif
 #if defined(HAVE_NETINET_IN_SYSTM_H)
@@ -43,4 +49,6 @@
 #include <signal.h>
+#ifndef _WIN32
 #include <sys/ioctl.h>
 #include <termios.h>
+#endif
 #if defined(HAVE_SYSCALL_H)
@@ -72,2 +80,3 @@
 #endif
+#ifndef _WIN32
 #include <sys/resource.h>
@@ -75,4 +84,6 @@
 #include <sys/socket.h>
+#endif
 #include <sys/stat.h>
 #include <sys/time.h>
+#ifndef _WIN32
 #include <sys/times.h>
@@ -80,2 +91,3 @@
 #include <sys/un.h>
+#endif
 #if defined(HAVE_SYS_USER_H)
@@ -91,2 +103,3 @@
 #include <unistd.h>
+#ifndef _WIN32
 #include <netdb.h>
@@ -94,2 +107,3 @@
 #include <grp.h>
+#endif
 #if defined(HAVE_LINUX_FILTER_H)
EOF
# fix undefined index() in gcc/m2/gm2spec.cc and gcc/m2/mc-boot-ch/Glibc.c(version >= 13.1.0)
sed -i.bak -e "s/\bindex/strchr/" gcc/m2/gm2spec.cc gcc/m2/mc-boot-ch/Glibc.c gcc/m2/mc-boot-ch/Gdtoa.cc
# fix gcc/m2/mc-boot-ch/GSelective.c (version >= 13.1.0)
patch -ulbf gcc/m2/mc-boot-ch/GSelective.c << EOF
@@ -28,2 +28,6 @@
 #include "gm2-libs-host.h"
+#ifdef _WIN32
+#undef HAVE_SELECT
+typedef void fd_set;
+#endif

EOF
# fix gcc/m2/mc-boot-ch/GSysExceptions.c (version >= 13.1.0)
patch -ulbf gcc/m2/mc-boot-ch/GSysExceptions.c << EOF
@@ -25,2 +25,5 @@
 #include "gm2-libs-host.h"
+#ifdef _WIN32
+#undef HAVE_SIGNAL_H
+#endif

EOF
# put LDFLAGS at the end of the linker arguments to make sure -lmman works
sed -i.bak -e "s/\(\s\$(LDFLAGS)\)\([^\\\\\"]*\)$/\2\1/" $(grep -l "\$(LDFLAGS)" $(find -name Makefile.in))
# fix build issue (version >= 12.1.0)
#### bug reported: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=105506
patch -ulbf Makefile.in << EOF
@@ -449,2 +449,3 @@

+@if pgo-build
 # Pass additional PGO and LTO compiler options to the PGO build.
@@ -491,2 +492,3 @@
 PGO_BUILD_TRAINING = \$(addprefix maybe-check-,\$(PGO-TRAINING-TARGETS))
+@endif pgo-build

EOF
# fix Makefile.tpl (version >= 12.2.0)
patch -ulbf Makefile.tpl << EOF
@@ -452,2 +452,3 @@

+@if pgo-build
 # Pass additional PGO and LTO compiler options to the PGO build.
@@ -494,2 +495,3 @@
 PGO_BUILD_TRAINING = \$(addprefix maybe-check-,\$(PGO-TRAINING-TARGETS))
+@endif pgo-build

EOF
# fix unsupported go language for GCC 12 and up in configure
patch -ulbf configure << EOF
@@ -3577,3 +3577,3 @@
 case "\${target}" in
-*-*-darwin* | *-*-cygwin* | *-*-mingw* | bpf-* )
+*-*-darwin* | *-*-cygwin* | bpf-* )
     unsupported_languages="\$unsupported_languages go"
@@ -3609,3 +3609,3 @@
        ;;
-    *-*-cygwin* | *-*-mingw*)
+    *-*-cygwin*)
        noconfigdirs="\$noconfigdirs target-libgo"
EOF
## fix linker error: export ordinal too large (version >= 13)
sed -i.bak "s/--export-all-symbols/--gc-keep-exported/" $(grep -l "\--export-all-symbols" $(find . -name configure))
# fix detection of GMP/MPFR/MPC
sed -i.bak -e  "s/#include [<\"]\(gmp\|mpc\|mpfr\|isl\)\.h[>\"]/#include <stdio.h>\n&/" configure
# fix missing mmap/munmap and linker error: export ordinal too large
sed -i.bak "s/\(\${wl}\)--export-all-symbols/\1--gc-keep-exported \1-lmman/" $(grep -l "\${wl}--export-all-symbols" $(find . -name configure))
# fix detection of GMP/MPFR/MPC
sed -i.bak -e  "s/#include [<\"]\(gmp\|mpc\|mpfr\|isl\)\.h[>\"]/#include <stdio.h>\n&/" configure
# copy MinGW-w64 files
mkdir -p gcc-build/mingw-w64/mingw/lib
cp -rf $M_TARGET/include gcc-build/mingw-w64/mingw
cp -rf $M_TARGET/$MINGW_TRIPLE/lib/* gcc-build/mingw-w64/mingw/lib/ || cp -rf $M_TARGET/lib gcc-build/mingw-w64/mingw/
cd gcc-build
../configure \
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
  --enable-mingw-wildcard \
  --enable-__cxa_atexit \
  --enable-lto \
  --enable-libgomp \
  --disable-multilib \
  --enable-checking=release \
  --disable-rpath \
  --disable-win32-registry \
  --disable-werror \
  --disable-symvers \
  --with-libiconv-prefix=$TOP_DIR/opt \
  --with-zlib-include=$TOP_DIR/opt/include \
  --with-zlib-lib=$TOP_DIR/opt/lib \
  --with-gnu-as \
  --with-gnu-ld \
  --with-pkgversion="GCC with MCF thread model" \
  --with-build-sysroot=$M_SOURCE/gcc-13.1.0/gcc-build/mingw-w64 \
  CFLAGS='-I$TOP_DIR/dlfcn-win32/include -Wno-int-conversion  -march=nocona -msahf -mtune=generic -O2' \
  CXXFLAGS='-Wno-int-conversion  -march=nocona -msahf -mtune=generic -O2' \
  LDFLAGS='-pthread -Wl,--no-insert-timestamp -Wl,--dynamicbase -Wl,--high-entropy-va -Wl,--nxcompat -Wl,--tsaware'
make -j$MJOBS
touch gcc/cc1.exe.a gcc/cc1plus.exe.a
make install LIBS="-lmman"
mv $M_TARGET/lib/gcc/x86_64-w64-mingw32/lib/libgcc_s.a $M_TARGET/lib/gcc/x86_64-w64-mingw32/$VER/
mv $M_TARGET/lib/gcc/x86_64-w64-mingw32/libgcc*.dll $M_TARGET/lib/gcc/x86_64-w64-mingw32/$VER/
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

echo "building pkgconf"
echo "======================="
cd $M_BUILD
mkdir pkgconf-build
cd pkgconf-build
meson setup $M_SOURCE/pkgconf \
  --prefix=$M_TARGET \
  --cross-file=$TOP_DIR/cross.meson \
  --buildtype=plain \
  -Dtests=disabled
ninja -j$MJOBS -C $M_BUILD/pkgconf-build
ninja install -C $M_BUILD/pkgconf-build
cp $M_TARGET/bin/pkgconf.exe $M_TARGET/bin/pkg-config.exe
cp $M_TARGET/bin/pkgconf.exe $M_TARGET/bin/x86_64-w64-mingw32-pkg-config.exe
cd $M_TARGET
