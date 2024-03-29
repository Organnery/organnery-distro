#!/usr/bin/env bash

apt-get install --yes alsa-utils console-common cpufrequtils debconf-utils fake-hwclock gnupg locales ntp psmisc rfkill rt-tests sudo whois dosfstools feh util-linux
apt-get install --yes xserver-xorg xserver-xorg-input-libinput xserver-xorg-video-fbdev x11-xserver-utils
apt-get install --yes lightdm lightdm-autologin-greeter
apt-get install --yes openbox
apt-get install --yes lxterminal

# install deb packages & fix depends
dpkg -i /mnt/workspace/debs/*.deb
apt-get install -f --yes

# setup config.txt
cat << EOF > /boot/config.txt

# configure OTP memory bit to boot from USB in future
program_usb_boot_mode=1

# the kernel to use
kernel=vmlinuz-4.19.25-v7-raspberrypi-default

# disable splash to save some bootup time
disable_splash=1

# disable wireless interfaces
dtoverlay=pi3-disable-wifi
dtoverlay=pi3-disable-bt

# default soundcard
dtoverlay=pisound

# force HDMI output when no monitor is available
hdmi_force_hotplug=1

# set HDMI resolution to 1024x768
hdmi_group=2
hdmi_mode=18
EOF

# kernel cmdline
echo -n "dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait vt.global_cursor_default=0 loglevel=0 quiet logo.nologo" > /boot/cmdline.txt

# use overlayfs for root filesystem
echo -n " init=/usr/share/organnery/overlayRoot.sh" >> /boot/cmdline.txt

# setup realtime for audio users
# (jack normally does this)
cat << EOF > /etc/security/limits.d/audio.conf
@audio   -  rtprio     95
@audio   -  memlock    unlimited
EOF

# setup static IP ethernet
cat << EOF > /etc/network/interfaces
source /etc/network/interfaces.d/*

# loopback network interface
auto lo
iface lo inet loopback

# ethernet IP
auto /enx*=eth0
allow-hotplug eth0
iface eth0 inet static
	address 192.168.0.100
	gateway 192.168.0.1
EOF

# set dhcp timeout to minimum to reduce boot time
mkdir -p /etc/systemd/system/networking.service.d/
cat << EOF > /etc/systemd/system/networking.service.d/reduce-timeout.conf
[Service]
TimeoutStartSec=2
EOF

# Allow members of group sudo to execute any command
cat << EOF > /etc/sudoers
# Allow members of group sudo to execute any command
%sudo	ALL=(ALL:ALL) NOPASSWD: ALL
EOF