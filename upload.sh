#!/usr/bin/env sh

python3 setup.py sdist
twine upload dist/pycx4-0.218.tar.gz