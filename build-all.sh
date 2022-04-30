#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR
ls /root > /dev/null

if [ ! -z "$SUDO_USER" ]; then
    HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
fi

./build-kernel.sh
./build-rootfs.sh
./build-imx-boot.sh
./build-bootfs.sh
./build-image.sh
