#!/bin/bash
#

PETALINUX_INSTALLER=/mnt/usb-backup/hold/xilinx-no-bkup/downloads/petalinux/petalinux-v2019.1-final-installer.run

PETALINUX_INSTALL_DIR=/mnt/sata-2/app/xilinx/petalinux/2019.1

set -e

if false
then
    

function do_installs
{
    # First Arg is array of packages to install
    a=("$@")
    for i in "${a[@]}"
    do
	echo; echo $i; echo
	#sleep 1
	apt install -y $i
    done

}

# Install User Packages
USER_PKGS=(
    emacs
    firefox
    ntp
    xinetd
    tftp
    tftpd
    screen
)

# Install Xilinx Deps
XILINX_PKGS=(
    tofrodos
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
)

# Install dependencies which are needed but not listed in UG1144
EXTRA_PKGS=(
    python
    libsdl1.2-dev
    libglib2.0-dev
    python3-gi
    less
    lsb-release
    fakeroot
    libgtk2.0-0
    libgtk2.0-dev
    cpio
    rsync
    xorg
    expect
    dos2unix
    sudo
    locales
    git
)



apt install -y gkrellm
gkrellm&
do_installs ${USER_PKGS[@]}
do_installs ${XILINX_PKGS[@]}
do_installs ${EXTRA_PKGS[@]}

fi

sudo -u bwhitlock git config --global user.email "bradley.whitlock@gmail.com"
sudo -u bwhitlock git config --global user.name  "Brad Whitlock"

cp /home/bwhitlock/scripts/server/support/sudoers /etc/sudoers
crontab < /home/bwhitlock/scripts/server/support/crontab.root

# NTP
timedatectl set-ntp yes

# PetaLinux requirement for Bash shell
sudo dpkg-reconfigure dash

mkdir -p /tftpboot
chmod 777 /tftpboot
chown -R nobody /tftpboot
cp /home/bwhitlock/scripts/server/support/tftp /etc/xinetd.d/
service xinetd restart

# Install PetaLinux
mkdir -p ${PETALINUX_INSTALL_DIR}
chmod -R 755 ${PETALINUX_INSTALL_DIR}
chown -R bwhitlock:bwhitlock ${PETALINUX_INSTALL_DIR}
sudo -u bwhitlock ${PETALINUX_INSTALLER} ${PETALINUX_INSTALL_DIR}
