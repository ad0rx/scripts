use IPC::Run 'run';
use warnings;

#735 is window width
#1500 is right side monitor

$TTERMPRO="C:\\Program Files (x86)\\teraterm\\ttermpro.exe";
$LOG6="D:/bwhitlock/projects/teraterm_logs/COM6-log.txt";
$LOG7="D:/bwhitlock/projects/teraterm_logs/COM7-log.txt";
$LOG8="D:/bwhitlock/projects/teraterm_logs/COM8-log.txt";

system 1, $TTERMPRO, "/C=8", "/BAUD 115200", "/x=455", "/y=0", "/L=$LOG8";
system 1, $TTERMPRO, "/C=6", "/BAUD 115200", "/x=1500", "/y=0", "/L=$LOG6";
system 1, $TTERMPRO, "/C=7", "/BAUD 115200", "/x=1500", "/y=400", "/L=$LOG7";
