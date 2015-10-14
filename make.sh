#!/usr/bin/env sh

python setup.py build_ext -i use_cython
python3 setup.py build_ext -i use_cython