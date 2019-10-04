use IPC::Run 'run';
use warnings;

$VBOXNAME="2019.1";
$MAC_ADDRESS="080027be962b";

$VBOXMANAGE="C:/Program Files/Oracle/VirtualBox/vboxmanage.exe";
$VBOX_GUEST_ADDITIONS="d:/bwhitlock/virtualbox5.1.22/VBoxGuestAdditions.iso";

#$VM_BASE_FOLDER="d:/bwhitlock/scripted-vbox";
$VM_BASE_FOLDER="c:/vm";
$VM_MEMORY_SIZE="8192";
$VM_VRAM_SIZE="128";
$VM_CPUS="2";
$VM_CPUEXECUTION_CAP="90";

#$UBUNTU_ISO="c:/vm/ubuntu-18.04.1-desktop-amd64.iso";
$UBUNTU_ISO="D:/bwhitlock/downloads/vm_support/ubuntu-18.04.1-desktop-amd64.iso";

$VM_HDD_FILENAME="${VBOXNAME}-hdd.vdi";
$VM_HDD="$VM_BASE_FOLDER/$VM_HDD_FILENAME";

# Shared Folders
$VM_DOWNLOADS="d:/bwhitlock/downloads";
$VM_PROJECTS="d:/bwhitlock/projects/2019.1";

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

sub start_vm
{
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

    print "Waiting a few seconds before starting\n";
    sleep 5;
}

sub createvm
{

    my $from_scratch = shift;
    my $hdd_file     = shift;

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
	    "--accelerate3d",      "off",
	    "--accelerate2dvideo", "off",
	    "--boot1", "dvd",
	    "--boot2", "disk",
	    "--macaddress1", ${MAC_ADDRESS},
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

    if ($from_scratch == 1)
    {

	print ("Creating VM Drive and attaching ISO");

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

    } # End from scratch
    else {

	print ("Creating VM using existing HDD: $hdd_file\n");
	$VM_HDD = "$VM_BASE_FOLDER/$hdd_file";
	#print ("VM_HDD: $VM_HDD\n");
    }

    system ($VBOXMANAGE, "storageattach",
	    $VBOXNAME,
	    "--storagectl", "SATA",
	    "--port",       "0",
	    "--device",     "0",
	    "--type",       "hdd",
	    "--medium",     $VM_HDD,
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

    print "\n\n** When system boots, cd /media/user/VBOX~; sudo VBoxL~; **\n\n";

    start_vm;
    wait_till_shutdown;

    # Unmount Guest Additions DVD
    system ($VBOXMANAGE, "storageattach",
	    $VBOXNAME,
	    "--storagectl", "IDE",
	    "--port",       "1",
	    "--device",     "1",
	    "--type",       "dvddrive",
	    "--medium",     "none",
	);

}

sub finalconfig
{
    print "Final Config\n";

    system ($VBOXMANAGE, "sharedfolder", "add",
	    $VBOXNAME,
	    "--name",    "downloads",
	    "--hostpath", $VM_DOWNLOADS,
	    "--automount",
	);

    system ($VBOXMANAGE, "sharedfolder", "add",
	    $VBOXNAME,
	    "--name",    "projects",
	    "--hostpath", $VM_PROJECTS,
	    "--automount",
	);

    system ($VBOXMANAGE, "sharedfolder", "add",
	    $VBOXNAME,
	    "--name",     "scripts",
	    "--hostpath", "$VM_BASE_FOLDER/scripts",
	    "--automount",
	);

    # In 18.04.1, shared folders are not automatically showing up
    #print "\n\n./get-config.sh; chmod +x configure-vm*; sudo ./configure-vm*\n";

}

######################################################################
######################################################################

sub vm_from_scratch
{
    # Flow for building from scratch
    createvm 1;
    start_vm;
    wait_till_shutdown;
    vboxadditions;
    finalconfig;
    start_vm;
}

# Flow for building when a base disk exists
sub vm_from_existing_hdd
{
    my $hdd_file = shift;

    # Flow for building from existing hdd
    createvm (0, $hdd_file);
    finalconfig;
    start_vm;
}

sub print_usage
{
    print "\n\n";
    print "Usage: build-vm-v2019.1.pl <BUILD_TYPE> <HDD_FILE>\n";
    print "BUILD_TYPE: new or existing\n";
    print "HDD_FILE: Path to existing vdi to use as main hdd\n";
}

my $build_type = "";
my $hdd_file   = "";

if ( defined $ARGV[0] && defined $ARGV[1] )
{
    $build_type = $ARGV[0];
    $hdd_file   = $ARGV[1];
}
else
{
    print_usage;
    exit;
}

if ( $build_type eq "new" )
{
    print "Building a new base OS drive\n";
    sleep ( 5 );
    #vm_from_scratch
}
elsif ( $build_type eq "existing" )
{
    print "Building a VM from existing base OS drive\n";
    sleep 5;
    vm_from_existing_hdd ( $hdd_file );
}
else
{
    print "\nERROR: Invalid BUILD_TYPE:  \"$build_type\"";
    print_usage;
}
