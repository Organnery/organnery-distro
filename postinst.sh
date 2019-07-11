#!/usr/bin/env bash

apt-get install --yes alsa-utils console-common cpufrequtils debconf-utils fake-hwclock gnupg locales ntp psmisc rfkill rt-tests sudo whois
apt-get install --yes xserver-xorg xserver-xorg-input-libinput xserver-xorg-video-fbdev x11-xserver-utils
apt-get install --yes lightdm lightdm-autologin-greeter
apt-get install --yes openbox
apt-get install --yes lxterminal

# install deb packages & fix depends
dpkg -i /mnt/workspace/debs/*.deb
apt-get install -f --yes

# setup config.txt
cat << EOF > /boot/config.txt
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

# set HDMI resolution to 1280x768
hdmi_group=2
hdmi_mode=24
EOF

# kernel cmdline
#echo -n "dwc_otg.lpm_enable=0 net.ifnames=0 console=ttyAMA0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait logo.nologo" > /boot/cmdline.txt
#default
echo -n "dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait" > /boot/cmdline.txt

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

# ethernet static IP
auto /enx*=eth0
allow-hotplug eth0
#iface eth0 inet dhcp
iface eth0 inet static
	address 192.168.0.100
	gateway 192.168.0.1
EOF
