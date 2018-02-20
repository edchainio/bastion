#!/usr/bin/env bash

# Testing

clear

echo ""
echo " Starting edChain..."

sleep 1

rm logs/*.json procedures/*.sh >/dev/null 2>&1

cp -r originals/*.sh procedures

clear

python3 shell.py

# Run

# python3 shell.py &>> logs/latest.log

# Clean-up

rm -rf __pycache__ wrappers/__pycache__