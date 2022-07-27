#!/bin/bash
# Start the VPN to peraton labs
CONFIGS_DIR=/home/bwhitlock/03_peraton_laptop/openvpn/config
CONFIG=brg-lab-tcp-per.ovpn
#
# One of the autoload has autostart: true
# while read line; do openvpn3 session-manage -D --path ${line/Path: /}; done < p
function get_paths () {

    PATHS=`openvpn3 sessions-list | grep Path`
    PATHS=${PATHS//Path: /}
    #echo "Paths: "
    #echo $PATHS
}

if [ -n "$1" ]
then
    get_paths
    for path in ${PATHS}
    do
        openvpn3 session-manage -D --path $path
    done

    echo "Current Sessions"
    openvpn3 sessions-list

    exit
else


    # Make sure no current sessions
    get_paths
    if [ -n "$PATHS" ]
    then
        echo "Sessions:"
        echo $PATHS
        echo "active session...exiting"
        exit
    fi

    # Start the connection
    #openvpn3 session-start --config ${CONFIGS_DIR}/${CONFIG}
    openvpn3-autoload --directory ${CONFIGS_DIR}

    # Remove from config manager to keep that clean, it's not necessary to
    # keep this in the config space
    openvpn3 config-remove --force -c ${CONFIG}

fi
