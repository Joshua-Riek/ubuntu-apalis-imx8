#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR
ls /root > /dev/null

if [ ! -z "$SUDO_USER" ]; then
    HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
fi

mkdir -p build && cd build

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
cat > $chroot_dir/etc/apt/sources.list<<EOF
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

cp *.deb $chroot_dir/tmp

# Run the inital chroot script to setup os env
cat << EOF | chroot $chroot_dir /bin/bash
#!/bin/bash
set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR

locale-gen en_US.UTF-8
update-locale LC_ALL="en_US.UTF-8"

chmod 1777 /tmp

DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends update 
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends upgrade 
DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
bash-completion live-boot man-db i2c-tools initramfs-tools linux-firmware \
zip p7zip-full tmux screen nano rsyslog ntfs-3g kbd dosfstools mtools \
network-manager network-manager-config-connectivity-ubuntu networkd-dispatcher \
net-tools wireless-tools curl openssh-client openssh-server ifupdown iproute2 \
iptables iputils-arping iputils-ping iputils-tracepath ubuntu-drivers-common \
tcpdump sysstat atop htop iotop pciutils lshw lsof cryptsetup sqlite3 uuid \
libhpdf-2.3.0 libsqlite3-0 tree exfat-fuse lvm2 kexec-tools squashfs-tools \
tlp telnetd socat lsscsi hwinfo dmidecode pigz runc ubuntu-fan cgroupfs-mount \
bridge-utils aufs-tools btrfs-progs autossh osslsigncode libncurses5 bison \
dislocker upower nginx-full libpython2.7 libverto1 expect parted uuid-runtime \
wpasupplicant git wget build-essential libncurses-dev xz-utils libssl-dev libelf-dev \
uhubctl

# Download and extract hdmi firmware
mkdir -p /tmp/imx-seco && cd /tmp/imx-seco
wget -nc https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/firmware-imx-8.0.bin
chmod u+x firmware-imx-8.0.bin
./firmware-imx-8.0.bin --auto-accept --force
mkdir -p /lib/firmware/imx/hdmi
cp /tmp/imx-seco/firmware-imx-8.0/firmware/hdmi/cadence/* /lib/firmware/imx/hdmi
cd / && rm -rf /tmp/imx-seco

# DNS
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Hostname
echo "ubuntu" > /etc/hostname

# Networking interfaces
cat << END > /etc/network/interfaces
auto lo
iface lo inet loopback

allow-hotplug eth0
iface eth0 inet dhcp

allow-hotplug wlan0
iface wlan0 inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
END

# Hosts file
cat << END > /etc/hosts
127.0.0.1       localhost
127.0.1.1       ubuntu

::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
ff02::3         ip6-allhosts
END

# WIFI
cat << END > /etc/wpa_supplicant/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
     ssid="your_ssid"
     psk="your_psk"
     key_mgmt=WPA-PSK
}
END

# Setup user account
adduser --shell /bin/bash --gecos ubuntu --disabled-password ubuntu
usermod -a -G sudo ubuntu
chown -R ubuntu:ubuntu /home/ubuntu
mkdir -m 700 /home/ubuntu/.ssh
echo -e "root\nroot" | passwd ubuntu

# Root pass
echo -e "root\nroot" | passwd

dpkg -i /tmp/*.deb

rm -rf /tmp/*
update-initramfs -u
EOF

# Umount the temporary API filesystems
umount -lf $chroot_dir/dev/pts 2> /dev/null || true
umount -lf $chroot_dir/proc 2> /dev/null || true
umount -lf $chroot_dir/* 2> /dev/null || true

# Tar the entire rootfs
cd rootfs && tar -cpf ../ubuntu-apalis-imx8.rootfs.tar . && cd ..
