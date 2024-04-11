# BusyBox

**BusyBox** is a software suite that provides a single binary executable file that contains many common Unix utilities. It is designed to be **small and efficient**, and is often used in **embedded systems** or other systems with limited resources. 

## Download BusyBox

```bash
git clone https://github.com/mirror/busybox.git
cd busybox/
```
## Configure BusyBox
```bash
make menuconfig
```
## Compile BusyBox
```bash
# export the compiler on the system
# chose the right compiler that corespond to your board
export CROSS_COMPILE=arm-cortexa9_neon-linux-musleabihf-
export ARCH=arm

# Configure busybox to be static build from menuconfig
make menuconfig

#build the busybox to get the minimal command
make

# generate the rootfs
make install
# this will create folder name _install has all binary
```
## Create the Rootfs

We need to copy the rootfs under folder `_install` under file name backwards of BusyBox directory and the files from sysroot which is output of **arm-cortexa9_neon-linux-musleabihf** toolchain

```bash
# create directory rootfs
mkdir ~/rootfs

# copy the content inside the _install into rootfs
cp -rp ./busybox/_install/ ./rootfs

#copy the conents under sysroot in ~/x-tools/arm-cortexa9_neon-linux-musleabihf/arm-cortexa9_neon-linux-musleabihf/sysroot
sudo rsync -a ./x-tools/arm-cortexa9_neon-linux-musleabihf/arm-cortexa9_neon-linux-musleabihf/sysroot/* ./rootfs/ 

# change directory to rootfs
cd rootfs

# create the rest folder for rootfs
mkdir -p ./dev /etc

#create folder inittab
touch /etc/inittab
```
# Mount rootfs through SD Card
```bash
# mount the sd card to the host file system
# No need to do this command if the sd card already mounted
sudo mount /dev/mmblck<x> /media/SDCARD
# copy rootfs into the sd card
cd rootfs
cp -r * /media/SDCARD/rootfs
# unmount the SD card
sudo umount /media/SDCARD
```
## Setup Bootargs in U-boot
```bash
setenv bootargs 'console=ttyO0,115200n8 root=/dev/mmcblk0p2 rootfstype=ext4 rw rootwait init=/sbin/init'
# console is set depends on the machine
```
# System configuration and startup 
The first user space program that gets executed by the kernel is `/sbin/init` and its configuration
file is `/etc/inittab`. in `inittab` we are executing `::sysinit:/etc/init.d/rcS`but this file doesn't exist.
create `/etc/init.d/rcS` startup script and in this script mount `/proc` `/sys` filesystems:
```sh 
#!/bin/sh
# mount a filesystem of type `proc` to /proc
mount -t proc nodev /proc
# mount a filesystem of type `sysfs` to /sys
mount -t sysfs nodev /sys
# you can create `/dev` and execute `mdev -s` if you missed the `devtmpfs` configuration  
```
> Note: `can't run '/etc/init.d/rcS': Permission denied` , use 
```sh
#inside `rootfs` folder
chmod +x ./etc/init.d/rcS # to give execution permission for rcS script
#restart
```