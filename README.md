INSTALLING DEBIAN WHEEZY TO OUYA
================================

This is tested on Debian Wheezy and mostly adapted from http://linux-sunxi.org/Debian

*OUYA IS EASILY BRICKABLE. READ NO FURTHER*

That said, the goal is not to flash anything on Ouya. Kernel is booted from memory and Debian from USB stick or SD card.

Known issues
------------
* Not properly tested, so there is a bunch unknown issues
* Low-power core doesn't work (kernel crash)
* HDMI must be connected always and the monitor/TV must be on always
* Audio plays at wrong rate
* Gstreamer usually assumes xvimagesink as the video sink, but nvxvimagesink must be used
* Only 1920x1080 supported


Setting up the rootfs
---------------------

### Prepare a USB stick ###

Partition an USB stick (I used SD card in a small USB reader) and give e.g. 512M for swap, the rest for EXT4. I recommend using at least 4GB stick.

Use `mkswap` and `mkfs.ext4` to initialise the partitions. If your system is properly set you shouldn't need even sudo for that while you would need sudo to format your actual root partition.

### Mount the USB stick: ###

Change the sdX2 below to match your setup.

    export TARGET=/mnt/rootfs
    sudo mkdir -p $TARGET
    sudo mount /dev/sdX2 $TARGET

### Extract base system packages to the USB stick: ###
    sudo debootstrap --verbose --arch armhf --foreign wheezy $TARGET http://ftp.debian.org/debian

### Prepare for chroot: ###
    sudo apt-get install qemu-user-static binfmt-support
    sudo cp /usr/bin/qemu-arm-static $TARGET/usr/bin
    sudo mkdir $TARGET/dev/pts
    sudo modprobe binfmt_misc
    sudo mount -t devpts devpts $TARGET/dev/pts
    sudo mount -t proc proc $TARGET/proc

### Finish the base system installation: ###
    sudo chroot $TARGET

You should see `I have no name!@hostname:/#`

    /debootstrap/debootstrap --second-stage

At the end, you should see `I: Base system installed successfully.`

Configuring rootfs while still in chroot
----------------------------------------

### Setup sources.list: ###
    cat <<END > /etc/apt/sources.list
    deb http://ftp.debian.org/debian/ wheezy main contrib non-free
    deb-src http://ftp.debian.org/debian/ wheezy main contrib non-free
    END

    apt-get update

### Configure language: ###
    export LANG=C
    apt-get install apt-utils dialog locales
    dpkg-reconfigure locales

Choose `en_US.UTF-8` for both prompts, or whatever you want.

    export LANG=en_US.UTF-8

### Install some important stuff: ###
    apt-get install dhcp3-client udev netbase ifupdown iproute openssh-server iputils-ping wget \
    net-tools ntpdate ntp vim nano less tzdata console-tools module-init-tools mc

### Configure ethernet with dhcp and set hostname: ###
    cat <<END > /etc/network/interfaces
    auto lo eth0
    iface lo inet loopback
    iface eth0 inet dhcp
    END

    echo ouya > /etc/hostname

### Create filesystem mounts: ###
FIXME: how to enable swap correctly in Debian nowadays?

    cat <<END > /etc/fstab
    # /etc/fstab: static file system information.
    #
    # <file system> <mount point>   <type>  <options>       <dump>  <pass>
    /dev/root      /               ext4    noatime,errors=remount-ro 0 1
    tmpfs          /tmp            tmpfs   defaults          0       0
    END

### Activate remote console and disable some local consoles: ###
    echo 'T0:2345:respawn:/sbin/getty -L ttyS0 115200 linux' >> /etc/inittab
    sed -i 's/^\([3-6]:.* tty[3-6]\)/#\1/' /etc/inittab

### Set root passwd: ###
    passwd

### Add normal user: ###
    adduser ouya
    adduser ouya video
    adduser ouya audio
    adduser ouya plugdev

### Install XFCE and Slim login manager: ###
    apt-get install xfce4 xfce4-goodies exaile exaile-plugin-contextinfo midori slim

Add "vt1" to `xserver_arguments` in `/etc/slim.conf` ###

### Install Tegra 3 proprietary binaries, configs, headers and pkgconfig files: ###
    dpkg -i tegra30-r16_3-*_armhf.deb

### Extract kernel modules: ###
    tar zxf modules-3.1.10-tk*.tar.gz -C $TARGET/lib/modules/

### Finish up with the chroot: ###

Log out from the chroot, kill any process started in the chroot (`lsof $TARGET`) and `sudo umount $TARGET`.

### Install adb and fastboot to the host Debian: ###
    sudo dpkg -i android-tools*deb

Booting Ouya
------------

Stick the USB stick to Ouya, turn on the TV (or monitor), select proper input and never turn it off again.

### Reboot Ouya to fastboot: ###
    adb reboot-bootloader

### Boot Ouya with the kernel: ###
*WARNING: NEVER EVER FLASH THE KERNEL, JUST BOOT FROM RAM*

    fastboot boot zImage-3.1.10-tk1+

