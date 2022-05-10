#!/usr/bin/env bash

# From some website:
#etags --language=none \
#  --regex='/[ \t]*\(`define\)[ \t]+\([^ \t]+\)/`\2/' \
#  --regex='/[ \t]*\(module\)[ \t]+\([^ \t]+\)/\2/' \
#  --regex='/[ \t]*\(input\|output\|reg\|wire\|function\)[ \t]+\(\[[^]]+\][ \t]+\)?\([^ \t]+\)/\3/' \
#  ../../*/include/*.v ../../include/*.v ../../../../include/*.v *.v
#  --output=TAGS

# Default to anchoring the find command in the current dir
ANCHOR=`pwd`
if [ -n "$1" ]
then
    echo "Anchoring find to $1"
    ANCHOR=$1
fi

rm TAGS
find $ANCHOR -regex '.*[.][s]?v[h]?' |                                \
    xargs etags --language=none -a -o TAGS                            \
          --regex='/[ \t]*\(`define\)[ \t]+\([^ \t]+\)/`\2/'          \
          --regex='/[ \t]*\(module\)[ \t]+\([^ \t]+\)/\2/'            \
          --regex='/[ \t]*\(class\)[ \t]+\([^ \t;]+\)/\2/'            \
          --regex='/[ \t]*\(package\)[ \t]+\([^ \t;]+\)/\2/'          \
          --regex='/[ \t]*\(interface\)[ \t]+\([^ \t;(]+\)/\2/'       \
          --regex='/[ \t]*\(task\)[ \t]+\([^ \t;(]+\)/\2/'            \
