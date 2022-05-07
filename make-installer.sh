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

if [ ! -f imx-mkimage/iMX8QM/imx-boot ]; then
    echo "Error: 'imx-mkimage/iMX8QM/imx-boot' not found"
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
mkpart primary ext4 8MB 100%

set +e

# Create partitions
fdisk ${disk} << EOF
t
83
w
EOF

set -eE

partprobe ${disk}

sleep 2

# Create filesystems on partitions
partition_char=`if [[ ${disk: -1} == [0-9] ]]; then echo p; fi`
dd if=/dev/zero of=${disk}${partition_char}1 bs=1KB count=10 > /dev/null
mkfs.ext4 -L installer ${disk}${partition_char}1

# Mount partitions
mkdir -p ${mount_point}/installer
mount ${disk}${partition_char}1 ${mount_point}/installer

# Copy the bootfs
cp ubuntu-apalis-imx8.bootfs.tar ${mount_point}/installer/ubuntu-apalis-imx8.bootfs.tar
bootfs_size=$(( $(wc -c < ${mount_point}/installer/ubuntu-apalis-imx8.bootfs.tar) / 1024 / 1024 ))

# Copy the rootfs
cp ubuntu-apalis-imx8.rootfs.tar ${mount_point}/installer/ubuntu-apalis-imx8.rootfs.tar
rootfs_size=$(( $(wc -c < ${mount_point}/installer/ubuntu-apalis-imx8.rootfs.tar) / 1024 / 1024 ))

# Copy imx boot
cp imx-mkimage/iMX8QM/imx-boot ${mount_point}/installer/imx-boot 

# Toradex easy installer config
cat > ${mount_point}/installer/image.json << EOF
{
    "config_format": "4",
    "autoinstall": true,
    "name": "Ubuntu 20.04",
    "description": "Ubuntu 20.04 based on Toradex Linux 5.4.161",
    "version": "Ubuntu_20.04_Toradex_5.4.161",
    "wrapup_script": "shutdown.sh", 
    "supported_product_ids": [
        "0037",
        "0047",
        "0048",
        "0049"
    ],
    "blockdevs": [
        {
            "name": "mmcblk0",
            "partitions": [
                {
                    "partition_size_nominal": 128,
                    "want_maximised": false,
                    "content": {
                        "label": "boot",
                        "filesystem_type": "FAT",
                        "mkfs_options": "",
                        "filename": "ubuntu-apalis-imx8.bootfs.tar",
                        "uncompressed_size": ${bootfs_size}
                    }
                },
                {
                    "partition_size_nominal": 1024,
                    "want_maximised": true,
                    "content": {
                        "label": "root",
                        "filesystem_type": "ext4",
                        "mkfs_options": "-E nodiscard",
                        "filename": "ubuntu-apalis-imx8.rootfs.tar",
                        "uncompressed_size": ${rootfs_size}
                    }
                }
            ]
        },
        {
            "name": "mmcblk0boot0",
            "erase": true,
            "content": {
                "filesystem_type": "raw",
                "rawfiles": [
                    {
                        "filename": "imx-boot",
                        "dd_options": "seek=0"
                    }
                ]
            }
        }
    ]
}
EOF

# Shutdown after install
cat > ${mount_point}/installer/shutdown.sh << EOF
#!/bin/sh

echo 1 > /proc/sys/kernel/sysrq 
echo s > /proc/sysrq-trigger
echo o > /proc/sysrq-trigger
sleep 5

# Should never reach reboot
echo b > /proc/sysrq-trigger
sleep 1000

exit 0
EOF

sync --file-system
sync

# Umount partitions
umount ${disk}${partition_char}1

