#!/usr/bin/env bash

sh -c 'echo "set const" >> .nanorc'

sh -c 'echo "set tabsize 4" >> .nanorc'

sh -c 'echo "set tabstospaces" >> .nanorc'

adduser --disabled-password --gecos "" kensotrabing

usermod -aG sudo kensotrabing

cp .nanorc /home/kensotrabing/

mkdir -p /etc/ssh/kensotrabing