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
umount -lf $chroot_dir/dev/pts 2> /dev/null || true
umount -lf $chroot_dir/proc 2> /dev/null || true
umount -lf $chroot_dir/* 2> /dev/null || true
rm -rf $chroot_dir
mkdir -p $chroot_dir

# Install the base system into a directory 
debootstrap --verbose --arch $arch $release $chroot_dir $mirror
cp -av /usr/bin/qemu-aarch64-static $chroot_dir/usr/bin

# Use a more complete sources.list file 
cat > $chroot_dir/etc/apt/sources.list << EOF
deb ${mirror} ${release} main universe
deb-src ${mirror} ${release} main universe
deb ${mirror} ${release}-security main universe
deb-src ${mirror} ${release}-security main universe
deb ${mirror} ${release}-updates main universe
deb-src ${mirror} ${release}-updates main universe
EOF

# Mount the temporary API filesystems
mkdir -p $chroot_dir/{proc,sys,run,dev,dev/pts}
mount -t proc /proc $chroot_dir/proc
mount -t sysfs /sys $chroot_dir/sys
mount -o bind /dev $chroot_dir/dev
mount -o bind /dev/pts $chroot_dir/dev/pts

# Copy kernel to the rootfs
cp ./*.deb $chroot_dir/tmp

# Download and update packages
cat << EOF | chroot $chroot_dir /bin/bash
set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

# Generate localisation files
locale-gen en_US.UTF-8
update-locale LC_ALL="en_US.UTF-8"

# Download package information
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends update

# Update installed packages
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends upgrade 

# System packages
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
bash-completion man-db manpages nano gnupg initramfs-tools linux-firmware \
ubuntu-drivers-common dosfstools mtools parted ntfs-3g zip p7zip-full atop \
htop iotop pciutils lshw lsof cryptsetup exfat-fuse hwinfo dmidecode pigz \
wget curl

# Developer packages
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
git binutils build-essential bc bison cmake flex libssl-dev device-tree-compiler \
i2c-tools u-boot-tools binfmt-support

# Networking packages
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
net-tools wireless-tools openssh-client openssh-server wpasupplicant ifupdown

# Clean package cache
apt-get autoremove -y && apt-get clean -y && apt-get autoclean -y
EOF

# Create user accounts
cat << EOF | chroot $chroot_dir /bin/bash
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

# Grab the kernel version
kernel_version="$(cat linux-toradex/include/generated/utsrelease.h | sed -e 's/.*"\(.*\)".*/\1/')"

# Install kernel and create initramfs
cat << EOF | chroot $chroot_dir /bin/bash
set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

# Install kernel
dpkg -i /tmp/*.deb
rm -rf /tmp/*

# Generate kernel module dependencies
depmod -a ${kernel_version}

# Update initramfs
update-initramfs -u
EOF

# DNS
echo "nameserver 8.8.8.8" > $chroot_dir/etc/resolv.conf

# Hostname
echo "apalis-imx8qm" > $chroot_dir/etc/hostname

# Networking interfaces
cat > $chroot_dir/etc/network/interfaces << END
auto lo
iface lo inet loopback

allow-hotplug eth0
iface eth0 inet dhcp

allow-hotplug wlan0
iface wlan0 inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
END

# Hosts file
cat > $chroot_dir/etc/hosts << END
127.0.0.1       localhost
127.0.1.1       apalis-imx8qm

::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
ff02::3         ip6-allhosts
END

# WIFI
cat > $chroot_dir/etc/wpa_supplicant/wpa_supplicant.conf << END
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
     ssid="your_ssid"
     psk="your_psk"
     key_mgmt=WPA-PSK
}
END

# Add command to resize serial terminal
tee -a $chroot_dir/home/ubuntu/.bashrc $chroot_dir/root/.bashrc &>/dev/null << END
resize() {
    local IFS='[;' R escape geometry x y
    echo -en '\e7\e[r\e[999;999H\e[6n\e8'
    read -rsd R escape geometry
    x="\${geometry##*;}"; y="\${geometry%%;*}"
    if [[ "\${COLUMNS}" -eq "\${x}" && "\${LINES}" -eq "\${y}" ]]; then 
        true
    else 
        stty cols "\${x}" rows "\${y}"
    fi
}
END

# Terminal dircolors
tee $chroot_dir/home/ubuntu/.dircolors $chroot_dir/root/.dircolors &>/dev/null << END
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
sed -i 's/#force_color_prompt=yes/color_prompt=yes/g' $chroot_dir/home/ubuntu/.bashrc

# Copy the hdmi firmware
mkdir -p $chroot_dir/lib/firmware/imx/hdmi
cp imx-seco/firmware-imx-8.15/firmware/hdmi/cadence/* $chroot_dir/lib/firmware/imx/hdmi

# Umount the temporary API filesystems
umount -lf $chroot_dir/dev/pts 2> /dev/null || true
umount -lf $chroot_dir/proc 2> /dev/null || true
umount -lf $chroot_dir/* 2> /dev/null || true

# Tar the entire rootfs
cd rootfs && tar -cpf ../ubuntu-apalis-imx8.rootfs.tar . && cd ..
