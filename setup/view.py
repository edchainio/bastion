#!/usr/bin/env python3

import os
import time
from os.path import expanduser


def header():
    os.system('clear')
    print(' _____________________________________________________________________________')
    print(' .............................................................................')
    print(' .............................................................................')    
    print(' ...............................  ___________  ...............................')
    print(' ..............................  /           \  ..............................')
    print(' .............................  /             \  .............................')
    print(' ............................  /               \  ............................')
    print(' _____________________________/     edChain     \_____________________________')
    print('\n\n\n\n')

def footer():
    print('\n\n\n')
    print(' .    .          .          .          .          .          .          .    .')
    time.sleep(0)
    print(' .       .         .         .                   .         .         .       .')
    time.sleep(1/100)
    print(' . .        .        .        .    2017-2018    .        .        .        . .')
    time.sleep(1/100)
    print(' .     .       .       .       .               .       .       .       .     .')
    time.sleep(2/100)
    print(' .    .     .     .     .     .     .     .     .     .     .     .     .    .')
    time.sleep(3/100)
    print(' .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .')
    time.sleep(5/100)
    print(' . .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  . .')
    time.sleep(8/100)
    print(' . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .')
    time.sleep(13/100)
    print(' .............................................................................')
    time.sleep(21/100)

def offset():
    os.system('clear')
    print(' .............................................................................')
    print(' . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .')
    print(' . .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  . .')
    print(' .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .')
    print(' .    .     .     .     .     .     .     .     .     .     .     .     .    .')
    print(' .     .       .       .       .               .       .       .       .     .')
    print(' . .        .        .        .     edChain     .        .        .        . .')
    print(' .       .         .         .                   .         .         .       .')
    print(' .    .          .          .          .          .          .          .    .')
    print('\n')

def main_menu():
    header()
    print(' Enter the following information.\n\n\n')
    remote_username  = input(' Remote username: ')
    remote_password  = input(' Remote password: ')
    email_address    = input(' E-mail address: ')
    defined_ssh_port = input(' Defined SSH port: ')
    cluster_name     = input(' Hostname: ')
    vm_count = int(input(' Number of nodes: '))
    # number_of_core_nodes = int(input(' Number of core nodes: '))
    # number_of_peripheral_nodes = int(input(' Number of peripheral nodes: '))
    user_home = expanduser('~')
    footer()
    offset()
    return cluster_name, defined_ssh_port, email_address, remote_username, remote_password, user_home, vm_count


if __name__ == '__main__':
    main_menu()