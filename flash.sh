#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

mkdir -p build && cd build

# Download the Universal Update Utility (uuu)
if [ ! -f uuu/uuu ]; then
    wget https://github.com/NXPmicro/mfgtools/releases/download/uuu_1.4.193/uuu -P uuu
    chmod +x uuu/uuu
fi

# Script to flash bootloader and os image
cat > uuu/flash.uuu << EOF
uuu_version 1.4.193

# Toradex configs
CFG: FB: -vid 0x0525 -pid 0x4000
CFG: FB: -vid 0x0525 -pid 0x4025
CFG: FB: -vid 0x0525 -pid 0x402F
CFG: FB: -vid 0x0525 -pid 0x4030
CFG: FB: -vid 0x0525 -pid 0x4031

# Load bootloader image into RAM
SDPS: boot -f imx-mkimage/iMX8QM/imx-boot

# Setup uboot environment for flashing emmc
FB: ucmd setenv fastboot_dev mmc
FB: ucmd setenv mmcdev 0
FB: ucmd mmc dev 0

# Flash the bootloader and os image to emmc
FB: flash -raw2sparse all ubuntu-20.04-preinstalled-server-custom-arm64-apalis.img
FB: flash bootloader imx-mkimage/iMX8QM/imx-boot
FB: done
EOF

./uuu/uuu -b uuu/flash.uuu