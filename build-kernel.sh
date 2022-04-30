#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR
ls /root > /dev/null

if [ ! -z "$SUDO_USER" ]; then
    HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
fi

mkdir -p build && cd build

# Download the toradex linux kernel source
if [ ! -d linux-toradex ]; then
    git clone --progress -b toradex_5.4-2.1.x-imx git://git.toradex.com/linux-toradex.git
fi
cd linux-toradex
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- distclean
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig
./scripts/config --set-val CONFIG_DEBUG_INFO n

echo "-toradex" > .scmversion

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j $(nproc)
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j $(nproc) DTC_FLAGS="-@" dtbs
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j $(nproc) bindeb-pkg -i
