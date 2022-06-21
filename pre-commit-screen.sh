#!/usr/bin/env bash
#
# run this from dkr container to see logs updated in realtim
# while running pre-commit
#######################################################################
xterm -fa \"Monospace\" -fs 14 -maximized -T pre-commit-screen -e     \
      ssh -t dkr screen -c ~/scripts/pre-commit-screen
