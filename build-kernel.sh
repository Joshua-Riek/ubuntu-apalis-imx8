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

# Apply patch for leak during kernel headers install
if git apply --check ../../patch/701-net-0408-sdk_fman-fix-CONFIG_COMPAT-leak-during-headers-insta.patch > /dev/null 2>&1; then
    git apply ../../patch/701-net-0408-sdk_fman-fix-CONFIG_COMPAT-leak-during-headers-insta.patch
fi

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- distclean
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig
./scripts/config --set-val CONFIG_DEBUG_INFO n

echo "-toradex" > .scmversion

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j $(nproc)
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j $(nproc) DTC_FLAGS="-@" \
freescale/imx8qm-apalis-v1.1-eval.dtb freescale/imx8qm-apalis-v1.1-ixora-v1.1.dtb \
freescale/imx8qm-apalis-eval.dtb freescale/imx8qm-apalis-ixora-v1.1.dtb
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j $(nproc) bindeb-pkg
