#!/bin/bash
# Start a VNC session
ME=$(basename $0)
#GEOM="1920x1080"
GEOM="1900x960"
DEPTH=16
USER=bwhitlock

echo; echo "${ME} Running"

# If an $1 was given, it was the geometry
if [ -n "$1" ]
then
    echo; echo "Setting Geometry to ${1}"
    GEOM="$1"
fi

#cd /home/${USER}
sudo -u ${USER} vncserver -depth 16 -geometry ${GEOM} -depth ${DEPTH} -rfbport 5901 -localhost

echo; echo "${ME} Complete"
