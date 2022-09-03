#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

if [ "$(id -u)" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

mkdir -p build && cd build

loop=/dev/loop1000

for rootfs in *.rootfs.tar; do
    if [ ! -e "${rootfs}" ]; then
        echo "Error: could not find any rootfs tarfile, please run build-rootfs.sh"
        exit 1
    fi

    # Ensure disk image is not mounted
    umount "${loop}"* 2> /dev/null || true
    losetup -d "${loop}" 2> /dev/null || true

    # Create an empty disk image
    img="$(dirname "${rootfs}")/$(basename "${rootfs}" .rootfs.tar).img"
    truncate -s "$(( $(wc -c < "${rootfs}") / 1024 / 1024 + 2048 + 512 ))M" "${img}"

    # Create loop device for disk image
    losetup "${loop}" "${img}"
    disk="${loop}"

    # Ensure disk is not mounted
    mount_point=/tmp/mnt
    umount "${disk}"* 2> /dev/null || true
    umount ${mount_point}/* 2> /dev/null || true
    mkdir -p ${mount_point}

    # Setup partition table
    dd if=/dev/zero of="${disk}" count=4096 bs=512
    parted --script "${disk}" \
    mklabel msdos \
    mkpart primary fat32 0% 512MiB \
    mkpart primary ext4 512MiB 100%

    set +e

    # Create partitions
    (
    echo t
    echo 1
    echo ef
    echo t
    echo 2
    echo 83
    echo a
    echo 1
    echo w
    ) | fdisk "${disk}"

    set -eE

    partprobe "${disk}"

    sleep 2

    # Create filesystems on partitions
    partition_char="$(if [[ ${disk: -1} == [0-9] ]]; then echo p; fi)"
    mkfs.vfat -F32 -n efi "${disk}${partition_char}1"
    dd if=/dev/zero of="${disk}${partition_char}2" bs=1KB count=10 > /dev/null
    mkfs.ext4 -L root "${disk}${partition_char}2"

    # Mount partitions
    mkdir -p ${mount_point}/{efi,root} 
    mount "${disk}${partition_char}1" ${mount_point}/efi
    mount "${disk}${partition_char}2" ${mount_point}/root

    # Get rootfs UUID
    fs_uuid=$(lsblk -ndo UUID "${disk}${partition_char}2")

    # Copy the rootfs to root partition
    tar -xpf "${rootfs}" -C ${mount_point}/root

    # Extract grub arm64-efi to host system 
    if [ ! -d "/usr/lib/grub/arm64-efi" ]; then
        rm -f /usr/lib/grub/arm64-efi
        ln -s ${mount_point}/root/usr/lib/grub/arm64-efi /usr/lib/grub/arm64-efi
    fi

    # Install grub 
    mkdir -p ${mount_point}/efi/efi/boot
    mkdir -p ${mount_point}/efi/boot/grub
    grub-install --target=arm64-efi --efi-directory=${mount_point}/efi --boot-directory=${mount_point}/efi/boot --removable --recheck

    # Remove grub arm64-efi if extracted
    if [ -L "/usr/lib/grub/arm64-efi" ]; then
        rm -f /usr/lib/grub/arm64-efi
    fi

    # Grub config
    cat > ${mount_point}/efi/boot/grub/grub.cfg << EOF
insmod gzio
set background_color=black
set default=0
set timeout=10

GRUB_RECORDFAIL_TIMEOUT=

menuentry 'Boot' {
    search --no-floppy --fs-uuid --set=root ${fs_uuid}
    linux /boot/vmlinuz root=UUID=${fs_uuid} console=ttyLP1,115200 console=tty1 pci=nomsi rootfstype=ext4 rootwait rw
    initrd /boot/initrd.img
}
EOF

    # Uboot script
    cat > ${mount_point}/efi/boot.cmd << EOF
env set bootargs "root=UUID=${fs_uuid} console=ttyLP1,115200 console=tty1 pci=nomsi rootfstype=ext4 rootwait rw"
fatload \${devtype} \${devnum}:1 \${fdt_addr_r} /imx8qm-apalis-v1.1-eval.dtb
fdt addr \${fdt_addr_r} && fdt resize 0x2000
fatload \${devtype} \${devnum}:1 \${loadaddr} /overlays/apalis-imx8_hdmi_overlay.dtbo
fdt apply \${loadaddr}
ext4load \${devtype} \${devnum}:2 \${ramdisk_addr_r} /boot/vmlinuz
unzip \${ramdisk_addr_r} \${kernel_addr_r}
ext4load \${devtype} \${devnum}:2 \${ramdisk_addr_r} /boot/initrd.img
booti \${kernel_addr_r} \${ramdisk_addr_r}:\${filesize} \${fdt_addr_r}
EOF
    mkimage -A arm64 -O linux -T script -C none -n "Boot Script" -d ${mount_point}/efi/boot.cmd ${mount_point}/efi/boot.scr
    rm ${mount_point}/efi/boot.cmd

    # Copy device tree blobs
    cp linux-toradex/arch/arm64/boot/dts/freescale/imx8qm-apalis-*.dtb ${mount_point}/efi

    # Copy device tree overlays
    mkdir -p ${mount_point}/efi/overlays
    cp device-tree-overlays/overlays/apalis-*.dtbo ${mount_point}/efi/overlays
    cp device-tree-overlays/overlays/display-*.dtbo ${mount_point}/efi/overlays

    # Copy hdmi firmware
    cp firmware-imx-8.15/firmware/hdmi/cadence/dpfw.bin ${mount_point}/efi
    cp firmware-imx-8.15/firmware/hdmi/cadence/hdmitxfw.bin ${mount_point}/efi

    sync --file-system
    sync

    # Umount partitions
    umount "${disk}${partition_char}1"
    umount "${disk}${partition_char}2"

    # File system consistency check 
    fsck.fat -a "${disk}${partition_char}1"
    fsck.ext4 -pf "${disk}${partition_char}2"

    # Remove loop device
    losetup -d "${loop}"

    echo "Compressing $(basename "${img}.xz")"
    xz -6 --extreme --force --keep --quiet --threads=0 "${img}"
    rm -f "${img}" "${rootfs}"
done