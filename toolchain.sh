#!/bin/bash

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

# <1> clean
date
rm -rf $M_CROSS

mkdir -p $M_SOURCE
cd $M_SOURCE

# get binutils
wget -c -O binutils-2.40.tar.bz2 http://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.bz2
tar xjf binutils-2.40.tar.bz2

# get gcc
wget -c -O gcc-12-20230421.tar.xz https://mirrorservice.org/sites/sourceware.org/pub/gcc/snapshots/12-20230421/gcc-12-20230421.tar.xz
xz -c -d gcc-12-20230421.tar.xz | tar xf -

# get mingw-w64
git clone https://github.com/mingw-w64/mingw-w64.git --branch master --depth 1

# <2> build
echo "building gendef"
echo "======================="
cd mingw-w64/mingw-w64-tools/gendef
./configure --prefix=$M_CROSS
make -j$MJOBS || echo "(-) Build Error!"
make install-strip
cd $M_SOURCE

echo "building binutils"
echo "======================="
cd binutils-2.40
./configure \
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
make -j$MJOBS || echo "(-) Build Error!"
make install-strip

cd $M_CROSS/bin
ln -s $(which pkg-config) $MINGW_TRIPLE-pkg-config
ln -s $(which pkg-config) $MINGW_TRIPLE-pkgconf
cd $M_SOURCE

echo "building mingw-w64-headers"
echo "======================="
cd mingw-w64/mingw-w64-headers 
./configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE \
  --enable-sdk=all \
  --enable-idl \
  --with-default-msvcrt=msvcrt
make -j$MJOBS || echo "(-) Build Error!"
make install install-strip

cd $M_CROSS
ln -s $MINGW_TRIPLE mingw
cd $M_SOURCE

echo "building gcc"
echo "======================="
cd gcc-12-20230421
# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=54412
curl -OL https://salsa.debian.org/mingw-w64-team/gcc-mingw-w64/-/raw/5e7d749d80e47d08e34a17971479d06cd423611e/debian/patches/vmov-alignment.patch
patch -p2 -i vmov-alignment.patch
./configure \
  --host=$MINGW_TRIPLE \
  --target=$MINGW_TRIPLE \
  --prefix=$M_CROSS \
  --libdir=$M_CROSS/lib \
  --with-sysroot=$M_CROSS \
  --disable-multilib \
  --enable-languages=c,c++ \
  --disable-nls \
  --disable-shared \
  --disable-win32-registry \
  --with-tune=generic \
  --enable-threads=posix \
  --without-included-gettext \
  --enable-lto \
  --enable-checking=release \
  --disable-sjlj-exceptions
make -j$MJOBS all-gcc || echo "(-) Build Error!"
make install-strip-gcc
cd $M_SOURCE

echo "building mingw-w64-crt"
echo "======================="
cd mingw-w64/mingw-w64-crt
autoreconf -ivf
./configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE \
  --with-sysroot=$M_CROSS \
  --with-default-msvcrt=msvcrt-os \
  --enable-lib64 \
  --disable-lib32
make -j$MJOBS || echo "(-) Build Error!"
make install-strip
cd $M_SOURCE

echo "building winpthreads"
echo "======================="
cd mingw-w64/mingw-w64-libraries/winpthreads
./configure \
  --host=$MINGW_TRIPLE \
  --prefix=$M_CROSS/$MINGW_TRIPLE \
  --enable-lib64 \
  --disable-lib32 \
  --disable-shared \
  --enable-static
make -j$MJOBS || echo "(-) Build Error!"
make install-strip
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
