#!/usr/bin/env bash

# Testing

rm logs/*.json procedures/*.sh

cp -r originals/*.sh procedures

python3 shell.py

# Run

# python3 shell.py &>> logs/latest.log

# Clean-up

rm -rf __pycache__ wrappers/__pycache__