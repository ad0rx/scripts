#!/bin/bash
# Start the VPN to peraton labs
CONFIGS_DIR=/home/bwhitlock/03_peraton_laptop/openvpn/config
CONFIG=brg-lab-tcp-per.ovpn
#
# One of the autoload has autostart: true

if [ -n "$1" ]
then
    openvpn3 session-manage -D -c ${CONFIG}
    exit
else


# Start the connection
#openvpn3 session-start --config ${CONFIGS_DIR}/${CONFIG}
openvpn3-autoload --directory ${CONFIGS_DIR}

# Remove from config manager to keep that clean, it's not necessary to
# keep this in the config space
openvpn3 config-remove --force -c ${CONFIG}

fi
