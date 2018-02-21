#!/usr/bin/env python3

import json
import os
import sys
import time

from wrappers import digitalocean


# TODO 1: Write a module for AWS Lightsail.
# TODO 2: Write an error handler.

def spinup(cluster_name, defined_ssh_port, remote_username, remote_password, user_home, vm_count, working_directory):
    timestamp_utc = time.time()
    writeout_file = 'logs/build-{timestamp_utc}.json'.format(timestamp_utc=timestamp_utc)
    aws_lightsail = ['awsl', 'aws lightsail']
    digital_ocean = ['do', 'digital ocean']
    iaas_platform = aws_lightsail + digital_ocean
    # vendor_choice = input('vendor_choice: ') # FIXME Parameter hard-coded to expedite testing.
    vendor_choice = 'do'                       # FIXME Parameter hard-coded to expedite testing.
    if vendor_choice in iaas_platform:
        if vendor_choice in aws_lightsail:
            pass # TODO 1
        elif vendor_choice in digital_ocean:
            os.system('{unix_command} > {writeout_file}'                                              \
                        .format(unix_command=digitalocean.builder(cluster_name, user_home, vm_count), \
                                writeout_file=writeout_file))
            time.sleep(60)
            return harden(defined_ssh_port, remote_username, remote_password, user_home, working_directory, writeout_file)
    else:
        pass # TODO 2

def harden(defined_ssh_port, remote_username, remote_password, user_home, working_directory, writeout_file):
    response = json.load(open(writeout_file))
    payloads = []
    if 'droplets' in response:
        payloads = response['droplets']
    else:
        payloads = [response['droplet']]
    ip_addresses = []
    for payload in payloads:
        ip_addresses.append(digitalocean.get_host(payload['id'], user_home, writeout_file))
    for ip_address in ip_addresses:
        # TODO n: Re-format local paths (e.g, {user_home}/.ssh/id_rsa.pub)
        os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/hybrid/remote0.sh'.format(ip_address=ip_address))
        os.system('scp {user_home}/.ssh/id_rsa.pub root@{ip_address}:/etc/ssh/{remote_username}/authorized_keys'.format(remote_username=remote_username, user_home=user_home, ip_address=ip_address))
        os.system('sh -c \'echo "{remote_password}" > {working_directory}/.htpasswd-credentials\''.format(remote_password=remote_password, working_directory=working_directory))
        os.system('sh -c \'echo "{remote_username}:{remote_password}" > {working_directory}/.chpasswd-credentials\''.format(remote_username=remote_username, remote_password=remote_password, working_directory=working_directory))
        os.system('scp {working_directory}/.htpasswd-credentials root@{ip_address}:/home/{remote_username}/'.format(remote_username=remote_username, ip_address=ip_address, working_directory=working_directory))
        os.system('scp {working_directory}/.chpasswd-credentials root@{ip_address}:/home/{remote_username}/'.format(remote_username=remote_username, ip_address=ip_address, working_directory=working_directory))
        os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/hybrid/remote1.sh'.format(ip_address=ip_address))
        os.system('ssh -o "StrictHostKeyChecking no" -p {defined_ssh_port} {remote_username}@{ip_address} \'bash -s\' < procedures/hybrid/remote2.sh'.format(defined_ssh_port=defined_ssh_port, ip_address=ip_address, remote_username=remote_username))
    os.system('rm {working_directory}/.htpasswd-credentials'.format(working_directory=working_directory))
    os.system('rm {working_directory}/.chpasswd-credentials'.format(working_directory=working_directory))
    return ip_addresses

# TODO n: Write logic for the following function.
# def teardown():
#     pass

def print_header():
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

def print_main_menu():
    print_header()
    print(' Welcome.\n\n\n')
    print(' Select one of the following options.\n\n')
    acceptable_input = ['s', 'm', 'q']
    user_input = input(' [S] Spin-up a single node (in development)\n [M] Spin-up multiple nodes\n\n [Q] Quit\n\n\n > ')
    if user_input.lower() in acceptable_input:
        if user_input.lower() == 's':
            print_single_node_menu()
        elif user_input.lower() == 'm':
            print_multiple_nodes_menu()
        else:
            print_footer()
    else:
        print('Sorry, that isn\'t an option.')
        time.sleep(2)
        print_main_menu()

def print_single_node_menu():
    print_header()
    print(' Main Menu  /  Single Node\n\n\n')
    print(' Select one of the following options.\n\n')
    acceptable_input = ['c', 'p', 'q']
    user_input = input(' [C] Spin-up a core node (in development)\n [P] Spin-up a peripheral node (in development)\n\n [Q] Quit\n\n\n > ')
    if user_input.lower() in acceptable_input:
        if user_input.lower() == 'c':
            os.system('clear')
            print_core_node_menu()
        elif user_input.lower() == 'p':
            print_peripheral_node_menu()
        else:
            print_footer()
    else:
        print('Sorry, that isn\'t an option.')
        time.sleep(2)
        print_single_node_menu()

def print_core_node_menu():
    print_header()
    print(' Main Menu  /  Single Node  /  Core Node\n\n\n')
    print(' Enter the following information.\n\n')
    print_final_menu()

def print_peripheral_node_menu():
    print_header()
    print(' Main Menu  /  Single Node  /  Peripheral Node\n\n\n')
    print(' Enter the following information.\n\n')
    print_final_menu()

def print_multiple_nodes_menu():
    print_header()
    print(' Main Menu  /  Multiple Nodes\n\n\n')
    print(' Select one of the following options.\n\n')
    acceptable_input = ['t', 'q']
    user_input = input(' [T] Spin-up a test network\n\n [Q] Quit\n\n\n > ')
    if user_input.lower() in acceptable_input:
        if user_input.lower() == 't':
            print_header()
            print(' Main Menu  /  Multiple Nodes  /  Test Network\n\n\n')
            print(' Enter the following information.\n\n')
            print_final_menu()
        else:
            print_footer()
    else:
        print('Sorry, that isn\'t an option.')
        time.sleep(2)
        print_multiple_nodes_menu()

def print_final_menu():
    remote_username  = input(' Remote username: ')
    remote_password  = input(' Remote password: ')
    email_address    = input(' E-mail address: ')
    defined_ssh_port = input(' Defined SSH port: ')
    cluster_name     = input(' Hostname: ')
    vm_count = int(input(' Number of nodes: '))
    print_footer()
    from test import search_and_replace
    search_and_replace('procedures/hybrid/remote0.sh', '<remote_username>', remote_username)
    search_and_replace('procedures/hybrid/remote1.sh', '<remote_username>', remote_username)
    search_and_replace('procedures/hybrid/remote1.sh', '<defined_ssh_port>', defined_ssh_port)
    search_and_replace('procedures/hybrid/remote1.sh', '<email_address>', email_address)
    search_and_replace('procedures/hybrid/remote1.sh', '<cluster_name>', cluster_name)
    from os.path import expanduser
    user_home = expanduser('~')
    working_directory = os.getcwd()
    from pprint import pprint
    pprint(spinup(cluster_name, defined_ssh_port, remote_username, remote_password, user_home, vm_count, working_directory))

def print_footer():
    print('\n\n\n')
    print(' .       .         .         .                   .         .         .       .')
    print(' . .        .        .        .   2017 - 2018   .        .        .        . .')
    print(' .     .       .       .       .               .       .       .       .     .')
    print(' .    .     .     .     .     .     .     .     .     .     .     .     .    .')
    print(' .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .')    
    print(' . .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  . .')
    print(' . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .')
    print(' _____________________________________________________________________________')
    print('\n')


if __name__ == '__main__':
    # print_header()
    print_main_menu()
    # remote_username  = input(' Remote username: ')
    # remote_password  = input(' Remote password: ')
    # email_address    = input(' E-mail address: ')
    # defined_ssh_port = input(' Defined SSH port: ')
    # cluster_name     = input(' Cluster name: ')

    # vm_count = int(input(' Cluster size (number of nodes): '))

    # print_footer()


    # from test import search_and_replace
    # search_and_replace('procedures/hybrid/remote0.sh', '<remote_username>', remote_username)
    # search_and_replace('procedures/hybrid/remote1.sh', '<remote_username>', remote_username)
    # search_and_replace('procedures/hybrid/remote1.sh', '<defined_ssh_port>', defined_ssh_port)
    # search_and_replace('procedures/hybrid/remote1.sh', '<email_address>', email_address)
    # search_and_replace('procedures/hybrid/remote1.sh', '<cluster_name>', cluster_name)

    # from os.path import expanduser
    # user_home = expanduser('~')

    # working_directory = os.getcwd()

    # from pprint import pprint
    # pprint(spinup(cluster_name, defined_ssh_port, remote_username, remote_password, user_home, vm_count, working_directory))