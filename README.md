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

Please install the below packages on your host machine. 

```
$ sudo apt-get install -y build-essential gcc-aarch64-linux-gnu qemu-user-static \
u-boot-tools binfmt-support debootstrap flex bison libssl-dev
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
2049 bytes read in 37 ms (53.7 KiB/s)
Loading Kernel: vmlinuz
10460362 bytes read in 337 ms (29.6 MiB/s)
Uncompressed size: 24826368 = 0x17AD200
Loading Ramdisk: initrd
10346199 bytes read in 338 ms (29.2 MiB/s)
Bootargs: console=ttyLP1,115200 console=tty1 pci=nomsi root=PARTUUID=af41fec5-02 rootfstype=ext4 rootwait rw
## Flattened Device Tree blob at 83000000
   Booting using the fdt blob at 0x83000000
   Loading Ramdisk to fcc6f000, end fd64ced7 ... OK
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
[    0.000000] Kernel command line: console=ttyLP1,115200 console=tty1 pci=nomsi root=PARTUUID=af41fec5-02 rootfstype=ext4 rootwait rw
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
[    0.000726] Console: colour dummy device 80x25
[    0.001222] printk: console [tty1] enabled
[    0.001304] Calibrating delay loop (skipped), value calculated using timer frequency.. 16.00 BogoMIPS (lpj=32000)
[    0.001325] pid_max: default: 32768 minimum: 301
[    0.001406] LSM: Security Framework initializing
[    0.001478] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes, linear)
[    0.001507] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes, linear)
[    0.002943] ASID allocator initialised with 32768 entries
[    0.003023] rcu: Hierarchical SRCU implementation.
[    0.005424] EFI services will not be available.
[    0.005666] smp: Bringing up secondary CPUs ...
[    0.006439] Detected VIPT I-cache on CPU1
[    0.006467] GICv3: CPU1: found redistributor 1 region 0:0x0000000051b20000
[    0.006500] CPU1: Booted secondary processor 0x0000000001 [0x410fd034]
[    0.007283] Detected VIPT I-cache on CPU2
[    0.007298] GICv3: CPU2: found redistributor 2 region 0:0x0000000051b40000
[    0.007316] CPU2: Booted secondary processor 0x0000000002 [0x410fd034]
[    0.008079] Detected VIPT I-cache on CPU3
[    0.008092] GICv3: CPU3: found redistributor 3 region 0:0x0000000051b60000
[    0.008108] CPU3: Booted secondary processor 0x0000000003 [0x410fd034]
[    0.009691] CPU features: detected: EL2 vector hardening
[    0.009703] CPU features: detected: Branch predictor hardening
[    0.009708] CPU features: detected: Spectre-BHB
[    0.009711] Detected PIPT I-cache on CPU4
[    0.009727] GICv3: CPU4: found redistributor 100 region 0:0x0000000051b80000
[    0.009744] CPU4: Booted secondary processor 0x0000000100 [0x410fd082]
[    0.010501] Detected PIPT I-cache on CPU5
[    0.010512] GICv3: CPU5: found redistributor 101 region 0:0x0000000051ba0000
[    0.010524] CPU5: Booted secondary processor 0x0000000101 [0x410fd082]
[    0.010581] smp: Brought up 1 node, 6 CPUs
[    0.010729] SMP: Total of 6 processors activated.
[    0.010740] CPU features: detected: 32-bit EL0 Support
[    0.010751] CPU features: detected: CRC32 instructions
[    0.020575] CPU: All CPU(s) started at EL2
[    0.020613] alternatives: patching kernel code
[    0.021687] devtmpfs: initialized
[    0.039848] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.039888] futex hash table entries: 2048 (order: 5, 131072 bytes, linear)
[    0.049036] pinctrl core: initialized pinctrl subsystem
[    0.049570] DMI not present or invalid.
[    0.049881] NET: Registered protocol family 16
[    0.056433] DMA: preallocated 256 KiB pool for atomic allocations
[    0.056455] audit: initializing netlink subsys (disabled)
[    0.056629] audit: type=2000 audit(0.052:1): state=initialized audit_enabled=0 res=1
[    0.057207] cpuidle: using governor menu
[    0.058737] hw-breakpoint: found 6 breakpoint and 4 watchpoint registers.
[    0.060667] Serial: AMBA PL011 UART driver
[    0.060720] imx mu driver is registered.
[    0.060744] imx rpmsg driver is registered.
[    0.114934] HugeTLB registered 1.00 GiB page size, pre-allocated 0 pages
[    0.114960] HugeTLB registered 32.0 MiB page size, pre-allocated 0 pages
[    0.114972] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    0.114985] HugeTLB registered 64.0 KiB page size, pre-allocated 0 pages
[    0.116140] cryptd: max_cpu_qlen set to 1000
[    0.120101] ACPI: Interpreter disabled.
[    0.122347] iommu: Default domain type: Translated 
[    0.122471] vgaarb: loaded
[    0.122757] SCSI subsystem initialized
[    0.122867] libata version 3.00 loaded.
[    0.123048] usbcore: registered new interface driver usbfs
[    0.123093] usbcore: registered new interface driver hub
[    0.123127] usbcore: registered new device driver usb
[    0.125139] mc: Linux media interface: v0.10
[    0.125174] videodev: Linux video capture interface: v2.00
[    0.125240] pps_core: LinuxPPS API ver. 1 registered
[    0.125251] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.125275] PTP clock support registered
[    0.125632] EDAC MC: Ver: 3.0.0
[    0.127281] No BMan portals available!
[    0.127709] QMan: Allocated lookup table at (____ptrval____), entry count 65537
[    0.128543] No QMan portals available!
[    0.129746] No USDPAA memory, no 'fsl,usdpaa-mem' in device-tree
[    0.130283] FPGA manager framework
[    0.130370] Advanced Linux Sound Architecture Driver Initialized.
[    0.131917] imx-scu scu: NXP i.MX SCU Initialized
[    0.138321] random: fast init done
[    0.180190] imx8qm-pinctrl scu:pinctrl: no groups defined in /scu/pinctrl/ledsixoragrp
[    0.180218] imx8qm-pinctrl scu:pinctrl: no groups defined in /scu/pinctrl/uart24forceoffgrp
[    0.180236] imx8qm-pinctrl scu:pinctrl: no groups defined in /scu/pinctrl/mmc1cdgrp_4bit
[    0.180253] imx8qm-pinctrl scu:pinctrl: no groups defined in /scu/pinctrl/usdhc2grp_4bit
[    0.180270] imx8qm-pinctrl scu:pinctrl: no groups defined in /scu/pinctrl/enable_3v3_vmmc
[    0.180287] imx8qm-pinctrl scu:pinctrl: no groups defined in /scu/pinctrl/enable_can1_power
[    0.180303] imx8qm-pinctrl scu:pinctrl: initialized IMX pinctrl driver
[    0.181248] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    0.184181] clocksource: Switched to clocksource arch_sys_counter
[    0.184352] VFS: Disk quotas dquot_6.6.0
[    0.184409] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.184600] pnp: PnP ACPI: disabled
[    0.216890] thermal_sys: Registered thermal governor 'step_wise'
[    0.216894] thermal_sys: Registered thermal governor 'power_allocator'
[    0.217763] NET: Registered protocol family 2
[    0.217983] IP idents hash table entries: 65536 (order: 7, 524288 bytes, linear)
[    0.219348] tcp_listen_portaddr_hash hash table entries: 2048 (order: 3, 32768 bytes, linear)
[    0.219407] TCP established hash table entries: 32768 (order: 6, 262144 bytes, linear)
[    0.219627] TCP bind hash table entries: 32768 (order: 7, 524288 bytes, linear)
[    0.220134] TCP: Hash tables configured (established 32768 bind 32768)
[    0.220272] UDP hash table entries: 2048 (order: 4, 65536 bytes, linear)
[    0.220355] UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes, linear)
[    0.220532] NET: Registered protocol family 1
[    0.220867] RPC: Registered named UNIX socket transport module.
[    0.220879] RPC: Registered udp transport module.
[    0.220889] RPC: Registered tcp transport module.
[    0.220898] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.220914] PCI: CLS 0 bytes, default 64
[    0.221082] Unpacking initramfs...
[    0.350667] Freeing initrd memory: 10100K
[    0.351483] hw perfevents: enabled with armv8_pmuv3 PMU driver, 7 counters available
[    0.353169] kvm [1]: IPA Size Limit: 40 bits
[    0.353815] kvm [1]: vgic-v2@52020000
[    0.353845] kvm [1]: GIC system register CPU interface enabled
[    0.353950] kvm [1]: vgic interrupt IRQ1
[    0.354094] kvm [1]: Hyp mode initialized successfully
[    0.357949] Initialise system trusted keyrings
[    0.358060] workingset: timestamp_bits=44 max_order=20 bucket_order=0
[    0.364064] NFS: Registering the id_resolver key type
[    0.364093] Key type id_resolver registered
[    0.364103] Key type id_legacy registered
[    0.364118] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[    0.364131] nfs4flexfilelayout_init: NFSv4 Flexfile Layout Driver Registering...
[    0.364162] jffs2: version 2.2. (NAND) © 2001-2006 Red Hat, Inc.
[    0.377307] Key type asymmetric registered
[    0.377320] Asymmetric key parser 'x509' registered
[    0.377356] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 244)
[    0.377372] io scheduler mq-deadline registered
[    0.377382] io scheduler kyber registered
[    0.391311] imx6q-pcie 5f000000.pcie: 5f000000.pcie supply epdev_on not found, using dummy regulator
[    0.393456] EINJ: ACPI disabled.
[    0.510677] mxs-dma 5b810000.dma-apbh: initialized
[    0.512392] Bus freq driver module loaded
[    0.518630] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.522980] 5a060000.serial: ttyLP0 at MMIO 0x5a060010 (irq = 47, base_baud = 5000000) is a FSL_LPUART
[    0.523336] fsl-lpuart 5a060000.serial: DMA tx channel request failed, operating without tx DMA
[    0.523354] fsl-lpuart 5a060000.serial: DMA rx channel request failed, operating without rx DMA
[    0.523703] 5a070000.serial: ttyLP1 at MMIO 0x5a070010 (irq = 48, base_baud = 5000000) is a FSL_LPUART
[    1.658307] printk: console [ttyLP1] enabled
[    1.663525] 5a080000.serial: ttyLP2 at MMIO 0x5a080010 (irq = 49, base_baud = 5000000) is a FSL_LPUART
[    1.673162] fsl-lpuart 5a080000.serial: DMA tx channel request failed, operating without tx DMA
[    1.681892] fsl-lpuart 5a080000.serial: DMA rx channel request failed, operating without rx DMA
[    1.691079] 5a090000.serial: ttyLP3 at MMIO 0x5a090010 (irq = 50, base_baud = 5000000) is a FSL_LPUART
[    1.703591] arm-smmu 51400000.iommu: probing hardware configuration...
[    1.710149] arm-smmu 51400000.iommu: SMMUv2 with:
[    1.714878] arm-smmu 51400000.iommu: 	stage 1 translation
[    1.720291] arm-smmu 51400000.iommu: 	stage 2 translation
[    1.725707] arm-smmu 51400000.iommu: 	nested translation
[    1.731032] arm-smmu 51400000.iommu: 	stream matching with 32 register groups
[    1.738185] arm-smmu 51400000.iommu: 	32 context banks (0 stage-2 only)
[    1.744824] arm-smmu 51400000.iommu: 	Supported page sizes: 0x61311000
[    1.751369] arm-smmu 51400000.iommu: 	Stage-1: 48-bit VA -> 48-bit IPA
[    1.757911] arm-smmu 51400000.iommu: 	Stage-2: 48-bit IPA -> 48-bit PA
[    1.836803] imx-drm display-subsystem: parent device of /bus@57240000/ldb@572410e0/lvds-channel@0 is not available
[    1.871423] loop: module loaded
[    1.874960] zram: Added device: zram0
[    1.883126] ahci-imx 5f020000.sata: Adding to iommu group 0
[    1.888915] ahci-imx 5f020000.sata: can't get sata_ext clock.
[    1.895040] imx ahci driver is registered.
[    1.907100] tun: Universal TUN/TAP device driver, 1.6
[    1.913850] fec 5b040000.ethernet: Adding to iommu group 1
[    1.919996] pps pps0: new PPS source ptp0
[    1.935047] Freescale FM module, FMD API version 21.1.0
[    1.941188] Freescale FM Ports module
[    1.946523] VFIO - User Level meta-driver version: 0.3
[    1.955678] cdns-usb3 5b110000.usb3: Adding to iommu group 2
[    1.962492] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.969081] ehci-pci: EHCI PCI platform driver
[    1.974893] usbcore: registered new interface driver usb-storage
[    1.981005] usbcore: registered new interface driver usbserial_generic
[    1.987567] usbserial: USB Serial support registered for generic
[    1.993616] usbcore: registered new interface driver cp210x
[    1.999217] usbserial: USB Serial support registered for cp210x
[    2.005178] usbcore: registered new interface driver ftdi_sio
[    2.010954] usbserial: USB Serial support registered for FTDI USB Serial Device
[    2.018302] usbcore: registered new interface driver pl2303
[    2.023911] usbserial: USB Serial support registered for pl2303
[    2.029896] usbcore: registered new interface driver usb_serial_simple
[    2.036468] usbserial: USB Serial support registered for carelink
[    2.042597] usbserial: USB Serial support registered for zio
[    2.048283] usbserial: USB Serial support registered for funsoft
[    2.054312] usbserial: USB Serial support registered for flashloader
[    2.060693] usbserial: USB Serial support registered for google
[    2.066639] usbserial: USB Serial support registered for libtransistor
[    2.073189] usbserial: USB Serial support registered for vivopay
[    2.079221] usbserial: USB Serial support registered for moto_modem
[    2.085519] usbserial: USB Serial support registered for motorola_tetra
[    2.092172] usbserial: USB Serial support registered for nokia
[    2.098030] usbserial: USB Serial support registered for novatel_gps
[    2.104418] usbserial: USB Serial support registered for hp4x
[    2.110192] usbserial: USB Serial support registered for suunto
[    2.116140] usbserial: USB Serial support registered for siemens_mpi
[    2.129545] input: sc-powerkey as /devices/platform/sc-powerkey/input/input0
[    2.139199] imx-sc-rtc scu:rtc: registered as rtc1
[    2.144633] i2c /dev entries driver
[    2.150153] pps_ldisc: PPS line discipline registered
[    2.164190] sdhci: Secure Digital Host Controller Interface driver
[    2.170401] sdhci: Copyright(c) Pierre Ossman
[    2.175306] Synopsys Designware Multimedia Card Interface Driver
[    2.183188] sdhci-pltfm: SDHCI platform and OF driver helper
[    2.190787] sdhci-esdhc-imx 5b010000.mmc: Adding to iommu group 3
[    2.228970] mmc0: SDHCI controller on 5b010000.mmc [5b010000.mmc] using ADMA
[    2.236583] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.243829] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.251006] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.258188] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.265348] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.272517] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.279688] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.286860] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.294096] sdhci-esdhc-imx 5b020000.mmc: Adding to iommu group 3
[    2.304546] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.312677] ledtrig-cpu: registered to indicate activity on CPUs
[    2.321321] caam 31400000.crypto: device ID = 0x0a16040000000100 (Era 9)
[    2.328054] caam 31400000.crypto: job rings = 2, qi = 0
[    2.334527] mmc0: new HS400 MMC card at address 0001
[    2.340113] mmcblk0: mmc0:0001 S0J56X 14.8 GiB 
[    2.344946] mmcblk0boot0: mmc0:0001 S0J56X partition 1 31.5 MiB
[    2.347766] caam algorithms registered in /proc/crypto
[    2.351137] mmcblk0boot1: mmc0:0001 S0J56X partition 2 31.5 MiB
[    2.357846] caam 31400000.crypto: caam pkc algorithms registered in /proc/crypto
[    2.362118] mmcblk0rpmb: mmc0:0001 S0J56X partition 3 4.00 MiB, chardev (237:0)
[    2.369393] caam 31400000.crypto: registering rng-caam
[    2.382085]  mmcblk0: p1 p2
[    2.382267] Device caam-keygen registered
[    2.391374] crng init done
[    2.393548] hidraw: raw HID events driver (C) Jiri Kosina
[    2.399687] usbcore: registered new interface driver usbhid
[    2.405288] usbhid: USB HID core driver
[    2.413154] No fsl,qman node
[    2.416043] Freescale USDPAA process driver
[    2.420238] fsl-usdpaa: no region found
[    2.424076] Freescale USDPAA process IRQ driver
[    2.443560] Galcore version 6.4.3.p1.305572
[    2.631250] [drm] Initialized vivante 1.0.0 20170808 for 80000000.imx8_gpu1_ss on minor 0
[    2.644026] [VPU Decoder] warning: init rtx channel failed, ret: -517
[    2.650525] [VPU Decoder] failed to request mailbox, ret = -517
[    2.660557] [VPU Encoder] warning:  init rtx channel failed, ret: -517
[    2.667131] [VPU Encoder] warning:  init rtx channel failed, ret: -517
[    2.673690] [VPU Encoder] fail to request mailbox, ret = -517
[    2.682624] dvbdev: DVB: registering new adapter (PPM DVB adapter)
[    2.689462] dvbdev: DVB: registering new adapter (PPM DVB adapter)
[    2.778166] imx-spdif sound-spdif: snd-soc-dummy-dai <-> 59020000.spdif mapping ok
[    2.785836] imx-spdif sound-spdif: ASoC: no DMI vendor name!
[    2.793276] imx-audmix imx-audmix.0: failed to find SAI platform device
[    2.799951] imx-audmix: probe of imx-audmix.0 failed with error -22
[    2.810013] pktgen: Packet Generator for packet performance testing. Version: 2.75
[    2.818415] NET: Registered protocol family 26
[    2.823791] NET: Registered protocol family 10
[    2.829033] Segment Routing with IPv6
[    2.832778] NET: Registered protocol family 17
[    2.837532] tsn generic netlink module v1 init...
[    2.842306] Key type dns_resolver registered
[    2.847060] registered taskstats version 1
[    2.851173] Loading compiled-in X.509 certificates
[    2.882913] mxs_phy 5b100000.usbphy: 5b100000.usbphy supply phy-3p0 not found, using dummy regulator
[    2.906907] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.914403] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.922214] usb_phy_generic bus@5b000000:usb3-phy: bus@5b000000:usb3-phy supply vcc not found, using dummy regulator
[    2.932928] usb_phy_generic bus@5b000000:usbphynop2: bus@5b000000:usbphynop2 supply vcc not found, using dummy regulator
[    2.944521] imx-lpi2c 5a800000.i2c: can't get pinctrl, bus recovery not supported
[    2.952311] i2c i2c-2: LPI2C adapter registered
[    2.959999] sgtl5000 3-000a: sgtl5000 revision 0x11
[    3.006119] usb3503 3-0008: switched to HUB mode
[    3.010780] usb3503 3-0008: usb3503_probe: probed in hub mode
[    3.016636] i2c i2c-3: LPI2C adapter registered
[    3.024570] rtc-ds1307 4-0068: registered as rtc0
[    3.029954] at24 4-0050: 256 byte 24c02 EEPROM, writable, 16 bytes/write
[    3.036712] i2c i2c-4: LPI2C adapter registered
[    3.042140] i2c i2c-5: LPI2C adapter registered
[    3.051599] imx6q-pcie 5f000000.pcie: 5f000000.pcie supply epdev_on not found, using dummy regulator
[    3.061078] pwm-backlight backlight: backlight supply power not found, using dummy regulator
[    3.061205] imx6q-pcie 5f000000.pcie: pcie_ext clock source missing or invalid
[    3.061610] imx6q-pcie 5f010000.pcie: pcie_ext clock source missing or invalid
[    3.090535] dpu-core 56180000.dpu: driver probed
[    3.097474] dpu-core 57180000.dpu: driver probed
[    3.102427] ahci-imx 5f020000.sata: phy impedance ratio is not specified.
[    3.109298] ahci-imx 5f020000.sata: No cache used with register defaults set!
[    3.116712] ahci-imx 5f020000.sata: 5f020000.sata supply ahci not found, using dummy regulator
[    3.125395] ahci-imx 5f020000.sata: 5f020000.sata supply phy not found, using dummy regulator
[    3.134006] ahci-imx 5f020000.sata: 5f020000.sata supply target not found, using dummy regulator
[    3.143967] ahci-imx 5f020000.sata: external osc is used.
[    3.152228] ahci-imx 5f020000.sata: no ahb clock.
[    3.157027] ahci-imx 5f020000.sata: AHCI 0001.0301 32 slots 1 ports 6 Gbps 0x1 impl platform mode
[    3.165938] ahci-imx 5f020000.sata: flags: 64bit ncq sntf pm clo only pmp fbs pio slum part ccc sadm sds apst 
[    3.176927] scsi host0: ahci-imx
[    3.180480] ata1: SATA max UDMA/133 mmio [mem 0x5f020000-0x5f02ffff] port 0x100 irq 105
[    3.193345] pps pps0: new PPS source ptp0
[    3.206036] fec 5b040000.ethernet eth0: registered PHC device 0
[    3.216481]  xhci-cdns3: xHCI Host Controller
[    3.220881]  xhci-cdns3: new USB bus registered, assigned bus number 1
[    3.228868]  xhci-cdns3: hcc params 0x200073c8 hci version 0x100 quirks 0x0000001000018010
[    3.237811] hub 1-0:1.0: USB hub found
[    3.241602] hub 1-0:1.0: 1 port detected
[    3.245760]  xhci-cdns3: xHCI Host Controller
[    3.250135]  xhci-cdns3: new USB bus registered, assigned bus number 2
[    3.256691]  xhci-cdns3: Host supports USB 3.0 SuperSpeed
[    3.262148] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
[    3.270685] hub 2-0:1.0: USB hub found
[    3.274468] hub 2-0:1.0: 1 port detected
[    3.279866] imx_usb 5b0d0000.usb: 5b0d0000.usb supply vbus not found, using dummy regulator
[    3.593697] ci_hdrc ci_hdrc.1: EHCI Host Controller
[    3.598646] ci_hdrc ci_hdrc.1: new USB bus registered, assigned bus number 3
[    3.620208] ci_hdrc ci_hdrc.1: USB 2.0 started, EHCI 1.00
[    3.626545] hub 3-0:1.0: USB hub found
[    3.630374] hub 3-0:1.0: 1 port detected
[    3.635962] gpio-fan gpio-fan: GPIO fan initialized
[    3.641558] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.648720] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.655900] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.663070] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.668203] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    3.670235] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.677163] ata1.00: supports DRM functions and may not be fully accessible
[    3.683585] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.690565] ata1.00: ATA-10: KINGSTON SKC600MS256G, S4800105, max UDMA/133
[    3.697709] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.704807] ata1.00: 500118192 sectors, multi 1: LBA48 NCQ (depth 32)
[    3.711748] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.718843] ata1.00: supports DRM functions and may not be fully accessible
[    3.725762] sdhci-esdhc-imx 5b020000.mmc: Got CD GPIO
[    3.732850] ata1.00: configured for UDMA/133
[    3.742025] scsi 0:0:0:0: Direct-Access     ATA      KINGSTON SKC600M 0105 PQ: 0 ANSI: 5
[    3.751241] sd 0:0:0:0: [sda] 500118192 512-byte logical blocks: (256 GB/238 GiB)
[    3.758764] sd 0:0:0:0: [sda] 4096-byte physical blocks
[    3.764037] sd 0:0:0:0: [sda] Write Protect is off
[    3.768475] mmc1: SDHCI controller on 5b020000.mmc [5b020000.mmc] using ADMA
[    3.768842] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    3.775946] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    3.776556] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.793807]  sda: sda1
[    3.797646] sd 0:0:0:0: [sda] Attached SCSI disk
[    3.818084] debugfs: Directory '59050000.sai' with parent 'apalis-imx8qm-sgtl5000' already present!
[    3.827754] asoc-simple-card sound: sgtl5000 <-> 59050000.sai mapping ok
[    3.834487] asoc-simple-card sound: ASoC: no DMI vendor name!
[    3.845832] imx6q-pcie 5f000000.pcie: 5f000000.pcie supply epdev_on not found, using dummy regulator
[    3.845842] imx6q-pcie 5f010000.pcie: No cache used with register defaults set!
[    3.846112] imx8qxp-lpcg-clk 5b260000.clock-controller: ignoring dependency for device, assuming no driver
[    3.855259] imx6q-pcie 5f000000.pcie: No cache used with register defaults set!
[    3.879627] rtc-ds1307 4-0068: setting system clock to 2022-05-29T19:59:00 UTC (1653854340)
[    3.882460] imx6q-pcie 5f010000.pcie: PCIe PLL locked after 0 us.
[    3.895268] ALSA device list:
[    3.898261]   #0: imx-spdif
[    3.901096]   #1: apalis-imx8qm-sgtl5000
[    3.990225] imx6q-pcie 5f000000.pcie: PCIe PLL locked after 0 us.
[    4.040210] usb 3-1: new high-speed USB device number 2 using ci_hdrc
[    4.108268] imx6q-pcie 5f010000.pcie: host bridge /bus@5f000000/pcie@0x5f010000 ranges:
[    4.116588] imx6q-pcie 5f010000.pcie:    IO 0x7ff80000..0x7ff8ffff -> 0x00000000
[    4.124028] imx6q-pcie 5f010000.pcie:   MEM 0x70000000..0x7fefffff -> 0x70000000
[    4.201549] hub 3-1:1.0: USB hub found
[    4.205485] hub 3-1:1.0: 3 ports detected
[    4.212288] imx6q-pcie 5f000000.pcie: host bridge /bus@5f000000/pcie@0x5f000000 ranges:
[    4.220392] imx6q-pcie 5f000000.pcie:    IO 0x6ff80000..0x6ff8ffff -> 0x00000000
[    4.228099] imx6q-pcie 5f000000.pcie:   MEM 0x60000000..0x6fefffff -> 0x60000000
[    4.231823] imx6q-pcie 5f010000.pcie: Link up
[    4.239900] imx6q-pcie 5f010000.pcie: Link: Gen2 disabled
[    4.245357] imx6q-pcie 5f010000.pcie: Link up, Gen1
[    4.250612] imx6q-pcie 5f010000.pcie: PCI host bridge to bus 0000:00
[    4.256991] pci_bus 0000:00: root bus resource [bus 00-ff]
[    4.262489] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    4.268683] pci_bus 0000:00: root bus resource [mem 0x70000000-0x7fefffff]
[    4.275574] pci 0000:00:00.0: [1957:0000] type 01 class 0x060400
[    4.281620] pci 0000:00:00.0: reg 0x10: [mem 0x00000000-0x00ffffff]
[    4.287904] pci 0000:00:00.0: reg 0x38: [mem 0x00000000-0x00ffffff pref]
[    4.294645] pci 0000:00:00.0: supports D1 D2
[    4.298925] pci 0000:00:00.0: PME# supported from D0 D1 D2 D3hot
[    4.308521] pci 0000:01:00.0: [1b4b:2b42] type 00 class 0x020000
[    4.314645] pci 0000:01:00.0: reg 0x10: [mem 0x00000000-0x000fffff 64bit pref]
[    4.321906] pci 0000:01:00.0: reg 0x18: [mem 0x00000000-0x000fffff 64bit pref]
[    4.329406] pci 0000:01:00.0: supports D1 D2
[    4.333680] pci 0000:01:00.0: PME# supported from D0 D1 D3hot D3cold
[    4.340174] pci 0000:01:00.0: 2.000 Gb/s available PCIe bandwidth, limited by 2.5 GT/s x1 link at 0000:00:00.0 (capable of 4.000 Gb/s with 5 GT/s x1 link)
[    4.372957] pci 0000:00:00.0: BAR 0: assigned [mem 0x70000000-0x70ffffff]
[    4.379772] pci 0000:00:00.0: BAR 6: assigned [mem 0x71000000-0x71ffffff pref]
[    4.387029] pci 0000:00:00.0: BAR 15: assigned [mem 0x72000000-0x721fffff 64bit pref]
[    4.394869] pci 0000:01:00.0: BAR 0: assigned [mem 0x72000000-0x720fffff 64bit pref]
[    4.402660] pci 0000:01:00.0: BAR 2: assigned [mem 0x72100000-0x721fffff 64bit pref]
[    4.410441] pci 0000:00:00.0: PCI bridge to [bus 01-ff]
[    4.415685] pci 0000:00:00.0:   bridge window [mem 0x72000000-0x721fffff 64bit pref]
[    4.423678] pcieport 0000:00:00.0: PME: Signaling with IRQ 567
[    4.496245] usb 3-1.3: new high-speed USB device number 3 using ci_hdrc
[    4.752219] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    4.759156] ata1.00: supports DRM functions and may not be fully accessible
[    4.766922] ata1.00: supports DRM functions and may not be fully accessible
[    4.774445] ata1.00: configured for UDMA/133
[    4.779044] sda: detected capacity change from 0 to 256060514304
[    5.224518] imx6q-pcie 5f000000.pcie: Phy link never came up
[    5.230296] imx6q-pcie 5f000000.pcie: failed to initialize host
[    5.236507] imx6q-pcie 5f000000.pcie: unable to add pcie port.
[    5.244941] Freeing unused kernel memory: 2560K
[    5.256307] Run /init as init process
[    6.136442] switch cluster 0 cpu-freq governor to schedutil
[    6.164628] switch cluster 1 cpu-freq governor to schedutil
[    6.194953] EXT4-fs (mmcblk0p2): recovery complete
[    6.200749] EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null)
[    6.445870] systemd[1]: systemd 245.4-4ubuntu3.17 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCRE2 default-hierarchy=hybrid)
[    6.469433] systemd[1]: Detected architecture arm64.
[    6.499497] systemd[1]: Set hostname to <apalis-imx8qm>.
[    6.834654] systemd[1]: Created slice system-modprobe.slice.
[    6.841532] systemd[1]: Created slice system-serial\x2dgetty.slice.
[    6.848746] systemd[1]: Created slice system-systemd\x2dfsck.slice.
[    6.856144] systemd[1]: Created slice User and Session Slice.
[    6.862224] systemd[1]: Started Dispatch Password Requests to Console Directory Watch.
[    6.870601] systemd[1]: Started Forward Password Requests to Wall Directory Watch.
[    6.878468] systemd[1]: Condition check resulted in Arbitrary Executable File Formats File System Automount Point being skipped.
[    6.890189] systemd[1]: Reached target Local Encrypted Volumes.
[    6.896354] systemd[1]: Reached target Paths.
[    6.900882] systemd[1]: Reached target Remote File Systems.
[    6.906616] systemd[1]: Reached target Slices.
[    6.911233] systemd[1]: Reached target Swap.
[    6.916075] systemd[1]: Listening on Syslog Socket.
[    6.921364] systemd[1]: Listening on fsck to fsckd communication Socket.
[    6.928383] systemd[1]: Listening on initctl Compatibility Named Pipe.
[    6.935679] systemd[1]: Listening on Journal Audit Socket.
[    6.941544] systemd[1]: Listening on Journal Socket (/dev/log).
[    6.947929] systemd[1]: Listening on Journal Socket.
[    6.953342] systemd[1]: Listening on udev Control Socket.
[    6.959074] systemd[1]: Listening on udev Kernel Socket.
[    6.967920] systemd[1]: Mounting Huge Pages File System...
[    6.976944] systemd[1]: Mounting POSIX Message Queue File System...
[    6.987395] systemd[1]: Mounting Kernel Debug File System...
[    6.993846] systemd[1]: Condition check resulted in Kernel Trace File System being skipped.
[    7.007162] systemd[1]: Starting Journal Service...
[    7.015912] systemd[1]: Starting Set the console keyboard layout...
[    7.027051] systemd[1]: Starting Create list of static device nodes for the current kernel...
[    7.036057] systemd[1]: Condition check resulted in Load Kernel Module drm being skipped.
[    7.045589] systemd[1]: Condition check resulted in Set Up Additional Binary Formats being skipped.
[    7.054817] systemd[1]: Condition check resulted in File System Check on Root Device being skipped.
[    7.069104] systemd[1]: Starting Load Kernel Modules...
[    7.078012] systemd[1]: Starting Remount Root and Kernel File Systems...
[    7.089017] systemd[1]: Starting udev Coldplug all Devices...
[    7.100443] systemd[1]: Mounted Huge Pages File System.
[    7.103019] EXT4-fs (mmcblk0p2): re-mounted. Opts: (null)
[    7.113998] systemd[1]: Mounted POSIX Message Queue File System.
[    7.121020] systemd[1]: Mounted Kernel Debug File System.
[    7.128834] systemd[1]: Finished Create list of static device nodes for the current kernel.
[    7.139969] systemd[1]: Finished Load Kernel Modules.
[    7.147412] systemd[1]: Finished Remount Root and Kernel File Systems.
[    7.154947] systemd[1]: Started Journal Service.
[    7.194184] systemd-journald[461]: Received client request to flush runtime journal.
[    7.215275] systemd-journald[461]: File /var/log/journal/e59b286a267e4330a5983db33b23998f/system.journal corrupted or uncleanly shut down, renaming and replacing.
[    7.594807] vpu-b0 2c000000.vpu_decoder: Direct firmware load for vpu/vpu_fw_imx8_dec.bin failed with error -2
[    7.594818] [VPU Decoder] error: vpu_firmware_download() request fw vpu/vpu_fw_imx8_dec.bin failed(-2)
[    7.594820] [VPU Decoder] error: vpu_firmware_download fail
[    7.606365] vpu-b0-encoder 2d000000.vpu_encoder: Direct firmware load for vpu/vpu_fw_imx8_enc.bin failed with error -2
[    7.606373] [VPU Encoder] vpu_firmware_download() request fw vpu/vpu_fw_imx8_enc.bin failed(-2)
[    7.606375] [VPU Encoder] error: vpu_firmware_download fail
[    7.606389] vpu-b0-encoder 2d000000.vpu_encoder: Direct firmware load for vpu/vpu_fw_imx8_enc.bin failed with error -2
[    7.606392] [VPU Encoder] vpu_firmware_download() request fw vpu/vpu_fw_imx8_enc.bin failed(-2)
[    7.606394] [VPU Encoder] error: vpu_firmware_download fail
[    7.608668] [VPU Encoder] failed to create encoder ctx
[    7.616080] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[    7.616085] [drm] No driver support for vblank timestamp query.
[    7.616311] imx-drm display-subsystem: bound imx-drm-dpu-bliteng.2 (ops dpu_bliteng_ops)
[    7.616385] imx-drm display-subsystem: bound imx-drm-dpu-bliteng.5 (ops dpu_bliteng_ops)
[    7.619747] imx-drm display-subsystem: bound imx-dpu-crtc.0 (ops dpu_crtc_ops)
[    7.625463] imx-drm display-subsystem: bound imx-dpu-crtc.1 (ops dpu_crtc_ops)
[    7.630879] imx-drm display-subsystem: bound imx-dpu-crtc.3 (ops dpu_crtc_ops)
[    7.632568] imx-drm display-subsystem: bound imx-dpu-crtc.4 (ops dpu_crtc_ops)
[    7.657204] mxc-jpeg 58400000.jpegdec: decoder device registered as /dev/video0 (81,2)
[    7.658422] mxc-jpeg 58450000.jpegenc: encoder device registered as /dev/video1 (81,3)
[    7.671184] [drm] Started firmware!
[    7.673740] [drm] HDP FW Version - ver 34559 verlib 20560
[    7.674140] cdns-mhdp-imx 56268000.hdmi: lane-mapping 0x93
[    7.681923] imx-drm display-subsystem: bound 56268000.hdmi (ops cdns_mhdp_imx_ops [cdns_mhdp_imx])
[    7.682776] [drm] Initialized imx-drm 1.0.0 20120507 for display-subsystem on minor 1
[    7.706089] CAN device driver interface
[    7.720637] cdns-mhdp-imx 56268000.hdmi: 0,ff,ff,ff,ff,ff,ff,0
[    7.731633] [drm] Mode: 1920x1080p148500
[    7.766278] [drm] Pixel clock: 148500 KHz, character clock: 148500, bpc is 8-bit.
[    7.766288] [drm] VCO frequency is 2970000 KHz
[    7.786948] cfg80211: Loading compiled-in X.509 certificates for regulatory database
[    7.813580] cfg80211: Loaded X.509 cert 'sforshee: 00b28ddf47aef9cea7'
[    7.818072] platform regulatory.0: Direct firmware load for regulatory.db failed with error -2
[    7.818087] cfg80211: failed to load regulatory.db
[    7.821331] lib80211: common routines for IEEE802.11 drivers
[    7.821342] lib80211_crypt: registered algorithm 'NULL'
[    7.852730] [drm] Sink Not Support SCDC
[    7.856566] mwifiex_pcie 0000:01:00.0: enabling device (0000 -> 0002)
[    7.856735] mwifiex_pcie: PCI memory map Virt0: ffff800025000000 PCI memory map Virt2: ffff800025200000
[    7.858627] [drm] No vendor infoframe
[    7.870110] r8188eu: module is from the staging directory, the quality is unknown, you have been warned.
[    7.890678] Chip Version Info: CHIP_8188E_Normal_Chip_TSMC_D_CUT_1T1R_RomVer(0)
[    7.901321] debugfs: Directory '59090000.sai' with parent 'imx-audio-hdmi-tx' already present!
[    7.901514] imx-cdnhdmi sound-hdmi: i2s-hifi <-> 59090000.sai mapping ok
[    7.901539] imx-cdnhdmi sound-hdmi: ASoC: no DMI vendor name!
[    7.901584] debugfs: File 'Capture' in directory 'dapm' already present!
[    7.905197] input: imx-audio-hdmi-tx HDMI Jack as /devices/platform/sound-hdmi/sound/card2/input1
[    7.937317] Console: switching to colour frame buffer device 240x67
[    7.950703] usbcore: registered new interface driver r8188eu
[    7.969374] r8188eu 3-1.3:1.0 wlx34c9f092281a: renamed from wlan0
[    7.976342] imx-drm display-subsystem: fb0: imx-drmdrmfb frame buffer device
[    8.595585] Process accounting resumed
[    8.975878] mwifiex_pcie 0000:01:00.0: info: FW download over, size 634228 bytes
[    9.268861] MAC Address = 34:c9:f0:92:28:1a
[    9.287324] Microchip KSZ9131 Gigabit PHY 5b040000.ethernet-1:07: attached PHY driver [Microchip KSZ9131 Gigabit PHY] (mii_bus:phy_addr=5b040000.ethernet-1:07, irq=304)
[    9.454120] [drm] HDMI Cable Plug Out
[    9.734247] cdns-mhdp-imx 56268000.hdmi: 0,ff,ff,ff,ff,ff,ff,0
[    9.735942] [drm] Mode: 1920x1080p148500
[    9.764231] [drm] Pixel clock: 148500 KHz, character clock: 148500, bpc is 8-bit.
[    9.764241] [drm] VCO frequency is 2970000 KHz
[    9.840247] mwifiex_pcie 0000:01:00.0: WLAN FW is active
[    9.845965] [drm] Sink Not Support SCDC
[    9.847488] [drm] No vendor infoframe
[    9.870227] mwifiex_pcie 0000:01:00.0: Unknown api_id: 3
[    9.870238] mwifiex_pcie 0000:01:00.0: Unknown api_id: 4
[    9.870247] mwifiex_pcie 0000:01:00.0: Unknown GET_HW_SPEC TLV type: 0x217
[    9.919377] [drm] HDMI Cable Plug In
[    9.976230] usb 3-1.1: new high-speed USB device number 4 using ci_hdrc
[   10.126450] Bluetooth: Core ver 2.22
[   10.126579] NET: Registered protocol family 31
[   10.126582] Bluetooth: HCI device and connection manager initialized
[   10.126605] Bluetooth: HCI socket layer initialized
[   10.126613] Bluetooth: L2CAP socket layer initialized
[   10.126628] Bluetooth: SCO socket layer initialized
[   10.137054] usbcore: registered new interface driver btusb
[   10.138768] Bluetooth: hci0: unexpected event for opcode 0x0000
[   10.687734] mwifiex_pcie 0000:01:00.0: info: MWIFIEX VERSION: mwifiex 1.0 (16.68.1.p195) 
[   10.687751] mwifiex_pcie 0000:01:00.0: driver_version = mwifiex 1.0 (16.68.1.p195) 
[   10.697921] mwifiex_pcie 0000:01:00.0 wlp1s0: renamed from mlan0
[   10.861312] R8188EU: assoc success
[   10.926459] IPv6: ADDRCONF(NETDEV_CHANGE): wlx34c9f092281a: link becomes ready
```
