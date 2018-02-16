#!/usr/bin/env python3

import csv
import os
import time
import urllib.request

import lxml.html


def check_component(component):
    if len(component) == 0:
        return False
    else:
        return True


def compose_uri(itinerary):
    with open('{}'.format(itinerary), newline="") as f:
        components = csv.reader(f)
        for component in components:
            scheme   = component[0]
            userinfo = component[1]
            host     = component[2]
            port     = component[3]
            path     = component[4]
            query    = component[5]
            fragment = component[6]

    uri, authority = '',""

    if check_component(scheme):    uri       += scheme   + ':'
    if check_component(userinfo):  authority += userinfo + '@'
    if check_component(host):      authority +=            host
    if check_component(port):      authority += ':'      + port
    if check_component(authority): uri       += '//'     + authority
    if check_component(path):      uri       +=            path
    if check_component(query):     uri       += '?'      + query
    if check_component(fragment):  uri       += '#'      + fragment

    return uri


def build_request(itinerary):
    request = urllib.request.Request(
                    compose_uri(itinerary),
                    data    = None,
                    headers = {'User-Agent': "Mozilla/5.0"}
                )

    return request


def request_response(itinerary):
    response = urllib.request.urlopen(build_request(itinerary)).read()

    return response


def store_resource(itinerary):
    timestamp = int(time.time())

    with open('{}_{}.{}'.format('test', timestamp, 'html'), "wb") as f:
        f.write(request_response(itinerary))

    with open('{}_{}.{}'.format('test', timestamp, 'html'), "rb") as f:
        document  = lxml.html.fromstring(f.read())
        deeplinks = document.xpath('//a/@href')
        for deeplink in deeplinks:
            # need to do something with this output
            print(deeplink)


if __name__ == '__main__':
    store_resource('targets.csv')