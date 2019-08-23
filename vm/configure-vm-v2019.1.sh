#!/bin/bash
#
# Use wget to get this file and run on vm
# wget https://raw.githubusercontent.com/ad0rx/scripts/master/vm/configure-vm-v2019.1.sh
# run with sudo

PETALINUX=/mnt/downloads/petalinux/petalinux-v2019.1-final-installer.run
PETALINUX_DIR=/app/petalinux/2019.1

SSH_ID=/mnt/downloads/vm_support/ssh-key-virtualbox/*

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

    # disable screen lock
    #echo "Disabling screen lock"
    #sudo -u user gsettings set org.gnome.desktop.screensaver lock-enabled false

    # Add shared folders to fstab
    echo "Configuring shared folder fstab"
    mkdir -p /mnt/{vm,downloads,projects}
    echo 'sharedfolder /mnt/vm        vboxsf rw 0 0' >> /etc/fstab
    echo 'downloads    /mnt/downloads vboxsf rw 0 0' >> /etc/fstab
    echo 'projects     /mnt/projects  vboxsf rw 0 0' >> /etc/fstab

    # Update the system
    #echo "Updating the system"
    #apt update && apt upgrade -y

    echo; echo "** reboot, and rerun this script **"; echo
    exit

fi

set -e

# Grab SSH ID
mkdir -p /home/user/.ssh
cp -r ${SSH_ID} /home/user/.ssh
chmod -R 700 /home/user/.ssh
chown -R user:user /home/user/.ssh

# This is all down here because we need to have a filesystem mounted
# and groups must be setup first
echo "Installing git"
#dpkg --configure -a
#rm -f /var/lib/dpkg/lock
apt install -y git screen
sudo -u user git config --global user.email "bradley.whitlock@gmail.com"

# Get scripts
echo "Getting scripts"
sudo -u user git clone git@github.com:ad0rx/scripts.git /home/user/scripts

# Get rcfiles
echo "Getting rcfiles"
sudo -u user git clone git@github.com:ad0rx/rcfiles.git /home/user/rcfiles
for f in /home/user/rcfiles/.*
do
    if [ -f $f ]
    then
	cp $f /home/user/
	chown user:user /home/user/$(basename $f)
    fi
done
cp -r /home/user/rcfiles/.git /home/user
chown -R user:user /home/user/.git

# Remove password requirement from sudo command
echo "Configuring sudoers"
cp /home/user/scripts/vm/support/sudoers /etc/sudoers

# Setup gkrellm
mkdir -p /home/user/.gkrellm2
cp /home/user/scripts/vm/support/user-config /home/user/.gkrellm2/
chown -R user:user /home/user/.gkrellm2

# Setup crontab
echo "Installing crontab for root"
crontab < /home/user/scripts/vm/support/crontab.root

# Install User Packages
USER_PKGS=(
    emacs
    firefox
    ntp
    xinetd
    tftp
    dkms
)

# Install Xilinx Deps listed in UG1144
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
sudo -u user gkrellm&
do_installs ${USER_PKGS[@]}
do_installs ${XILINX_PKGS[@]}
do_installs ${EXTRA_PKGS[@]}

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
