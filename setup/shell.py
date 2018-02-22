#!/usr/bin/env python3

import json
import os
import sys
import time
from os.path import expanduser

from pprint import pprint

from test import search_and_replace
from wrappers import digitalocean


# TODO 1: Write a module for AWS Lightsail.
# TODO 2: Write an error handler.

def spinup(cluster_name, defined_ssh_port, email_address, remote_username, remote_password, user_home, vm_count, working_directory):
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
            return harden(cluster_name, defined_ssh_port, email_address, remote_username, remote_password, user_home, working_directory, writeout_file)
    else:
        pass # TODO 2

def harden(cluster_name, defined_ssh_port, email_address, remote_username, remote_password, user_home, working_directory, writeout_file):
    response = json.load(open(writeout_file))
    payloads = []
    if 'droplets' in response:
        payloads = response['droplets']
    else:
        payloads = [response['droplet']]
    ip_addresses = []
    for payload in payloads:
        ip_addresses.append(digitalocean.get_host(payload['id'], user_home, writeout_file))
    count = 0
    for ip_address in ip_addresses:
        #
        # User-defined variables in the build scripts:
        #
        #
        # Automatically replaced:
        #
        #
        #
        #
        #
        # Not automatically replaced:
        #
        # <client_server_public_ip_address>
        #
        #
        #
        #
        os.system('cp originals/hybrid/get-private-ip-address.sh procedures/hybrid/get-private-ip-address-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count))
        os.system('cp originals/hybrid/remote0.sh procedures/hybrid/remote0-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count))
        os.system('cp originals/hybrid/remote1.sh procedures/hybrid/remote1-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count))
        search_and_replace('procedures/hybrid/remote0-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<remote_username>', remote_username)
        search_and_replace('procedures/hybrid/remote1-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<remote_username>', remote_username)
        search_and_replace('procedures/hybrid/remote1-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<defined_ssh_port>', defined_ssh_port)
        search_and_replace('procedures/hybrid/remote1-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<email_address>', email_address)
        search_and_replace('procedures/hybrid/remote1-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<cluster_name>', cluster_name)
        search_and_replace('procedures/hybrid/remote1-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<core_server_public_ip_address>', ip_address)
        os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/hybrid/get-private-ip-address-{cluster_name}-{count}.sh > addresses/.private-ip-address-{cluster_name}-{count}'.format(cluster_name=cluster_name, count=count, ip_address=ip_address))
        core_server_private_ip_address = open('addresses/.private-ip-address-{cluster_name}-{count}'.format(cluster_name=cluster_name, count=count), 'r').read().strip()
        search_and_replace('procedures/hybrid/remote1-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<core_server_private_ip_address>', core_server_private_ip_address)
        os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/hybrid/remote0-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count, ip_address=ip_address))
        os.system('scp {user_home}/.ssh/id_rsa.pub root@{ip_address}:/etc/ssh/{remote_username}/authorized_keys'.format(remote_username=remote_username, user_home=user_home, ip_address=ip_address))
        os.system('sh -c \'echo "{remote_password}" > {working_directory}/.htpasswd-credentials\''.format(remote_password=remote_password, working_directory=working_directory))
        os.system('sh -c \'echo "{remote_username}:{remote_password}" > {working_directory}/.chpasswd-credentials\''.format(remote_username=remote_username, remote_password=remote_password, working_directory=working_directory))
        os.system('scp {working_directory}/.htpasswd-credentials root@{ip_address}:/home/{remote_username}/'.format(remote_username=remote_username, ip_address=ip_address, working_directory=working_directory))
        os.system('scp {working_directory}/.chpasswd-credentials root@{ip_address}:/home/{remote_username}/'.format(remote_username=remote_username, ip_address=ip_address, working_directory=working_directory))
        os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/hybrid/remote1-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count, ip_address=ip_address))
        count += 1
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
    user_home = expanduser('~')
    working_directory = os.getcwd()
    pprint(spinup(cluster_name, defined_ssh_port, email_address, remote_username, remote_password, user_home, vm_count, working_directory))

def print_footer():
    print('\n\n\n')
    print(' .    .          .          .          .          .          .          .    .')
    time.sleep(1/100)
    print(' .       .         .         .                   .         .         .       .')
    time.sleep(1/100)
    print(' . .        .        .        .    2017-2018    .        .        .        . .')
    time.sleep(2/100)
    print(' .     .       .       .       .               .       .       .       .     .')
    time.sleep(3/100)
    print(' .    .     .     .     .     .     .     .     .     .     .     .     .    .')
    time.sleep(5/100)
    print(' .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .   .')
    time.sleep(8/100)
    print(' . .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  . .')
    time.sleep(13/100)
    print(' . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .')
    time.sleep(21/100)
    print(' .............................................................................')
    time.sleep(1)
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
    print('\n\n\n\n Here we go...\n\n\n')


if __name__ == '__main__':
    print_main_menu()