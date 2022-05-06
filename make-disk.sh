#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR
ls /root > /dev/null

if [ ! -z "$SUDO_USER" ]; then
    HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
fi

if test "$#" -ne 1; then
    echo "Usage: $0 /dev/mmcblk0"
    exit 1
fi

disk=$1
if [ ! -b ${disk} ]; then
    echo "Error: '${disk}' is not a block device"
    exit 1
fi

mkdir -p build && cd build

if [ ! -f ubuntu-apalis-imx8.bootfs.tar ]; then
    echo "Error: 'ubuntu-apalis-imx8.bootfs.tar' not found"
    exit 1
fi

if [ ! -f ubuntu-apalis-imx8.rootfs.tar ]; then
    echo "Error: 'ubuntu-apalis-imx8.rootfs.tar' not found"
    exit 1
fi

# Ensure disk is not mounted
mount_point=/tmp/mnt
umount ${disk}* 2> /dev/null || true
umount ${mount_point}/* 2> /dev/null || true
mkdir -p ${mount_point}

# Setup partition table
dd if=/dev/zero of=${disk} count=4096 bs=512
parted --script ${disk} \
mklabel msdos \
mkpart primary fat32 8MB 1GB \
mkpart primary ext4 1GB 100%

set +e

# Create partitions
fdisk ${disk} << EOF
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

partprobe ${disk}

sleep 2

# Create filesystems on partitions
partition_char=`if [[ ${disk: -1} == [0-9] ]]; then echo p; fi`
mkfs.vfat -F32 -n boot ${disk}${partition_char}1
dd if=/dev/zero of=${disk}${partition_char}2 bs=1KB count=10 > /dev/null
mkfs.ext4 -L root ${disk}${partition_char}2

# Mount partitions
mkdir -p ${mount_point}/{boot,root}
mount ${disk}${partition_char}1 ${mount_point}/boot
mount ${disk}${partition_char}2 ${mount_point}/root

# Copy the bootfs
tar -xpf ubuntu-apalis-imx8.bootfs.tar -C ${mount_point}/boot

# Copy the rootfs
tar -xpf ubuntu-apalis-imx8.rootfs.tar -C ${mount_point}/root

sync --file-system
sync

# Umount partitions
umount ${disk}${partition_char}1
umount ${disk}${partition_char}2