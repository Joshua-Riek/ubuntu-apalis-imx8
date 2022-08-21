#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

if [ "$(id -u)" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

mkdir -p build && cd build

if [ ! -d linux-toradex ]; then
    echo "Error: 'linux-toradex' not found"
    exit 1
fi

# Debootstrap options
arch=arm64
release=focal
mirror=http://ports.ubuntu.com/ubuntu-ports
chroot_dir=rootfs

# Clean chroot dir and make sure folder is not mounted
umount -lf ${chroot_dir}/dev/pts 2> /dev/null || true
umount -lf ${chroot_dir}/proc 2> /dev/null || true
umount -lf ${chroot_dir}/* 2> /dev/null || true
rm -rf ${chroot_dir}
mkdir -p ${chroot_dir}

# Install the base system into a directory 
debootstrap --verbose --arch ${arch} ${release} ${chroot_dir} ${mirror}
cp -av /usr/bin/qemu-aarch64-static ${chroot_dir}/usr/bin

# Use a more complete sources.list file 
cat > ${chroot_dir}/etc/apt/sources.list << EOF
deb ${mirror} ${release} main universe
deb-src ${mirror} ${release} main universe
deb ${mirror} ${release}-security main universe
deb-src ${mirror} ${release}-security main universe
deb ${mirror} ${release}-updates main universe
deb-src ${mirror} ${release}-updates main universe
EOF

# Mount the temporary API filesystems
mkdir -p ${chroot_dir}/{proc,sys,run,dev,dev/pts}
mount -t proc /proc ${chroot_dir}/proc
mount -t sysfs /sys ${chroot_dir}/sys
mount -o bind /dev ${chroot_dir}/dev
mount -o bind /dev/pts ${chroot_dir}/dev/pts

# Copy the the kernel, modules, and headers to the rootfs
cp ./linux-{headers,image,libc}-*.deb ${chroot_dir}/tmp

# Download and update packages
cat << EOF | chroot ${chroot_dir} /bin/bash
set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

# Generate localisation files
locale-gen en_US.UTF-8
update-locale LC_ALL="en_US.UTF-8"

# Download package information
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends update

# Update installed packages
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends upgrade

# Update installed packages and dependencies
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends dist-upgrade

# Download and install generic packages
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
bash-completion man-db manpages nano gnupg initramfs-tools linux-firmware \
ubuntu-drivers-common ubuntu-server dosfstools mtools parted ntfs-3g zip atop \
p7zip-full htop iotop pciutils lshw lsof cryptsetup exfat-fuse hwinfo dmidecode \
net-tools wireless-tools openssh-client openssh-server wpasupplicant ifupdown \
pigz wget curl grub-common grub2-common grub-efi-arm64 grub-efi-arm64-bin

# Clean package cache
apt-get -y autoremove && apt-get -y clean && apt-get -y autoclean
EOF

# Grab the kernel version
kernel_version="$(cat linux-toradex/include/generated/utsrelease.h | sed -e 's/.*"\(.*\)".*/\1/')"

# Install kernel, modules, and headers
cat << EOF | chroot ${chroot_dir} /bin/bash
set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

# Install the kernel, modules, and headers
dpkg -i /tmp/linux-{headers,image,libc}-*.deb
rm -rf /tmp/*

# Generate kernel module dependencies
depmod -a ${kernel_version}
update-initramfs -c -k ${kernel_version}

# Create kernel and component symlinks
cd /boot
ln -s initrd.img-${kernel_version} initrd.img
ln -s vmlinuz-${kernel_version} vmlinuz
ln -s System.map-${kernel_version} System.map
ln -s config-${kernel_version} config
EOF

# Create user accounts
cat << EOF | chroot ${chroot_dir} /bin/bash
set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

# Setup user account
adduser --shell /bin/bash --gecos ubuntu --disabled-password ubuntu
usermod -a -G sudo ubuntu
chown -R ubuntu:ubuntu /home/ubuntu
mkdir -m 700 /home/ubuntu/.ssh
echo -e "root\nroot" | passwd ubuntu

# Root pass
echo -e "root\nroot" | passwd
EOF

# DNS
echo "nameserver 8.8.8.8" > ${chroot_dir}/etc/resolv.conf

# Hostname
echo "apalis-imx8" > ${chroot_dir}/etc/hostname

# Networking interfaces
cat > ${chroot_dir}/etc/network/interfaces << END
auto lo
iface lo inet loopback

allow-hotplug eth0
iface eth0 inet dhcp

allow-hotplug enp0s3
iface enp0s3 inet dhcp

allow-hotplug wlx34c9f092281a
iface wlx34c9f092281a inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
END

# Hosts file
cat > ${chroot_dir}/etc/hosts << END
127.0.0.1       localhost
127.0.1.1       apalis-imx8

::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
ff02::3         ip6-allhosts
END

# WIFI
cat > ${chroot_dir}/etc/wpa_supplicant/wpa_supplicant.conf << END
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
    ssid="Skynet_Global_Defense_Network"
    psk="usf1991spc2019ucf2021"
    key_mgmt=WPA-PSK
    priority=1
}

network={
    ssid="your_work_ssid"
    psk="your_work_psk"
    key_mgmt=WPA-PSK
    priority=2
}
END

# Expand root filesystem on first boot
cat > ${chroot_dir}/etc/init.d/expand-rootfs.sh << 'END'
#!/bin/bash
### BEGIN INIT INFO
# Provides: expand-rootfs.sh
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5 S
# Default-Stop:
# Short-Description: Resize the root filesystem to fill partition
# Description:
### END INIT INFO

# Get the root partition
partition_root="$(findmnt -n -o SOURCE /)"
partition_name="$(lsblk -no name "${partition_root}")"
partition_pkname="$(lsblk -no pkname "${partition_root}")"
partition_num="$(echo "${partition_name}" | grep -Eo '[0-9]+$')"

# Get size of disk and root partition
total_size="$(cat /sys/block/${partition_pkname}/size)"
partition_size="$(cat /sys/block/${partition_pkname}/${partition_name}/size)"
partition_start="$(cat /sys/block/${partition_pkname}/${partition_name}/start)"

# Resize partition and filesystem
if [ $(( (0 + partition_size) / 2048 )) -lt $(( total_size / 2048 )) ]; then
    echo -e "Yes\n100%" | parted "/dev/${partition_pkname}" resizepart "${partition_num}" ---pretend-input-tty
    partx -u "/dev/${partition_pkname}"
    resize2fs "/dev/${partition_name}"
fi

# Remove script
update-rc.d expand-rootfs.sh remove
rm -f "$(readlink -f "$0")"
END
chmod +x ${chroot_dir}/etc/init.d/expand-rootfs.sh

# Update fstab on first boot
cat > ${chroot_dir}/etc/init.d/update-fstab.sh << 'EOF'
#!/bin/bash
### BEGIN INIT INFO
# Provides: update-fstab.sh
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5 S
# Default-Stop:
# Short-Description: Update default fstab
# Description:
### END INIT INFO

# Get root block device and remove partition number
disk="$(findmnt -n -o SOURCE / | sed "s/[0-9]*$//")"

# Write the new fstab entries to the root device
cat > /etc/fstab << END
# <device> <dir>       <type>  <options>   <dump>  <fsck>
${disk}1   /boot/efi   vfat    defaults    0       2
${disk}2   /           ext4    defaults    0       1
END

# Remount according to fstab
mkdir -p /boot/efi
mount -a

# Remove script
update-rc.d update-fstab.sh remove
rm -f "$(readlink -f "$0")"
EOF
chmod +x ${chroot_dir}/etc/init.d/update-fstab.sh

# Install init script
cat << EOF | chroot ${chroot_dir} /bin/bash
set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

update-rc.d update-fstab.sh defaults
update-rc.d expand-rootfs.sh defaults
EOF

# Copy the hdmi firmware
mkdir -p ${chroot_dir}/lib/firmware/imx/hdmi
cp imx-seco/firmware-imx-8.15/firmware/hdmi/cadence/* ${chroot_dir}/lib/firmware/imx/hdmi

# Copy the vpu firmware
mkdir -p ${chroot_dir}/lib/firmware/vpu
cp imx-seco/firmware-imx-8.15/firmware/vpu/* ${chroot_dir}/lib/firmware/vpu

# Umount the temporary API filesystems
umount -lf ${chroot_dir}/dev/pts 2> /dev/null || true
umount -lf ${chroot_dir}/proc 2> /dev/null || true
umount -lf ${chroot_dir}/* 2> /dev/null || true

# Tar the entire rootfs
cd ${chroot_dir} && tar -cpf ../ubuntu-20.04-preinstalled-server-arm64-apalis.rootfs.tar . && cd ..

# Mount the temporary API filesystems
mount -t proc /proc ${chroot_dir}/proc
mount -t sysfs /sys ${chroot_dir}/sys
mount -o bind /dev ${chroot_dir}/dev
mount -o bind /dev/pts ${chroot_dir}/dev/pts

# Download and update packages
cat << EOF | chroot ${chroot_dir} /bin/bash
set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

# Developer packages
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
git binutils build-essential bc bison cmake flex libssl-dev device-tree-compiler \
i2c-tools u-boot-tools binfmt-support

# Clean package cache
apt-get -y autoremove && apt-get -y clean && apt-get -y autoclean
EOF

# Terminal dircolors
tee ${chroot_dir}/home/ubuntu/.dircolors ${chroot_dir}/root/.dircolors &>/dev/null << END
# Core formats
RESET 0
DIR 01;34
LINK 01;36
MULTIHARDLINK 00
FIFO 40;33
SOCK 01;35
DOOR 01;35
BLK 40;33;01
CHR 40;33;01
ORPHAN 40;31;01
MISSING 00
SETUID 37;41
SETGID 30;43
CAPABILITY 30;41
STICKY_OTHER_WRITABLE 30;42
OTHER_WRITABLE 34;42
STICKY 37;44
EXEC 01;32
# Archive formats
*.7z 01;31
*.arj 01;31
*.bz2 01;31
*.cpio 01;31
*.gz 01;31
*.lrz 01;31
*.lz 01;31
*.lzma 01;31
*.lzo 01;31
*.rar 01;31
*.s7z 01;31
*.sz 01;31
*.tar 01;31
*.tbz 01;31
*.tgz 01;31
*.warc 01;31
*.WARC 01;31
*.xz 01;31
*.z 01;31
*.zip 01;31
*.zipx 01;31
*.zoo 01;31
*.zpaq 01;31
*.zst 01;31
*.zstd 01;31
*.zz 01;31
# Packaged app formats
.apk 01;31
.ipa 01;31
.deb 01;31
.rpm 01;31
.jad 01;31
.jar 01;31
.ear 01;31
.war 01;31
.cab 01;31
.pak 01;31
.pk3 01;31
.vdf 01;31
.vpk 01;31
.bsp 01;31
.dmg 01;31
.crx 01;31
.xpi 01;31
# Image formats
.bmp 01;35
.dicom 01;35
.tiff 01;35
.tif 01;35
.TIFF 01;35
.cdr 01;35
.flif 01;35
.gif 01;35
.icns 01;35
.ico 01;35
.jpeg 01;35
.JPG 01;35
.jpg 01;35
.nth 01;35
.png 01;35
.psd 01;35
.pxd 01;35
.pxm 01;35
.xpm 01;35
.webp 01;35
.ai 01;35
.eps 01;35
.epsf 01;35
.drw 01;35
.ps 01;35
.svg 01;35
# Audio formats
.3ga 01;35
.S3M 01;35
.aac 01;35
.amr 01;35
.au 01;35
.caf 01;35
.dat 01;35
.dts 01;35
.fcm 01;35
.m4a 01;35
.mod 01;35
.mp3 01;35
.mp4a 01;35
.oga 01;35
.ogg 01;35
.opus 01;35
.s3m 01;35
.sid 01;35
.wma 01;35
.ape 01;35
.aiff 01;35
.cda 01;35
.flac 01;35
.alac 01;35
.mid 01;35
.midi 01;35
.pcm 01;35
.wav 01;35
.wv 01;35
.wvc 01;35
.ogv 01;35
.ogx 01;35
# Video formats
.avi 01;35
.divx 01;35
.IFO 01;35
.m2v 01;35
.m4v 01;35
.mkv 01;35
.MOV 01;35
.mov 01;35
.mp4 01;35
.mpeg 01;35
.mpg 01;35
.ogm 01;35
.rmvb 01;35
.sample 01;35
.wmv 01;35
.3g2 01;35
.3gp 01;35
.gp3 01;35
.webm 01;35
.gp4 01;35
.asf 01;35
.flv 01;35
.ts 01;35
.ogv 01;35
.f4v 01;35
.VOB 01;35
.vob 01;35
# Termcap
TERM ansi
TERM color-xterm
TERM con132x25
TERM con132x30
TERM con132x43
TERM con132x60
TERM con80x25
TERM con80x28
TERM con80x30
TERM con80x43
TERM con80x50
TERM con80x60
TERM cons25
TERM console
TERM cygwin
TERM dtterm
TERM Eterm
TERM eterm-color
TERM gnome
TERM gnome-256color
TERM jfbterm
TERM konsole
TERM kterm
TERM linux
TERM linux-c
TERM mach-color
TERM mlterm
TERM putty
TERM rxvt
TERM rxvt-256color
TERM rxvt-cygwin
TERM rxvt-cygwin-native
TERM rxvt-unicode
TERM rxvt-unicode-256color
TERM rxvt-unicode256
TERM screen
TERM screen-256color
TERM screen-256color-bce
TERM screen-bce
TERM screen-w
TERM screen.linux
TERM screen.rxvt
TERM terminator
TERM vt100
TERM vt220
TERM xterm
TERM xterm-16color
TERM xterm-256color
TERM xterm-88color
TERM xterm-color
TERM xterm-debian
TERM xterm-kitty
END
sed -i 's/#force_color_prompt=yes/color_prompt=yes/g' ${chroot_dir}/home/ubuntu/.bashrc

# Umount the temporary API filesystems
umount -lf ${chroot_dir}/dev/pts 2> /dev/null || true
umount -lf ${chroot_dir}/proc 2> /dev/null || true
umount -lf ${chroot_dir}/* 2> /dev/null || true

# Tar the entire rootfs
cd ${chroot_dir} && tar -cpf ../ubuntu-20.04-preinstalled-server-custom-arm64-apalis.rootfs.tar . && cd ..
