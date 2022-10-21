#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

if [ "$(id -u)" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

cd "$(dirname -- "$(readlink -f -- "$0")")" && cd ..
mkdir -p build && cd build

if [ ! -d linux-toradex ]; then
    echo "Error: could not find the kernel source code, please run build-kernel.sh"
    exit 1
fi

# Download and extract the IMX Firmware
if [ ! -d firmware-imx-8.15 ]; then
    wget -nc https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/firmware-imx-8.15.bin
    chmod u+x firmware-imx-8.15.bin
    ./firmware-imx-8.15.bin --auto-accept --force
    rm -f firmware-imx-8.15.bin
fi

# These env vars can cause issues with chroot
unset TMP
unset TEMP
unset TMPDIR

# Debootstrap options
arch=arm64
release=focal
mirror=http://ports.ubuntu.com/ubuntu-ports
chroot_dir=rootfs

# Clean chroot dir and make sure folder is not mounted
umount -lf ${chroot_dir}/dev/pts 2> /dev/null || true
umount -lf ${chroot_dir}/* 2> /dev/null || true
rm -rf ${chroot_dir}
mkdir -p ${chroot_dir}

# Install the base system into a directory 
qemu-debootstrap --arch ${arch} ${release} ${chroot_dir} ${mirror}

# Use a more complete sources.list file 
cat > ${chroot_dir}/etc/apt/sources.list << EOF
# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb ${mirror} ${release} main restricted
# deb-src ${mirror} ${release} main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb ${mirror} ${release}-updates main restricted
# deb-src ${mirror} ${release}-updates main restricted

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb ${mirror} ${release} universe
# deb-src ${mirror} ${release} universe
deb ${mirror} ${release}-updates universe
# deb-src ${mirror} ${release}-updates universe

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team, and may not be under a free licence. Please satisfy yourself as to
## your rights to use the software. Also, please note that software in
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb ${mirror} ${release} multiverse
# deb-src ${mirror} ${release} multiverse
deb ${mirror} ${release}-updates multiverse
# deb-src ${mirror} ${release}-updates multiverse

## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
deb ${mirror} ${release}-backports main restricted universe multiverse
# deb-src ${mirror} ${release}-backports main restricted universe multiverse

deb ${mirror} ${release}-security main restricted
# deb-src ${mirror} ${release}-security main restricted
deb ${mirror} ${release}-security universe
# deb-src ${mirror} ${release}-security universe
deb ${mirror} ${release}-security multiverse
# deb-src ${mirror} ${release}-security multiverse
EOF

# Mount the temporary API filesystems
mkdir -p ${chroot_dir}/{proc,sys,run,dev,dev/pts}
mount -t proc /proc ${chroot_dir}/proc
mount -t sysfs /sys ${chroot_dir}/sys
mount -o bind /dev ${chroot_dir}/dev
mount -o bind /dev/pts ${chroot_dir}/dev/pts

# Copy the the kernel, modules, and headers to the rootfs
if ! cp linux-{headers,image,libc}-*.deb ${chroot_dir}/tmp; then
    echo "Error: could not find the kernel deb packages, please run build-kernel.sh"
    exit 1
fi

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
    ssid="your_home_ssid"
    psk="your_home_psk"
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

# Serial console resize script
cat > ${chroot_dir}/etc/profile.d/serial-console.sh << 'END'
rsz() {
    if [[ -t 0 && $# -eq 0 ]]; then
        local IFS='[;' R escape geometry x y
        echo -en '\e7\e[r\e[999;999H\e[6n\e8'
        read -rsd R escape geometry
        x="${geometry##*;}"; y="${geometry%%;*}"
        if [[ "${COLUMNS}" -eq "${x}" && "${LINES}" -eq "${y}" ]]; then 
            true
        else 
            stty cols "${x}" rows "${y}"
        fi
    else
        echo 'Usage: rsz'
    fi
}

case $(/usr/bin/tty) in
    /dev/ttyAMA0|/dev/ttyS0|/dev/ttyLP1)
        export LANG=C
        rsz
        ;;
esac
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
partition_start="$(cat /sys/block/${partition_pkname}/${partition_name}/start)"
partition_end="$(( partition_start + $(cat /sys/block/${partition_pkname}/${partition_name}/size)))"
partition_newend="$(( $(cat /sys/block/${partition_pkname}/size) - 8))"

# Resize partition and filesystem
if [ "${partition_newend}" -gt "${partition_end}" ];then
    echo -e "Yes\n100%" | parted "/dev/${partition_pkname}" resizepart "${partition_num}" ---pretend-input-tty
    partx -u "/dev/${partition_pkname}"
    resize2fs "/dev/${partition_name}"
    sync
fi

# Remove script
update-rc.d expand-rootfs.sh remove
END
chmod +x ${chroot_dir}/etc/init.d/expand-rootfs.sh

# Install init script
cat << EOF | chroot ${chroot_dir} /bin/bash
set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

update-rc.d expand-rootfs.sh defaults
EOF

# Remove release upgrade motd
rm -f ${chroot_dir}/var/lib/ubuntu-release-upgrader/release-upgrade-available
sed -i 's/^Prompt.*/Prompt=never/' ${chroot_dir}/etc/update-manager/release-upgrades

# Copy the hdmi firmware
mkdir -p ${chroot_dir}/lib/firmware/imx/hdmi
cp firmware-imx-8.15/firmware/hdmi/cadence/* ${chroot_dir}/lib/firmware/imx/hdmi

# Copy the vpu firmware
mkdir -p ${chroot_dir}/lib/firmware/vpu
cp firmware-imx-8.15/firmware/vpu/* ${chroot_dir}/lib/firmware/vpu

# Umount the temporary API filesystems
umount -lf ${chroot_dir}/dev/pts 2> /dev/null || true
umount -lf ${chroot_dir}/* 2> /dev/null || true

# Tar the entire rootfs
cd ${chroot_dir} && XZ_OPT="-0 -T0" tar -cpJf ../ubuntu-20.04-preinstalled-server-arm64-apalis.rootfs.tar.xz . && cd ..

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
umount -lf ${chroot_dir}/* 2> /dev/null || true

# Tar the entire rootfs
cd ${chroot_dir} && XZ_OPT="-0 -T0" tar -cpJf ../ubuntu-20.04-preinstalled-server-custom-arm64-apalis.rootfs.tar.xz . && cd ..

images="ubuntu-20.04-preinstalled-server-arm64-apalis.rootfs.tar.xz ubuntu-20.04-preinstalled-server-custom-arm64-apalis.rootfs.tar.xz"
for rootfs in ${images}; do
    rm -rf ${chroot_dir}
    mkdir -p ${chroot_dir}

    # Untar the entire rootfs
    cd ${chroot_dir} && tar -xpJf "../${rootfs}" . && cd ..

    # Mount the temporary API filesystems
    mkdir -p ${chroot_dir}/{proc,sys,run,dev,dev/pts}
    mount -t proc /proc ${chroot_dir}/proc
    mount -t sysfs /sys ${chroot_dir}/sys
    mount -o bind /dev ${chroot_dir}/dev
    mount -o bind /dev/pts ${chroot_dir}/dev/pts

    # Download and update packages
    cat << EOF | chroot ${chroot_dir} /bin/bash
set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

# Install dependencies
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
v4l-utils alsa-utils libglib2.0-dev libpango1.0-dev libatk1.0-dev libcairo2 \
libxcb-composite0 libxcb-xfixes0 libxcursor1 libjpeg62 libxfont2 libtinfo5 \
libxshmfence1 libxdamage1 x11-xkb-utils libxaw7 libxinerama1 libjpeg-turbo8 \
libev-dev libevdev2 libevdev-dev libevdev-doc libinput10 libinput-bin \
libinput-dev libxkbcommon0 libxkbcommon-dev mtdev-tools

# GPU benchmark tools
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
glmark2 glmark2-es2 glmark2-wayland glmark2-es2-wayland 

# Install default wallpapers
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
ubuntu-wallpapers

# Clean package cache
apt-get -y autoremove && apt-get -y clean && apt-get -y autoclean
EOF

    # Service to start weston
    cat > ${chroot_dir}/lib/systemd/system/weston.service << END
[Unit]
Description=Weston Wayland Compositor (on tty7)
RequiresMountsFor=/run
Conflicts=plymouth-quit.service
After=systemd-user-sessions.service plymouth-quit-wait.service

[Service]
PermissionsStartOnly=true

# Grab tty7
UtmpIdentifier=tty7
TTYPath=/dev/tty7
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes

# stderr to journal so our logging doesn't get thrown into /dev/null
StandardOutput=tty
StandardInput=tty
StandardError=journal

# Set environment and XDG runtime
Environment="XDG_RUNTIME_DIR=/run/user/0"
EnvironmentFile=-/etc/default/weston
ExecStartPre=/bin/mkdir -p \${XDG_RUNTIME_DIR}

# Weston does not successfully change VT, nor does systemd place us on
# the VT it just activated for us. Switch manually:
ExecStartPre=/usr/bin/chvt 7

ExecStart=/usr/bin/weston --log=\${XDG_RUNTIME_DIR}/weston.log \$OPTARGS

[Install]
WantedBy=multi-user.target
END

    # Enable weston service
    cat << EOF | chroot ${chroot_dir} /bin/bash
set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

systemctl enable weston.service
EOF

    # Configuration file for weston
    mkdir -p ${chroot_dir}/etc/xdg/weston
    cat > ${chroot_dir}/etc/xdg/weston/weston.ini << END
[core]
#gbm-format=argb8888
idle-time=0
use-g2d=1
xwayland=true

[shell]
#size=1920x1080
background-image=/usr/share/backgrounds/warty-final-ubuntu.png
background-type=scale

#[output]
#name=HDMI-A-1
#mode=1920x1080@60
#transform=90

#[output]
#name=HDMI-A-2
#mode=off
#	WIDTHxHEIGHT    Resolution size width and height in pixels
#	off             Disables the output
#	preferred       Uses the preferred mode
#	current         Uses the current crt controller mode
#transform=90

[screen-share]
command=@bindir@/weston --backend=rdp-backend.so --shell=fullscreen-shell.so --no-clients-resize
END

    # Remove drm, mesa, and wayland
    rm -rf ${chroot_dir}/usr/lib/aarch64-linux-gnu/libdrm*
    rm -rf ${chroot_dir}/usr/lib/aarch64-linux-gnu/mesa-egl
    rm -rf ${chroot_dir}/usr/lib/aarch64-linux-gnu/libglapi.so.0*
    rm -rf ${chroot_dir}/usr/lib/aarch64-linux-gnu/libwayland-*

    # Extract and install GPU accelerated packages
    for deb in ../debs/*/*.deb; do 
        dpkg -x "${deb}" ${chroot_dir}
    done

    # Umount the temporary API filesystems
    umount -lf ${chroot_dir}/dev/pts 2> /dev/null || true
    umount -lf ${chroot_dir}/* 2> /dev/null || true

    # Tar the entire rootfs
    cd ${chroot_dir} && XZ_OPT="-0 -T0" tar -cpJf "../${rootfs//server/desktop-weston}" . && cd ..
done
