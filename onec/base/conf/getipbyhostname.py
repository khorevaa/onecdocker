#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function

import socket; 
from urlparse import urlparse;
import sys

hostname = sys.argv[1]
parse = urlparse(hostname)
ip =  socket.gethostbyname(parse.hostname)
print("{}:{}".format(ip, parse.port))