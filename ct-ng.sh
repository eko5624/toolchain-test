#!/bin/bash

MJOBS=$(grep -c processor /proc/cpuinfo)
TOP_DIR=$(pwd)
M_CROSS=$TOP_DIR/cross
mkdir -p $M_CROSS

echo "building crosstool-ng"
echo "======================="
cd $M_CROSS
git clone https://github.com/crosstool-ng/crosstool-ng.git
cd crosstool-ng
./bootstrap
./configure --enable-local
make -j $MJOBS
cp /.config .config
./ct-ng build
cd $M_CROSS
rm -rf crosstool-ng
