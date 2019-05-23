#!/bin/bash
# Remove Xilinx log files rooted at $1
# if no dir given, the current dir is used

ROOT=.

if [ -n "$1" ]
then
    ROOT=$1
    echo "Using ROOT=${ROOT}"
fi

nice -n 20 find ${ROOT} -regex '.*vivado.*\(jou\|log\|str\)$' | xargs rm -f
nice -n 20 find ${ROOT} -regex '.*SDK.*\(log\)$'              | xargs rm -f
nice -n 20 find ${ROOT} -regex '.*webtalk.*\(jou\)$'          | xargs rm -f

echo "${ROOT}" > /home/user/00_cleanup_xilinx
