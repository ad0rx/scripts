#!/bin/bash
# run this as root user

XILINX_VERSION=2019.2

SF_DOWNLOADS=/media/sf_downloads
SF_SUPPORT=/media/sf_support

PETALINUX=${SF_DOWNLOADS}/petalinux/petalinux-v${XILINX_VERSION}-final-installer.run
PETALINUX_DIR=/app/petalinux/${XILINX_VERSION}
XRT=${SF_DOWNLOADS}/vitis/${XILINX_VERSION}/xrt/xrt_201920.2.3.1301_16.04-xrt.deb
EDGE_PLATFORM_DIR=/app/xilinx/Vitis/${XILINX_VERSION}/platforms
EDGE_PLATFORM_ZCU102=${SF_DOWNLOADS}/vitis/${XILINX_VERSION}/edge_platforms/zcu102_base_2019.2.zip

SSH_ID=${SF_SUPPORT}/ssh-key-virtualbox/*

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

function setup_system
{
    # Configure apt
    sudo apt-get remove unattended-upgrades
    #echo "APT::Install-Recommends false;"               > /etc/apt/apt.conf.d/00norecommends
    #echo "APT::AutoRemove::RecommendsImportant false;" >> /etc/apt/apt.conf.d/00norecommends
    #echo "APT::Install-Suggests false;"                 > /etc/apt/apt.conf.d/00nosuggests
    #echo "APT::AutoRemove::SuggestsImportant false;"   >> /etc/apt/apt.conf.d/00nosuggests
    apt update

}

function setup_user_group
{
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
	#echo "Configuring shared folder fstab"
	#mkdir -p /mnt/petalinux_projects
	#chown -R user:xilinx /mnt/petalinux_projects
	#chmod -R 775 /mnt/petalinux_projects
	#chmod -R g+s /mnt/petalinux_projects
	#echo '/dev/sdb  /mnt/petalinux-projects  ext4  rw  0  0' >> /etc/fstab
	#mkdir -p /mnt/{downloads,projects}
	#echo 'downloads    /mnt/downloads vboxsf rw 0 0' >> /etc/fstab
	#echo 'projects     /mnt/projects  vboxsf rw 0 0' >> /etc/fstab

	# Update the system
	#echo "Updating the system"
	#apt update && apt upgrade -y

	echo; echo "** reboot, and rerun this script **"; echo
	exit

    fi

}

#set -e

function setup_user
{

    # Grab SSH ID
    mkdir -p /home/user/.ssh
    cp -r ${SSH_ID} /home/user/.ssh
    chmod -R 700 /home/user/.ssh
    #chown -R user:user /home/user/.ssh

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
	    #chown user:user /home/user/$(basename $f)
	fi
    done
    cp -r /home/user/rcfiles/.git /home/user
    #chown -R user:user /home/user/.git

    # Remove password requirement from sudo command
    echo "Configuring sudoers"
    cp /home/user/scripts/vm/support/sudoers /etc/sudoers

    # Setup gkrellm
    mkdir -p /home/user/.gkrellm2
    cp /home/user/scripts/vm/support/user-config /home/user/.gkrellm2/
    #chown -R user:user /home/user/.gkrellm2

    # Setup crontab
    echo "Installing crontab for root"
    crontab < /home/user/scripts/vm/support/crontab.root

    chown -R user:user /home/user

}

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
    iproute
    gawk
    make
    net-tools
    libncurses5-dev
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
    libtool-bin
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
    #    python
    #    libsdl1.2-dev
	libglib2.0-dev
    #    python3-gi
    #    less
    #    lsb-release
    #    fakeroot
    #    libgtk2.0-0
    #    libgtk2.0-dev
    #    cpio
    #    rsync
    #    xorg
    #    expect
    #    dos2unix
    #    sudo
    #    locales
    #    git
    #    xvfb
    update-inetd
    tftpd
)

XRT_PKGS=(
    ocl-icd-libopencl1
    opencl-headers
    ocl-icd-opencl-dev
)

function install_pkgs
{
    apt install -y gkrellm
    sudo -u user gkrellm&
    do_installs ${USER_PKGS[@]}
    do_installs ${XILINX_PKGS[@]}
    do_installs ${EXTRA_PKGS[@]}

    # NTP
    timedatectl set-ntp yes

}

function setup_xilinx
{
    # Xilinx Install Area
    mkdir -p /app
    chown -R user:xilinx /app
    chmod -R g+s /app
    chmod -R 775 /app
}

function install_petalinux
{
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

    # Disable postinst hooks so that zcu102 builds succeed
    @files = (
	update_font_cache
	update_gio_module_cache
	update_gtk_immodules_cache
	update_icon_cache
	update_pixbuf_cache
	)
    pushd $PETALINUX_DIR/components/yocto/source/aarch64/layers/core/scripts/postinst-intercepts
    mkdir hold
    for f in "${files[@]}"
    do
	mv $f hold
    done
    popd

    # Set ownership on home, for some reason root takes some files
    chown -R user:user /home/user
}

# Edge platforms download from Xilinx.com Downloads
function install_xrt
{
    do_installs ${XRT_PKGS[@]}

    # fix python AR#73055
    #pip install --upgrade pip
    #python -m pip install numpy

    pip install setuptools

    # Install XRT
    apt install ${XRT}

    # Extract ZCU102 platform to Vitis installation dir
    unzip ${EDGE_PLATFORM_ZCU102} -d ${EDGE_PLATFORM_DIR}
}


function main
{

    setup_system
    setup_user_group
    set -e
    setup_user
    install_pkgs
    setup_xilinx
    install_petalinux

    #NEED TO INSTALL VITIS FIRST
    #install_xrt

    # Generate a SYSROOT for ZCU102

}
