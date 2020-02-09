#!/usr/bin/env python3

from wheel.pep425tags import get_abbr_impl, get_impl_ver, get_abi_tag, get_platform
from pycx4.version import __version__
import subprocess

subprocess.run(['python3', 'setup.py', 'sdist', 'bdist_wheel'])
subprocess.run(['twine', 'upload', 'dist/pycx4-' + __version__ + '.tar.gz'])


tags = [get_abbr_impl() + get_impl_ver(),
         get_abi_tag(),
         get_platform()]

stag = '-'.join(tags)

tags_out = tags[:2] + ['manylinux2014_x86_64']

dtag = '-'.join(tags_out)

subprocess.run(['mv',
                'dist/pycx4-' + __version__ + '-' + stag + '.whl',
                'dist/pycx4-' + __version__ + '-' + dtag + '.whl'])

subprocess.run(['twine', 'upload', 'dist/pycx4-' + __version__ + '-' + dtag + '.whl'])