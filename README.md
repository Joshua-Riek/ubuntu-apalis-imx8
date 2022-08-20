## Overview

This is a collection of scripts that are used to build a Ubuntu 20.04 preinstalled server image for the [Apalis iMX8 QuadMax](https://www1.toradex.com/computer-on-modules/apalis-arm-family/nxp-imx-8) and [Ixora Carrier Board](https://www.toradex.com/products/carrier-board/ixora-carrier-board) from Toradex.

![Apalis iMX8 QuadMax and Ixora Carrier Board](https://docs.toradex.com/107141-carrier-board.png)

## Recommended Hardware

To setup the build environment for the Ubuntu 20.04 image creation, a Linux host with the following configuration is recommended. A host machine with adequate processing power and disk space is ideal as the build process can be severial gigabytes in size and can take alot of time.

* Intel Core i7 CPU (>= 8 cores)
* Strong internet connection
* 20 GB free disk space
* 16 GB RAM

## Requirements

Please install the below packages on your host machine:

```
sudo apt-get install -y build-essential gcc-aarch64-linux-gnu bison \
qemu-user-static u-boot-tools binfmt-support debootstrap flex libssl-dev
```

## Building

To checkout the source and build:

```
git clone https://github.com/Joshua-Riek/ubuntu-apalis-imx8.git
cd ubuntu-apalis-imx8
sudo ./build.sh
```

## Project Layout

```shell
ubuntu-apalis-imx8
├── build-kernel.sh     # Build the Linux kernel and Device Tree Blobs
├── build-imx-boot.sh   # Build U-Boot and the imx boot container
├── build-rootfs.sh     # Build the root file system
├── build-image.sh      # Build the Ubuntu preinstalled image
├── build.sh            # Build the kernel, bootloader, rootfs, and image
└── flash.sh            # Flash produced disk image to emmc
```
