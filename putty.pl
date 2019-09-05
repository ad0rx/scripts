use IPC::Run 'run';
use warnings;

#735 is window width
#1500 is right side monitor

$TTERMPRO="C:\\Program Files (x86)\\teraterm\\ttermpro.exe";

system 1, $TTERMPRO, "/C=8", "/BAUD 115200", "/x=455", "/y=0";
system 1, $TTERMPRO, "/C=6", "/BAUD 115200", "/x=1500", "/y=0";
system 1, $TTERMPRO, "/C=7", "/BAUD 115200", "/x=1500", "/y=400";
