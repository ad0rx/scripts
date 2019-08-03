#!/bin/bash
#

set -e

# Install User Packages
USER_PKGS=(
    emacs
    firefox
    ntp
    xinetd
    tftp
    tftpd
    gkrellm
    screen)

for i in "${USER_PKGS[@]}"
do
    echo
    echo $i
    echo
    #sleep 1
    apt install -y $i

done

sudo -u bwhitlock gkrellm&

# Install Xilinx Deps
XILINX_PKGS=(tofrodos
	     iproute2
	     gawk
	     make
	     net-tools
	     libncurses5-dev
	     tftpd
	     zlib1g:i386
	     libssl-dev
	     flex
	     bison
	     libselinux1
	     gnupg
	     wget
	     diffstat
	     chrpath
	     socat
	     xterm
	     autoconf
	     libtool
	     tar
	     unzip
	     texinfo
	     zlib1g-dev
	     gcc-multilib
	     build-essential
	     screen
	     pax
	     gzip
	     python)

for i in "${XILINX_PKGS[@]}"
do

    echo
    echo $i
    echo
    #sleep 1
    apt install -y $i

done

sudo -u bwhitlock git config --global user.email "bradley.whitlock@gmail.com"
sudo -u bwhitlock git config --global user.name  "Brad Whitlock"

cp /home/bwhitlock/scripts/server/support/sudoers /etc/sudoers
crontab < /home/bwhitlock/scripts/server/support/crontab.root

# NTP
timedatectl set-ntp yes

#install petalinux
sudo dpkg-reconfigure dash
mkdir -p /tftpboot
chmod 777 /tftpboot
chown -R nobody /tftpboot
cp /home/bwhitlock/scripts/server/support/tftp /etc/xinetd.d/
service xinetd restart
