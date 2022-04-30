#!/bin/bash

set -eE 
trap 'echo Error: in $0 on line $LINENO' ERR
ls /root > /dev/null

mkdir -p image && mkdir -p build && cd build

if [ ! -d bootfs ]; then
    echo "Error: 'bootfs' not found"
    exit 1
fi

if [ ! -d rootfs ]; then
    echo "Error: 'rootfs' not found"
    exit 1
fi

if [ ! -f imx-mkimage/iMX8QM/imx-boot ]; then
    echo "Error: 'imx-boot' not found"
    exit 1
fi

# Tar the entire bootfs
cd bootfs && tar -cpf ../../image/ubuntu-20.04-apalis-imx8.bootfs.tar . && cd ..
bootfs_size=$(( $(wc -c < ../image/ubuntu-20.04-apalis-imx8.bootfs.tar) / 1024 / 1024 ))

# Tar the entire rootfs
cd rootfs && tar -cpf ../../image/ubuntu-20.04-apalis-imx8.rootfs.tar . && cd ..
rootfs_size=$(( $(wc -c < ../image/ubuntu-20.04-apalis-imx8.rootfs.tar) / 1024 / 1024 ))

# Copy imx boot
cp imx-mkimage/iMX8QM/imx-boot ../image/imx-boot 

# Toradex easy installer config
cat > ../image/image.json << EOF
{
    "config_format": "4",
    "autoinstall": false,
    "name": "Ubuntu 20.04",
    "description": "Ubuntu 20.04 based on Toradex Linux 5.4.77",
    "version": "Ubuntu_20.04_Toradex_5.4.77",
    "wrapup_script": "wrapup.sh", 
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
                        "filename": "ubuntu-20.04-apalis-imx8.bootfs.tar",
                        "uncompressed_size": ${bootfs_size}
                    }
                },
                {
                    "partition_size_nominal": 1024,
                    "want_maximised": true,
                    "content": {
                        "label": "root",
                        "filesystem_type": "ext4",
                        "mkfs_options": "-E nodiscard",
                        "filename": "ubuntu-20.04-apalis-imx8.rootfs.tar",
                        "uncompressed_size": ${rootfs_size}
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

# Shutdown after install
cat > ../image/wrapup.sh << EOF
#!/bin/sh

echo 1 > /proc/sys/kernel/sysrq 
echo o > /proc/sysrq-trigger
echo b > /proc/sysrq-trigger

exit 0
EOF
