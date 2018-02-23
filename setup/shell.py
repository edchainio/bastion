#!/usr/bin/env python3

import json
import os
import sys
import time

from pprint import pprint

import view
from utility import search_and_replace
from wrappers import digitalocean


# TODO 1: Write a module for AWS Lightsail.
# TODO 2: Write an error handler.

def spinup(cluster_name, defined_ssh_port, email_address, remote_username, remote_password, user_home, vm_count):
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
            return harden(cluster_name, defined_ssh_port, email_address, remote_username, remote_password, user_home, writeout_file)
    else:
        pass # TODO 2

def harden(cluster_name, defined_ssh_port, email_address, remote_username, remote_password, user_home, writeout_file):
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
        if count < 1:
            os.system('cp originals/core/get-private-ip-address.sh procedures/core/get-private-ip-address-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count))
            os.system('cp originals/core/remote0.sh procedures/core/remote0-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count))
            os.system('cp originals/core/remote1a.sh procedures/core/remote1a-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count))
            os.system('cp originals/core/remote1b.sh procedures/core/remote1b-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count))
            search_and_replace('procedures/core/remote0-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<remote_username>', remote_username)
            search_and_replace('procedures/core/remote1a-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<remote_username>', remote_username)
            search_and_replace('procedures/core/remote1a-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<defined_ssh_port>', defined_ssh_port)
            search_and_replace('procedures/core/remote1a-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<core_server_public_ip_address>', ip_address)
            os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/core/get-private-ip-address-{cluster_name}-{count}.sh > addresses/.private-ip-address-{cluster_name}-{count}'.format(cluster_name=cluster_name, count=count, ip_address=ip_address))
            core_server_private_ip_address = open('addresses/.private-ip-address-{cluster_name}-{count}'.format(cluster_name=cluster_name, count=count), 'r').read().strip()
            search_and_replace('procedures/core/remote1a-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<core_server_private_ip_address>', core_server_private_ip_address)
            search_and_replace('procedures/core/remote1b-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<remote_username>', remote_username)
            search_and_replace('procedures/core/remote1b-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<defined_ssh_port>', defined_ssh_port)
            search_and_replace('procedures/core/remote1b-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<email_address>', email_address)
            search_and_replace('procedures/core/remote1b-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<cluster_name>', cluster_name)
            os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/core/remote0-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count, ip_address=ip_address))
            os.system('scp {user_home}/.ssh/id_rsa.pub root@{ip_address}:/etc/ssh/{remote_username}/authorized_keys'.format(remote_username=remote_username, user_home=user_home, ip_address=ip_address))
            os.system('sh -c \'echo "{remote_password}" > .htpasswd-credentials\''.format(remote_password=remote_password))
            os.system('sh -c \'echo "{remote_username}:{remote_password}" > .chpasswd-credentials\''.format(remote_username=remote_username, remote_password=remote_password))
            os.system('scp .htpasswd-credentials root@{ip_address}:/home/{remote_username}/'.format(remote_username=remote_username, ip_address=ip_address))
            os.system('scp .chpasswd-credentials root@{ip_address}:/home/{remote_username}/'.format(remote_username=remote_username, ip_address=ip_address))
            os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/core/remote1a-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count, ip_address=ip_address))
            os.system('scp root@{ip_address}:/etc/pki/tls/certs/logstash-forwarder.crt certificates'.format(ip_address=ip_address))
            os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/core/remote1b-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count, ip_address=ip_address))
            # os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/core/remote2-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count, ip_address=ip_address))
            count += 1
        else:
            os.system('cp originals/peripheral/get-private-ip-address.sh procedures/peripheral/get-private-ip-address-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count))
            os.system('cp originals/peripheral/remote0.sh procedures/peripheral/remote0-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count))
            os.system('cp originals/peripheral/remote1a.sh procedures/peripheral/remote1a-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count))
            os.system('cp originals/peripheral/remote1b.sh procedures/peripheral/remote1b-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count))
            search_and_replace('procedures/peripheral/remote0-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<remote_username>', remote_username)
            search_and_replace('procedures/peripheral/remote1a-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<remote_username>', remote_username)
            search_and_replace('procedures/peripheral/remote1a-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<defined_ssh_port>', defined_ssh_port)
            search_and_replace('procedures/peripheral/remote1a-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<peripheral_server_public_ip_address>', ip_address)
            os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/peripheral/get-private-ip-address-{cluster_name}-{count}.sh > addresses/.private-ip-address-{cluster_name}-{count}'.format(cluster_name=cluster_name, count=count, ip_address=ip_address))
            peripheral_server_private_ip_address = open('addresses/.private-ip-address-{cluster_name}-{count}'.format(cluster_name=cluster_name, count=count), 'r').read().strip()
            search_and_replace('procedures/peripheral/remote1a-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<peripheral_server_private_ip_address>', peripheral_server_private_ip_address)
            search_and_replace('procedures/peripheral/remote1b-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<remote_username>', remote_username)
            search_and_replace('procedures/peripheral/remote1b-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<defined_ssh_port>', defined_ssh_port)
            search_and_replace('procedures/peripheral/remote1b-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<email_address>', email_address)
            search_and_replace('procedures/peripheral/remote1b-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count), '<cluster_name>', cluster_name)
            os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/peripheral/remote0-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count, ip_address=ip_address))
            os.system('scp {user_home}/.ssh/id_rsa.pub root@{ip_address}:/etc/ssh/{remote_username}/authorized_keys'.format(remote_username=remote_username, user_home=user_home, ip_address=ip_address))
            os.system('sh -c \'echo "{remote_password}" > .htpasswd-credentials\''.format(remote_password=remote_password))
            os.system('sh -c \'echo "{remote_username}:{remote_password}" > .chpasswd-credentials\''.format(remote_username=remote_username, remote_password=remote_password))
            os.system('scp .htpasswd-credentials root@{ip_address}:/home/{remote_username}/'.format(remote_username=remote_username, ip_address=ip_address))
            os.system('scp .chpasswd-credentials root@{ip_address}:/home/{remote_username}/'.format(remote_username=remote_username, ip_address=ip_address))
            os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/peripheral/remote1a-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count, ip_address=ip_address))
            os.system('scp certificates/logstash-forwarder.crt root@{ip_address}:/tmp'.format(ip_address=ip_address))
            os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/peripheral/remote1b-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count, ip_address=ip_address))
            # os.system('ssh -o "StrictHostKeyChecking no" root@{ip_address} \'bash -s\' < procedures/peripheral/remote2-{cluster_name}-{count}.sh'.format(cluster_name=cluster_name, count=count, ip_address=ip_address))
            count += 1
    os.system('rm .htpasswd-credentials')
    os.system('rm .chpasswd-credentials')
    return ip_addresses


if __name__ == '__main__':
    (cluster_name, defined_ssh_port, email_address, remote_username, remote_password, user_home, vm_count) = view.main_menu()
    print(spinup(cluster_name, defined_ssh_port, email_address, remote_username, remote_password, user_home, vm_count))