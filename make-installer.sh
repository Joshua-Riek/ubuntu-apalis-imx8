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

if [ ! -f imx-mkimage/iMX8QM/imx-boot ]; then
    echo "Error: 'imx-mkimage/iMX8QM/imx-boot' not found"
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
mkpart primary ext4 8MB 100%

set +e

# Create partitions
fdisk "${disk}" << EOF
t
83
w
EOF

set -eE

partprobe "${disk}"

sleep 2

# Create filesystems on partitions
partition_char="$(if [[ "${disk: -1}" == [0-9] ]]; then echo p; fi)"
dd if=/dev/zero of="${disk}${partition_char}1" bs=1KB count=10 > /dev/null
mkfs.ext4 -L installer "${disk}${partition_char}1"

# Mount partitions
mkdir -p ${mount_point}/installer
mount "${disk}${partition_char}1" ${mount_point}/installer

# Copy device tree blobs
cd linux-toradex/arch/arm64/boot/dts/freescale && tar -cpf ${mount_point}/installer/ubuntu-apalis-imx8.bootfs.tar ./imx8qm-apalis-*.dtb && cd - >/dev/null
cd linux-toradex/arch/arm64/boot/dts/freescale && tar -rpf ${mount_point}/installer/ubuntu-apalis-imx8.bootfs.tar ./imx8qp-apalis-*.dtb && cd - >/dev/null

# Copy hdmi firmware
cd imx-seco/firmware-imx-8.15/firmware/hdmi/cadence && tar -rpf ${mount_point}/installer/ubuntu-apalis-imx8.bootfs.tar ./dpfw.bin && cd - >/dev/null
cd imx-seco/firmware-imx-8.15/firmware/hdmi/cadence && tar -rpf ${mount_point}/installer/ubuntu-apalis-imx8.bootfs.tar ./hdmitxfw.bin&& cd - >/dev/null

# Copy device tree overlays
cd device-tree-overlays/overlays && tar --transform "s/^./.\/overlays/" -rpf ${mount_point}/installer/ubuntu-apalis-imx8.bootfs.tar ./apalis-*.dtbo && cd - >/dev/null
cd device-tree-overlays/overlays && tar --transform "s/^./.\/overlays/" -rpf ${mount_point}/installer/ubuntu-apalis-imx8.bootfs.tar ./display-*.dtbo && cd - >/dev/null

# Copy kernel and initrd
cd rootfs/boot && tar --transform='s/^.\/initrd.img-.*/.\/initrd/' -rpf ${mount_point}/installer/ubuntu-apalis-imx8.bootfs.tar ./initrd.img-* && cd - >/dev/null
cd rootfs/boot && tar --transform='s/^.\/vmlinuz-.*/.\/vmlinuz/' -rpf ${mount_point}/installer/ubuntu-apalis-imx8.bootfs.tar ./vmlinuz-* && cd - >/dev/null

# Uboot script
cat > ${mount_point}/installer/boot.cmd << 'EOF'
test -n ${devnum} || env set devnum 0
test -n ${devtype} || env set devtype mmc
test -n ${boot_part} || env set boot_part 1
test -n ${root_part} || env set root_part 2
test -n ${kernel_image} || env set kernel_image vmlinuz
test -n ${ramdisk_image} || env set ramdisk_image initrd
test -n ${overlay_file} || env set overlay_file overlays/apalis-imx8_hdmi_overlay.dtbo
test -n ${fdt_file} || env set fdt_file imx8qm-apalis-v1.1-ixora-v1.2.dtb

env set set_bootcmd_dtb 'env set bootcmd_dtb "echo Loading DeviceTree: ${fdt_file}; load ${devtype} ${devnum}:${boot_part} ${fdt_addr_r} ${fdt_file}; fdt addr ${fdt_addr_r} && fdt resize 0x2000"'
env set set_bootcmd_overlays 'env set bootcmd_overlays "echo Applying Overlay: ${overlay_file}; load ${devtype} ${devnum}:${boot_part} ${loadaddr} ${overlay_file}; fdt apply ${loadaddr}"'
env set set_bootcmd_kernel 'env set bootcmd_kernel "echo Loading Kernel: ${kernel_image}; load ${devtype} ${devnum}:${boot_part} ${ramdisk_addr_r} ${kernel_image}; unzip ${ramdisk_addr_r} ${kernel_addr_r}"'
env set set_bootcmd_ramdisk 'env set bootcmd_ramdisk "echo Loading Ramdisk: ${ramdisk_image}; load ${devtype} ${devnum}:${boot_part} ${ramdisk_addr_r} ${ramdisk_image}"'
env set set_bootcmd_args 'env set bootcmd_args "part uuid ${devtype} ${devnum}:${root_part} uuid && env set bootargs console=ttyLP1,115200 console=tty1 pci=nomsi root=PARTUUID=\\${uuid} rootfstype=ext4 rootwait rw"'
env set set_bootcmd_boot 'env set bootcmd_boot "echo Bootargs: \\${bootargs} && booti ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r}"'
env set set_scriptcmd_load 'env set scriptcmd_load "setexpr found_scriptaddr ${scriptaddr} + 0x10000; if load ${devtype} ${devnum}:${boot_part} \\${found_scriptaddr} boot.scr; then source \\${found_scriptaddr}; fi"'

env set bootcmd_prepare 'run set_bootcmd_dtb && run set_bootcmd_args && run set_bootcmd_overlays && run set_bootcmd_kernel && run set_bootcmd_ramdisk && run set_bootcmd_boot'
env set bootcmd_run 'run bootcmd_dtb && run bootcmd_overlays && run bootcmd_args && run bootcmd_kernel && run bootcmd_ramdisk && run bootcmd_boot; echo "Booting from ${devtype} failed!" && false'

usb start
if test -n ${found_scriptaddr}; then
    run bootcmd_prepare && run bootcmd_run
else
    for devtype in usb mmc; do 
        for devnum in 1 0; do
            if ${devtype} dev ${devnum}; then
                if test ${devtype} = mmc && test ${devnum} -eq 0; then
                    run bootcmd_prepare && run bootcmd_run
                else
                    run set_scriptcmd_load && run scriptcmd_load
                fi 
            fi
        done
    done
fi
EOF
mkimage -A arm64 -O linux -T script -C none -n "Boot Script" -d ${mount_point}/installer/boot.cmd ${mount_point}/installer/boot.scr
cd ${mount_point}/installer && tar -rpf ${mount_point}/installer/ubuntu-apalis-imx8.bootfs.tar ./boot.scr && cd - >/dev/null
rm ${mount_point}/installer/boot.cmd ${mount_point}/installer/boot.scr

# Copy the rootfs
cp ubuntu-apalis-imx8.rootfs.tar ${mount_point}/installer/ubuntu-apalis-imx8.rootfs.tar

# Copy imx boot
cp imx-mkimage/iMX8QM/imx-boot ${mount_point}/installer/imx-boot 

# Grab ubuntu logo
wget -nc https://assets.ubuntu.com/v1/29985a98-ubuntu-logo32.png -O ${mount_point}/installer/ubuntu.png

# Toradex easy installer config
cat > ${mount_point}/installer/image.json << EOF
{
    "config_format": "4",
    "autoinstall": true,
    "name": "Ubuntu 20.04",
    "description": "Ubuntu 20.04 based on Toradex Linux 5.4.161",
    "version": "Ubuntu_20.04_Toradex_5.4.161",
    "prepare_script": "prepare.sh", 
    "wrapup_script": "wrapup.sh",
    "icon": "ubuntu.png",
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
                        "filename": "ubuntu-apalis-imx8.bootfs.tar"
                    }
                },
                {
                    "partition_size_nominal": 1024,
                    "want_maximised": true,
                    "content": {
                        "label": "root",
                        "filesystem_type": "ext4",
                        "mkfs_options": "-E nodiscard",
                        "filename": "ubuntu-apalis-imx8.rootfs.tar"
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

# Script to run after install
cat > ${mount_point}/installer/wrapup.sh << EOF
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

# Script to run before install
cat > ${mount_point}/installer/prepare.sh << EOF
#!/bin/sh

exit 0
EOF

sync --file-system
sync

# Umount partitions
umount "${disk}${partition_char}1"

