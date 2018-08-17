#!/usr/bin/env python3

from argparse import ArgumentParser
import yaml
import yamlordereddictloader


def update_image(filepath, backend, system, image):
    
    with open(filepath, "r") as f:
        filemap = yaml.load(f, Loader=yamlordereddictloader.Loader)

    systems = {}
    try:
        systems = filemap['backends'][backend]['systems']        
    except:
        print('Error matching system on backend')

    for sys in systems:
        if system in sys.keys():
            sys[system]['image'] = image
            break

    with open(filepath, "w") as f:
        yaml.dump(filemap, f, Dumper=yamlordereddictloader.Dumper, default_flow_style=False)


if __name__ == '__main__':
    args_parser = ArgumentParser("Parse input parameters")
    args_parser.add_argument('filepath', type=str)
    args_parser.add_argument('backend', type=str, choices=['google', 'linode'])
    args_parser.add_argument('system', type=str)
    args_parser.add_argument('image', type=str)
                             
    args = args_parser.parse_args()
    update_image(args.filepath, args.backend, args.system, args.image)
