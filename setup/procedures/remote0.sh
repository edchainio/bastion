#!/usr/bin/env bash

sh -c 'echo "set const" >> .nanorc'

sh -c 'echo "set tabsize 4" >> .nanorc'

sh -c 'echo "set tabstospaces" >> .nanorc'

adduser --disabled-password --gecos "" <remote_username>

usermod -aG sudo <remote_username>

cp .nanorc /home/<remote_username>/

mkdir -p /etc/ssh/<remote_username>