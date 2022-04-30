## Overview

This is a collection of scripts that are used to build a minimial Ubuntu 20.04 installation for the Apalis iMX8 QuadMax Compute on Module.

## Recommended Hardware

To setup the build environment for the Ubuntu image creation, a Linux host with the following configuration is recommended. A host machine with adequate processing power and disk space is ideal as the build process can be severial gigabytes in size and can take alot of time.

* Intel Core-i7 CPU (>= 8 cores)
* High speed internet
* 20 GB free disk space
* 16 GB RAM

## Getting Started

Please update and install the below packages on your host machine. 

```
$ sudo apt update
$ sudo apt install build-essential gcc-aarch64-linux-gnu qemu-user-static u-boot-tools binfmt-support debootstrap flex bison libssl-dev
```

## Project Layout

* build-kernel.sh   - Build the Linux kernel and Device Tree Blobs
* build-rootfs.sh   - Create the root file system
* build-imx-boot.sh - Build U-Boot and the imx boot container
* build-bootfs.sh   - Create the boot file system
* build-image.sh    - Produce the Ubuntu installation image 

## Bootlog

```
U-Boot 2020.04-06936-g253ce5b0e3 (Apr 29 2022 - 13:57:41 -0400)

CPU:   NXP i.MX8QM RevB A53 at 1200 MHz

DRAM:  4 GiB
MMC:   FSL_SDHC: 0, FSL_SDHC: 1, FSL_SDHC: 2
Loading Environment from MMC... *** Warning - bad CRC, using default environment

In:    serial
Out:   serial
Err:   serial
Model: Toradex Apalis iMX8 QuadMax 4GB Wi-Fi / BT IT V1.1C, Serial# 07039853

 BuildInfo:
  - SCFW 0d54291f, SECO-FW d63fdb21, IMX-MKIMAGE ff8a39a8, ATF
  - U-Boot 2020.04-06936-g253ce5b0e3

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
467 bytes read in 12 ms (37.1 KiB/s)
## Executing script at 83100000
127661 bytes read in 32 ms (3.8 MiB/s)
10202814 bytes read in 335 ms (29 MiB/s)
Uncompressed size: 24197632 = 0x1713A00
14131237 bytes read in 446 ms (30.2 MiB/s)
## Flattened Device Tree blob at 83000000
   Booting using the fdt blob at 0x83000000
   Loading Ramdisk to fc8d3000, end fd64d025 ... OK
   Loading Device Tree to 00000000fc890000, end 00000000fc8d2fff ... OK

Starting kernel ...

[    0.000000] Booting Linux on physical CPU 0x0000000000 [0x410fd034]
[    0.000000] Linux version 5.4.77-toradex (joshua@joshua-MS-7B10) (gcc version 9.4.0 (Ubuntu 9.4.0-1ubuntu1~20.04.1)) #1 SMP PREEMPT Fri Apr 29 12:55:05 EDT 2022
[    0.000000] Machine model: Toradex Apalis iMX8QM V1.1 on Apalis Ixora V1.1 Carrier Board
[    0.000000] efi: Getting EFI parameters from FDT:
[    0.000000] efi: UEFI not found.
[    0.000000] OF: reserved mem: failed to allocate memory for node 'linux,cma'
[    0.000000] Reserved memory: created DMA memory pool at 0x0000000090400000, size 1 MiB
[    0.000000] OF: reserved mem: initialized node vdevbuffer, compatible id shared-dma-pool
[    0.000000] cma: Reserved 320 MiB at 0x00000000e8000000
[    0.000000] NUMA: No NUMA configuration found
[    0.000000] NUMA: Faking a node at [mem 0x0000000080200000-0x00000008ffffffff]
[    0.000000] NUMA: NODE_DATA [mem 0x8ff7e1500-0x8ff7e2fff]
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
[    0.000000] psci: probing for conduit method from DT.
[    0.000000] psci: PSCIv1.1 detected in firmware.
[    0.000000] psci: Using standard PSCI v0.2 function IDs
[    0.000000] psci: MIGRATE_INFO_TYPE not supported.
[    0.000000] psci: SMC Calling Convention v1.1
[    0.000000] percpu: Embedded 24 pages/cpu s58904 r8192 d31208 u98304
[    0.000000] Detected VIPT I-cache on CPU0
[    0.000000] CPU features: detected: ARM erratum 845719
[    0.000000] CPU features: detected: GIC system register CPU interface
[    0.000000] Speculative Store Bypass Disable mitigation not required
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 977508
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: console=ttyLP1,115200 console=tty1 pci=nomsi root=/dev/mmcblk0p2 rw rootwait
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes, linear)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes, linear)
[    0.000000] mem auto-init: stack:off, heap alloc:off, heap free:off
[    0.000000] software IO TLB: mapped [mem 0xe4000000-0xe8000000] (64MB)
[    0.000000] Memory: 3459316K/3972096K available (13948K kernel code, 974K rwdata, 6136K rodata, 2496K init, 1013K bss, 185100K reserved, 327680K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=6, Nodes=1
[    0.000000] rcu: Preemptible hierarchical RCU implementation.
[    0.000000] rcu:     RCU restricting CPUs from NR_CPUS=256 to nr_cpu_ids=6.
[    0.000000]  Tasks RCU enabled.
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
[    0.000000] random: get_random_bytes called from start_kernel+0x2b8/0x450 with crng_init=0
[    0.000000] arch_timer: cp15 timer(s) running at 8.00MHz (phys).
[    0.000000] clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0x1d854df40, max_idle_ns: 440795202120 ns
[    0.000004] sched_clock: 56 bits at 8MHz, resolution 125ns, wraps every 2199023255500ns
[    0.000643] Console: colour dummy device 80x25
[    0.001149] printk: console [tty1] enabled
[    0.001237] Calibrating delay loop (skipped), value calculated using timer frequency.. 16.00 BogoMIPS (lpj=32000)
[    0.001257] pid_max: default: 32768 minimum: 301
[    0.001340] LSM: Security Framework initializing
[    0.001413] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes, linear)
[    0.001443] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes, linear)
[    0.002848] ASID allocator initialised with 32768 entries
[    0.002924] rcu: Hierarchical SRCU implementation.
[    0.005015] EFI services will not be available.
[    0.005251] smp: Bringing up secondary CPUs ...
[    0.006010] Detected VIPT I-cache on CPU1
[    0.006036] GICv3: CPU1: found redistributor 1 region 0:0x0000000051b20000
[    0.006067] CPU1: Booted secondary processor 0x0000000001 [0x410fd034]
[    0.006826] Detected VIPT I-cache on CPU2
[    0.006840] GICv3: CPU2: found redistributor 2 region 0:0x0000000051b40000
[    0.006855] CPU2: Booted secondary processor 0x0000000002 [0x410fd034]
[    0.007601] Detected VIPT I-cache on CPU3
[    0.007615] GICv3: CPU3: found redistributor 3 region 0:0x0000000051b60000
[    0.007631] CPU3: Booted secondary processor 0x0000000003 [0x410fd034]
[    0.009200] CPU features: detected: EL2 vector hardening
[    0.009213] CPU features: detected: Branch predictor hardening
[    0.009218] Detected PIPT I-cache on CPU4
[    0.009234] GICv3: CPU4: found redistributor 100 region 0:0x0000000051b80000
[    0.009252] CPU4: Booted secondary processor 0x0000000100 [0x410fd082]
[    0.010003] Detected PIPT I-cache on CPU5
[    0.010014] GICv3: CPU5: found redistributor 101 region 0:0x0000000051ba0000
[    0.010026] CPU5: Booted secondary processor 0x0000000101 [0x410fd082]
[    0.010084] smp: Brought up 1 node, 6 CPUs
[    0.010228] SMP: Total of 6 processors activated.
[    0.010240] CPU features: detected: 32-bit EL0 Support
[    0.010251] CPU features: detected: CRC32 instructions
[    0.019779] CPU: All CPU(s) started at EL2
[    0.019816] alternatives: patching kernel code
[    0.020849] devtmpfs: initialized
[    0.035996] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.036036] futex hash table entries: 2048 (order: 5, 131072 bytes, linear)
[    0.044903] pinctrl core: initialized pinctrl subsystem
[    0.045466] DMI not present or invalid.
[    0.045745] NET: Registered protocol family 16
[    0.052139] DMA: preallocated 256 KiB pool for atomic allocations
[    0.052160] audit: initializing netlink subsys (disabled)
[    0.052326] audit: type=2000 audit(0.048:1): state=initialized audit_enabled=0 res=1
[    0.052895] cpuidle: using governor menu
[    0.054184] hw-breakpoint: found 6 breakpoint and 4 watchpoint registers.
[    0.055890] Serial: AMBA PL011 UART driver
[    0.055942] imx mu driver is registered.
[    0.055966] imx rpmsg driver is registered.
[    0.104541] HugeTLB registered 1.00 GiB page size, pre-allocated 0 pages
[    0.104568] HugeTLB registered 32.0 MiB page size, pre-allocated 0 pages
[    0.104580] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    0.104593] HugeTLB registered 64.0 KiB page size, pre-allocated 0 pages
[    0.105630] cryptd: max_cpu_qlen set to 1000
[    0.109490] ACPI: Interpreter disabled.
[    0.111663] iommu: Default domain type: Translated
[    0.111791] vgaarb: loaded
[    0.112125] SCSI subsystem initialized
[    0.112434] usbcore: registered new interface driver usbfs
[    0.112474] usbcore: registered new interface driver hub
[    0.112543] usbcore: registered new device driver usb
[    0.114570] mc: Linux media interface: v0.10
[    0.114605] videodev: Linux video capture interface: v2.00
[    0.114670] pps_core: LinuxPPS API ver. 1 registered
[    0.114681] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.114705] PTP clock support registered
[    0.115059] EDAC MC: Ver: 3.0.0
[    0.116563] No BMan portals available!
[    0.116966] QMan: Allocated lookup table at (____ptrval____), entry count 65537
[    0.117700] No QMan portals available!
[    0.118860] No USDPAA memory, no 'fsl,usdpaa-mem' in device-tree
[    0.119406] FPGA manager framework
[    0.119498] Advanced Linux Sound Architecture Driver Initialized.
[    0.120982] imx-scu scu: NXP i.MX SCU Initialized
[    0.126101] random: fast init done
[    0.164865] imx8qm-pinctrl scu:pinctrl: no groups defined in /scu/pinctrl/ledsixoragrp
[    0.164894] imx8qm-pinctrl scu:pinctrl: no groups defined in /scu/pinctrl/uart24forceoffgrp
[    0.164910] imx8qm-pinctrl scu:pinctrl: initialized IMX pinctrl driver
[    0.165837] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    0.168625] clocksource: Switched to clocksource arch_sys_counter
[    0.168832] VFS: Disk quotas dquot_6.6.0
[    0.168893] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.169083] pnp: PnP ACPI: disabled
[    0.196067] thermal_sys: Registered thermal governor 'step_wise'
[    0.196070] thermal_sys: Registered thermal governor 'power_allocator'
[    0.196933] NET: Registered protocol family 2
[    0.197292] tcp_listen_portaddr_hash hash table entries: 2048 (order: 3, 32768 bytes, linear)
[    0.197350] TCP established hash table entries: 32768 (order: 6, 262144 bytes, linear)
[    0.197571] TCP bind hash table entries: 32768 (order: 7, 524288 bytes, linear)
[    0.198057] TCP: Hash tables configured (established 32768 bind 32768)
[    0.198164] UDP hash table entries: 2048 (order: 4, 65536 bytes, linear)
[    0.198248] UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes, linear)
[    0.198439] NET: Registered protocol family 1
[    0.198789] RPC: Registered named UNIX socket transport module.
[    0.198802] RPC: Registered udp transport module.
[    0.198812] RPC: Registered tcp transport module.
[    0.198821] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.198840] PCI: CLS 0 bytes, default 64
[    0.199008] Unpacking initramfs...
[    0.373947] Freeing initrd memory: 13800K
[    0.374711] hw perfevents: enabled with armv8_pmuv3 PMU driver, 7 counters available
[    0.376306] kvm [1]: IPA Size Limit: 40bits
[    0.376951] kvm [1]: vgic-v2@52020000
[    0.376979] kvm [1]: GIC system register CPU interface enabled
[    0.377084] kvm [1]: vgic interrupt IRQ1
[    0.377217] kvm [1]: Hyp mode initialized successfully
[    0.381117] Initialise system trusted keyrings
[    0.381233] workingset: timestamp_bits=44 max_order=20 bucket_order=0
[    0.387142] NFS: Registering the id_resolver key type
[    0.387167] Key type id_resolver registered
[    0.387177] Key type id_legacy registered
[    0.387193] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[    0.387223] jffs2: version 2.2. (NAND) © 2001-2006 Red Hat, Inc.
[    0.400817] Key type asymmetric registered
[    0.400830] Asymmetric key parser 'x509' registered
[    0.400867] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 244)
[    0.400883] io scheduler mq-deadline registered
[    0.400893] io scheduler kyber registered
[    0.414315] imx6q-pcie 5f000000.pcie: 5f000000.pcie supply epdev_on not found, using dummy regulator
[    0.415975] EINJ: ACPI disabled.
[    0.529487] mxs-dma 5b810000.dma-apbh: initialized
[    0.531167] Bus freq driver module loaded
[    0.537366] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.541684] 5a060000.serial: ttyLP0 at MMIO 0x5a060010 (irq = 47, base_baud = 5000000) is a FSL_LPUART
[    0.542039] fsl-lpuart 5a060000.serial: DMA tx channel request failed, operating without tx DMA
[    0.542058] fsl-lpuart 5a060000.serial: DMA rx channel request failed, operating without rx DMA
[    0.542402] 5a070000.serial: ttyLP1 at MMIO 0x5a070010 (irq = 48, base_baud = 5000000) is a FSL_LPUART
[    1.629363] printk: console [ttyLP1] enabled
[    1.634497] 5a080000.serial: ttyLP2 at MMIO 0x5a080010 (irq = 49, base_baud = 5000000) is a FSL_LPUART
[    1.644134] fsl-lpuart 5a080000.serial: DMA tx channel request failed, operating without tx DMA
[    1.652879] fsl-lpuart 5a080000.serial: DMA rx channel request failed, operating without rx DMA
[    1.662063] 5a090000.serial: ttyLP3 at MMIO 0x5a090010 (irq = 50, base_baud = 5000000) is a FSL_LPUART
[    1.671702] fsl-lpuart 5a090000.serial: DMA tx channel request failed, operating without tx DMA
[    1.680428] fsl-lpuart 5a090000.serial: DMA rx channel request failed, operating without rx DMA
[    1.691865] arm-smmu 51400000.iommu: probing hardware configuration...
[    1.698424] arm-smmu 51400000.iommu: SMMUv2 with:
[    1.703139] arm-smmu 51400000.iommu:         stage 1 translation
[    1.708552] arm-smmu 51400000.iommu:         stage 2 translation
[    1.713962] arm-smmu 51400000.iommu:         nested translation
[    1.719295] arm-smmu 51400000.iommu:         stream matching with 32 register groups
[    1.726453] arm-smmu 51400000.iommu:         32 context banks (0 stage-2 only)
[    1.733089] arm-smmu 51400000.iommu:         Supported page sizes: 0x61311000
[    1.739634] arm-smmu 51400000.iommu:         Stage-1: 48-bit VA -> 48-bit IPA
[    1.746175] arm-smmu 51400000.iommu:         Stage-2: 48-bit IPA -> 48-bit PA
[    1.823981] imx-drm display-subsystem: parent device of /bus@57240000/ldb@572410e0/lvds-channel@0 is not available
[    1.857316] loop: module loaded
[    1.860919] zram: Added device: zram0
[    1.869171] ahci-imx 5f020000.sata: Adding to iommu group 0
[    1.874944] ahci-imx 5f020000.sata: can't get sata_ext clock.
[    1.881079] imx ahci driver is registered.
[    1.892786] libphy: Fixed MDIO Bus: probed
[    1.897115] tun: Universal TUN/TAP device driver, 1.6
[    1.903817] fec 5b040000.ethernet: Adding to iommu group 1
[    1.911827] Freescale FM module, FMD API version 21.1.0
[    1.917930] Freescale FM Ports module
[    1.923173] VFIO - User Level meta-driver version: 0.3
[    1.932304] cdns-usb3 5b110000.usb3: Adding to iommu group 2
[    1.938899] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.945448] ehci-pci: EHCI PCI platform driver
[    1.951245] usbcore: registered new interface driver usb-storage
[    1.957331] usbcore: registered new interface driver usbserial_generic
[    1.963892] usbserial: USB Serial support registered for generic
[    1.969937] usbcore: registered new interface driver cp210x
[    1.975558] usbserial: USB Serial support registered for cp210x
[    1.981517] usbcore: registered new interface driver ftdi_sio
[    1.987292] usbserial: USB Serial support registered for FTDI USB Serial Device
[    1.994641] usbcore: registered new interface driver pl2303
[    2.000237] usbserial: USB Serial support registered for pl2303
[    2.006227] usbcore: registered new interface driver usb_serial_simple
[    2.012794] usbserial: USB Serial support registered for carelink
[    2.018917] usbserial: USB Serial support registered for zio
[    2.024616] usbserial: USB Serial support registered for funsoft
[    2.030651] usbserial: USB Serial support registered for flashloader
[    2.037032] usbserial: USB Serial support registered for google
[    2.042980] usbserial: USB Serial support registered for libtransistor
[    2.049542] usbserial: USB Serial support registered for vivopay
[    2.055575] usbserial: USB Serial support registered for moto_modem
[    2.061865] usbserial: USB Serial support registered for motorola_tetra
[    2.068501] usbserial: USB Serial support registered for novatel_gps
[    2.074878] usbserial: USB Serial support registered for hp4x
[    2.080649] usbserial: USB Serial support registered for suunto
[    2.086605] usbserial: USB Serial support registered for siemens_mpi
[    2.099819] input: sc-powerkey as /devices/platform/sc-powerkey/input/input0
[    2.109484] imx-sc-rtc scu:rtc: registered as rtc1
[    2.114937] i2c /dev entries driver
[    2.120423] pps_ldisc: PPS line discipline registered
[    2.135156] sdhci: Secure Digital Host Controller Interface driver
[    2.141382] sdhci: Copyright(c) Pierre Ossman
[    2.146520] Synopsys Designware Multimedia Card Interface Driver
[    2.154400] sdhci-pltfm: SDHCI platform and OF driver helper
[    2.162001] sdhci-esdhc-imx 5b010000.mmc: Adding to iommu group 3
[    2.168573] mmc0: CQHCI version 5.10
[    2.203654] mmc0: SDHCI controller on 5b010000.mmc [5b010000.mmc] using ADMA
[    2.212896] sdhci-esdhc-imx 5b020000.mmc: Adding to iommu group 3
[    2.219622] mmc1: CQHCI version 5.10
[    2.227500] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    2.235574] ledtrig-cpu: registered to indicate activity on CPUs
[    2.243741] caam 31400000.crypto: device ID = 0x0a16040000000100 (Era 9)
[    2.250489] caam 31400000.crypto: job rings = 2, qi = 0
[    2.277119] caam algorithms registered in /proc/crypto
[    2.283728] caam 31400000.crypto: caam pkc algorithms registered in /proc/crypto
[    2.292298] caam_jr 31430000.jr: registering rng-caam
[    2.303678] hidraw: raw HID events driver (C) Jiri Kosina
[    2.309954] usbcore: registered new interface driver usbhid
[    2.315707] usbhid: USB HID core driver
[    2.323904] No fsl,qman node
[    2.326819] Freescale USDPAA process driver
[    2.331080] fsl-usdpaa: no region found
[    2.334940] Freescale USDPAA process IRQ driver
[    2.342838] mmc0: Command Queue Engine enabled
[    2.347323] mmc0: new DDR MMC card at address 0001
[    2.352720] mmcblk0: mmc0:0001 S0J56X 14.8 GiB
[    2.357453] mmcblk0boot0: mmc0:0001 S0J56X partition 1 31.5 MiB
[    2.363571] mmcblk0boot1: mmc0:0001 S0J56X partition 2 31.5 MiB
[    2.367896] dvbdev: DVB: registering new adapter (PPM DVB adapter)
[    2.369609] mmcblk0rpmb: mmc0:0001 S0J56X partition 3 4.00 MiB, chardev (237:0)
[    2.376291] dvbdev: DVB: registering new adapter (PPM DVB adapter)
[    2.389316]  mmcblk0: p1 p2
[    2.480017] imx-spdif sound-hdmi-arc: snd-soc-dummy-dai <-> 59030000.spdif mapping ok
[    2.487936] imx-spdif sound-hdmi-arc: ASoC: no DMI vendor name!
[    2.497235] imx-spdif sound-spdif: snd-soc-dummy-dai <-> 59020000.spdif mapping ok
[    2.504857] imx-spdif sound-spdif: ASoC: no DMI vendor name!
[    2.512067] imx-audmix imx-audmix.0: failed to find SAI platform device
[    2.518754] imx-audmix: probe of imx-audmix.0 failed with error -22
[    2.528668] pktgen: Packet Generator for packet performance testing. Version: 2.75
[    2.537045] NET: Registered protocol family 26
[    2.542079] NET: Registered protocol family 10
[    2.547188] Segment Routing with IPv6
[    2.550920] NET: Registered protocol family 17
[    2.555415] tsn generic netlink module v1 init...
[    2.560188] Key type dns_resolver registered
[    2.564914] registered taskstats version 1
[    2.569043] Loading compiled-in X.509 certificates
[    2.601233] mxs_phy 5b100000.usbphy: 5b100000.usbphy supply phy-3p0 not found, using dummy regulator
[    2.624745] usb_phy_generic bus@5b000000:usb3-phy: bus@5b000000:usb3-phy supply vcc not found, using dummy regulator
[    2.635508] usb_phy_generic bus@5b000000:usbphynop2: bus@5b000000:usbphynop2 supply vcc not found, using dummy regulator
[    2.647108] imx-lpi2c 5a800000.i2c: can't get pinctrl, bus recovery not supported
[    2.654864] i2c i2c-2: LPI2C adapter registered
[    2.662247] sgtl5000 3-000a: sgtl5000 revision 0x11
[    2.707393] usb3503 3-0008: switched to HUB mode
[    2.712055] usb3503 3-0008: usb3503_probe: probed in hub mode
[    2.717910] i2c i2c-3: LPI2C adapter registered
[    2.725617] rtc-ds1307 4-0068: oscillator failed, set time!
[    2.731518] rtc-ds1307 4-0068: registered as rtc0
[    2.736280] i2c i2c-4: LPI2C adapter registered
[    2.741663] i2c i2c-5: LPI2C adapter registered
[    2.751393] imx6q-pcie 5f010000.pcie: pcie_ext clock source missing or invalid
[    2.751401] pwm-backlight backlight: backlight supply power not found, using dummy regulator
[    2.758911] imx6q-pcie 5f000000.pcie: 5f000000.pcie supply epdev_on not found, using dummy regulator
[    2.775406] dpu-core 56180000.dpu: driver probed
[    2.776769] imx6q-pcie 5f000000.pcie: No cache used with register defaults set!
[    2.782861] dpu-core 57180000.dpu: driver probed
[    2.789210] imx6q-pcie 5f000000.pcie: host bridge /bus@5f000000/pcie@0x5f000000 ranges:
[    2.793231] ahci-imx 5f020000.sata: phy impedance ratio is not specified.
[    2.800961] imx6q-pcie 5f000000.pcie:    IO 0x6ff80000..0x6ff8ffff -> 0x00000000
[    2.807795] ahci-imx 5f020000.sata: No cache used with register defaults set!
[    2.815175] imx6q-pcie 5f000000.pcie:   MEM 0x60000000..0x6fefffff -> 0x60000000
[    2.829976] ahci-imx 5f020000.sata: 5f020000.sata supply ahci not found, using dummy regulator
[    2.838681] ahci-imx 5f020000.sata: 5f020000.sata supply phy not found, using dummy regulator
[    2.847271] ahci-imx 5f020000.sata: 5f020000.sata supply target not found, using dummy regulator
[    2.856644] ahci-imx 5f020000.sata: external osc is used.
[    2.864872] ahci-imx 5f020000.sata: no ahb clock.
[    2.869648] ahci-imx 5f020000.sata: AHCI 0001.0301 32 slots 1 ports 6 Gbps 0x1 impl platform mode
[    2.878545] ahci-imx 5f020000.sata: flags: 64bit ncq sntf pm clo only pmp fbs pio slum part ccc sadm sds apst
[    2.889621] scsi host0: ahci-imx
[    2.893143] ata1: SATA max UDMA/133 mmio [mem 0x5f020000-0x5f02ffff] port 0x100 irq 99
[    2.903087] fsl_lpspi 5a020000.spi: dma setup error -19, use pio
[    2.922550] pps pps0: new PPS source ptp0
[    2.928417] libphy: fec_enet_mii_bus: probed
[    2.941383] fec 5b040000.ethernet eth0: registered PHC device 0
[    2.951777]  xhci-cdns3: xHCI Host Controller
[    2.956182]  xhci-cdns3: new USB bus registered, assigned bus number 1
[    2.964294]  xhci-cdns3: hcc params 0x200073c8 hci version 0x100 quirks 0x0000001000018010
[    2.973645] hub 1-0:1.0: USB hub found
[    2.977432] hub 1-0:1.0: 1 port detected
[    2.981590]  xhci-cdns3: xHCI Host Controller
[    2.985971]  xhci-cdns3: new USB bus registered, assigned bus number 2
[    2.992519]  xhci-cdns3: Host supports USB 3.0 SuperSpeed
[    2.997974] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
[    3.006717] hub 2-0:1.0: USB hub found
[    3.010516] hub 2-0:1.0: 1 port detected
[    3.016088] imx_usb 5b0d0000.usb: 5b0d0000.usb supply vbus not found, using dummy regulator
[    3.056670] imx6q-pcie 5f000000.pcie: PCIe PLL locked after 0 us.
[    3.088933] ci_hdrc ci_hdrc.1: EHCI Host Controller
[    3.093857] ci_hdrc ci_hdrc.1: new USB bus registered, assigned bus number 3
[    3.116674] ci_hdrc ci_hdrc.1: USB 2.0 started, EHCI 1.00
[    3.122847] hub 3-0:1.0: USB hub found
[    3.126644] hub 3-0:1.0: 1 port detected
[    3.131764] gpio-fan gpio-fan: GPIO fan initialized
[    3.138856] mmc1: CQHCI version 5.10
[    3.142500] sdhci-esdhc-imx 5b020000.mmc: Got CD GPIO
[    3.178976] mmc1: SDHCI controller on 5b020000.mmc [5b020000.mmc] using ADMA
[    3.186759] imx8qm-pinctrl scu:pinctrl: invalid function pinctrl in map table
[    3.205489] debugfs: Directory '59050000.sai' with parent 'apalis-imx8qm-sgtl5000' already present!
[    3.215149] asoc-simple-card sound: sgtl5000 <-> 59050000.sai mapping ok
[    3.221890] asoc-simple-card sound: ASoC: no DMI vendor name!
[    3.232675] imx8qxp-lpcg-clk 5b260000.clock-controller: ignoring dependency for device, assuming no driver
[    3.233067] imx6q-pcie 5f010000.pcie: No cache used with register defaults set!
[    3.245402] debugfs: Directory 'lvds1' with parent 'pm_genpd' already present!
[    3.250272] imx6q-pcie 5f010000.pcie: host bridge /bus@5f000000/pcie@0x5f010000 ranges:
[    3.257340] debugfs: Directory 'mipi1-i2c1' with parent 'pm_genpd' already present!
[    3.265007] imx6q-pcie 5f010000.pcie:    IO 0x7ff80000..0x7ff8ffff -> 0x00000000
[    3.265017] imx6q-pcie 5f010000.pcie:   MEM 0x70000000..0x7fefffff -> 0x70000000
[    3.272695] debugfs: Directory 'mipi1-i2c0' with parent 'pm_genpd' already present!
[    3.295209] debugfs: Directory 'mipi1-pwm0' with parent 'pm_genpd' already present!
[    3.302925] debugfs: Directory 'mipi1' with parent 'pm_genpd' already present!
[    3.318865] input: gpio-keys as /devices/platform/gpio-keys/input/input1
[    3.327293] rtc-ds1307 4-0068: hctosys: unable to read the hardware clock
[    3.341551] ALSA device list:
[    3.344524]   #0: imx-hdmi-arc
[    3.347846]   #1: imx-spdif
[    3.350657]   #2: apalis-imx8qm-sgtl5000
[    3.376659] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    3.383627] ata1.00: supports DRM functions and may not be fully accessible
[    3.390619] ata1.00: ATA-10: KINGSTON SKC600MS256G, S4800105, max UDMA/133
[    3.397507] ata1.00: 500118192 sectors, multi 1: LBA48 NCQ (depth 32)
[    3.404651] ata1.00: supports DRM functions and may not be fully accessible
[    3.412159] ata1.00: configured for UDMA/133
[    3.416631] imx6q-pcie 5f010000.pcie: PCIe PLL locked after 0 us.
[    3.522794] imx6q-pcie 5f010000.pcie: Link up
[    3.527186] imx6q-pcie 5f010000.pcie: Link: Gen2 disabled
[    3.532623] imx6q-pcie 5f010000.pcie: Link up, Gen1
[    3.537905] imx6q-pcie 5f010000.pcie: PCI host bridge to bus 0000:00
[    3.544272] pci_bus 0000:00: root bus resource [bus 00-ff]
[    3.549804] pci_bus 0000:00: root bus resource [io  0x10000-0x1ffff] (bus address [0x0000-0xffff])
[    3.558777] pci_bus 0000:00: root bus resource [mem 0x70000000-0x7fefffff]
[    3.565681] pci 0000:00:00.0: [1957:0000] type 01 class 0x060400
[    3.571714] pci 0000:00:00.0: reg 0x10: [mem 0x00000000-0x00ffffff]
[    3.578006] pci 0000:00:00.0: reg 0x38: [mem 0x00000000-0x00ffffff pref]
[    3.584750] pci 0000:00:00.0: supports D1 D2
[    3.589037] pci 0000:00:00.0: PME# supported from D0 D1 D2 D3hot
[    3.598277] pci 0000:01:00.0: [1b4b:2b42] type 00 class 0x020000
[    3.604336] pci 0000:01:00.0: MSI quirk detected; MSI disabled
[    3.610190] usb 3-1: new high-speed USB device number 2 using ci_hdrc
[    3.616713] pci 0000:01:00.0: quirk_disable_all_msi+0x0/0x30 took 12063 usecs
[    3.623975] pci 0000:01:00.0: reg 0x10: [mem 0x00000000-0x000fffff 64bit pref]
[    3.631535] pci 0000:01:00.0: reg 0x18: [mem 0x00000000-0x000fffff 64bit pref]
[    3.639052] pci 0000:01:00.0: supports D1 D2
[    3.643351] pci 0000:01:00.0: PME# supported from D0 D1 D3hot D3cold
[    3.649851] pci 0000:01:00.0: 2.000 Gb/s available PCIe bandwidth, limited by 2.5 GT/s x1 link at 0000:00:00.0 (capable of 4.000 Gb/s with 5 GT/s x1 link)
[    3.680065] pci 0000:00:00.0: BAR 0: assigned [mem 0x70000000-0x70ffffff]
[    3.687128] pci 0000:00:00.0: BAR 6: assigned [mem 0x71000000-0x71ffffff pref]
[    3.694405] pci 0000:00:00.0: BAR 15: assigned [mem 0x72000000-0x721fffff 64bit pref]
[    3.702274] pci 0000:01:00.0: BAR 0: assigned [mem 0x72000000-0x720fffff 64bit pref]
[    3.710066] pci 0000:01:00.0: BAR 2: assigned [mem 0x72100000-0x721fffff 64bit pref]
[    3.717863] pci 0000:00:00.0: PCI bridge to [bus 01-ff]
[    3.723124] pci 0000:00:00.0:   bridge window [mem 0x72000000-0x721fffff 64bit pref]
[    3.731330] pcieport 0000:00:00.0: PME: Signaling with IRQ 561
[    3.777790] hub 3-1:1.0: USB hub found
[    3.781777] hub 3-1:1.0: 3 ports detected
[    4.055318] imx6q-pcie 5f000000.pcie: Phy link never came up
[    4.061081] imx6q-pcie 5f000000.pcie: failed to initialize host
[    4.067073] imx6q-pcie 5f000000.pcie: unable to add pcie port.
[    4.304656] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    4.311616] ata1.00: supports DRM functions and may not be fully accessible
[    4.319518] ata1.00: supports DRM functions and may not be fully accessible
[    4.327018] ata1.00: configured for UDMA/133
[    4.331465] scsi 0:0:0:0: Direct-Access     ATA      KINGSTON SKC600M 0105 PQ: 0 ANSI: 5
[    4.340427] sd 0:0:0:0: [sda] 500118192 512-byte logical blocks: (256 GB/238 GiB)
[    4.347934] sd 0:0:0:0: [sda] 4096-byte physical blocks
[    4.353217] sd 0:0:0:0: [sda] Write Protect is off
[    4.358082] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    4.369170]  sda: sda1
[    4.372514] sd 0:0:0:0: [sda] Attached SCSI disk
[    4.378608] Freeing unused kernel memory: 2496K
[    4.388814] Run /init as init process
[    5.142108] raid6: using algorithm neonx8 gen() 0 MB/s
[    5.147292] raid6: .... xor() 0 MB/s, rmw enabled
[    5.152261] raid6: using neon recovery algorithm
[    5.157992] xor: measuring software checksum speed
[    5.200628]    8regs     :  2372.000 MB/sec
[    5.244632]    32regs    :  2722.000 MB/sec
[    5.288628]    arm64_neon:  2328.000 MB/sec
[    5.292821] xor: using function: 32regs (2722.000 MB/sec)
[    5.334130] Btrfs loaded, crc32c=crc32c-generic
[    5.529197] EXT4-fs (mmcblk0p2): recovery complete
[    5.534707] EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null)
[    5.620960] switch cluster 0 cpu-freq governor to schedutil
[    5.807467] systemd[1]: System time before build time, advancing clock.
[    5.843611] systemd[1]: systemd 245.4-4ubuntu3.16 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCRE2 default-hierarchy=hybrid)
[    5.866575] systemd[1]: Detected architecture arm64.
[    5.915657] systemd[1]: Set hostname to <ubuntu>.
[    6.091442] random: lvmconfig: uninitialized urandom read (4 bytes read)
[    6.290559] random: systemd: uninitialized urandom read (16 bytes read)
[    6.299056] systemd[1]: Created slice system-modprobe.slice.
[    6.305058] random: systemd: uninitialized urandom read (16 bytes read)
[    6.312280] systemd[1]: Created slice system-serial\x2dgetty.slice.
[    6.319263] systemd[1]: Created slice User and Session Slice.
[    6.325339] systemd[1]: Started Dispatch Password Requests to Console Directory Watch.
[    6.333503] systemd[1]: Started Forward Password Requests to Wall Directory Watch.
[    6.341328] systemd[1]: Condition check resulted in Arbitrary Executable File Formats File System Automount Point being skipped.
[    6.352985] systemd[1]: Reached target Local Encrypted Volumes.
[    6.359088] systemd[1]: Reached target Paths.
[    6.363565] systemd[1]: Reached target Remote File Systems.
[    6.369266] systemd[1]: Reached target Slices.
[    6.373833] systemd[1]: Reached target Swap.
[    6.378373] systemd[1]: Listening on Device-mapper event daemon FIFOs.
[    6.385283] systemd[1]: Listening on LVM2 poll daemon socket.
[    6.391374] systemd[1]: Listening on Syslog Socket.
[    6.396483] systemd[1]: Listening on initctl Compatibility Named Pipe.
[    6.403555] systemd[1]: Listening on Journal Audit Socket.
[    6.409381] systemd[1]: Listening on Journal Socket (/dev/log).
[    6.415675] systemd[1]: Listening on Journal Socket.
[    6.421012] systemd[1]: Listening on udev Control Socket.
[    6.426684] systemd[1]: Listening on udev Kernel Socket.
[    6.434820] systemd[1]: Mounting Huge Pages File System...
[    6.443040] systemd[1]: Mounting POSIX Message Queue File System...
[    6.451973] systemd[1]: Mounting Kernel Debug File System...
[    6.458027] systemd[1]: Condition check resulted in Kernel Trace File System being skipped.
[    6.469919] systemd[1]: Starting Journal Service...
[    6.477687] systemd[1]: Starting Availability of block devices...
[    6.486642] systemd[1]: Starting Set the console keyboard layout...
[    6.496277] systemd[1]: Starting Create list of static device nodes for the current kernel...
[    6.507794] systemd[1]: Starting Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling...
[    6.518376] systemd[1]: Condition check resulted in Load Kernel Module drm being skipped.
[    6.527750] systemd[1]: Condition check resulted in Set Up Additional Binary Formats being skipped.
[    6.541301] systemd[1]: Starting Load Kernel Modules...
[    6.549467] systemd[1]: Starting Remount Root and Kernel File Systems...
[    6.559183] systemd[1]: Starting udev Coldplug all Devices...
[    6.568177] systemd[1]: Mounted Huge Pages File System.
[    6.573988] systemd[1]: Mounted POSIX Message Queue File System.
[    6.580446] systemd[1]: Mounted Kernel Debug File System.
[    6.587300] systemd[1]: Finished Availability of block devices.
[    6.594935] systemd[1]: Finished Create list of static device nodes for the current kernel.
[    6.604993] systemd[1]: Finished Load Kernel Modules.
[    6.611764] systemd[1]: Finished Remount Root and Kernel File Systems.
[    6.619101] systemd[1]: Condition check resulted in FUSE Control File System being skipped.
[    6.627681] systemd[1]: Condition check resulted in Kernel Configuration File System being skipped.
[    6.639667] systemd[1]: Condition check resulted in Rebuild Hardware Database being skipped.
[    6.648883] systemd[1]: Condition check resulted in Platform Persistent Storage Archival being skipped.
[    6.661346] systemd[1]: Starting Load/Save Random Seed...
[    6.669584] systemd[1]: Starting Apply Kernel Variables...
[    6.679982] systemd[1]: Starting Create System Users...
[    6.686732] systemd[1]: Started Journal Service.
[    7.685878] imx-cdnhdmi sound-hdmi: ASoC: failed to init link imx8 hdmi: -517
[    7.685888] imx-cdnhdmi sound-hdmi: snd_soc_register_card failed (-517)
[    7.785845] imx-cdnhdmi sound-hdmi: ASoC: failed to init link imx8 hdmi: -517
[    7.793161] imx-cdnhdmi sound-hdmi: snd_soc_register_card failed (-517)
[    7.809134] imx-cdnhdmi sound-hdmi: ASoC: failed to init link imx8 hdmi: -517
[    7.816684] imx-cdnhdmi sound-hdmi: snd_soc_register_card failed (-517)
[    7.873451] debugfs: Directory '59090000.sai' with parent 'imx-audio-hdmi-tx' already present!
[    7.883195] debugfs: File 'Capture' in directory 'dapm' already present!
```
