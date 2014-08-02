#!/usr/bin/env python3

import datetime
import dns.zone
import os
import sys

_SCRIPT_PATH = os.path.dirname(os.path.realpath(__file__))


class ZoneFile(object):

    def __init__(self,
                 path_to_zone,
                 origin,
                 current_soa,
                 zonefile):
        self.path_to_zone = path_to_zone
        self.origin = origin
        self.current_soa = current_soa
        self.zonefile = zonefile

    def load_zone(self, path_to_zone):
        path_to_zone = os.path.expanduser(path_to_zone)
        os.path.exists(path_to_zone)
        try:
            self.zonefile = open(path_to_zone, "r").read()
        except FileNotFoundError:
            print('can\'t find the goddamn file at ' + path_to_zone + '.')
            print(sys.exc_info()[0])
            raise
        else:
            self.zonefile = dns.zone.from_file(path_to_zone,
                                               os.path.basename(path_to_zone))


def gen_timestamp():
    """
    returns current YYYYMMDDHH timestamp as a string.
    """
    now = datetime.datetime.now()
    return int(now.strftime("%Y%m%d%H"))
