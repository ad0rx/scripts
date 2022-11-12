#!/bin/bash
# Start the VPN to peraton labs
#
# One of the autoload has autostart: true
#
#######################################################################

CONFIGS_DIR=/home/bwhitlock/03_peraton_laptop/openvpn/config
CONFIG=brg-lab-tcp-per.ovpn

# while read line; do openvpn3 session-manage -D --path ${line/Path: /}; done < p
function get_paths () {

    PATHS=`openvpn3 sessions-list | grep Path`
    PATHS=${PATHS//Path: /}

}

function remove_sessions () {

    get_paths
    for path in ${PATHS}
    do
        openvpn3 session-manage -D --path $path
    done

    echo "Current Sessions"
    openvpn3 sessions-list

}
#
# One of the autoload has autostart: true
#
#######################################################################

function test_connection () {

    PING_OUTPUT=$(ping -W 1 -c 1 hc14)
    RETURN=$?
    echo "Ping Return: $RETURN"

    if [ "$RETURN" -eq "1" ]
    then
        echo "Connection is not functional"
    fi

    return $RETURN
}

function remove_configs () {

    local configs=`openvpn3 configs-list | grep configuration`

    for config in $configs
    do
        echo "Removing config $config"
        openvpn3 config-remove --force --path $config
    done

}

function start_new_connection () {

    # Start the connection
    #openvpn3 session-start --config ${CONFIGS_DIR}/${CONFIG}
    openvpn3-autoload --directory ${CONFIGS_DIR}

    # Remove from config manager to keep that clean, it's not necessary to
    # keep this in the config space
    #openvpn3 config-remove --force -c ${CONFIG}
    remove_configs
}

touch /home/bwhitlock/03_peraton_laptop/00_vpn.log

# Begin Main Program Execution
if [ -n "$1" ]
then
    remove_sessions
    exit
else

    if test_connection
    then
        # Connection Up
        echo "Current Connection Functional"
    else
        # Connection Down
        echo "Current Connection non-Functional"

        remove_sessions
        start_new_connection
    fi

fi
