#!/usr/bin/bash
#
# Push and Pull via rsync to bubba
#
# Further work
# 1. save the list of candidate files from dry run
#    so that you don't have to wait for building
#    the file list twice. See --list-only option
#
######################################################################

#LOCAL=/home/bwhitlock/03_peraton_laptop/docker/
LOCAL=/home/bwhitlock/03_peraton_laptop/
#REMOTE=bubba:/mnt/projects/documents/03_peraton_laptop/docker/
REMOTE=bubba:/mnt/projects/documents/03_peraton_laptop/
USER=bwhitlock
PUSH_OPTION="-ui -P -avh --stats --delete-before"
PULL_OPTION="-ui -P -avh --stats"
#SSH_PORT=65534
REMOTE_SHELL="ssh -p 65534 -l bwhitlock"
FILTER_FILE=/home/bwhitlock/03_peraton_laptop/rsync_filter

function push() {

    DRYRUN="-n"

    # If called without arg, then perform dryrun
    if [ -z "$1" ]
    then
        echo 'will dry'
    fi

    # If called with "DO IT", then perform sync
    if [ "$1" = "DO IT" ]
    then
        echo "will sync"
        DRYRUN=""
    fi

    rsync $PUSH_OPTION --filter=". $FILTER_FILE"                      \
          --rsh="$REMOTE_SHELL"                                       \
          $LOCAL $REMOTE                                              \
          $DRYRUN

}

function pull() {

    DRYRUN="-n"

    # If called without arg, then perform dryrun
    if [ -z "$1" ]
    then
        echo 'will dry'
    fi

    # If called with "DO IT", then perform sync
    if [ "$1" = "DO IT" ]
    then
        echo "will sync"
        DRYRUN=""
    fi

    rsync $PULL_OPTION --filter=". $FILTER_FILE"                      \
          --rsh="$REMOTE_SHELL"                                       \
          $REMOTE $LOCAL                                              \
          $DRYRUN

}

function usage() {
    echo "USAGE: plap_rsync <push> | <pull>"
    exit
}

######################################################################
######################################################################

# Check args
if [ "$1" = "push" ]
then

    # Perform Dry Run
    push

    # Ask for Y/N
    # If Y, perform SYNC
    echo
    echo "------------------------"
    echo "Does the sync look sane?"
    echo "Type 1 or 2 ENTER"
    select yn in "Y" "N"; do
        case $yn in
            Y) push "DO IT"; break;;
            N) exit;;
        esac
    done

elif [ "$1" = "pull" ]
then

    # Perform Dry Run
    pull

    # Ask for Y/N
    # If Y, perform SYNC
    echo
    echo "------------------------"
    echo "Does the sync look sane?"
    echo "Type 1 or 2 ENTER"
    select yn in "Y" "N"; do
        case $yn in
            Y ) pull "DO IT"; break;;
            N ) exit;;
        esac
    done

else
    usage
fi
