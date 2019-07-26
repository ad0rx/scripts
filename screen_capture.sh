#!/bin/bash
#
# Capture a window or full screen and store in ~/tmp for
# easy transfer to laptop for importing into email or
# document
#
#

#
CAPTURE_FILE=~/tmp/capture.png
#CAPTURE_FILE=~/tmp/capture.jpg
#CAPTURE_FILE=~/tmp/capture.svg

# 72 pixels per inch on laptop
# 576 pixles is 8"
SIZE=576
#SIZE=560

# Get the window info
echo; echo "Select window of interest"
XWININFO=$(xwininfo | grep "Window id")

# Grab everything in quotes
WINDOW=$(echo ${XWININFO} | grep -oP '"\K[^"]+')

echo; echo "Clear the window of interest for capture"
sleep 5

# Grab the window
import -window "${WINDOW}" ${CAPTURE_FILE}

# Edit capture in Gimp
echo; echo "When done editing, export as capture.bmp"
gimp ${CAPTURE_FILE} &> /dev/null

# Resize with ImageMagic
convert -resize ${SIZE} ${CAPTURE_FILE} ${CAPTURE_FILE%%.png}_small.png



