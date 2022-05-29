## Overview

This is a collection of scripts that are used to build a minimial Ubuntu 20.04 installation for the [Apalis iMX8 QuadMax](https://www1.toradex.com/computer-on-modules/apalis-arm-family/nxp-imx-8) and [Ixora Carrier Board](https://www.toradex.com/products/carrier-board/ixora-carrier-board) from Toradex.

![Apalis iMX8 QuadMax and Ixora Carrier Board](https://docs.toradex.com/107141-carrier-board.png)

## Recommended Hardware

To setup the build environment for the Ubuntu 20.04 image creation, a Linux host with the following configuration is recommended. A host machine with adequate processing power and disk space is ideal as the build process can be severial gigabytes in size and can take alot of time.

* Intel Core i7 CPU (>= 8 cores)
* Strong internet connection
* 10 GB free disk space
* 16 GB RAM

## Requirements

Please install the below packages on your host machine:

```
$ sudo apt-get install -y build-essential gcc-aarch64-linux-gnu bison \
qemu-user-static u-boot-tools binfmt-support debootstrap flex libssl-dev
```

## Building

To checkout the source and build:

```
$ git clone https://github.com/Joshua-Riek/ubuntu-apalis-imx8.git
$ cd ubuntu-apalis-imx8
$ sudo ./build-kernel.sh && sudo ./build-imx-boot.sh && sudo ./build-rootfs.sh
```

## Project Layout

```shell
ubuntu-apalis-imx8
├── build-imx-boot.sh   # Build U-Boot and the imx boot container
├── build-kernel.sh     # Build the Linux kernel and Device Tree Blobs
├── build-rootfs.sh     # Create the root file system
├── make-disk.sh        # Write the Ubuntu image to usb/sdcard
├── make-installer.sh   # Write the Ubuntu installation image to usb/sdcard
├── patch
│   └── 001-increase-spi-fifo-size.patch
└── README.md
```

## Boot log

```
U-Boot 2020.04-06956-gfef4b016a4 (May 29 2022 - 15:35:18 -0400)

CPU:   NXP i.MX8QM RevB A53 at 1200 MHz

DRAM:  4 GiB
MMC:   FSL_SDHC: 0, FSL_SDHC: 1, FSL_SDHC: 2
Loading Environment from MMC... *** Warning - bad CRC, using default environment

In:    serial
Out:   serial
Err:   serial
Model: Toradex Apalis iMX8 QuadMax 4GB Wi-Fi / BT IT V1.1C, Serial# 07039853

 BuildInfo: 
  - SCFW 0d54291f, SECO-FW d63fdb21, IMX-MKIMAGE 6a315dbc, ATF 
  - U-Boot 2020.04-06956-gfef4b016a4 

switch to partitions #0, OK
mmc0(part 0) is current device
flash target is MMC:0
Net:   eth0: ethernet@5b040000
Fastboot: Normal
Normal Boot
Hit any key to stop autoboot:  0 
MMC: no card present
MMC: no card present
switch to partitions #0, OK
mmc0(part 0) is current device
Scanning mmc 0:1...
Found U-Boot script /boot.scr
2109 bytes read in 27 ms (76.2 KiB/s)
## Executing script at 83100000
starting USB...
Bus usb@5b0d0000: usb dr_mode not found
Port not available.
Bus usbh3: XHCI-imx8 init hccr 0x000000005b130000 and hcor 0x000000005b130080 hc_length 128
Register 2000820 NbrPorts 2
Starting the controller
USB XHCI 1.00
scanning bus usbh3 for devices... 1 USB Device(s) found
       scanning usb for storage devices... 0 Storage Device(s) found

Device 1: unknown device

Device 0: unknown device
MMC: no card present
switch to partitions #0, OK
mmc0(part 0) is current device
Loading DeviceTree: imx8qm-apalis-v1.1-ixora-v1.2.dtb
169408 bytes read in 31 ms (5.2 MiB/s)
Applying Overlay: overlays/apalis-imx8_hdmi_overlay.dtbo
2049 bytes read in 36 ms (54.7 KiB/s)
Loading Kernel: vmlinuz
10460362 bytes read in 338 ms (29.5 MiB/s)
Uncompressed size: 24826368 = 0x17AD200
Loading Ramdisk: initrd
10346270 bytes read in 338 ms (29.2 MiB/s)
Bootargs: console=ttyLP1,115200 console=tty1 pci=nomsi root=PARTUUID=38bd731b-02 rootfstype=ext4 rootwait rw
## Flattened Device Tree blob at 83000000
   Booting using the fdt blob at 0x83000000
   Loading Ramdisk to fcc6f000, end fd64cf1e ... OK
   Loading Device Tree to 00000000fcc40000, end 00000000fcc6efff ... OK

Starting kernel ...

[    0.000000] Booting Linux on physical CPU 0x0000000000 [0x410fd034]
[    0.000000] Linux version 5.4.193-toradex (root@joshua-MS-7B10) (gcc version 9.4.0 (Ubuntu 9.4.0-1ubuntu1~20.04.1)) #1 SMP PREEMPT Sun May 29 15:30:47 EDT 2022
[    0.000000] Machine model: Toradex Apalis iMX8QM V1.1 on Apalis Ixora V1.2 Carrier Board
[    0.000000] efi: Getting EFI parameters from FDT:
[    0.000000] efi: UEFI not found.
[    0.000000] Reserved memory: created DMA memory pool at 0x0000000090400000, size 1 MiB
[    0.000000] OF: reserved mem: initialized node vdevbuffer, compatible id shared-dma-pool
[    0.000000] cma: Reserved 320 MiB at 0x00000000e8000000
[    0.000000] NUMA: No NUMA configuration found
[    0.000000] NUMA: Faking a node at [mem 0x0000000080200000-0x00000008ffffffff]
[    0.000000] NUMA: NODE_DATA [mem 0x8ff7c0500-0x8ff7c1fff]
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x0000000080200000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x00000008ffffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000080200000-0x0000000083ffffff]
[    0.000000]   node   0: [mem 0x0000000086400000-0x0000000087ffffff]
[    0.000000]   node   0: [mem 0x0000000090000000-0x00000000901fffff]
[    0.000000]   node   0: [mem 0x0000000090500000-0x0000000091ffffff]
[    0.000000]   node   0: [mem 0x0000000094c00000-0x0000000094ffffff]
[    0.000000]   node   0: [mem 0x0000000095400000-0x00000000ffffffff]
[    0.000000]   node   0: [mem 0x0000000880000000-0x00000008ffffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000080200000-0x00000008ffffffff]
[    0.000000] On node 0 totalpages: 993024
[    0.000000]   DMA32 zone: 7324 pages used for memmap
[    0.000000]   DMA32 zone: 0 pages reserved
[    0.000000]   DMA32 zone: 468736 pages, LIFO batch:63
[    0.000000]   Normal zone: 8192 pages used for memmap
[    0.000000]   Normal zone: 524288 pages, LIFO batch:63
[    0.000000] psci: probing for conduit method from DT.
[    0.000000] psci: PSCIv1.1 detected in firmware.
[    0.000000] psci: Using standard PSCI v0.2 function IDs
[    0.000000] psci: MIGRATE_INFO_TYPE not supported.
[    0.000000] psci: SMC Calling Convention v1.1
[    0.000000] percpu: Embedded 24 pages/cpu s58904 r8192 d31208 u98304
[    0.000000] pcpu-alloc: s58904 r8192 d31208 u98304 alloc=24*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3 [0] 4 [0] 5 
[    0.000000] Detected VIPT I-cache on CPU0
[    0.000000] CPU features: detected: ARM erratum 845719
[    0.000000] CPU features: detected: GIC system register CPU interface
[    0.000000] Speculative Store Bypass Disable mitigation not required
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 977508
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: console=ttyLP1,115200 console=tty1 pci=nomsi root=PARTUUID=38bd731b-02 rootfstype=ext4 rootwait rw
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes, linear)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes, linear)
[    0.000000] mem auto-init: stack:off, heap alloc:off, heap free:off
[    0.000000] software IO TLB: mapped [mem 0xe4000000-0xe8000000] (64MB)
[    0.000000] Memory: 3462228K/3972096K available (14332K kernel code, 1012K rwdata, 6264K rodata, 2560K init, 1017K bss, 182188K reserved, 327680K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=6, Nodes=1
[    0.000000] rcu: Preemptible hierarchical RCU implementation.
[    0.000000] rcu: 	RCU restricting CPUs from NR_CPUS=256 to nr_cpu_ids=6.
[    0.000000] 	Tasks RCU enabled.
[    0.000000] rcu: RCU calculated value of scheduler-enlistment delay is 25 jiffies.
[    0.000000] rcu: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=6
[    0.000000] NR_IRQS: 64, nr_irqs: 64, preallocated irqs: 0
[    0.000000] GICv3: GIC: Using split EOI/Deactivate mode
[    0.000000] GICv3: 512 SPIs implemented
[    0.000000] GICv3: 0 Extended SPIs implemented
[    0.000000] GICv3: Distributor has no Range Selector support
[    0.000000] GICv3: 16 PPIs implemented
[    0.000000] GICv3: no VLPI support, no direct LPI support
[    0.000000] GICv3: CPU0: found redistributor 0 region 0:0x0000000051b00000
[    0.000000] ITS: No ITS available, not enabling LPIs
[    0.000000] random: get_random_bytes called from start_kernel+0x2b8/0x440 with crng_init=0
[    0.000000] arch_timer: cp15 timer(s) running at 8.00MHz (phys).
[    0.000000] clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0x1d854df40, max_idle_ns: 440795202120 ns
[    0.000003] sched_clock: 56 bits at 8MHz, resolution 125ns, wraps every 2199023255500ns
[    0.000722] Console: colour dummy device 80x25
[    0.001212] printk: console [tty1] enabled
[    0.001294] Calibrating delay loop (skipped), value calculated using timer frequency.. 16.00 BogoMIPS (lpj=32000)
[    0.001314] pid_max: default: 32768 minimum: 301
[    0.001396] LSM: Security Framework initializing
[    0.001468] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes, linear)
[    0.001497] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes, linear)
[    0.002930] ASID allocator initialised with 32768 entries
[    0.003011] rcu: Hierarchical SRCU implementation.
[    0.005408] EFI services will not be available.
[    0.005647] smp: Bringing up secondary CPUs ...
[    0.006416] Detected VIPT I-cache on CPU1
[    0.006445] GICv3: CPU1: found redistributor 1 region 0:0x0000000051b20000
[    0.006480] CPU1: Booted secondary processor 0x0000000001 [0x410fd034]
[    0.007260] Detected VIPT I-cache on CPU2
[    0.007275] GICv3: CPU2: found redistributor 2 region 0:0x0000000051b40000
[    0.007293] CPU2: Booted secondary processor 0x0000000002 [0x410fd034]
[    0.008045] Detected VIPT I-cache on CPU3
[    0.008060] GICv3: CPU3: found redistributor 3 region 0:0x0000000051b60000
[    0.008076] CPU3: Booted secondary processor 0x0000000003 [0x410fd034]
[    0.009663] CPU features: detected: EL2 vector hardening
[    0.009674] CPU features: detected: Branch predictor hardening
[    0.009679] CPU features: detected: Spectre-BHB
[    0.009682] Detected PIPT I-cache on CPU4
[    0.009699] GICv3: CPU4: found redistributor 100 region 0:0x0000000051b80000
[    0.009717] CPU4: Booted secondary processor 0x0000000100 [0x410fd082]
[    0.010477] Detected PIPT I-cache on CPU5
[    0.010488] GICv3: CPU5: found redistributor 101 region 0:0x0000000051ba0000
[    0.010500] CPU5: Booted secondary processor 0x0000000101 [0x410fd082]
[    0.010557] smp: Brought up 1 node, 6 CPUs
[    0.010706] SMP: Total of 6 processors activated.
[    0.010717] CPU features: detected: 32-bit EL0 Support
[    0.010728] CPU features: detected: CRC32 instructions
[    0.020548] CPU: All CPU(s) started at EL2
[    0.020586] alternatives: patching kernel code
[    0.021659] devtmpfs: initialized
[    0.039792] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.039830] futex hash table entries: 2048 (order: 5, 131072 bytes, linear)
[    0.048903] pinctrl core: initialized pinctrl subsystem
[    0.049434] DMI not present or invalid.
[    0.049711] NET: Registered protocol family 16
[    0.056272] DMA: preallocated 256 KiB pool for atomic allocations
[    0.056293] audit: initializing netlink subsys (disabled)
[    0.056461] audit: type=2000 audit(0.052:1): state=initialized audit_enabled=0 res=1
[    0.057036] cpuidle: using governor menu
[    0.058587] hw-breakpoint: found 6 breakpoint and 4 watchpoint registers.
[    0.060517] Serial: AMBA PL011 UART driver
[    0.060570] imx mu driver is registered.
[    0.060594] imx rpmsg driver is registered.
[    0.114800] HugeTLB registered 1.00 GiB page size, pre-allocated 0 pages
[    0.114827] HugeTLB registered 32.0 MiB page size, pre-allocated 0 pages
[    0.114840] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    0.114852] HugeTLB registered 64.0 KiB page size, pre-allocated 0 pages
[    0.115999] cryptd: max_cpu_qlen set to 1000
[    0.119989] ACPI: Interpreter disabled.
[    0.122236] iommu: Default domain type: Translated 
[    0.122361] vgaarb: loaded
[    0.122645] SCSI subsystem initialized
[    0.122754] libata version 3.00 loaded.
[    0.122941] usbcore: registered new interface driver usbfs
[    0.122985] usbcore: registered new interface driver hub
[    0.123018] usbcore: registered new device driver usb
[    0.125040] mc: Linux media interface: v0.10
[    0.125074] videodev: Linux video capture interface: v2.00
[    0.125139] pps_core: LinuxPPS API ver. 1 registered
[    0.125150] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.125174] PTP clock support registered
[    0.125531] EDAC MC: Ver: 3.0.0
[    0.127199] No BMan portals available!
[    0.127624] QMan: Allocated lookup table at (____ptrval____), entry count 65537
[    0.128451] No QMan portals available!
[    0.129657] No USDPAA memory, no 'fsl,usdpaa-mem' in device-tree
[    0.130197] FPGA manager framework
[    0.130282] Advanced Linux Sound Architecture Driver Initialized.
[    0.131818] imx-scu scu: NXP i.MX SCU Initialized
[    0.138229] random: fast init done
[    0.180091] imx8qm-pinctrl scu:pinctrl: no groups defined in /scu/pinctrl/ledsixoragrp
[    0.180119] imx8qm-pinctrl scu:pinctrl: no groups defined in /scu/pinctrl/uart24forceoffgrp
[    0.180136] imx8qm-pinctrl scu:pinctrl: no groups defined in /scu/pinctrl/mmc1cdgrp_4bit
[    0.180153] imx8qm-pinctrl scu:pinctrl: no groups defined in /scu/pinctrl/usdhc2grp_4bit
[    0.180170] imx8qm-pinctrl scu:pinctrl: no groups defined in /scu/pinctrl/enable_3v3_vmmc
[    0.180187] imx8qm-pinctrl scu:pinctrl: no groups defined in /scu/pinctrl/enable_can1_power
[    0.180203] imx8qm-pinctrl scu:pinctrl: initialized IMX pinctrl driver
[    0.181131] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    0.184060] clocksource: Switched to clocksource arch_sys_counter
[    0.184233] VFS: Disk quotas dquot_6.6.0
[    0.184289] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.184482] pnp: PnP ACPI: disabled
[    0.217948] thermal_sys: Registered thermal governor 'step_wise'
[    0.217952] thermal_sys: Registered thermal governor 'power_allocator'
[    0.218825] NET: Registered protocol family 2
[    0.219059] IP idents hash table entries: 65536 (order: 7, 524288 bytes, linear)
[    0.220449] tcp_listen_portaddr_hash hash table entries: 2048 (order: 3, 32768 bytes, linear)
[    0.220509] TCP established hash table entries: 32768 (order: 6, 262144 bytes, linear)
[    0.220729] TCP bind hash table entries: 32768 (order: 7, 524288 bytes, linear)
[    0.221239] TCP: Hash tables configured (established 32768 bind 32768)
[    0.221348] UDP hash table entries: 2048 (order: 4, 65536 bytes, linear)
[    0.221432] UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes, linear)
[    0.221617] NET: Registered protocol family 1
[    0.221956] RPC: Registered named UNIX socket transport module.
[    0.221968] RPC: Registered udp transport module.
[    0.221978] RPC: Registered tcp transport module.
[    0.221987] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.222005] PCI: CLS 0 bytes, default 64
[    0.222215] Unpacking initramfs...
[    0.352378] Freeing initrd memory: 10100K
[    0.353175] hw perfevents: enabled with armv8_pmuv3 PMU driver, 7 counters available
[    0.354790] kvm [1]: IPA Size Limit: 40 bits
[    0.355440] kvm [1]: vgic-v2@52020000
[    0.355469] kvm [1]: GIC system register CPU interface enabled
[    0.355570] kvm [1]: vgic interrupt IRQ1
[    0.355712] kvm [1]: Hyp mode initialized successfully
[    0.359564] Initialise system trusted keyrings
[    0.359682] workingset: timestamp_bits=44 max_order=20 bucket_order=0
[    0.365685] NFS: Registering the id_resolver key type
[    0.365713] Key type id_resolver registered
[    0.365723] Key type id_legacy registered
[    0.365738] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[    0.365751] nfs4flexfilelayout_init: NFSv4 Flexfile Layout Driver Registering...
[    0.365782] jffs2: version 2.2. (NAND) © 2001-2006 Red Hat, Inc.
[    0.379649] Key type asymmetric registered
[    0.379662] Asymmetric key parser 'x509' registered
[    0.379697] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 244)
[    0.379713] io scheduler mq-deadline registered
[    0.379722] io scheduler kyber registered
[    0.393685] imx6q-pcie 5f000000.pcie: 5f000000.pcie supply epdev_on not found, using dummy regulator
[    0.395607] EINJ: ACPI disabled.
[    0.510817] mxs-dma 5b810000.dma-apbh: initialized
[    0.512520] Bus freq driver module loaded
[    0.518760] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.523116] 5a060000.serial: ttyLP0 at MMIO 0x5a060010 (irq = 47, base_baud = 5000000) is a FSL_LPUART
[    0.523455] fsl-lpuart 5a060000.serial: DMA tx channel request failed, operating without tx DMA
[    0.523474] fsl-lpuart 5a060000.serial: DMA rx channel request failed, operating without rx DMA
[    0.523830] 5a070000.serial: ttyLP1 at MMIO 0x5a070010 (irq = 48, base_baud = 5000000) is a FSL_LPUART
[    1.658128] printk: console [ttyLP1] enabled
[    1.663346] 5a080000.serial: ttyLP2 at MMIO 0x5a080010 (irq = 49, base_baud = 5000000) is a FSL_LPUART
[    1.672988] fsl-lpuart 5a080000.serial: DMA tx channel request failed, operating without tx DMA
[    1.681712] fsl-lpuart 5a080000.serial: DMA rx channel request failed, operating without rx DMA
[    1.690909] 5a090000.serial: ttyLP3 at MMIO 0x5a090010 (irq = 50, base_baud = 5000000) is a FSL_LPUART
[    1.703497] arm-smmu 51400000.iommu: probing hardware configuration...
[    1.710058] arm-smmu 51400000.iommu: SMMUv2 with:
[    1.714782] arm-smmu 51400000.iommu: 	stage 1 translation
[    1.720192] arm-smmu 51400000.iommu: 	stage 2 translation
[    1.725607] arm-smmu 51400000.iommu: 	nested translation
[    1.730938] arm-smmu 51400000.iommu: 	stream matching with 32 register groups
[    1.738092] arm-smmu 51400000.iommu: 	32 context banks (0 stage-2 only)
[    1.744732] arm-smmu 51400000.iommu: 	Supported page sizes: 0x61311000
[    1.751275] arm-smmu 51400000.iommu: 	Stage-1: 48-bit VA -> 48-bit IPA
[    1.757817] arm-smmu 51400000.iommu: 	Stage-2: 48-bit IPA -> 48-bit PA
[    1.835515] imx-drm display-subsystem: parent device of /bus@57240000/ldb@572410e0/lvds-channel@0 is not available
[    1.870062] loop: module loaded
[    1.873580] zram: Added device: zram0
[    1.881866] ahci-imx 5f020000.sata: Adding to iommu group 0
[    1.887652] ahci-imx 5f020000.sata: can't get sata_ext clock.
[    1.893779] imx ahci driver is registered.
[    1.905808] tun: Universal TUN/TAP device driver, 1.6
[    1.912539] fec 5b040000.ethernet: Adding to iommu group 1
[    1.918667] pps pps0: new PPS source ptp0
[    1.933560] Freescale FM module, FMD API version 21.1.0
[    1.939697] Freescale FM Ports module
[    1.945048] VFIO - User Level meta-driver version: 0.3
[    1.954293] cdns-usb3 5b110000.usb3: Adding to iommu group 2
[    1.961152] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.967703] ehci-pci: EHCI PCI platform driver
[    1.973499] usbcore: registered new interface driver usb-storage
[    1.979591] usbcore: registered new interface driver usbserial_generic
[    1.986171] usbserial: USB Serial support registered for generic
[    1.992217] usbcore: registered new interface driver cp210x
[    1.997814] usbserial: USB Serial support registered for cp210x
[    2.003776] usbcore: registered new interface driver ftdi_sio
[    2.009555] usbserial: USB Serial support registered for FTDI USB Serial Device
[    2.016897] usbcore: registered new interface driver pl2303
[    2.022520] usbserial: USB Serial support registered for pl2303
[    2.028493] usbcore: registered new interface driver usb_serial_simple
[    2.035049] usbserial: USB Serial support registered for carelink
[    2.041176] usbserial: USB Serial support registered for zio
[    2.046863] usbserial: USB Serial support registered for funsoft
[    2.052901] usbserial: USB Serial support registered for flashloader
[    2.059289] usbserial: USB Serial support registered for google
[    2.065243] usbserial: USB Serial support registered for libtransistor
[    2.071796] usbserial: USB Serial support registered for vivopay
[    2.077827] usbserial: USB Serial support registered for moto_modem
[    2.084123] usbserial: USB Serial support registered for motorola_tetra
[    2.090770] usbserial: USB Serial support registered for nokia
[    2.096632] usbserial: USB Serial support registered for novatel_gps
[    2.103012] usbserial: USB Serial support registered for hp4x
[    2.108789] usbserial: USB Serial support registered for suunto
[    2.114738] usbserial: USB Serial support registered for siemens_mpi
[    2.128114] input: sc-powerkey as /devices/platform/sc-powerkey/input/input0
[    2.137790] imx-sc-rtc scu:rtc: registered as rtc1
[    2.143227] i2c /dev entries driver
[    2.148760] pps_ldisc: PPS line discipline registered
[    2.162842] sdhci: Secure Digital Host Controller Interface driver
[    2.169072] sdhci: Copyright(c) Pierre Ossman
[    2.173960] Synopsys Designware Multimedia Card Interface Driver
[    2.181925] sdhci-pltfm: SDHCI platform and OF driver helper
[    2.189543] sdhci-esdhc-imx 5b010000.mmc: Adding to iommu group 3
[    2.227947] mmc0: SDHCI controller on 5b010000.mmc [5b010000.mmc] using ADMA
[    2.235453] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.243056] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.250263] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.257456] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.264676] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.271896] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.279104] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.286315] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.293602] sdhci-esdhc-imx 5b020000.mmc: Adding to iommu group 3
[    2.304340] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.312479] ledtrig-cpu: registered to indicate activity on CPUs
[    2.321160] caam 31400000.crypto: device ID = 0x0a16040000000100 (Era 9)
[    2.327928] caam 31400000.crypto: job rings = 2, qi = 0
[    2.349436] caam algorithms registered in /proc/crypto
[    2.356133] caam 31400000.crypto: caam pkc algorithms registered in /proc/crypto
[    2.363607] caam 31400000.crypto: registering rng-caam
[    2.369203] Device caam-keygen registered
[    2.378258] crng init done
[    2.378432] hidraw: raw HID events driver (C) Jiri Kosina
[    2.386590] usbcore: registered new interface driver usbhid
[    2.392177] usbhid: USB HID core driver
[    2.397018] mmc0: new HS400 MMC card at address 0001
[    2.399456] No fsl,qman node
[    2.402725] mmcblk0: mmc0:0001 S0J56X 14.8 GiB 
[    2.404934] Freescale USDPAA process driver
[    2.409755] mmcblk0boot0: mmc0:0001 S0J56X partition 1 31.5 MiB
[    2.413668] fsl-usdpaa: no region found
[    2.413669] Freescale USDPAA process IRQ driver
[    2.428615] mmcblk0boot1: mmc0:0001 S0J56X partition 2 31.5 MiB
[    2.434958] mmcblk0rpmb: mmc0:0001 S0J56X partition 3 4.00 MiB, chardev (237:0)
[    2.443755]  mmcblk0: p1 p2
[    2.457545] Galcore version 6.4.3.p1.305572
[    2.612682] [drm] Initialized vivante 1.0.0 20170808 for 80000000.imx8_gpu1_ss on minor 0
[    2.625005] [VPU Decoder] warning: init rtx channel failed, ret: -517
[    2.631506] [VPU Decoder] failed to request mailbox, ret = -517
[    2.641120] [VPU Encoder] warning:  init rtx channel failed, ret: -517
[    2.647668] [VPU Encoder] warning:  init rtx channel failed, ret: -517
[    2.654241] [VPU Encoder] fail to request mailbox, ret = -517
[    2.662873] dvbdev: DVB: registering new adapter (PPM DVB adapter)
[    2.669685] dvbdev: DVB: registering new adapter (PPM DVB adapter)
[    2.731879] imx-spdif sound-spdif: snd-soc-dummy-dai <-> 59020000.spdif mapping ok
[    2.739523] imx-spdif sound-spdif: ASoC: no DMI vendor name!
[    2.746315] imx-audmix imx-audmix.0: failed to find SAI platform device
[    2.752980] imx-audmix: probe of imx-audmix.0 failed with error -22
[    2.762469] pktgen: Packet Generator for packet performance testing. Version: 2.75
[    2.770799] NET: Registered protocol family 26
[    2.775567] NET: Registered protocol family 10
[    2.780468] Segment Routing with IPv6
[    2.784193] NET: Registered protocol family 17
[    2.788662] tsn generic netlink module v1 init...
[    2.793405] Key type dns_resolver registered
[    2.797929] registered taskstats version 1
[    2.802042] Loading compiled-in X.509 certificates
[    2.824802] mxs_phy 5b100000.usbphy: 5b100000.usbphy supply phy-3p0 not found, using dummy regulator
[    2.844463] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.851859] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.859750] usb_phy_generic bus@5b000000:usb3-phy: bus@5b000000:usb3-phy supply vcc not found, using dummy regulator
[    2.870394] usb_phy_generic bus@5b000000:usbphynop2: bus@5b000000:usbphynop2 supply vcc not found, using dummy regulator
[    2.881964] imx-lpi2c 5a800000.i2c: can't get pinctrl, bus recovery not supported
[    2.889676] i2c i2c-2: LPI2C adapter registered
[    2.897041] sgtl5000 3-000a: sgtl5000 revision 0x11
[    2.943063] usb3503 3-0008: switched to HUB mode
[    2.947721] usb3503 3-0008: usb3503_probe: probed in hub mode
[    2.953575] i2c i2c-3: LPI2C adapter registered
[    2.961420] rtc-ds1307 4-0068: registered as rtc0
[    2.966716] at24 4-0050: 256 byte 24c02 EEPROM, writable, 16 bytes/write
[    2.973467] i2c i2c-4: LPI2C adapter registered
[    2.978855] i2c i2c-5: LPI2C adapter registered
[    2.987448] pwm-backlight backlight: backlight supply power not found, using dummy regulator
[    2.987677] imx6q-pcie 5f000000.pcie: 5f000000.pcie supply epdev_on not found, using dummy regulator
[    2.987743] imx6q-pcie 5f010000.pcie: pcie_ext clock source missing or invalid
[    3.002309] dpu-core 56180000.dpu: driver probed
[    3.005317] imx6q-pcie 5f000000.pcie: No cache used with register defaults set!
[    3.013788] dpu-core 57180000.dpu: driver probed
[    3.029126] ahci-imx 5f020000.sata: phy impedance ratio is not specified.
[    3.035972] ahci-imx 5f020000.sata: No cache used with register defaults set!
[    3.043292] ahci-imx 5f020000.sata: 5f020000.sata supply ahci not found, using dummy regulator
[    3.051960] ahci-imx 5f020000.sata: 5f020000.sata supply phy not found, using dummy regulator
[    3.060535] ahci-imx 5f020000.sata: 5f020000.sata supply target not found, using dummy regulator
[    3.069526] ahci-imx 5f020000.sata: external osc is used.
[    3.077752] ahci-imx 5f020000.sata: no ahb clock.
[    3.082504] ahci-imx 5f020000.sata: AHCI 0001.0301 32 slots 1 ports 6 Gbps 0x1 impl platform mode
[    3.091407] ahci-imx 5f020000.sata: flags: 64bit ncq sntf pm clo only pmp fbs pio slum part ccc sadm sds apst 
[    3.102119] scsi host0: ahci-imx
[    3.105574] ata1: SATA max UDMA/133 mmio [mem 0x5f020000-0x5f02ffff] port 0x100 irq 105
[    3.117551] pps pps0: new PPS source ptp0
[    3.126373] imx6q-pcie 5f000000.pcie: PCIe PLL locked after 0 us.
[    3.132467] fec 5b040000.ethernet eth0: registered PHC device 0
[    3.142362]  xhci-cdns3: xHCI Host Controller
[    3.146747]  xhci-cdns3: new USB bus registered, assigned bus number 1
[    3.154657]  xhci-cdns3: hcc params 0x200073c8 hci version 0x100 quirks 0x0000001000018010
[    3.163594] hub 1-0:1.0: USB hub found
[    3.167371] hub 1-0:1.0: 1 port detected
[    3.171431]  xhci-cdns3: xHCI Host Controller
[    3.175802]  xhci-cdns3: new USB bus registered, assigned bus number 2
[    3.182351]  xhci-cdns3: Host supports USB 3.0 SuperSpeed
[    3.187785] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
[    3.196294] hub 2-0:1.0: USB hub found
[    3.200070] hub 2-0:1.0: 1 port detected
[    3.205096] imx_usb 5b0d0000.usb: 5b0d0000.usb supply vbus not found, using dummy regulator
[    3.348161] imx6q-pcie 5f000000.pcie: host bridge /bus@5f000000/pcie@0x5f000000 ranges:
[    3.356227] imx6q-pcie 5f000000.pcie:    IO 0x6ff80000..0x6ff8ffff -> 0x00000000
[    3.363645] imx6q-pcie 5f000000.pcie:   MEM 0x60000000..0x6fefffff -> 0x60000000
[    3.520793] ci_hdrc ci_hdrc.1: EHCI Host Controller
[    3.525733] ci_hdrc ci_hdrc.1: new USB bus registered, assigned bus number 3
[    3.548078] ci_hdrc ci_hdrc.1: USB 2.0 started, EHCI 1.00
[    3.554347] hub 3-0:1.0: USB hub found
[    3.558166] hub 3-0:1.0: 1 port detected
[    3.563506] gpio-fan gpio-fan: GPIO fan initialized
[    3.568813] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.575972] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.583125] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.588105] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    3.590282] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.597237] ata1.00: supports DRM functions and may not be fully accessible
[    3.603631] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.603638] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.603644] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.603649] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.639580] ata1.00: ATA-10: KINGSTON SKC600MS256G, S4800105, max UDMA/133
[    3.646491] ata1.00: 500118192 sectors, multi 1: LBA48 NCQ (depth 32)
[    3.653422] sdhci-esdhc-imx 5b020000.mmc: Got CD GPIO
[    3.653827] ata1.00: supports DRM functions and may not be fully accessible
[    3.666009] ata1.00: configured for UDMA/133
[    3.690396] mmc1: SDHCI controller on 5b020000.mmc [5b020000.mmc] using ADMA
[    3.698148] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.727222] debugfs: Directory '59050000.sai' with parent 'apalis-imx8qm-sgtl5000' already present!
[    3.736859] asoc-simple-card sound: sgtl5000 <-> 59050000.sai mapping ok
[    3.743582] asoc-simple-card sound: ASoC: no DMI vendor name!
[    3.753617] imx8qxp-lpcg-clk 5b260000.clock-controller: ignoring dependency for device, assuming no driver
[    3.753883] imx6q-pcie 5f010000.pcie: No cache used with register defaults set!
[    3.772218] rtc-ds1307 4-0068: setting system clock to 2022-05-29T21:05:20 UTC (1653858320)
[    3.773553] imx6q-pcie 5f010000.pcie: PCIe PLL locked after 0 us.
[    3.788944] ALSA device list:
[    3.791933]   #0: imx-spdif
[    3.794779]   #1: apalis-imx8qm-sgtl5000
[    3.968100] usb 3-1: new high-speed USB device number 2 using ci_hdrc
[    4.000151] imx6q-pcie 5f010000.pcie: host bridge /bus@5f000000/pcie@0x5f010000 ranges:
[    4.008237] imx6q-pcie 5f010000.pcie:    IO 0x7ff80000..0x7ff8ffff -> 0x00000000
[    4.015918] imx6q-pcie 5f010000.pcie:   MEM 0x70000000..0x7fefffff -> 0x70000000
[    4.123512] imx6q-pcie 5f010000.pcie: Link up
[    4.127923] imx6q-pcie 5f010000.pcie: Link: Gen2 disabled
[    4.133615] imx6q-pcie 5f010000.pcie: Link up, Gen1
[    4.138638] imx6q-pcie 5f010000.pcie: PCI host bridge to bus 0000:00
[    4.145041] pci_bus 0000:00: root bus resource [bus 00-ff]
[    4.150962] pci_bus 0000:00: root bus resource [io  0x10000-0x1ffff] (bus address [0x0000-0xffff])
[    4.160008] hub 3-1:1.0: USB hub found
[    4.163784] pci_bus 0000:00: root bus resource [mem 0x70000000-0x7fefffff]
[    4.170669] hub 3-1:1.0: 3 ports detected
[    4.174713] pci 0000:00:00.0: [1957:0000] type 01 class 0x060400
[    4.180795] pci 0000:00:00.0: reg 0x10: [mem 0x00000000-0x00ffffff]
[    4.187098] pci 0000:00:00.0: reg 0x38: [mem 0x00000000-0x00ffffff pref]
[    4.193933] pci 0000:00:00.0: supports D1 D2
[    4.198225] pci 0000:00:00.0: PME# supported from D0 D1 D2 D3hot
[    4.208017] pci 0000:01:00.0: [1b4b:2b42] type 00 class 0x020000
[    4.214137] pci 0000:01:00.0: reg 0x10: [mem 0x00000000-0x000fffff 64bit pref]
[    4.221410] pci 0000:01:00.0: reg 0x18: [mem 0x00000000-0x000fffff 64bit pref]
[    4.228917] pci 0000:01:00.0: supports D1 D2
[    4.233197] pci 0000:01:00.0: PME# supported from D0 D1 D3hot D3cold
[    4.239673] pci 0000:01:00.0: 2.000 Gb/s available PCIe bandwidth, limited by 2.5 GT/s x1 link at 0000:00:00.0 (capable of 4.000 Gb/s with 5 GT/s x1 link)
[    4.272866] pci 0000:00:00.0: BAR 0: assigned [mem 0x70000000-0x70ffffff]
[    4.279739] pci 0000:00:00.0: BAR 6: assigned [mem 0x71000000-0x71ffffff pref]
[    4.287232] pci 0000:00:00.0: BAR 15: assigned [mem 0x72000000-0x721fffff 64bit pref]
[    4.295082] pci 0000:01:00.0: BAR 0: assigned [mem 0x72000000-0x720fffff 64bit pref]
[    4.302861] pci 0000:01:00.0: BAR 2: assigned [mem 0x72100000-0x721fffff 64bit pref]
[    4.310648] pci 0000:00:00.0: PCI bridge to [bus 01-ff]
[    4.315877] pci 0000:00:00.0:   bridge window [mem 0x72000000-0x721fffff 64bit pref]
[    4.323916] pcieport 0000:00:00.0: PME: Signaling with IRQ 567
[    4.360082] imx6q-pcie 5f000000.pcie: Phy link never came up
[    4.365789] imx6q-pcie 5f000000.pcie: failed to initialize host
[    4.371737] imx6q-pcie 5f000000.pcie: unable to add pcie port.
[    4.492099] usb 3-1.3: new high-speed USB device number 3 using ci_hdrc
[    4.916084] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    4.923041] ata1.00: supports DRM functions and may not be fully accessible
[    4.930701] ata1.00: supports DRM functions and may not be fully accessible
[    4.938319] ata1.00: configured for UDMA/133
[    4.942710] scsi 0:0:0:0: Direct-Access     ATA      KINGSTON SKC600M 0105 PQ: 0 ANSI: 5
[    4.951188] sd 0:0:0:0: [sda] 500118192 512-byte logical blocks: (256 GB/238 GiB)
[    4.958695] sd 0:0:0:0: [sda] 4096-byte physical blocks
[    4.963960] sd 0:0:0:0: [sda] Write Protect is off
[    4.968761] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    4.968796] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    4.979477]  sda: sda1
[    4.982483] sd 0:0:0:0: [sda] Attached SCSI disk
[    4.988857] Freeing unused kernel memory: 2560K
[    5.004175] Run /init as init process
[    5.781125] EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null)
[    6.034721] systemd[1]: systemd 245.4-4ubuntu3.17 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCRE2 default-hierarchy=hybrid)
[    6.058136] systemd[1]: Detected architecture arm64.
[    6.084731] systemd[1]: Set hostname to <apalis-imx8qm>.
[    6.420752] systemd[1]: Created slice system-modprobe.slice.
[    6.427739] systemd[1]: Created slice system-serial\x2dgetty.slice.
[    6.434910] systemd[1]: Created slice system-systemd\x2dfsck.slice.
[    6.442311] systemd[1]: Created slice User and Session Slice.
[    6.448420] systemd[1]: Started Dispatch Password Requests to Console Directory Watch.
[    6.456803] systemd[1]: Started Forward Password Requests to Wall Directory Watch.
[    6.464647] systemd[1]: Condition check resulted in Arbitrary Executable File Formats File System Automount Point being skipped.
[    6.476365] systemd[1]: Reached target Local Encrypted Volumes.
[    6.482504] systemd[1]: Reached target Paths.
[    6.487037] systemd[1]: Reached target Remote File Systems.
[    6.492765] systemd[1]: Reached target Slices.
[    6.497389] systemd[1]: Reached target Swap.
[    6.502226] systemd[1]: Listening on Syslog Socket.
[    6.507514] systemd[1]: Listening on fsck to fsckd communication Socket.
[    6.514549] systemd[1]: Listening on initctl Compatibility Named Pipe.
[    6.521837] systemd[1]: Listening on Journal Audit Socket.
[    6.527706] systemd[1]: Listening on Journal Socket (/dev/log).
[    6.534083] systemd[1]: Listening on Journal Socket.
[    6.539493] systemd[1]: Listening on udev Control Socket.
[    6.545219] systemd[1]: Listening on udev Kernel Socket.
[    6.554051] systemd[1]: Mounting Huge Pages File System...
[    6.563290] systemd[1]: Mounting POSIX Message Queue File System...
[    6.573738] systemd[1]: Mounting Kernel Debug File System...
[    6.580211] systemd[1]: Condition check resulted in Kernel Trace File System being skipped.
[    6.593613] systemd[1]: Starting Journal Service...
[    6.602785] systemd[1]: Starting Set the console keyboard layout...
[    6.613815] systemd[1]: Starting Create list of static device nodes for the current kernel...
[    6.622827] systemd[1]: Condition check resulted in Load Kernel Module drm being skipped.
[    6.632480] systemd[1]: Condition check resulted in Set Up Additional Binary Formats being skipped.
[    6.641711] systemd[1]: Condition check resulted in File System Check on Root Device being skipped.
[    6.654617] systemd[1]: Starting Load Kernel Modules...
[    6.663194] systemd[1]: Starting Remount Root and Kernel File Systems...
[    6.672761] systemd[1]: Starting udev Coldplug all Devices...
[    6.681785] systemd[1]: Mounted Huge Pages File System.
[    6.685489] EXT4-fs (mmcblk0p2): re-mounted. Opts: (null)
[    6.694240] systemd[1]: Mounted POSIX Message Queue File System.
[    6.700932] systemd[1]: Mounted Kernel Debug File System.
[    6.708208] systemd[1]: Finished Create list of static device nodes for the current kernel.
[    6.718440] systemd[1]: Finished Load Kernel Modules.
[    6.725077] systemd[1]: Finished Remount Root and Kernel File Systems.
[    6.732445] systemd[1]: Condition check resulted in FUSE Control File System being skipped.
[    6.741252] systemd[1]: Condition check resulted in Kernel Configuration File System being skipped.
[    6.753867] systemd[1]: Condition check resulted in Rebuild Hardware Database being skipped.
[    6.762754] systemd[1]: Condition check resulted in Platform Persistent Storage Archival being skipped.
[    6.775411] systemd[1]: Starting Load/Save Random Seed...
[    6.784548] systemd[1]: Starting Apply Kernel Variables...
[    6.793279] systemd[1]: Starting Create System Users...
[    6.806628] systemd[1]: Started Journal Service.
[    6.844720] systemd-journald[463]: Received client request to flush runtime journal.
[    7.255423] [VPU Encoder] enable mu for core[0]
[    7.263082] [VPU Encoder] vpu encoder core[0] firmware version is 1.3.1
[    7.300466] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[    7.300471] [drm] No driver support for vblank timestamp query.
[    7.300590] imx-drm display-subsystem: bound imx-drm-dpu-bliteng.2 (ops dpu_bliteng_ops)
[    7.300665] imx-drm display-subsystem: bound imx-drm-dpu-bliteng.5 (ops dpu_bliteng_ops)
[    7.302271] imx-drm display-subsystem: bound imx-dpu-crtc.0 (ops dpu_crtc_ops)
[    7.303848] imx-drm display-subsystem: bound imx-dpu-crtc.1 (ops dpu_crtc_ops)
[    7.304215] imx-drm display-subsystem: bound imx-dpu-crtc.3 (ops dpu_crtc_ops)
[    7.304534] imx-drm display-subsystem: bound imx-dpu-crtc.4 (ops dpu_crtc_ops)
[    7.330575] mxc-jpeg 58400000.jpegdec: decoder device registered as /dev/video0 (81,2)
[    7.334971] mxc-jpeg 58450000.jpegenc: encoder device registered as /dev/video1 (81,3)
[    7.353908] CAN device driver interface
[    7.378416] [drm] Started firmware!
[    7.379536] [drm] HDP FW Version - ver 34559 verlib 20560
[    7.379820] cdns-mhdp-imx 56268000.hdmi: lane-mapping 0x93
[    7.392312] imx-drm display-subsystem: bound 56268000.hdmi (ops cdns_mhdp_imx_ops [cdns_mhdp_imx])
[    7.394282] [drm] Initialized imx-drm 1.0.0 20120507 for display-subsystem on minor 1
[    7.423579] cdns-mhdp-imx 56268000.hdmi: 0,ff,ff,ff,ff,ff,ff,0
[    7.429485] [drm] Mode: 1920x1080p148500
[    7.453652] cfg80211: Loading compiled-in X.509 certificates for regulatory database
[    7.456118] [drm] Pixel clock: 148500 KHz, character clock: 148500, bpc is 8-bit.
[    7.456127] [drm] VCO frequency is 2970000 KHz
[    7.473549] cfg80211: Loaded X.509 cert 'sforshee: 00b28ddf47aef9cea7'
[    7.473698] platform regulatory.0: Direct firmware load for regulatory.db failed with error -2
[    7.473704] cfg80211: failed to load regulatory.db
[    7.525525] lib80211: common routines for IEEE802.11 drivers
[    7.525534] lib80211_crypt: registered algorithm 'NULL'
[    7.538321] r8188eu: module is from the staging directory, the quality is unknown, you have been warned.
[    7.545775] debugfs: Directory '59090000.sai' with parent 'imx-audio-hdmi-tx' already present!
[    7.554069] mwifiex_pcie 0000:01:00.0: enabling device (0000 -> 0002)
[    7.554247] mwifiex_pcie: PCI memory map Virt0: ffff800024f00000 PCI memory map Virt2: ffff800025100000
[    7.555441] [drm] Sink Not Support SCDC
[    7.558627] [drm] No vendor infoframe
[    7.560831] imx-cdnhdmi sound-hdmi: i2s-hifi <-> 59090000.sai mapping ok
[    7.560867] imx-cdnhdmi sound-hdmi: ASoC: no DMI vendor name!
[    7.560937] debugfs: File 'Capture' in directory 'dapm' already present!
[    7.561259] input: imx-audio-hdmi-tx HDMI Jack as /devices/platform/sound-hdmi/sound/card2/input1
[    7.563188] Chip Version Info: CHIP_8188E_Normal_Chip_TSMC_D_CUT_1T1R_RomVer(0)
[    7.621404] usbcore: registered new interface driver r8188eu
[    7.629935] r8188eu 3-1.3:1.0 wlx34c9f092281a: renamed from wlan0
[    7.632532] Console: switching to colour frame buffer device 240x67
[    7.676856] imx-drm display-subsystem: fb0: imx-drmdrmfb frame buffer device
[    8.210890] Microchip KSZ9131 Gigabit PHY 5b040000.ethernet-1:07: attached PHY driver [Microchip KSZ9131 Gigabit PHY] (mii_bus:phy_addr=5b040000.ethernet-1:07, irq=304)
[    8.386756] Process accounting resumed
[    8.648262] mwifiex_pcie 0000:01:00.0: info: FW download over, size 634228 bytes
[    8.952380] switch cluster 0 cpu-freq governor to schedutil
[    8.976326] switch cluster 1 cpu-freq governor to schedutil
[    8.992787] MAC Address = 34:c9:f0:92:28:1a
[    9.149285] [drm] HDMI Cable Plug Out
[    9.427385] cdns-mhdp-imx 56268000.hdmi: 0,ff,ff,ff,ff,ff,ff,0
[    9.428583] [drm] Mode: 1920x1080p148500
[    9.456089] [drm] Pixel clock: 148500 KHz, character clock: 148500, bpc is 8-bit.
[    9.456097] [drm] VCO frequency is 2970000 KHz
[    9.508180] [drm] Sink Not Support SCDC
[    9.509696] [drm] No vendor infoframe
[    9.512073] mwifiex_pcie 0000:01:00.0: WLAN FW is active
[    9.551938] mwifiex_pcie 0000:01:00.0: Unknown api_id: 3
[    9.551950] mwifiex_pcie 0000:01:00.0: Unknown api_id: 4
[    9.551959] mwifiex_pcie 0000:01:00.0: Unknown GET_HW_SPEC TLV type: 0x217
[    9.581447] [drm] HDMI Cable Plug In
[    9.648137] usb 3-1.1: new high-speed USB device number 4 using ci_hdrc
[    9.800488] Bluetooth: Core ver 2.22
[    9.800615] NET: Registered protocol family 31
[    9.800618] Bluetooth: HCI device and connection manager initialized
[    9.800639] Bluetooth: HCI socket layer initialized
[    9.800646] Bluetooth: L2CAP socket layer initialized
[    9.800662] Bluetooth: SCO socket layer initialized
[    9.811381] usbcore: registered new interface driver btusb
[    9.812813] Bluetooth: hci0: unexpected event for opcode 0x0000
[   10.437012] mwifiex_pcie 0000:01:00.0: info: MWIFIEX VERSION: mwifiex 1.0 (16.68.1.p195) 
[   10.437024] mwifiex_pcie 0000:01:00.0: driver_version = mwifiex 1.0 (16.68.1.p195) 
[   10.447117] mwifiex_pcie 0000:01:00.0 wlp1s0: renamed from mlan0
[   10.511641] R8188EU: assoc success
[   10.552691] IPv6: ADDRCONF(NETDEV_CHANGE): wlx34c9f092281a: link becomes ready
```
