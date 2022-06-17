#!/usr/bin/env perl
use warnings;
use diagnostics;
use strict;
use v5.32;

my $RCFILES_PATH  = "C:/Users/bwhitlock/Documents/rcfiles";
my $GIT           = "C:/Users/bwhitlock/AppData/Local/Programs/Git/cmd/git.exe";
my $PUTTY         ="\"C:/Program Files/PuTTY/putty.exe\"";

my @PUTTY_SESSIONS = ("plap", "dkr_via_plap_2022");

my $PUTTY_SESSION ="plap";
my $PUTTY_SESSION1="dkr_via_plap_2022";
#my $EMACS         ="\"C:/Program Files (x86)/Emacs/i686/bin/runemacs.exe\"";
my $EMACS         ="\"C:/Program Files/Emacs-27.1/x86_64/bin/runemacs.exe\"";

# Git Pull rcfiles
print ("Performing git pull\n");
chdir $RCFILES_PATH;
system ("$GIT pull");

# Start SSH Connections
print ("Starting SSH Sessions\n");
foreach ( @PUTTY_SESSIONS ) {
    system ("START /MIN \"\" $PUTTY -load $_");
}

# Open Emacs and run pstart
print ("Starting Emacs\n");
system ("START /MIN \"\" $EMACS -f pstart");

# Sleep for a while so I can see output from commands
sleep (10);
