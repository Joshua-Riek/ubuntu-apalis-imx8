#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

if [ "$(id -u)" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

cd "$(dirname -- "$(readlink -f -- "$0")")" && cd ..
mkdir -p build && cd build

# Download the toradex linux kernel source
if [ ! -d linux-toradex ]; then
    git clone --depth=1 --progress -b toradex_5.4-2.3.x-imx git://git.toradex.com/linux-toradex.git
fi
cd linux-toradex

# Apply git patch if not already applied
if git apply --check ../../patches/linux-toradex/0001-increase-spi-fifo-size.patch > /dev/null 2>&1; then
    git apply ../../patches/linux-toradex/0001-increase-spi-fifo-size.patch
fi

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- distclean
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig
./scripts/config --set-val CONFIG_DEBUG_INFO n

echo "-toradex" > .scmversion

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- DTC_FLAGS="-@" -j "$(nproc)"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- DTC_FLAGS="-@" -j "$(nproc)" bindeb-pkg
cd ..

# Download and build the device tree overlays
if [ ! -d device-tree-overlays ]; then
    git clone --depth=1 --progress -b toradex_5.4-2.3.x-imx git://git.toradex.com/device-tree-overlays.git
fi
cd device-tree-overlays/overlays
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- STAGING_KERNEL_DIR="$(readlink -f ../../linux-toradex)"
