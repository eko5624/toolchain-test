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
export RUSTUP_LOCATION=$M_ROOT/rustup_location

export PATH="$M_CROSS/bin:$RUSTUP_LOCATION/.cargo/bin:$PATH"
export PKG_CONFIG="pkgconf --static"
export PKG_CONFIG_LIBDIR="$M_CROSS/lib/pkgconfig"
export RUSTUP_HOME="$RUSTUP_LOCATION/.rustup"
export CARGO_HOME="$RUSTUP_LOCATION/.cargo"

mkdir -p $M_SOURCE
mkdir -p $M_BUILD

echo "gettiong source"
echo "======================="
cd $M_SOURCE
wget -c -O binutils-2.40.tar.bz2 http://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.bz2
tar xjf binutils-2.40.tar.bz2
wget -c -O gcc-13.1.0.tar.xz https://ftp.gnu.org/gnu/gcc/gcc-13.1.0/gcc-13.1.0.tar.xz
xz -c -d gcc-13.1.0.tar.xz | tar xf -
git clone https://github.com/mingw-w64/mingw-w64.git --branch master --depth 1

echo "building gendef"
echo "======================="
cd $M_BUILD
mkdir gendef-build
cd gendef-build
$M_SOURCE/mingw-w64/mingw-w64-tools/gendef/configure --prefix=$M_CROSS
make -j$MJOBS
make install
cd $M_BUILD

echo "building binutils"
echo "======================="
mkdir binutils-build
cd binutils-build
$M_SOURCE/binutils-2.40/configure \
  --target=$MINGW_TRIPLE \
  --prefix=$M_CROSS \
  --with-sysroot=$M_CROSS \
  --disable-multilib \
  --disable-nls \
  --disable-shared \
  --disable-win32-registry \
  --without-included-gettext \
  --enable-lto \
  --enable-plugins \
  --enable-threads
make -j$MJOBS
make install
cd $M_CROSS/bin
ln -s $(which pkg-config) $MINGW_TRIPLE-pkg-config
ln -s $(which pkg-config) $MINGW_TRIPLE-pkgconf
cd $M_CROSS
mkdir -p $MINGW_TRIPLE/lib
ln -s $MINGW_TRIPLE mingw
cd $MINGW_TRIPLE
ln -s lib lib64
cd $M_BUILD

echo "building mingw-w64-headers"
echo "======================="
mkdir headers-build
cd headers-build
$M_SOURCE/mingw-w64/mingw-w64-headers/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE \
  --enable-sdk=all \
  --enable-idl \
  --with-default-msvcrt=msvcrt
make -j$MJOBS
make install
cd $M_BUILD

echo "building gcc"
echo "======================="
# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=54412
#curl -OL https://salsa.debian.org/mingw-w64-team/gcc-mingw-w64/-/raw/5e7d749d80e47d08e34a17971479d06cd423611e/debian/patches/vmov-alignment.patch
#patch -d $M_SOURCE/gcc-12-20230421 -p2 < vmov-alignment.patch
mkdir gcc-build
cd gcc-build
$M_SOURCE/gcc-13.1.0/configure \
  --target=$MINGW_TRIPLE \
  --prefix=$M_CROSS \
  --libdir=$M_CROSS/lib \
  --with-sysroot=$M_CROSS \
  --disable-multilib \
  --enable-languages=c,c++ \
  --disable-nls \
  --disable-shared \
  --disable-win32-registry \
  --with-arch=x86-64 \
  --with-tune=generic \
  --enable-threads=posix \
  --without-included-gettext \
  --enable-lto \
  --enable-checking=release \
  --disable-sjlj-exceptions
make -j$MJOBS all-gcc
make install-gcc
cd $M_BUILD

echo "building mingw-w64-crt"
echo "======================="
cd $M_SOURCE/mingw-w64/mingw-w64-crt
autoreconf -ivf
mkdir crt-build
cd crt-build
$M_SOURCE/mingw-w64/mingw-w64-crt/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE \
  --with-sysroot=$M_CROSS \
  --with-default-msvcrt=msvcrt-os \
  --enable-lib64 \
  --disable-lib32
make -j$MJOBS
make install
cd $M_BUILD

echo "building winpthreads"
echo "======================="
mkdir winpthreads-build
cd winpthreads-build
$M_SOURCE/mingw-w64/mingw-w64-libraries/winpthreads/configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE \
  --disable-shared \
  --enable-static
make -j$MJOBS
make install
cd $M_BUILD

echo "installing gcc final"
echo "======================="
cd gcc-build
make -j$MJOBS
make install
cd $M_SOURCE

echo "building rustup"
echo "======================="
curl -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --target x86_64-pc-windows-gnu --no-modify-path --profile minimal
rustup update
cargo install cargo-c --profile=release-strip --features=vendored-openssl
cat <<EOF >$CARGO_HOME/config
[net]
git-fetch-with-cli = true

[target.x86_64-pc-windows-gnu]
linker = "$M_CROSS/bin/x86_64-w64-mingw32-gcc"
ar = "$M_CROSS/bin/x86_64-w64-mingw32-ar"

[profile.release]
panic = "abort"
strip = true
EOF
