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

if [ ! -d device-tree-overlays ]; then
    echo "Error: 'device-tree-overlays' not found"
    exit 1
fi

if [ ! -d imx-seco ]; then
    echo "Error: 'imx-seco' not found"
    exit 1
fi

if [ ! -d rootfs ]; then
    echo "Error: 'rootfs' not found"
    exit 1
fi

mkdir -p bootfs && mkdir -p bootfs/overlays

# Copy device tree blobs
cp linux-toradex/arch/arm64/boot/dts/freescale/imx8qm-apalis-*.dtb bootfs
cp linux-toradex/arch/arm64/boot/dts/freescale/imx8qp-apalis-*.dtb bootfs

# Copy hdmi firmware
cp imx-seco/firmware-imx-8.0/firmware/hdmi/cadence/dpfw.bin bootfs
cp imx-seco/firmware-imx-8.0/firmware/hdmi/cadence/hdmitxfw.bin bootfs

# Copy device tree overlays
cp device-tree-overlays/overlays/apalis-*.dtbo bootfs/overlays
cp device-tree-overlays/overlays/display-*.dtbo bootfs/overlays

# Copy kernel and initrd
cp rootfs/boot/initrd.img-* bootfs/initrd
cp rootfs/boot/vmlinuz-* bootfs/vmlinuz

# Uboot script
cat > bootfs/boot.cmd << EOF
setenv bootargs "console=ttyLP1,115200 console=tty1 pci=nomsi root=/dev/mmcblk0p2 rw rootwait"
fatload mmc \${mmcdev}:\${mmcpart} \${fdt_addr_r} \${fdtfile}
fdt addr \${fdt_addr_r} && fdt resize 0x20000
fatload mmc \${mmcdev}:\${mmcpart} \${loadaddr} overlays/apalis-imx8_hdmi_overlay.dtbo
fdt apply \${loadaddr}
fatload mmc \${mmcdev}:\${mmcpart} \${ramdisk_addr_r} vmlinuz
unzip \${ramdisk_addr_r} \${kernel_addr_r}
fatload mmc \${mmcdev}:\${mmcpart} \${ramdisk_addr_r} initrd
booti \${kernel_addr_r} \${ramdisk_addr_r}:\${filesize} \${fdt_addr_r}
EOF
mkimage -A arm64 -O linux -T script -C none -n "Boot Script" -d bootfs/boot.cmd bootfs/boot.scr
rm bootfs/boot.cmd

# Tar the entire bootfs
cd bootfs && tar -cpf ../ubuntu-apalis-imx8.bootfs.tar . && cd ..
