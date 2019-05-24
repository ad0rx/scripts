#!/bin/bash
#
# Run on the VM
# cd /media/sf_sharedfolder ; sudo xterm -e vm.sh

PETALINUX=/media/sf_downloads/petalinux-v2018.3-final-installer.run
PETALINUX_DIR=/app/petalinux/2018.3
SDX=/media/sf_downloads/Xilinx_SDx_2018.3_1207_2324/xsetup

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

    # Get rcfiles
    #sudo -u user wget https://raw.githubusercontent.com/ad0rx/rcfiles/master/.bashrc
    #sudo -u user mv .bashrc /home/user/
    #sudo -u user wget https://raw.githubusercontent.com/ad0rx/rcfiles/master/.screenrc 
    #sudo -u user mv .screen /home/user/

    apt -y install git
    
    # Get scripts
    sudo -u user git config --global user.email "bradley.whitlock@gmail.com" 
    sudo -u user git clone https://github.com/ad0rx/scripts.git /home/user/scripts

    # Get rcfiles
    sudo -u user git clone https://github.com/ad0rx/rcfiles.git /home/user/rcfiles
    cp /home/user/rcfiles/.* /home/user/

    # Remove password requirement from sudo command
    cp /home/user/scripts/vm/support/sudoers /etc/sudoers

    # Setup crontab
    crontab < /home/user/scripts/vm/support/crontab.root
    
    # disable screen lock
    sudo -u user gsettings set org.gnome.desktop.screensaver lock-enabled false
    
    echo "Logout and relogin, and rerun this script"
    exit
    
fi

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

# install vivado
#sudo -u user nice -n 20 $SDX &

#install petalinux
sudo dpkg-reconfigure dash
mkdir /tftpboot
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

