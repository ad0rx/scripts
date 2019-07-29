#!/bin/bash
#
# mdadm read about 300MB/s and motherboard was over 400MB/s
#
# Run these commands to build the server -
# work in progress

# Copy SSH ID from backups and then pull scripts and rcfiles from
# git manually. Do that before running commands in this file.

# Setup the raid drive
# Do this manually because drives enumerate differently
#
# Install mdadm
#
# Remove existing:
#lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
#    sudo mdadm --zero-superblock /dev/sdc
#    sudo mdadm --zero-superblock /dev/sdd
#    sudo mdadm --zero-superblock /dev/sdb
#
#
# Build new array:
#sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd

# Create Filesystem:
# sudo mkfs.ext4 -F /dev/md0
#
# Use disks tools GUI to label the array 'projects-raid0'
# Mount:
#sudo mount /dev/disk/by-label/projects-raid0 /mnt/projects
#
# Save the raid layout:
# sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
#
# Add to fstab
# echo '/dev/md0 /mnt/md0 ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab

# Create a nologin 'projects' user and group
#sudo useradd -M projects
#sudo usermod -L projects
#sudo usermod -aG projects bwhitlock

# Change permissions on projects
#sudo chown -R projects:projects projects/
#sudo chmod -R g+s projects/
#chmod -R 755 projects/

if false
then
    
# Install User Packages
USER_PKGS=(
    emacs24
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

# Install Xilinx Deps
XILINX_PKGS=(gcc
	     gawk
	     tofrodos
	     tofrodos
	     xvfb
	     gcc
	     make
	     libncurses5-dev
	     zlib1g-dev
	     zlib1g-dev:i386
	     libssl-dev
	     flex
	     bison
	     diffstat
	     chrpath
	     socat
	     xterm
	     autoconf
	     libtool
	     unzip
	     texinfo
	     gcc-multilib
	     build-essential
	     libsdl1.2-dev
	     git
	     pax)
for i in "${XILINX_PKGS[@]}"
do

    #echo $i
    apt install -y $i

done

fi

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
mkdir -p $PETALINUX_DIR
chown -R user:xilinx /app
chmod -R 777 /app

exit

# Below copied from VM version

PETALINUX=/media/sf_downloads/petalinux/petalinux-v2018.3-final-installer.run
PETALINUX_DIR=/app/petalinux/2018.3
SDX=/media/sf_downloads/sdx/Xilinx_SDx_2018.3_1207_2324/xsetup

XILINX_LICENSE=/media/sf_downloads/virtual-box.lic

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
    rm -f /var/lib/dpkg/lock
    apt install -y git

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
    echo "Disabling screen lock"
    sudo -u user gsettings set org.gnome.desktop.screensaver lock-enabled false

    # Add shared folders to fstab
    echo "Configuring shared folder fstab"
    mkdir -p /mnt/{vm,downloads}
    echo 'sharedfolder /mnt/vm        vboxsf rw 0 0' >> /etc/fstab
    echo 'downloads    /mnt/downloads vboxsf rw 0 0' >> /etc/fstab

    echo; echo "** Logout and relogin, and rerun this script **"; echo
    exit

fi

set -e

# Update the system
#apt update && apt upgrade -y

# Install Packages
USER_PKGS=(emacs
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

# Install Xilinx Deps
XILINX_PKGS=(gcc
	     gawk
	     tofrodos
	     tofrodos
	     xvfb
	     gcc
	     make
	     libncurses5-dev
	     zlib1g-dev
	     zlib1g-dev:i386
	     libssl-dev
	     flex
	     bison
	     diffstat
	     chrpath
	     socat
	     xterm
	     autoconf
	     libtool
	     unzip
	     texinfo
	     gcc-multilib
	     build-essential
	     libsdl1.2-dev
	     git
	     pax)
for i in "${XILINX_PKGS[@]}"
do

    #echo $i
    apt install -y $i

done

# NTP
timedatectl set-ntp yes

#sudo -u user gkrellm &

# Xilinx Install Area
mkdir -p /app
chown -R user:xilinx /app
chmod -R g+s /app
chmod -R 775 /app

# Set MAC address for Xilinx license
#ip link set dev eth0 address ${MAC}

# install vivado
sudo -u user nice -n 20 $SDX &

#install petalinux
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

wait
# Set permissions on /app
chown -R user:xilinx /app
chmod -R 755 /app
