#!/usr/bin/env bash

echo ''
echo ''
echo ' LEFT OFF MODIFYING THE CORE / HYBRID FILES FOR peripherals '
echo ''
echo ' Start by gutting the installations that the peripheral nodes do not need.'
echo ''
echo ' Then, go back through old commits to reference the hybrid code for the peripheral node set-up.'
echo ''
echo ''
echo ''

rm addresses/.private* certificates/*.crt logs/*.json procedures/core/*.sh procedures/peripheral/*.sh >/dev/null 2>&1

python3 shell.py

rm -rf __pycache__/ wrappers/__pycache__/