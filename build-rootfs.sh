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

# Run the inital chroot script to setup os env
cat << EOF | chroot $chroot_dir /bin/bash
#!/bin/bash
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

# Download and extract hdmi firmware
mkdir -p /tmp/imx-seco && cd /tmp/imx-seco
wget -nc https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/firmware-imx-8.15.bin
chmod u+x firmware-imx-8.15.bin
./firmware-imx-8.15.bin --auto-accept --force
mkdir -p /lib/firmware/imx/hdmi
cp /tmp/imx-seco/firmware-imx-8.15/firmware/hdmi/cadence/* /lib/firmware/imx/hdmi
cd / && rm -rf /tmp/imx-seco

# Setup user account
adduser --shell /bin/bash --gecos ubuntu --disabled-password ubuntu
usermod -a -G sudo ubuntu
chown -R ubuntu:ubuntu /home/ubuntu
mkdir -m 700 /home/ubuntu/.ssh
echo -e "root\nroot" | passwd ubuntu

# Root pass
echo -e "root\nroot" | passwd

# Install kernel
dpkg -i /tmp/*.deb
rm -rf /tmp/*

# Update initramfs
update-initramfs -u

# DNS
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Hostname
echo "apalis-imx8qm" > /etc/hostname

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
127.0.1.1       apalis-imx8qm

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

# Terminal colors for ls
LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;
01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;
31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;
31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;
31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;
31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;
31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;
31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;
35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;
35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;
35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;
35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;
35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;
35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;
35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;
36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;
36:*.xspf=00;36:'

# Set ls colors
echo "export LS_COLORS='$LS_COLORS'" > /root/.lscolors
echo "export LS_COLORS='$LS_COLORS'" > /home/ubuntu/.lscolors
echo "if [ -f /root/.lscolors ]; then . /root/.lscolors; fi" >> /root/.bashrc
echo "if [ -f /home/ubuntu/.lscolors ]; then . /home/ubuntu/.lscolors; fi" >> /home/ubuntu/.bashrc
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/ubuntu/.bashrc

# Enable serial console on ttyLP1
sed -i '/Service/aEnvironment=TERM=linux' /lib/systemd/system/serial-getty@.service
systemctl enable serial-getty@ttyLP1

EOF

# Umount the temporary API filesystems
umount -lf $chroot_dir/dev/pts 2> /dev/null || true
umount -lf $chroot_dir/proc 2> /dev/null || true
umount -lf $chroot_dir/* 2> /dev/null || true

# Tar the entire rootfs
cd rootfs && tar -cpf ../ubuntu-apalis-imx8.rootfs.tar . && cd ..
