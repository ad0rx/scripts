#!/usr/bin/bash

#etags --language=none \
#  --regex='/[ \t]*\(`define\)[ \t]+\([^ \t]+\)/`\2/' \
#  --regex='/[ \t]*\(module\)[ \t]+\([^ \t]+\)/\2/' \
#  --regex='/[ \t]*\(input\|output\|reg\|wire\|function\)[ \t]+\(\[[^]]+\][ \t]+\)?\([^ \t]+\)/\3/' \
#  ../../*/include/*.v ../../include/*.v ../../../../include/*.v *.v
#  --output=TAGS

find $1 -regex '.*[.][s]?v[h]?' | xargs etags -a -o TAGS \
                                        --regex='/[ \t]*\(`define\)[ \t]+\([^ \t]+\)/`\2/' \
                                        --regex='/[ \t]*\(module\)[ \t]+\([^ \t]+\)/\2/' \
                                        --regex='/[ \t]*\(input\|output\|reg\|wire\|function\)[ \t]+\(\[[^]]+\][ \t]+\)?\([^ \t]+\)/\3/'
