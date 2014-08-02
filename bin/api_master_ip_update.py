#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import configparser
import os
from urllib import request
from linode.api import Api


_SCRIPT_PATH = os.path.dirname(os.path.realpath(__file__))

config = configparser.RawConfigParser()
config.read(_SCRIPT_PATH + '/../conf/config.ini')
api_key_from_file = config.get('linode', 'API_KEY').lstrip('\'').rstrip('\'')


parser = argparse.ArgumentParser()
parser.add_argument('--master_ip',
                    '-i',
                    type=str,
                    nargs='+',
                    help='dns master ip(s)')
parser.add_argument('--api_key',
                    '-k',
                    type=str,
                    nargs='?',
                    default=api_key_from_file,
                    help='linode api key')
args = parser.parse_args()

if args.api_key:
    api_key = args.api_key
else:
    api_key = api_key_from_file

if args.master_ip:
    master_ip = args.master_ip
else:
    icanhazip = request.urlopen('http://icanhazip.com')
    master_ip = icanhazip.read()

api = Api(api_key)
for domain in api.domain.list():
    if domain['TYPE'] == 'slave':
        targetID = domain['DOMAINID']
        try:
            api.domain.update(DomainID=targetID,
                              MASTER_IPS=master_ip)
            print("{0} -> {1}".format(targetID, master_ip))
        except:
            raise
