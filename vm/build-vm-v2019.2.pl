use IPC::Run 'run';
use warnings;

$OS_VERSION="ubuntu-16.04.5";
$XILINX_VERSION="2019.2";

$VBOXNAME="${OS_VERSION}-${XILINX_VERSION}";
$MAC_ADDRESS="080027be962b";

$VBOXMANAGE="c:/Program Files/Oracle/VirtualBox/vboxmanage.exe";
$VBOX_GUEST_ADDITIONS="c:/Program Files/Oracle/VirtualBoxVBoxGuestAdditions.iso";
$Z7="c:/Program Files/7-Zip/7z.exe";

$VM_BASE_FOLDER="d:/bwhitlock/vm_support/vms";
$VM_MEMORY_SIZE="8192";
$VM_VRAM_SIZE="128";
$VM_CPUS="2";
$VM_CPUEXECUTION_CAP="100";

$UBUNTU_ISO="d:/bwhitlock/vm_support/ubuntu-16.04.5-desktop-amd64.iso";

$VM_HDD_FILENAME="${VBOXNAME}-hdd.vdi";
$VM_HDD="${VM_BASE_FOLDER}/${VBOXNAME}/${VM_HDD_FILENAME}";

# Shared Folders
$VM_DOWNLOADS="d:/bwhitlock/downloads";
$VM_PROJECTS="d:/bwhitlock/projects/${XILINX_VERSION}";
$VM_SCRIPTS="c:/vm/scripts";

# PetaLinux Project Drive
#$PETALINUX_PROJECTS="d:/bwhitlock/vm_support/vms/drives/petalinux-projects.vdi";

sub vm_is_running
{
    my $vm_name = shift;

    run [ $VBOXMANAGE, "showvminfo", $vm_name ], ">", \my $stdout;

    if ( $stdout =~ /State:\s*(powered off)/ )
    {
	return 0;
    }

    return 1;
}

sub start_vm
{
    system ($VBOXMANAGE, "startvm",
	    $VBOXNAME);
}

sub wait_till_shutdown
{
    print ("Waiting for machine to shutdown\n");
    while (vm_is_running $VBOXNAME)
    {
	sleep (3);
    };

    print ("Waiting a few seconds before starting\n");
    sleep (5);
}

sub setuuid
{
    my $hdd_file = shift;
    print ("Setting UUID on ${hdd_file}\n");
    system ($VBOXMANAGE, "internalcommands",
	    "sethduuid", ${hdd_file});

}

sub createvm
{

    my $from_scratch = shift;
    my $hdd_file     = shift;

    print ("Creating VM\n");
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
	$VM_HDD = "$hdd_file";

    }

    system ($VBOXMANAGE, "storageattach",
	    $VBOXNAME,
	    "--storagectl", "SATA",
	    "--port",       "0",
	    "--device",     "0",
	    "--type",       "hdd",
	    "--medium",     $VM_HDD,
	);

#    system ($VBOXMANAGE, "storageattach",
#	    $VBOXNAME,
#	    "--storagectl", "SATA",
#	    "--port",       "1",
#	    "--device",     "0",
#	    "--type",       "hdd",
#	    "--medium",     $PETALINUX_PROJECTS,
#	);

}

sub vboxadditions
{

    print ("VBox Additions\n");

    system ($VBOXMANAGE, "storageattach",
	    $VBOXNAME,
	    "--storagectl", "IDE",
	    "--port",       "1",
	    "--device",     "1",
	    "--type",       "dvddrive",
	    "--medium",     $VBOX_GUEST_ADDITIONS,
	);

    print ("\n\n** When system boots, cd /media/user/VBOX~; sudo VBoxL~; **\n\n");

    start_vm ();
    wait_till_shutdown ();

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
    print ("Final Config\n");

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
	    "--hostpath", "$VM_SCRIPTS",
	    "--automount",
	);

    # In 18.04.1, shared folders are not automatically showing up
    print ("sudo passwd root; su; #./media/sf_scripts/configure-vm-v${XILINX_VERSION}.sh\n");

}

######################################################################
######################################################################

sub vm_from_scratch
{
    # Flow for building from scratch
    createvm (1);
    start_vm ();
    wait_till_shutdown ();
    vboxadditions ();
    finalconfig ();
    start_vm ();
}

# Flow for building when a base disk exists
sub vm_from_existing_hdd
{
    my $zip_hdd_file = shift;
    my $hdd_file     = shift;

    # Unzip the hdd
    system (${Z7},
	    "e",  "${zip_hdd_file}",
	    "-o${VM_BASE_FOLDER}/${VBOXNAME}");

    my $some_dir = "${VM_BASE_FOLDER}/${VBOXNAME}";
    opendir (my $dh, $some_dir);

    while (readdir $dh)
    {
	my $file = "$some_dir/$_";
	if ($file =~ /base-os/)
	{
	    #print ("file: $file\n");
	    $zip_hdd_file = $_;
	    #print ("zip_hdd_file: $zip_hdd_file\n");
	}

    }
    #print ("some_dir/zip_hdd_file: ${some_dir}/${zip_hdd_file}\n");
    #print ("some_dir/VM_HDD_FILE:  ${some_dir}/${VM_HDD_FILENAME}\n");
    rename ("${some_dir}/${zip_hdd_file}",
	    "${some_dir}/${VM_HDD_FILENAME}");

    # Change the UUID on the HDD to prevent collision with existing VMs
    setuuid ($hdd_file);

    # Flow for building from existing hdd
    createvm (0, $hdd_file);
    finalconfig ();
    start_vm ();
}

sub print_usage
{
    print ("\n\n");
    print ("Usage: build-vm-v${XILINX_VERSION}.pl <NEW_OR_EXISTING> <ZIP_HDD_FILE>\n");
    print ("NEW_OR_EXISTING: 'new' or 'existing'\n");
    print ("ZIP_HDD_FILE   : Path to existing 7z'd drive to use as OS hdd\n");
}

my $new_or_existing = "";
my $hdd_file   = "";

if ( defined $ARGV[0] && defined $ARGV[1] )
{
    $new_or_existing = $ARGV[0];
    $zip_hdd_file    = $ARGV[1];
    $hdd_file        = $VM_HDD;
}
else
{
    print_usage ();
    exit;
}

if ( $new_or_existing eq "new" )
{
    print ( "Building a new base OS drive\n" );
    sleep (5);
    vm_from_scratch ();
}
elsif ( $new_or_existing eq "existing" )
{
    print ("Building a VM from existing base OS drive\n");
    sleep (5);
    vm_from_existing_hdd ( $zip_hdd_file, $hdd_file );
}
else
{
    print ("\nERROR: Invalid NEW_OR_EXISTING:  \"$new_or_existing\"");
    print_usage ();
}
