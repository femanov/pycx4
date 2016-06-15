#!/usr/bin/env python3

from pycx4.version import __version__
import subprocess

subprocess.run(['python3', 'setup.py', 'sdist'])
subprocess.run(['twine', 'upload', 'dist/pycx4-' + __version__ + '.tar.gz'])
