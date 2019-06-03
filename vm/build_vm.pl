use IPC::Run 'run';
use warnings;

print "Running...\n";

$VBOXNAME="Test-VM-3";

$VBOXMANAGE="d:/bwhitlock/virtualbox5.1.22/vboxmanage.exe";
$VBOX_GUEST_ADDITIONS="d:/bwhitlock/virtualbox5.1.22/VBoxGuestAdditions.iso";

#$VM_BASE_FOLDER="d:/bwhitlock/scripted-vbox";
$VM_BASE_FOLDER="c:/vm";
$VM_MEMORY_SIZE="8192";
$VM_VRAM_SIZE="128";
$VM_CPUS="2";
$VM_CPUEXECUTION_CAP="90";

#$UBUNTU_ISO="D:/bwhitlock/downloads/vm_support/ubuntu-16.04.4-desktop-amd64.iso";
$UBUNTU_ISO="c:/vm/ubuntu-16.04.4-desktop-amd64.iso";

$VM_HDD_FILENAME="${VBOXNAME}-hdd.vdi";
$VM_HDD="$VM_BASE_FOLDER/$VM_HDD_FILENAME";

$VM_SHARED_FOLDER="c:/vm";
$VM_DOWNLOADS="d:/bwhitlock/downloads";

sub vm_is_running
{
    my $vm_name = shift;

    run [ $VBOXMANAGE, "showvminfo", $vm_name ], ">", \my $stdout;

    #print $stdout, "\n";
    
    if ( $stdout =~ /State:\s*(powered off)/ )
    {
        return 0;
    }

    return 1;
}

sub createvm
{
    print "Creating VM\n";
    system ($VBOXMANAGE, "--version");
    system ($VBOXMANAGE, "createvm",
            "--name",    $VBOXNAME,
            "--basefolder", $VM_BASE_FOLDER,
            "--ostype",  "Ubuntu_64",
            "--register",
        );

    system ($VBOXMANAGE, "modifyvm",
            $VBOXNAME,
            "--memory", $VM_MEMORY_SIZE,
            "--vram",   $VM_VRAM_SIZE,
            "--cpus",   $VM_CPUS,
            "--cpuexecutioncap", $VM_CPUEXECUTION_CAP,
            "--pae",      "on",
            "--hwvirtex", "on",
            "--paravirtprovider", "default",
            "--accelerate3d",      "on",
            "--accelerate2dvideo", "off",
            "--boot1", "dvd",
            "--boot2", "disk",

        );

    system ($VBOXMANAGE,  "modifyvm",
            $VBOXNAME,
            "--nic1",     "bridged",
            "--nictype1", "82540EM",
            "--bridgeadapter1", "Intel(R) Ethernet Connection I219-LM",
        );


    system ($VBOXMANAGE, "modifyvm",
            $VBOXNAME,
            "--clipboard",    "bidirectional",
            "--usb",          "on",
            "--audio",        "none",
        );

    system ($VBOXMANAGE, "storagectl",
            $VBOXNAME,
            "--name",        "IDE",
            "--add",         "ide",
            "--bootable",    "on",
            "--hostiocache", "off",
        );

    system ($VBOXMANAGE, "storagectl",
            $VBOXNAME,
            "--name",     "SATA",
            "--add",      "sata",
            "--bootable", "on",

        );

    system ($VBOXMANAGE, "storageattach",
            $VBOXNAME,
            "--storagectl", "IDE",
            "--port",       "1",
            "--device",     "1",
            "--type",       "dvddrive",
            "--medium",     $UBUNTU_ISO,
        );

    system ($VBOXMANAGE, "createmedium",
            "disk",
            "--filename", $VM_HDD,
            "--size",     "102400",
            "--format",   "vdi",
        );

    system ($VBOXMANAGE, "storageattach",
            $VBOXNAME,
            "--storagectl", "SATA",
            "--port",       "0",
            "--device",     "0",
            "--type",       "hdd",
            "--medium",     $VM_HDD,
        );

    system ($VBOXMANAGE, "startvm",
            $VBOXNAME,
        );
}

sub vboxadditions
{

    print "VBox Additions\n";
    
    system ($VBOXMANAGE, "storageattach",
            $VBOXNAME,
            "--storagectl", "IDE",
            "--port",       "1",
            "--device",     "1",
            "--type",       "dvddrive",
            "--medium",     $VBOX_GUEST_ADDITIONS,
        );


    print "\n\n** When system boots, cd /media/user/VBOX~; sudo sh ./VBoxL~; then shutdown **\n\n";

    system ($VBOXMANAGE, "startvm",
            $VBOXNAME,
        );

}

sub finalconfig
{
    print "Final Config\n";
    
    # Unmount Guest Additions DVD
    system ($VBOXMANAGE, "storageattach",
            $VBOXNAME,
            "--storagectl", "IDE",
            "--port",       "1",
            "--device",     "1",
            "--type",       "dvddrive",
            "--medium",     "none",
        );

    system ($VBOXMANAGE, "sharedfolder", "add",
            $VBOXNAME,
            "--name",    "sharedfolder",
            "--hostpath", $VM_SHARED_FOLDER,
            "--automount",
        );

    system ($VBOXMANAGE, "sharedfolder", "add",
            $VBOXNAME,
            "--name",    "downloads",
            "--hostpath", $VM_DOWNLOADS,
            "--automount",
        );

    system ($VBOXMANAGE, "startvm",
            $VBOXNAME,
        );

}

sub wait_till_shutdown
{
    print "Waiting for machine to shutdown\n";
    while (vm_is_running $VBOXNAME)
    {
        sleep 3;
    };

}

######################################################################
######################################################################

createvm;
wait_till_shutdown;
vboxadditions;
wait_till_shutdown;
finalconfig;

print "Exiting.\n";
