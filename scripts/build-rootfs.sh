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

# Download and install developer packages
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
git binutils build-essential bc bison cmake flex libssl-dev device-tree-compiler \
i2c-tools u-boot-tools binfmt-support

# Clean package cache
apt-get -y autoremove && apt-get -y clean && apt-get -y autoclean
EOF

# Grab the kernel version
kernel_version="$(sed -e 's/.*"\(.*\)".*/\1/' linux-toradex/include/generated/utsrelease.h)"

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
usermod -a -G sudo,video,adm,dialout,cdrom,audio,plugdev ubuntu
mkdir -m 700 /home/ubuntu/.ssh
chown -R ubuntu:ubuntu /home/ubuntu
echo -e "root\nroot" | passwd ubuntu

# Root pass
echo -e "root\nroot" | passwd
EOF

# Create swapfile
cat << EOF | chroot ${chroot_dir} /bin/bash
set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

dd if=/dev/zero of=/tmp/swapfile bs=1024 count=2097152
chmod 600 /tmp/swapfile
mkswap /tmp/swapfile
mv /tmp/swapfile /swapfile
EOF

# DNS
echo "nameserver 8.8.8.8" > ${chroot_dir}/etc/resolv.conf

# Hostname
echo "apalis-imx8" > ${chroot_dir}/etc/hostname

# Networking interfaces
cat > ${chroot_dir}/etc/network/interfaces << EOF
auto lo
iface lo inet loopback

allow-hotplug eth0
iface eth0 inet dhcp

allow-hotplug enp0s3
iface enp0s3 inet dhcp

allow-hotplug wlx34c9f092281a
iface wlx34c9f092281a inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
EOF

# Hosts file
cat > ${chroot_dir}/etc/hosts << EOF
127.0.0.1       localhost
127.0.1.1       apalis-imx8

::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
ff02::3         ip6-allhosts
EOF

# WIFI
cat > ${chroot_dir}/etc/wpa_supplicant/wpa_supplicant.conf << EOF
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
EOF

# Serial console resize script
cat > ${chroot_dir}/etc/profile.d/resize.sh << 'EOF'
if [ -t 0 -a $# -eq 0 ]; then
    if [ ! -x @BINDIR@/resize ] ; then
        if [ -n "$BASH_VERSION" ] ; then
            # Optimized resize funciton for bash
            resize() {
                local x y
                IFS='[;' read -t 2 -p $(printf '\e7\e[r\e[999;999H\e[6n\e8') -sd R _ y x _
                [ -n "$y" ] && \
                echo -e "COLUMNS=$x;\nLINES=$y;\nexport COLUMNS LINES;" && \
                stty cols $x rows $y
            }
        else
            # Portable resize function for ash/bash/dash/ksh
            # with subshell to avoid local variables
            resize() {
                (o=$(stty -g)
                stty -echo raw min 0 time 2
                printf '\0337\033[r\033[999;999H\033[6n\0338'
                if echo R | read -d R x 2> /dev/null; then
                    IFS='[;R' read -t 2 -d R -r z y x _
                else
                    IFS='[;R' read -r _ y x _
                fi
                stty "$o"
                [ -z "$y" ] && y=${z##*[}&&x=${y##*;}&&y=${y%%;*}
                [ -n "$y" ] && \
                echo "COLUMNS=$x;"&&echo "LINES=$y;"&&echo "export COLUMNS LINES;"&& \
                stty cols $x rows $y)
            }
        fi
    fi
    # Use the EDITOR not being set as a trigger to call resize
    # and only do this for /dev/tty[A-z] which are typically
    # serial ports
    if [ -z "$EDITOR" -a "$SHLVL" = 1 ] ; then
        case $(tty 2>/dev/null) in
            /dev/tty[A-z]*) resize >/dev/null;;
        esac
    fi
fi
EOF

# Expand root filesystem on first boot
cat > ${chroot_dir}/etc/init.d/expand-rootfs.sh << 'EOF'
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
EOF
chmod +x ${chroot_dir}/etc/init.d/expand-rootfs.sh

# Install init script
chroot ${chroot_dir} /bin/bash -c "update-rc.d expand-rootfs.sh defaults"

# Set term for serial tty
mkdir -p ${chroot_dir}/lib/systemd/system/serial-getty@.service.d
echo "[Service]" > ${chroot_dir}/lib/systemd/system/serial-getty@.service.d/10-term.conf
echo "Environment=TERM=linux" >> ${chroot_dir}/lib/systemd/system/serial-getty@.service.d/10-term.conf

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
v4l-utils alsa-utils libglib2.0-dev libpango1.0-dev libcairo2 libtbb2 \
libflac8 libxfont2 libpciaccess-dev x11-xkb-utils libxshmfence1 libxinerama1 \
libev-dev libevdev2 libevdev-dev libevdev-doc libinput-bin libinput-dev \
libxaw7 libtinfo5 libxkbcommon-dev libnss3 libwebpdemux2 libxslt1.1 libfaad2 \
libinput10 libpixman-1-0 libxkbcommon0 libpng16-16 libfontconfig1 libxcb-shm0 \
libxcb-render0 libxrender1 libthai0 libharfbuzz0b libcolord2 libpangocairo-1.0-0 \
libxcb-composite0 libxcb-xfixes0 libatk-bridge2.0-0 libatk1.0-0 libcurl4 \
libdc1394-22 libmodplug1 libsoup2.4-1 librsvg2-2 libopenmpt0 libmpcdec6 libzbar0 \
libbs2b0 libvpx6 libv4l-0 libavfilter7 libvo-aacenc0 libgdk-pixbuf2.0-0 libde265-0 \
libmms0 libmjpegutils-2.1-0 libvo-amrwbenc0 libwildmidi2 libmpeg2encpp-2.1-0 \
libvisual-0.4-0 libsrt1 libtag1-dev libcaca0 libavfilter7 libcodec2-0.9 libxdamage1 \
libshout3 libchromaprint1 libusrsctp1 libjack0 libsbc1 libmplex2-2.1-0 libavc1394-0 \
libsoundtouch1 libfluidsynth2 libshout3 libdca0 libofa0 libsrtp2-1 libdv4 libkate1 \
libwebrtc-audio-processing1 libaa1 libnice10 libcurl4-gnutls-dev libdvdnav4 libnspr4 \
libiec61883-0 libgraphene-1.0-0 libspandsp2 liborc-0.4-0 libcdparanoia0 liba52-0.7.4 \
libcdio18 libmpeg2-4 libopencore-amrnb0 libopencore-amrwb0 libsidplay1v5 libilmbase24 \
libopenexr24 libxv1 libx11-xcb1 libtheora0 nettle-bin nettle-dev googletest mpg123 \
libsoup2.4-dev libassimp5 gtk-update-icon-cache hicolor-icon-theme

# GPU benchmark tools
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
glmark2 glmark2-es2 glmark2-wayland glmark2-es2-wayland 

# Install default wallpapers
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
ubuntu-wallpapers

# Clean package cache
apt-get -y autoremove && apt-get -y clean && apt-get -y autoclean
EOF

# Remove drm, mesa, and wayland
rm -rf ${chroot_dir}/usr/lib/aarch64-linux-gnu/libdrm*
rm -rf ${chroot_dir}/usr/lib/aarch64-linux-gnu/mesa-egl
rm -rf ${chroot_dir}/usr/lib/aarch64-linux-gnu/libglapi.so.0*
rm -rf ${chroot_dir}/usr/lib/aarch64-linux-gnu/libwayland-*

# Copy GPU accelerated packages to the rootfs
cp -r ../debs ${chroot_dir}/tmp

# Install GPU accelerated packages
cat << EOF | chroot ${chroot_dir} /bin/bash
set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

# Install packages
dpkg --force-overwrite --no-debsig --install /tmp/debs/libfmt/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/libimxdmabuffer/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/libvulkan/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/libdrm/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/libepoxy/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/libjpeg/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/devil/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/mesa/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/imx-codec/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/imx-parser/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/wayland/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/wayland-protocols/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/imx-gpu-viv/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/imx-dpu-g2d/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/imx-gpu-sdk/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/libgpuperfcnt/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/gputop/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/xserver-xorg/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/xterm/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/weston/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/libwebp/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/chromium-ozone-wayland/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/gstreamer1.0/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/gstreamer1.0-plugins-base/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/gstreamer1.0-plugins-bad/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/gstreamer1.0-plugins-good/*.deb
dpkg --force-overwrite --no-debsig --install /tmp/debs/imx-gst1.0-plugin/*.deb

# Hold packages
for i in /tmp/debs/*/*.deb; do
    apt-mark hold "\$(basename "\${i}" | cut -d "_" -f1)"
done

# Clean package cache
apt-get -y autoremove && apt-get -y clean && apt-get -y autoclean
rm -rf /tmp/*
EOF

# Service to start weston
cat > ${chroot_dir}/lib/systemd/system/weston.service << EOF
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
Environment="DISPLAY=:0"
Environment="XDG_RUNTIME_DIR=/run/user/0"
EnvironmentFile=-/etc/default/weston
ExecStartPre=/bin/mkdir -p \${XDG_RUNTIME_DIR}

# Weston does not successfully change VT, nor does systemd place us on
# the VT it just activated for us. Switch manually:
ExecStartPre=/usr/bin/chvt 7

ExecStart=/usr/bin/weston --log=\${XDG_RUNTIME_DIR}/weston.log \$OPTARGS

[Install]
WantedBy=multi-user.target
EOF

# Enable weston service
chroot ${chroot_dir} /bin/bash -c "systemctl enable weston.service"

# Configuration file for weston
mkdir -p ${chroot_dir}/etc/xdg/weston
cat > ${chroot_dir}/etc/xdg/weston/weston.ini << EOF
[core]
#gbm-format=argb8888
idle-time=0
use-g2d=1
xwayland=true
backend=drm-backend.so

[shell]
#size=1920x1080
background-image=/usr/share/backgrounds/warty-final-ubuntu.png
background-type=scale

[launcher]
displayname=terminal
icon=/usr/share/weston/terminal.png
path=/usr/bin/weston-terminal

[launcher]
displayname=chromium
icon=/usr/share/icons/hicolor/24x24/apps/chromium.png
path=/usr/lib/chromium/chromium-bin --no-sandbox --use-gl=egl --enable-features=UseOzonePlatform --ozone-platform=wayland --in-process-gpu 

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
EOF

# Create links to shared libraries
chroot ${chroot_dir} /bin/bash -c "ldconfig"

# Gstreamer plugin search path
echo GST_PLUGIN_PATH="\"/usr/lib/gstreamer-1.0"\" >> ${chroot_dir}/etc/environment

# Umount the temporary API filesystems
umount -lf ${chroot_dir}/dev/pts 2> /dev/null || true
umount -lf ${chroot_dir}/* 2> /dev/null || true

# Tar the entire rootfs
cd ${chroot_dir} && XZ_OPT="-0 -T0" tar -cpJf "../ubuntu-20.04-preinstalled-desktop-weston-arm64-apalis.rootfs.tar.xz" . && cd ..
