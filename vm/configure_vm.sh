#!/bin/bash
#
# Run on the VM
# Checkout the vm scripts to the local windows machine and

PETALINUX=/mnt/downloads/petalinux/petalinux-v2019.1-final-installer.run
PETALINUX_DIR=/app/petalinux/2019.1

SSH_ID=/mnt/downloads/ssh-key-virtualbox/*

# Add user to vboxsf group
T=$(groups user | grep vboxsf)
if  [ ! "$T" ]
then

    echo "Setting up groups"
    sleep 2

    usermod -aG vboxsf user
    usermod -aG sudo user

    groupadd xilinx
    usermod -aG xilinx user

    echo "Installing git"
    #dpkg --configure -a
    #rm -f /var/lib/dpkg/lock
    apt install -y git screen

    # Grab SSH ID
    mkdir -p /home/user/.ssh
    cp ${SSH_ID} /home/user/.ssh/
    chmod -R 700 /home/user/.ssh

    # Get scripts
    echo "Getting scripts"
    sudo -u user git config --global user.email "bradley.whitlock@gmail.com"
    sudo -u user git clone https://github.com/ad0rx/scripts.git /home/user/scripts

    # Get rcfiles
    echo "Getting rcfiles"
    sudo -u user git clone https://github.com/ad0rx/rcfiles.git /home/user/rcfiles
    cp /home/user/rcfiles/.* /home/user/

    # Remove password requirement from sudo command
    echo "Configuring sudoers"
    cp /home/user/scripts/vm/support/sudoers /etc/sudoers

    # Setup crontab
    echo "Installing crontab for root"
    crontab < /home/user/scripts/vm/support/crontab.root

    # disable screen lock
    #echo "Disabling screen lock"
    #sudo -u user gsettings set org.gnome.desktop.screensaver lock-enabled false

    # Add shared folders to fstab
    echo "Configuring shared folder fstab"
    mkdir -p /mnt/{vm,downloads}
    echo 'sharedfolder /mnt/vm        vboxsf rw 0 0' >> /etc/fstab
    echo 'downloads    /mnt/downloads vboxsf rw 0 0' >> /etc/fstab

    # Update the system
    #echo "Updating the system"
    #apt update && apt upgrade -y

    echo; echo "** Logout and relogin, and rerun this script **"; echo
    exit

fi

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

sudo -u user gkrellm&

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

# NTP
timedatectl set-ntp yes

# Xilinx Install Area
mkdir -p /app
chown -R user:xilinx /app
chmod -R g+s /app
chmod -R 775 /app

#install petalinux
echo; echo "Installing PetaLinux"; echo
sudo dpkg-reconfigure dash
mkdir -p /tftpboot
chmod 777 /tftpboot
chown -R nobody /tftpboot
cp /home/user/scripts/vm/support/tftp /etc/xinetd.d/
service xinetd restart
mkdir -p $PETALINUX_DIR
chown -R user:xilinx /app
chmod -R 777 /app
pushd /home/user
sudo -u user $PETALINUX $PETALINUX_DIR
popd

# Set permissions on /app
chown -R user:xilinx /app
chmod -R 755 /app
