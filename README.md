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
└── README.md
```

## Boot log

```
U-Boot 2020.04-06938-g44d5a7a61b (May 09 2022 - 20:22:43 -0400)

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
  - U-Boot 2020.04-06938-g44d5a7a61b 

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
2557 bytes read in 35 ms (71.3 KiB/s)
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
Loading DeviceTree: imx8qm-apalis-v1.1-eval.dtb
166807 bytes read in 24 ms (6.6 MiB/s)
Applying Overlay: overlays/apalis-imx8_hdmi_overlay.dtbo
2049 bytes read in 38 ms (51.8 KiB/s)
Loading Kernel: vmlinuz
10443402 bytes read in 347 ms (28.7 MiB/s)
Uncompressed size: 24760832 = 0x179D200
Loading Ramdisk: initrd
14142594 bytes read in 455 ms (29.6 MiB/s)
Bootargs: console=ttyLP1,115200 console=tty1 pci=nomsi root=PARTUUID=4a3e3418-02 rw rootwait
## Flattened Device Tree blob at 83000000
   Booting using the fdt blob at 0x83000000
   Loading Ramdisk to fd64c000, end fd64c9fd ... OK
   Loading Device Tree to 00000000fd61e000, end 00000000fd64bfff ... OK

Starting kernel ...

[    0.000000] Booting Linux on physical CPU 0x0000000000 [0x410fd034]
[    0.000000] Linux version 5.4.161-toradex (root@joshua-MS-7B10) (gcc version 9.4.0 (Ubuntu 9.4.0-1ubuntu1~20.04.1)) #1 SMP PREEMPT Mon May 9 20:18:08 EDT 2022
[    0.000000] Machine model: Toradex Apalis iMX8QM V1.1 on Apalis Evaluation Board
[    0.000000] efi: Getting EFI parameters from FDT:
[    0.000000] efi: UEFI not found.
[    0.000000] Reserved memory: created DMA memory pool at 0x0000000090400000, size 1 MiB
[    0.000000] OF: reserved mem: initialized node vdevbuffer, compatible id shared-dma-pool
[    0.000000] cma: Reserved 320 MiB at 0x00000000e8000000
[    0.000000] NUMA: No NUMA configuration found
[    0.000000] NUMA: Faking a node at [mem 0x0000000080200000-0x00000008ffffffff]
[    0.000000] NUMA: NODE_DATA [mem 0x8ff7c3500-0x8ff7c4fff]
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
[    0.000000] Kernel command line: console=ttyLP1,115200 console=tty1 pci=nomsi root=PARTUUID=4a3e3418-02 rw rootwait
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes, linear)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes, linear)
[    0.000000] mem auto-init: stack:off, heap alloc:off, heap free:off
[    0.000000] software IO TLB: mapped [mem 0xe4000000-0xe8000000] (64MB)
[    0.000000] Memory: 3472408K/3972096K available (14332K kernel code, 1012K rwdata, 6256K rodata, 2496K init, 1017K bss, 172008K reserved, 327680K cma-reserved)
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
[    0.000710] Console: colour dummy device 80x25
[    0.001215] printk: console [tty1] enabled
[    0.001298] Calibrating delay loop (skipped), value calculated using timer frequency.. 16.00 BogoMIPS (lpj=32000)
[    0.001319] pid_max: default: 32768 minimum: 301
[    0.001400] LSM: Security Framework initializing
[    0.001470] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes, linear)
[    0.001499] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes, linear)
[    0.002939] ASID allocator initialised with 32768 entries
[    0.003015] rcu: Hierarchical SRCU implementation.
[    0.005346] EFI services will not be available.
[    0.005580] smp: Bringing up secondary CPUs ...
[    0.006344] Detected VIPT I-cache on CPU1
[    0.006371] GICv3: CPU1: found redistributor 1 region 0:0x0000000051b20000
[    0.006404] CPU1: Booted secondary processor 0x0000000001 [0x410fd034]
[    0.007178] Detected VIPT I-cache on CPU2
[    0.007193] GICv3: CPU2: found redistributor 2 region 0:0x0000000051b40000
[    0.007209] CPU2: Booted secondary processor 0x0000000002 [0x410fd034]
[    0.007956] Detected VIPT I-cache on CPU3
[    0.007970] GICv3: CPU3: found redistributor 3 region 0:0x0000000051b60000
[    0.007986] CPU3: Booted secondary processor 0x0000000003 [0x410fd034]
[    0.009564] CPU features: detected: EL2 vector hardening
[    0.009576] CPU features: detected: Branch predictor hardening
[    0.009581] Detected PIPT I-cache on CPU4
[    0.009598] GICv3: CPU4: found redistributor 100 region 0:0x0000000051b80000
[    0.009617] CPU4: Booted secondary processor 0x0000000100 [0x410fd082]
[    0.010369] Detected PIPT I-cache on CPU5
[    0.010380] GICv3: CPU5: found redistributor 101 region 0:0x0000000051ba0000
[    0.010392] CPU5: Booted secondary processor 0x0000000101 [0x410fd082]
[    0.010449] smp: Brought up 1 node, 6 CPUs
[    0.010598] SMP: Total of 6 processors activated.
[    0.010609] CPU features: detected: 32-bit EL0 Support
[    0.010621] CPU features: detected: CRC32 instructions
[    0.020399] CPU: All CPU(s) started at EL2
[    0.020436] alternatives: patching kernel code
[    0.021469] devtmpfs: initialized
[    0.040065] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.040107] futex hash table entries: 2048 (order: 5, 131072 bytes, linear)
[    0.049321] pinctrl core: initialized pinctrl subsystem
[    0.049851] DMI not present or invalid.
[    0.050171] NET: Registered protocol family 16
[    0.056736] DMA: preallocated 256 KiB pool for atomic allocations
[    0.056759] audit: initializing netlink subsys (disabled)
[    0.056923] audit: type=2000 audit(0.052:1): state=initialized audit_enabled=0 res=1
[    0.057491] cpuidle: using governor menu
[    0.058978] hw-breakpoint: found 6 breakpoint and 4 watchpoint registers.
[    0.060855] Serial: AMBA PL011 UART driver
[    0.060908] imx mu driver is registered.
[    0.060932] imx rpmsg driver is registered.
[    0.114505] HugeTLB registered 1.00 GiB page size, pre-allocated 0 pages
[    0.114533] HugeTLB registered 32.0 MiB page size, pre-allocated 0 pages
[    0.114546] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    0.114558] HugeTLB registered 64.0 KiB page size, pre-allocated 0 pages
[    0.115680] cryptd: max_cpu_qlen set to 1000
[    0.119593] ACPI: Interpreter disabled.
[    0.121784] iommu: Default domain type: Translated 
[    0.121908] vgaarb: loaded
[    0.122194] SCSI subsystem initialized
[    0.122508] usbcore: registered new interface driver usbfs
[    0.122549] usbcore: registered new interface driver hub
[    0.122583] usbcore: registered new device driver usb
[    0.124612] mc: Linux media interface: v0.10
[    0.124642] videodev: Linux video capture interface: v2.00
[    0.124706] pps_core: LinuxPPS API ver. 1 registered
[    0.124718] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.124746] PTP clock support registered
[    0.125104] EDAC MC: Ver: 3.0.0
[    0.126745] No BMan portals available!
[    0.127165] QMan: Allocated lookup table at (____ptrval____), entry count 65537
[    0.127959] No QMan portals available!
[    0.129136] No USDPAA memory, no 'fsl,usdpaa-mem' in device-tree
[    0.129690] FPGA manager framework
[    0.129769] Advanced Linux Sound Architecture Driver Initialized.
[    0.131296] imx-scu scu: NXP i.MX SCU Initialized
[    0.137585] random: fast init done
[    0.179261] imx8qm-pinctrl scu:pinctrl: initialized IMX pinctrl driver
[    0.183115] clocksource: Switched to clocksource arch_sys_counter
[    0.183295] VFS: Disk quotas dquot_6.6.0
[    0.183352] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.183532] pnp: PnP ACPI: disabled
[    0.216686] thermal_sys: Registered thermal governor 'step_wise'
[    0.216690] thermal_sys: Registered thermal governor 'power_allocator'
[    0.217542] NET: Registered protocol family 2
[    0.217771] IP idents hash table entries: 65536 (order: 7, 524288 bytes, linear)
[    0.219142] tcp_listen_portaddr_hash hash table entries: 2048 (order: 3, 32768 bytes, linear)
[    0.219203] TCP established hash table entries: 32768 (order: 6, 262144 bytes, linear)
[    0.219423] TCP bind hash table entries: 32768 (order: 7, 524288 bytes, linear)
[    0.219924] TCP: Hash tables configured (established 32768 bind 32768)
[    0.220038] UDP hash table entries: 2048 (order: 4, 65536 bytes, linear)
[    0.220121] UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes, linear)
[    0.220314] NET: Registered protocol family 1
[    0.220656] RPC: Registered named UNIX socket transport module.
[    0.220668] RPC: Registered udp transport module.
[    0.220678] RPC: Registered tcp transport module.
[    0.220687] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.220705] PCI: CLS 0 bytes, default 64
[    0.220871] Unpacking initramfs...
[    0.223588] Initramfs unpacking failed: Decoding failed
[    0.224303] hw perfevents: enabled with armv8_pmuv3 PMU driver, 7 counters available
[    0.225900] kvm [1]: IPA Size Limit: 40 bits
[    0.226553] kvm [1]: vgic-v2@52020000
[    0.226583] kvm [1]: GIC system register CPU interface enabled
[    0.226680] kvm [1]: vgic interrupt IRQ1
[    0.226817] kvm [1]: Hyp mode initialized successfully
[    0.230371] Initialise system trusted keyrings
[    0.230480] workingset: timestamp_bits=44 max_order=20 bucket_order=0
[    0.236502] NFS: Registering the id_resolver key type
[    0.236531] Key type id_resolver registered
[    0.236541] Key type id_legacy registered
[    0.236560] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[    0.236573] nfs4flexfilelayout_init: NFSv4 Flexfile Layout Driver Registering...
[    0.236608] jffs2: version 2.2. (NAND) © 2001-2006 Red Hat, Inc.
[    0.249913] Key type asymmetric registered
[    0.249926] Asymmetric key parser 'x509' registered
[    0.249962] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 244)
[    0.249978] io scheduler mq-deadline registered
[    0.249989] io scheduler kyber registered
[    0.264048] imx6q-pcie 5f000000.pcie: 5f000000.pcie supply epdev_on not found, using dummy regulator
[    0.265977] EINJ: ACPI disabled.
[    0.379956] mxs-dma 5b810000.dma-apbh: initialized
[    0.381631] Bus freq driver module loaded
[    0.387845] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.392197] 5a060000.serial: ttyLP0 at MMIO 0x5a060010 (irq = 47, base_baud = 5000000) is a FSL_LPUART
[    0.392545] fsl-lpuart 5a060000.serial: DMA tx channel request failed, operating without tx DMA
[    0.392564] fsl-lpuart 5a060000.serial: DMA rx channel request failed, operating without rx DMA
[    0.392923] 5a070000.serial: ttyLP1 at MMIO 0x5a070010 (irq = 48, base_baud = 5000000) is a FSL_LPUART
[    1.465492] printk: console [ttyLP1] enabled
[    1.470646] 5a080000.serial: ttyLP2 at MMIO 0x5a080010 (irq = 49, base_baud = 5000000) is a FSL_LPUART
[    1.480286] fsl-lpuart 5a080000.serial: DMA tx channel request failed, operating without tx DMA
[    1.489014] fsl-lpuart 5a080000.serial: DMA rx channel request failed, operating without rx DMA
[    1.498199] 5a090000.serial: ttyLP3 at MMIO 0x5a090010 (irq = 50, base_baud = 5000000) is a FSL_LPUART
[    1.510673] arm-smmu 51400000.iommu: probing hardware configuration...
[    1.517227] arm-smmu 51400000.iommu: SMMUv2 with:
[    1.521944] arm-smmu 51400000.iommu: 	stage 1 translation
[    1.527354] arm-smmu 51400000.iommu: 	stage 2 translation
[    1.532772] arm-smmu 51400000.iommu: 	nested translation
[    1.538105] arm-smmu 51400000.iommu: 	stream matching with 32 register groups
[    1.545263] arm-smmu 51400000.iommu: 	32 context banks (0 stage-2 only)
[    1.551902] arm-smmu 51400000.iommu: 	Supported page sizes: 0x61311000
[    1.558448] arm-smmu 51400000.iommu: 	Stage-1: 48-bit VA -> 48-bit IPA
[    1.564989] arm-smmu 51400000.iommu: 	Stage-2: 48-bit IPA -> 48-bit PA
[    1.643077] imx-drm display-subsystem: parent device of /bus@57240000/ldb@572410e0/lvds-channel@0 is not available
[    1.677476] loop: module loaded
[    1.680992] zram: Added device: zram0
[    1.689239] ahci-imx 5f020000.sata: Adding to iommu group 0
[    1.695029] ahci-imx 5f020000.sata: can't get sata_ext clock.
[    1.701157] imx ahci driver is registered.
[    1.713002] libphy: Fixed MDIO Bus: probed
[    1.717339] tun: Universal TUN/TAP device driver, 1.6
[    1.724051] fec 5b040000.ethernet: Adding to iommu group 1
[    1.730190] pps pps0: new PPS source ptp0
[    1.735854] libphy: fec_enet_mii_bus: probed
[    1.742608] Freescale FM module, FMD API version 21.1.0
[    1.748739] Freescale FM Ports module
[    1.754031] VFIO - User Level meta-driver version: 0.3
[    1.763101] cdns-usb3 5b110000.usb3: Adding to iommu group 2
[    1.769885] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.776453] ehci-pci: EHCI PCI platform driver
[    1.782212] usbcore: registered new interface driver usb-storage
[    1.788299] usbcore: registered new interface driver usbserial_generic
[    1.794878] usbserial: USB Serial support registered for generic
[    1.800930] usbcore: registered new interface driver cp210x
[    1.806532] usbserial: USB Serial support registered for cp210x
[    1.812491] usbcore: registered new interface driver ftdi_sio
[    1.818269] usbserial: USB Serial support registered for FTDI USB Serial Device
[    1.825621] usbcore: registered new interface driver pl2303
[    1.831278] usbserial: USB Serial support registered for pl2303
[    1.837240] usbcore: registered new interface driver usb_serial_simple
[    1.843793] usbserial: USB Serial support registered for carelink
[    1.849918] usbserial: USB Serial support registered for zio
[    1.855614] usbserial: USB Serial support registered for funsoft
[    1.861643] usbserial: USB Serial support registered for flashloader
[    1.868022] usbserial: USB Serial support registered for google
[    1.873975] usbserial: USB Serial support registered for libtransistor
[    1.880533] usbserial: USB Serial support registered for vivopay
[    1.886576] usbserial: USB Serial support registered for moto_modem
[    1.892869] usbserial: USB Serial support registered for motorola_tetra
[    1.899517] usbserial: USB Serial support registered for novatel_gps
[    1.905900] usbserial: USB Serial support registered for hp4x
[    1.911676] usbserial: USB Serial support registered for suunto
[    1.917630] usbserial: USB Serial support registered for siemens_mpi
[    1.930939] input: sc-powerkey as /devices/platform/sc-powerkey/input/input0
[    1.940605] imx-sc-rtc scu:rtc: registered as rtc1
[    1.946065] i2c /dev entries driver
[    1.951570] pps_ldisc: PPS line discipline registered
[    1.965940] sdhci: Secure Digital Host Controller Interface driver
[    1.972179] sdhci: Copyright(c) Pierre Ossman
[    1.977350] Synopsys Designware Multimedia Card Interface Driver
[    1.985204] sdhci-pltfm: SDHCI platform and OF driver helper
[    1.992793] sdhci-esdhc-imx 5b010000.mmc: Adding to iommu group 3
[    2.031169] mmc0: SDHCI controller on 5b010000.mmc [5b010000.mmc] using ADMA
[    2.040469] sdhci-esdhc-imx 5b020000.mmc: Adding to iommu group 3
[    2.048043] sdhci-esdhc-imx 5b030000.mmc: Adding to iommu group 3
[    2.059776] ledtrig-cpu: registered to indicate activity on CPUs
[    2.068482] caam 31400000.crypto: device ID = 0x0a16040000000100 (Era 9)
[    2.075245] caam 31400000.crypto: job rings = 2, qi = 0
[    2.093300] caam algorithms registered in /proc/crypto
[    2.099940] caam 31400000.crypto: caam pkc algorithms registered in /proc/crypto
[    2.107449] caam 31400000.crypto: registering rng-caam
[    2.112855] Device caam-keygen registered
[    2.121478] hidraw: raw HID events driver (C) Jiri Kosina
[    2.126986] random: crng init done
[    2.127322] usbcore: registered new interface driver usbhid
[    2.135997] usbhid: USB HID core driver
[    2.143479] No fsl,qman node
[    2.146366] Freescale USDPAA process driver
[    2.147801] mmc0: new HS400 MMC card at address 0001
[    2.150589] fsl-usdpaa: no region found
[    2.156148] mmcblk0: mmc0:0001 S0J56X 14.8 GiB 
[    2.159385] Freescale USDPAA process IRQ driver
[    2.168905] mmcblk0boot0: mmc0:0001 S0J56X partition 1 31.5 MiB
[    2.175242] mmcblk0boot1: mmc0:0001 S0J56X partition 2 31.5 MiB
[    2.181479] mmcblk0rpmb: mmc0:0001 S0J56X partition 3 4.00 MiB, chardev (237:0)
[    2.190172]  mmcblk0: p1 p2
[    2.203145] Galcore version 6.4.3.p1.305572
[    2.394179] [drm] Initialized vivante 1.0.0 20170808 for 80000000.imx8_gpu1_ss on minor 0
[    2.406773] [VPU Decoder] warning: init rtx channel failed, ret: -517
[    2.413260] [VPU Decoder] failed to request mailbox, ret = -517
[    2.423214] [VPU Encoder] warning:  init rtx channel failed, ret: -517
[    2.430062] [VPU Encoder] warning:  init rtx channel failed, ret: -517
[    2.436649] [VPU Encoder] fail to request mailbox, ret = -517
[    2.445277] dvbdev: DVB: registering new adapter (PPM DVB adapter)
[    2.452088] dvbdev: DVB: registering new adapter (PPM DVB adapter)
[    2.515959] imx-spdif sound-spdif: snd-soc-dummy-dai <-> 59020000.spdif mapping ok
[    2.523565] imx-spdif sound-spdif: ASoC: no DMI vendor name!
[    2.530224] imx-audmix imx-audmix.0: failed to find SAI platform device
[    2.536877] imx-audmix: probe of imx-audmix.0 failed with error -22
[    2.545985] pktgen: Packet Generator for packet performance testing. Version: 2.75
[    2.554157] NET: Registered protocol family 26
[    2.558917] NET: Registered protocol family 10
[    2.563758] Segment Routing with IPv6
[    2.567466] NET: Registered protocol family 17
[    2.571945] tsn generic netlink module v1 init...
[    2.576697] Key type dns_resolver registered
[    2.581218] registered taskstats version 1
[    2.585332] Loading compiled-in X.509 certificates
[    2.607997] mxs_phy 5b100000.usbphy: 5b100000.usbphy supply phy-3p0 not found, using dummy regulator
[    2.627687] usb_phy_generic bus@5b000000:usb3-phy: bus@5b000000:usb3-phy supply vcc not found, using dummy regulator
[    2.638364] usb_phy_generic bus@5b000000:usbphynop2: bus@5b000000:usbphynop2 supply vcc not found, using dummy regulator
[    2.649894] imx-lpi2c 5a800000.i2c: can't get pinctrl, bus recovery not supported
[    2.657567] i2c i2c-2: LPI2C adapter registered
[    2.664628] sgtl5000 3-000a: sgtl5000 revision 0x11
[    2.706651] usb3503 3-0008: switched to HUB mode
[    2.711307] usb3503 3-0008: usb3503_probe: probed in hub mode
[    2.717163] i2c i2c-3: LPI2C adapter registered
[    2.724925] rtc-ds1307 4-0068: oscillator failed, set time!
[    2.730863] rtc-ds1307 4-0068: registered as rtc0
[    2.735613] i2c i2c-4: LPI2C adapter registered
[    2.741031] i2c i2c-5: LPI2C adapter registered
[    2.749743] pwm-backlight backlight: backlight supply power not found, using dummy regulator
[    2.749880] imx6q-pcie 5f000000.pcie: 5f000000.pcie supply epdev_on not found, using dummy regulator
[    2.750329] imx6q-pcie 5f010000.pcie: pcie_ext clock source missing or invalid
[    2.764322] dpu-core 56180000.dpu: driver probed
[    2.767538] imx6q-pcie 5f000000.pcie: No cache used with register defaults set!
[    2.776134] dpu-core 57180000.dpu: driver probed
[    2.791395] ahci-imx 5f020000.sata: phy impedance ratio is not specified.
[    2.798252] ahci-imx 5f020000.sata: No cache used with register defaults set!
[    2.805582] ahci-imx 5f020000.sata: 5f020000.sata supply ahci not found, using dummy regulator
[    2.814249] ahci-imx 5f020000.sata: 5f020000.sata supply phy not found, using dummy regulator
[    2.822809] ahci-imx 5f020000.sata: 5f020000.sata supply target not found, using dummy regulator
[    2.831901] ahci-imx 5f020000.sata: external osc is used.
[    2.840116] ahci-imx 5f020000.sata: no ahb clock.
[    2.844879] ahci-imx 5f020000.sata: AHCI 0001.0301 32 slots 1 ports 6 Gbps 0x1 impl platform mode
[    2.853767] ahci-imx 5f020000.sata: flags: 64bit ncq sntf pm clo only pmp fbs pio slum part ccc sadm sds apst 
[    2.864273] scsi host0: ahci-imx
[    2.867680] ata1: SATA max UDMA/133 mmio [mem 0x5f020000-0x5f02ffff] port 0x100 irq 106
[    2.879120] pps pps0: new PPS source ptp0
[    2.884250] libphy: fec_enet_mii_bus: probed
[    2.889141] imx6q-pcie 5f000000.pcie: PCIe PLL locked after 0 us.
[    2.897141] fec 5b040000.ethernet eth0: registered PHC device 0
[    2.906883]  xhci-cdns3: xHCI Host Controller
[    2.911372]  xhci-cdns3: new USB bus registered, assigned bus number 1
[    2.919274]  xhci-cdns3: hcc params 0x200073c8 hci version 0x100 quirks 0x0000001000018010
[    2.927997] hub 1-0:1.0: USB hub found
[    2.931776] hub 1-0:1.0: 1 port detected
[    2.935834]  xhci-cdns3: xHCI Host Controller
[    2.940213]  xhci-cdns3: new USB bus registered, assigned bus number 2
[    2.946754]  xhci-cdns3: Host supports USB 3.0 SuperSpeed
[    2.952194] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
[    2.960575] hub 2-0:1.0: USB hub found
[    2.964354] hub 2-0:1.0: 1 port detected
[    2.969110] imx_usb 5b0d0000.usb: 5b0d0000.usb supply vbus not found, using dummy regulator
[    3.111220] imx6q-pcie 5f000000.pcie: host bridge /bus@5f000000/pcie@0x5f000000 ranges:
[    3.119286] imx6q-pcie 5f000000.pcie:    IO 0x6ff80000..0x6ff8ffff -> 0x00000000
[    3.126701] imx6q-pcie 5f000000.pcie:   MEM 0x60000000..0x6fefffff -> 0x60000000
[    3.284115] ci_hdrc ci_hdrc.1: EHCI Host Controller
[    3.289058] ci_hdrc ci_hdrc.1: new USB bus registered, assigned bus number 3
[    3.311131] ci_hdrc ci_hdrc.1: USB 2.0 started, EHCI 1.00
[    3.317441] hub 3-0:1.0: USB hub found
[    3.321264] hub 3-0:1.0: 1 port detected
[    3.326527] gpio-fan gpio-fan: GPIO fan initialized
[    3.332701] sdhci-esdhc-imx 5b020000.mmc: Got CD GPIO
[    3.351168] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    3.358125] ata1.00: supports DRM functions and may not be fully accessible
[    3.365150] ata1.00: ATA-10: KINGSTON SKC600MS256G, S4800105, max UDMA/133
[    3.369221] mmc1: SDHCI controller on 5b020000.mmc [5b020000.mmc] using ADMA
[    3.372263] ata1.00: 500118192 sectors, multi 1: LBA48 NCQ (depth 32)
[    3.381676] sdhci-esdhc-imx 5b030000.mmc: Got CD GPIO
[    3.386463] ata1.00: supports DRM functions and may not be fully accessible
[    3.398393] ata1.00: configured for UDMA/133
[    3.422046] mmc2: SDHCI controller on 5b030000.mmc [5b030000.mmc] using ADMA
[    3.454786] debugfs: Directory '59050000.sai' with parent 'apalis-imx8qm-sgtl5000' already present!
[    3.464415] asoc-simple-card sound: sgtl5000 <-> 59050000.sai mapping ok
[    3.471139] asoc-simple-card sound: ASoC: no DMI vendor name!
[    3.481054] imx8qxp-lpcg-clk 5b260000.clock-controller: ignoring dependency for device, assuming no driver
[    3.481313] imx6q-pcie 5f010000.pcie: No cache used with register defaults set!
[    3.499496] rtc-ds1307 4-0068: hctosys: unable to read the hardware clock
[    3.501043] imx6q-pcie 5f010000.pcie: PCIe PLL locked after 0 us.
[    3.515839] ALSA device list:
[    3.519037]   #0: imx-spdif
[    3.521846]   #1: apalis-imx8qm-sgtl5000
[    3.723146] usb 3-1: new high-speed USB device number 2 using ci_hdrc
[    3.727208] imx6q-pcie 5f010000.pcie: host bridge /bus@5f000000/pcie@0x5f010000 ranges:
[    3.737649] imx6q-pcie 5f010000.pcie:    IO 0x7ff80000..0x7ff8ffff -> 0x00000000
[    3.745073] imx6q-pcie 5f010000.pcie:   MEM 0x70000000..0x7fefffff -> 0x70000000
[    3.852639] imx6q-pcie 5f010000.pcie: Link up
[    3.857030] imx6q-pcie 5f010000.pcie: Link: Gen2 disabled
[    3.862455] imx6q-pcie 5f010000.pcie: Link up, Gen1
[    3.867429] imx6q-pcie 5f010000.pcie: PCI host bridge to bus 0000:00
[    3.873806] pci_bus 0000:00: root bus resource [bus 00-ff]
[    3.879305] pci_bus 0000:00: root bus resource [io  0x10000-0x1ffff] (bus address [0x0000-0xffff])
[    3.884034] hub 3-1:1.0: USB hub found
[    3.888277] pci_bus 0000:00: root bus resource [mem 0x70000000-0x7fefffff]
[    3.888293] pci 0000:00:00.0: [1957:0000] type 01 class 0x060400
[    3.892103] hub 3-1:1.0: 3 ports detected
[    3.898941] pci 0000:00:00.0: reg 0x10: [mem 0x00000000-0x00ffffff]
[    3.915232] pci 0000:00:00.0: reg 0x38: [mem 0x00000000-0x00ffffff pref]
[    3.921983] pci 0000:00:00.0: supports D1 D2
[    3.926261] pci 0000:00:00.0: PME# supported from D0 D1 D2 D3hot
[    3.935774] pci 0000:01:00.0: [1b4b:2b42] type 00 class 0x020000
[    3.941880] pci 0000:01:00.0: reg 0x10: [mem 0x00000000-0x000fffff 64bit pref]
[    3.949158] pci 0000:01:00.0: reg 0x18: [mem 0x00000000-0x000fffff 64bit pref]
[    3.956680] pci 0000:01:00.0: supports D1 D2
[    3.960968] pci 0000:01:00.0: PME# supported from D0 D1 D3hot D3cold
[    3.967451] pci 0000:01:00.0: 2.000 Gb/s available PCIe bandwidth, limited by 2.5 GT/s x1 link at 0000:00:00.0 (capable of 4.000 Gb/s with 5 GT/s x1 link)
[    3.994320] pci 0000:00:00.0: BAR 0: assigned [mem 0x70000000-0x70ffffff]
[    4.001151] pci 0000:00:00.0: BAR 6: assigned [mem 0x71000000-0x71ffffff pref]
[    4.008687] pci 0000:00:00.0: BAR 15: assigned [mem 0x72000000-0x721fffff 64bit pref]
[    4.016570] pci 0000:01:00.0: BAR 0: assigned [mem 0x72000000-0x720fffff 64bit pref]
[    4.024614] pci 0000:01:00.0: BAR 2: assigned [mem 0x72100000-0x721fffff 64bit pref]
[    4.032411] pci 0000:00:00.0: PCI bridge to [bus 01-ff]
[    4.037643] pci 0000:00:00.0:   bridge window [mem 0x72000000-0x721fffff 64bit pref]
[    4.045700] pcieport 0000:00:00.0: PME: Signaling with IRQ 568
[    4.134408] imx6q-pcie 5f000000.pcie: Phy link never came up
[    4.140152] imx6q-pcie 5f000000.pcie: failed to initialize host
[    4.146134] imx6q-pcie 5f000000.pcie: unable to add pcie port.
[    4.635139] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    4.642283] ata1.00: supports DRM functions and may not be fully accessible
[    4.649969] ata1.00: supports DRM functions and may not be fully accessible
[    4.657477] ata1.00: configured for UDMA/133
[    4.661930] scsi 0:0:0:0: Direct-Access     ATA      KINGSTON SKC600M 0105 PQ: 0 ANSI: 5
[    4.671076] sd 0:0:0:0: [sda] 500118192 512-byte logical blocks: (256 GB/238 GiB)
[    4.678615] sd 0:0:0:0: [sda] 4096-byte physical blocks
[    4.684171] sd 0:0:0:0: [sda] Write Protect is off
[    4.689020] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    4.699769]  sda: sda1
[    4.702754] sd 0:0:0:0: [sda] Attached SCSI disk
[    4.716462] EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null)
[    4.724654] VFS: Mounted root (ext4 filesystem) on device 179:2.
[    4.732381] devtmpfs: mounted
[    4.736573] Freeing unused kernel memory: 2496K
[    4.741244] Run /sbin/init as init process
[    4.874052] systemd[1]: System time before build time, advancing clock.
[    4.915501] systemd[1]: systemd 245.4-4ubuntu3.16 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN2 -IDN +PCRE2 default-hierarchy=hybrid)
[    4.938637] systemd[1]: Detected architecture arm64.
[    4.980121] systemd[1]: Set hostname to <ubuntu>.
[    5.386737] systemd[1]: Created slice system-modprobe.slice.
[    5.393966] systemd[1]: Created slice system-serial\x2dgetty.slice.
[    5.401128] systemd[1]: Created slice User and Session Slice.
[    5.407307] systemd[1]: Started Dispatch Password Requests to Console Directory Watch.
[    5.415555] systemd[1]: Started Forward Password Requests to Wall Directory Watch.
[    5.423416] systemd[1]: Condition check resulted in Arbitrary Executable File Formats File System Automount Point being skipped.
[    5.435114] systemd[1]: Reached target Local Encrypted Volumes.
[    5.441285] systemd[1]: Reached target Paths.
[    5.445811] systemd[1]: Reached target Remote File Systems.
[    5.451541] systemd[1]: Reached target Slices.
[    5.456169] systemd[1]: Reached target Swap.
[    5.460796] systemd[1]: Listening on Device-mapper event daemon FIFOs.
[    5.467889] systemd[1]: Listening on LVM2 poll daemon socket.
[    5.474034] systemd[1]: Listening on Syslog Socket.
[    5.479219] systemd[1]: Listening on initctl Compatibility Named Pipe.
[    5.486537] systemd[1]: Listening on Journal Audit Socket.
[    5.492410] systemd[1]: Listening on Journal Socket (/dev/log).
[    5.498839] systemd[1]: Listening on Journal Socket.
[    5.504265] systemd[1]: Listening on udev Control Socket.
[    5.510025] systemd[1]: Listening on udev Kernel Socket.
[    5.519137] systemd[1]: Mounting Huge Pages File System...
[    5.528256] systemd[1]: Mounting POSIX Message Queue File System...
[    5.538629] systemd[1]: Mounting Kernel Debug File System...
[    5.545005] systemd[1]: Condition check resulted in Kernel Trace File System being skipped.
[    5.558034] systemd[1]: Starting Journal Service...
[    5.566542] systemd[1]: Starting Availability of block devices...
[    5.577139] systemd[1]: Starting Set the console keyboard layout...
[    5.588336] systemd[1]: Starting Create list of static device nodes for the current kernel...
[    5.600925] systemd[1]: Starting Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling...
[    5.611878] systemd[1]: Condition check resulted in Load Kernel Module drm being skipped.
[    5.622684] systemd[1]: Condition check resulted in Set Up Additional Binary Formats being skipped.
[    5.638135] systemd[1]: Starting Load Kernel Modules...
[    5.647466] systemd[1]: Starting Remount Root and Kernel File Systems...
[    5.658504] systemd[1]: Starting udev Coldplug all Devices...
[    5.669863] systemd[1]: Mounted Huge Pages File System.
[    5.675973] systemd[1]: Mounted POSIX Message Queue File System.
[    5.682735] systemd[1]: Mounted Kernel Debug File System.
[    5.690412] systemd[1]: Finished Availability of block devices.
[    5.697393] systemd[1]: Started Journal Service.
[    5.741363] systemd-journald[381]: Received client request to flush runtime journal.
[    6.587425] debugfs: Directory '59090000.sai' with parent 'imx-audio-hdmi-tx' already present!
[    6.587700] debugfs: File 'Capture' in directory 'dapm' already present!
```
