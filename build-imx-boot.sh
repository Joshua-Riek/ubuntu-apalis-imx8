#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR
ls /root > /dev/null

if [ ! -z "$SUDO_USER" ]; then
    HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
fi

mkdir -p build && cd build

if [ ! -d linux-toradex ]; then
    echo "Error: 'linux-toradex' not found"
    exit 1
fi

# Download and extract the Security Controller (SECO) Firmware
mkdir -p imx-seco && cd imx-seco
wget -nc https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/imx-seco-3.8.1.bin 
chmod u+x imx-seco-3.8.1.bin
./imx-seco-3.8.1.bin --auto-accept --force
wget -nc https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/firmware-imx-8.0.bin
chmod u+x firmware-imx-8.0.bin
./firmware-imx-8.0.bin --auto-accept --force
cd ..

# Download the SCU Firmware (SCFW)
mkdir -p scfw-bin && cd scfw-bin
wget -nc https://github.com/toradex/i.MX-System-Controller-Firmware/raw/60d8c942f49012b6620f34800e2e9f11e45a9ef5/src/scfw_export_mx8qm_b0/build_mx8qm_b0/mx8qm-apalis-scfw-tcm.bin
cd ..

# Download and build the ARM Trusted Firmware (ATF)
if [ ! -d imx-atf ]; then
    git clone --progress -b toradex_imx_5.4.70_2.3.0 git://git.toradex.com/imx-atf.git 
fi
cd imx-atf
make PLAT=imx8qm CROSS_COMPILE=aarch64-linux-gnu- bl31
cd ..

# Download and build u-boot
if [ ! -d u-boot-toradex ]; then
    git clone --progress -b toradex_imx_v2020.04_5.4.70_2.3.0 git://git.toradex.com/u-boot-toradex.git
fi
cd u-boot-toradex
cp ../imx-seco/firmware-imx-8.0/firmware/seco/mx8qm-ahab-container.img mx8qm-ahab-container.img
cp ../scfw-bin/mx8qm-apalis-scfw-tcm.bin mx8qm-apalis-scfw-tcm.bin
cp ../imx-atf/build/imx8qm/release/bl31.bin bl31.bin
make ARCH=arm CROSS_COMPILE=aarch64-linux-gnu- apalis-imx8_defconfig
make ARCH=arm CROSS_COMPILE=aarch64-linux-gnu- -j $(nproc) 
cd ..

# Download and build the boot container
if [ ! -d imx-mkimage ]; then
    git clone --progress -b imx_5.4.70_2.3.0 https://source.codeaurora.org/external/imx/imx-mkimage/
fi
cd imx-mkimage
cp ../imx-seco/imx-seco-3.8.1/firmware/seco/mx8qmb0-ahab-container.img iMX8QM/mx8qmb0-ahab-container.img
cp ../scfw-bin/mx8qm-apalis-scfw-tcm.bin iMX8QM/scfw_tcm.bin
cp ../imx-atf/build/imx8qm/release/bl31.bin iMX8QM/bl31.bin
cp ../u-boot-toradex/u-boot.bin iMX8QM/u-boot.bin
make SOC=iMX8QM CROSS_COMPILE=aarch64-linux-gnu- flash_b0
cp iMX8QM/flash.bin iMX8QM/imx-boot
cd ..

# Download the and build the device tree overlays
if [ ! -d device-tree-overlays ]; then
    git clone --progress -b toradex_5.4-2.3.x-imx git://git.toradex.com/device-tree-overlays.git
fi
cd device-tree-overlays/overlays
make CROSS_COMPILE=aarch64-linux-gnu- STAGING_KERNEL_DIR="$(readlink -f ../../linux-toradex)"
cd ..
