#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function

import argparse
import math
from jinja2 import Template
from jinja2 import Environment, FileSystemLoader
import shutil 
import os
from render import generate

# Capture our current directory
THIS_DIR = os.path.dirname(os.path.abspath(__file__))

def main():
    
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--path',  type=str,  help="changed path")
    parser.add_argument('-r', '--render', type=str, help="base path to render")
    parser.add_argument('-o', '--output', type=str, help="output file name")
    parser.add_argument('-e', '--event', type=str, help="event type modified/created/deleted")
    parser.add_argument('-d', '--descriptors', type=str, help="descriptor catalog")
    
    args = parser.parse_args()
    
    for dirname, subdirs, filelist in os.walk(args.path):
        for name in filelist:
            if os.path.splitext(os.path.basename(name))[1] == ".vrd":
                try:
                    generate(path=os.path.join(dirname, name), render = args.render, output=args.output, descriptors=args.descriptors)
                except IOError as ex:
                    print(ex)
                    exit(1)

                
if __name__=="__main__":
    main()