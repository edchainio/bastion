#!/usr/bin/env bash

# Testing

echo "


___________________________________ TESTING ___________________________________

This is program is currently in testing. 

You can change this setting in run.sh.



"

sleep 3

rm logs/*.json procedures/*.sh

cp -r originals/*.sh procedures

python3 shell.py

# Run

# python3 shell.py &>> logs/latest.log

# Clean-up

rm -rf __pycache__ wrappers/__pycache__