# YOCTO
Yocto Project provides a flexible toolset and a development environment that allows embedded device developers across the world to collaborate through shared technologies, software stacks, configurations, and best practices used to create these tailored Linux images.

![Yocto Project](https://e-labworks.com/images/training/ypr-860x460_hufca6c21192e465296dd08cdf2cc86043_38921_0x450_resize_q90_h2_lanczos_3.webp)

## Setting up Build Machine

1. 50 Gb of free disk
2. Runs a supported linux distribution (example: Ubuntu, Fedora...)
3. 	Git 1.8.3.1 or greater
   	
   	tar 1.27 or greater

   	Python 3.4.0 or greater.
## Setting Host Environment
Need to download the following essential tool to build yocto project

```bash
sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib \
build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
pylint3 xterm
```
## Steps to Configure Yocto project
### 1. Download Yocto Project

1.  Create a directory called `yocto` and change directory to it.
```bash
mkdir yocto && cd yocto
```
2. Clone Poky reference and change directory to poky and checkout to stable release by poky dunfell branch
```bash
# Clone the repo
git clone -b dunfell git://git.yoctoproject.org/poky.git
# Change directory
cd poky
```
### 2. ## Configuration Poky

We need to source the oe-init-build-env to set the environment for poky
```bash
source oe-init-build-env [Give folder name to be created] (Raspberrypi4)
```
Edit the tune of the parallelism of bitbake generator for fast execution and generation of project.
```bash
# change directory to conf
cd conf
# edit the file local.conf
vim local.com
```
## 3. Set my Configurations 
 * Add the Following
```bash
## Enbling UART in Target
ENABLE_UART = "1"

## Add packages to the image (Optional)
IMAGE_INSTALL:append = " bash vim ncurses openssh readline"
## Change the default shell (Optional)
### But make sure that the shell is installed in the image
SHELL = "/bin/bash"

## Enable the creation of an SD card image
IMAGE_FSTYPES = "tar.xz ext3 rpi-sdimg"

## Delete work files ... to save disk space as the build progresses
INHERIT += "rm_work" 

## Exclude some recipes from having their work directories deleted by rm_work
RM_WORK_EXCLUDE += "openssh"

## spawns interactive terminals on the host development system
OE_TERMINAL = "screen"

## RM_OLD_IMAGE: Reclaims disk space by removing previously built versions of the same image
RM_OLD_IMAGE = "1"

## my machine has 6 cores ##
## BB_NUMBER_THREADS ?= "1.5 * Number of cores"
BB_NUMBER_THREADS ?= "8"
## PARALLEL_MAKE ?= "-j 2 * Number of cores"
PARALLEL_MAKE ?= "12"
```
## Qemu build
Poky the default setting is to build qemu so we only need to run bitbake

```bash
# bitbake [options] [recipename/target ...]
bitbake core-image-minimal
```

## Raspberry Pi

We need to download the meta layer for raspberry pi

Check the following link for other meta layer required [OpenEmbedded Link](https://layers.openembedded.org/layerindex/branch/master/layers/)

Any meta data downloaded make sure to check out to **Dunfell branch**

```bash
# getting meta-raspberrypi
git clone git://git.yoctoproject.org/meta-raspberrypi
git checkout dunfell
```

We can also download of the layer that has many feature

```bash
git clone git://git.openembedded.org/meta-openembedded
git checkout dunfell
```

We need to add the layer in **bblayer.conf**

```bash
# POKY_BBLAYERS_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \
  /home/minazakka/YOCTO/Raspberrypi/poky/meta \
  /home/minazakka/YOCTO/Raspberrypi/poky/meta-poky \
  /home/minazakka/YOCTO/Raspberrypi/poky/meta-yocto-bsp \
  /home/minazakka/YOCTO/Raspberrypi/meta-raspberrypi \
  "
```
Change the machine in **local.conf** to the require raspberry pi chosen

```bash
...
# This sets the default machine to be qemux86-64 if no other machine is selected:
#MACHINE ??= "qemux86-64"
MACHINE ?= "raspberrypi4-64"
...
```
**Build the image**
```bash
# bitbake [options] [recipename/target ...]
bitbake core-image-minimal
```
### Note: Streamlining Disk Space with rm_work
rm_work aids in efficient disk space management by removing unnecessary temporary workspace, particularly beneficial during builds.

The OpenEmbedded build system consumes significant disk space during the build process, notably in the ${TMPDIR}/work directory for each recipe. Once packages are generated, these work files become redundant. Enabling rm_work in your local.conf file, found in the Build Directory, ensures timely removal of these files:
```bash
INHERIT += "rm_work"
```
However, be cautious when modifying and building source code from the work directory, as enabling rm_work may result in loss of changes. To safeguard specific recipes, use RM_WORK_EXCLUDE in local.conf:

```bash
RM_WORK_EXCLUDE += "busybox glibc openssh"
```
This selective exclusion preserves modifications while optimizing disk space during the build.