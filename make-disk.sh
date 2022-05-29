#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

if [ "$(id -u)" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

if test "$#" -ne 1; then
    echo "Usage: $0 /dev/mmcblk0"
    exit 1
fi

disk="$1"
if [ ! -b "${disk}" ]; then
    echo "Error: '${disk}' is not a block device"
    exit 1
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

if [ ! -f ubuntu-apalis-imx8.rootfs.tar ]; then
    echo "Error: 'ubuntu-apalis-imx8.rootfs.tar' not found"
    exit 1
fi

# Ensure disk is not mounted
mount_point=/tmp/mnt
umount "${disk}"* 2> /dev/null || true
umount ${mount_point}/* 2> /dev/null || true
mkdir -p ${mount_point}

# Setup partition table
dd if=/dev/zero of="${disk}" count=4096 bs=512
parted --script "${disk}" \
mklabel msdos \
mkpart primary fat32 8MiB 264MiB \
mkpart primary ext4 264MiB 100%

set +e

# Create partitions
fdisk "${disk}" << EOF
t
1
e
t
2
83
a
1
w
EOF

set -eE

partprobe "${disk}"

sleep 2

# Create filesystems on partitions
partition_char="$(if [[ ${disk: -1} == [0-9] ]]; then echo p; fi)"
mkfs.vfat -F32 -n boot "${disk}${partition_char}1"
dd if=/dev/zero of="${disk}${partition_char}2" bs=1KB count=10 > /dev/null
mkfs.ext4 -L root "${disk}${partition_char}2"

# Mount partitions
mkdir -p ${mount_point}/{boot,root} 
mount "${disk}${partition_char}1" ${mount_point}/boot
mount "${disk}${partition_char}2" ${mount_point}/root

# Copy device tree blobs
cp linux-toradex/arch/arm64/boot/dts/freescale/imx8qm-apalis-*.dtb ${mount_point}/boot

# Copy device tree overlays
mkdir -p ${mount_point}/boot/overlays
cp device-tree-overlays/overlays/apalis-*.dtbo ${mount_point}/boot/overlays
cp device-tree-overlays/overlays/display-*.dtbo ${mount_point}/boot/overlays

# Copy hdmi firmware
cp imx-seco/firmware-imx-8.15/firmware/hdmi/cadence/dpfw.bin ${mount_point}/boot
cp imx-seco/firmware-imx-8.15/firmware/hdmi/cadence/hdmitxfw.bin ${mount_point}/boot

# Copy kernel and initrd
cp rootfs/boot/initrd.img-* ${mount_point}/boot/initrd
cp rootfs/boot/vmlinuz-* ${mount_point}/boot/vmlinuz

# Uboot script
cat > ${mount_point}/boot/boot.cmd << 'EOF'
test -n ${devnum} || env set devnum 0
test -n ${devtype} || env set devtype mmc
test -n ${boot_part} || env set boot_part 1
test -n ${root_part} || env set root_part 2
test -n ${boot_script} || env set boot_script boot.scr
test -n ${kernel_image} || env set kernel_image vmlinuz
test -n ${ramdisk_image} || env set ramdisk_image initrd
test -n ${overlay_file} || env set overlay_file overlays/apalis-imx8_hdmi_overlay.dtbo
test -n ${fdt_file} || env set fdt_file imx8qm-apalis-v1.1-ixora-v1.2.dtb

part uuid ${devtype} ${devnum}:${root_part} uuid
env set bootargs console=ttyLP1,115200 console=tty1 pci=nomsi root=PARTUUID=${uuid} rootfstype=ext4 rootwait rw

echo "Loading DeviceTree: ${fdt_file}"
load ${devtype} ${devnum}:${boot_part} ${fdt_addr_r} ${fdt_file}
fdt addr ${fdt_addr_r} && fdt resize 0x2000

echo "Applying Overlay: ${overlay_file}"
load ${devtype} ${devnum}:${boot_part} ${loadaddr} ${overlay_file}
fdt apply ${loadaddr}

echo "Loading Kernel: ${kernel_image}"
load ${devtype} ${devnum}:${boot_part} ${ramdisk_addr_r} ${kernel_image}
unzip ${ramdisk_addr_r} ${kernel_addr_r}

echo "Loading Ramdisk: ${ramdisk_image}"
load mmc 0:1 ${ramdisk_addr_r} ${ramdisk_image}

echo "Bootargs: ${bootargs}"
booti ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r}

echo "Booting from ${devtype} failed!"
EOF
mkimage -A arm64 -O linux -T script -C none -n "Boot Script" -d ${mount_point}/boot/boot.cmd ${mount_point}/boot/boot.scr

# Copy the rootfs
tar -xpf ubuntu-apalis-imx8.rootfs.tar -C ${mount_point}/root

sync --file-system
sync

# Umount partitions
umount "${disk}${partition_char}1"
umount "${disk}${partition_char}2"