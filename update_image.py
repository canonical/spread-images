#!/usr/bin/env python3

from argparse import ArgumentParser
import sys
import yaml
import yamlordereddictloader

SUPPORTED_BACKENDS = ['google', 'google-unstable']


def update_image(filepath, backend, system, image, workers):
    
    with open(filepath, "r") as f:
        filemap = yaml.load(f, Loader=yamlordereddictloader.Loader)

    systems = {}
    try:
        systems = filemap['backends'][backend]['systems']
    except:
        print('Error matching system on backend')

    for sys in systems:
        if system in sys.keys():
            if image:
                sys[system]['image'] = image
            if workers:
                sys[system]['workers'] = workers
            break

    with open(filepath, "w") as f:
        yaml.dump(filemap, f, Dumper=yamlordereddictloader.Dumper, default_flow_style=False)


def _is_system_defined(filemap, backend, system):
    systems = {}
    try:
        systems = filemap['backends'][backend]['systems']
    except:
        print('Error matching system on backend')

    for sys in systems:
        if system in sys.keys():
            return True

    return False


def get_backend_for_system(filepath, backend, system):
    with open(filepath, "r") as f:
        filemap = yaml.load(f, Loader=yamlordereddictloader.Loader)

    if _is_system_defined(filemap, backend, system):
        return backend

    for back in [x for x in SUPPORTED_BACKENDS if x != backend]:
        if _is_system_defined(filemap, back, system):
            return back


if __name__ == '__main__':
    args_parser = ArgumentParser("Parse input parameters")
    args_parser.add_argument('filepath', type=str,
        help='path to the spread.yaml file')
    args_parser.add_argument('backend', type=str,
        choices=['google', 'google-unstable'],
        help="""default backend to update. In case the system is not defined
        in the backend, one supported backend will be used""")
    args_parser.add_argument('system', type=str,
        help='system to update')
    args_parser.add_argument('image', type=str,
        help='image to use')
    args_parser.add_argument('workers', type=str, nargs='?',
        help='workers to use')

    args = args_parser.parse_args()

    backend = get_backend_for_system(args.filepath, args.backend, args.system)
    if backend:
        update_image(args.filepath, backend, args.system, args.image,
            int(args.workers) if args.workers and args.workers.isdigit() else None)
    else:
        print('System not available on any supported backend')
        sys.exit(1)
