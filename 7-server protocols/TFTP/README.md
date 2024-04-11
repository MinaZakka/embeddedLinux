# Initialize TFTP protocol
### Ubuntu
```bash
#Switch to root
sudo su
#Make sure you are connected to internet
ping google.com
#Download tftp protocol
sudo apt-get install tftpd-hpa
#Check the tftp ip address
ip addr `will be needed`
#Change the configuration of tftp
nano /etc/default/tftpd-hpa
	#write inside the file
    tftf_option = “--secure –-create”
#Restart the protocal
Systemctl restart tftpd-hpa
#Make sure the tftp protocol is running
Systemctl status tftpd-hpa
#Change the file owner
cd /srv
chown tftp:tftp tftp 
#Move your image or file to the server
cp [File name] /srv/tftp
```
### Create Virtual Ethernet For QEMU
This section for Qemu emulator users only **no need for who using HW**

Create a script `qemu-ifup` 
```bash
#!/bin/sh
ip a add 192.168.0.1/24 dev $1
ip link set $1 up
```
#### Start Qemu
In order to start Qemu with the new virtual ethernet
```bash
sudo qemu-system-arm -M vexpress-a9 -m 128M -nographic \
-kernel u-boot/u-boot \
-sd sd.img \
-net tap,script=./qemu-ifup -net nic
```
## Setup U-Boot IP address
```bash
#Apply ip address for embedded device
setenv ipaddr [chose] 
#Set the server ip address that we get from previous slide
setenv serverip [host ip address]

#### WARNING ####
#the ip address should has the same net mask
```
## Load File to RAM
First we need to know the ram address by running the following commend
```bash
# this commend will show all the board information and it start ram address
bdinfo
```
### Load from FAT
```bash
# addressRam is a variable knowen from bdinfo commend
fatload mmc 0:1 [addressRam] [fileName]
```
### Load from TFTP
```bash
# addressRam is a variable knowen from bdinfo commend
tftp [addressRam] [fileName]
```