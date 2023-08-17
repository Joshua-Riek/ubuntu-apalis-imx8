#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

cd "$(dirname -- "$(readlink -f -- "$0")")" && cd ..
mkdir -p build && cd build

# Download and extract the Security Controller (SECO) Firmware
if [ ! -d imx-seco-3.8.1 ]; then
    wget -nc https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/imx-seco-3.8.1.bin
    chmod u+x imx-seco-3.8.1.bin
    ./imx-seco-3.8.1.bin --auto-accept --force
    rm -f imx-seco-3.8.1.bin
fi

# Download and extract the IMX Firmware
if [ ! -d firmware-imx-8.15 ]; then
    wget -nc https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/firmware-imx-8.15.bin
    chmod u+x firmware-imx-8.15.bin
    ./firmware-imx-8.15.bin --auto-accept --force
    rm -f firmware-imx-8.15.bin
fi

# Download the SCU Firmware (SCFW)
if [ ! -d scfw-bin ]; then
    wget -nc https://github.com/toradex/i.MX-System-Controller-Firmware/raw/60d8c942f49012b6620f34800e2e9f11e45a9ef5/src/scfw_export_mx8qm_b0/build_mx8qm_b0/mx8qm-apalis-scfw-tcm.bin -P scfw-bin
fi

# Download and build the ARM Trusted Firmware (ATF)
if [ ! -d imx-atf ]; then
    git clone --depth=1 --progress -b toradex_imx_5.4.70_2.3.0 git://git.toradex.com/imx-atf.git 
fi
cd imx-atf
make PLAT=imx8qm CROSS_COMPILE=aarch64-linux-gnu- bl31
cd ..

# Download and build u-boot
if [ ! -d u-boot-toradex ]; then
    git clone --depth=1 --progress -b toradex_imx_v2020.04_5.4.70_2.3.0 git://git.toradex.com/u-boot-toradex.git
fi
cd u-boot-toradex
if git apply --check ../../patches/u-boot-toradex/0001-usb-first-boot-target.patch > /dev/null 2>&1; then
    git apply ../../patches/u-boot-toradex/0001-usb-first-boot-target.patch
fi
cp ../scfw-bin/mx8qm-apalis-scfw-tcm.bin mx8qm-apalis-scfw-tcm.bin
cp ../imx-atf/build/imx8qm/release/bl31.bin bl31.bin
make ARCH=arm CROSS_COMPILE=aarch64-linux-gnu- apalis-imx8_defconfig
make ARCH=arm CROSS_COMPILE=aarch64-linux-gnu- -j "$(nproc)"
cd ..

# Download and build the boot container
if [ ! -d imx-mkimage ]; then
    git clone --depth=1 --progress -b imx_5.4.70_2.3.0 https://github.com/nxp-imx/imx-mkimage/
fi
cd imx-mkimage
cp ../imx-seco-3.8.1/firmware/seco/mx8qmb0-ahab-container.img iMX8QM/mx8qmb0-ahab-container.img
cp ../scfw-bin/mx8qm-apalis-scfw-tcm.bin iMX8QM/scfw_tcm.bin
cp ../imx-atf/build/imx8qm/release/bl31.bin iMX8QM/bl31.bin
cp ../u-boot-toradex/u-boot.bin iMX8QM/u-boot.bin
make SOC=iMX8QM CROSS_COMPILE=aarch64-linux-gnu- flash_b0
cp iMX8QM/flash.bin iMX8QM/imx-boot
