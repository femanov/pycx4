from setuptools import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import numpy
from searchcx import cxpath
import sys

cxdir = cxpath()
if cxdir is None:
    print('Error: Unable to locate CX')
    sys.exit(1)

cx4lib = cxdir +'/4cx/src/lib'
cx4include = cxdir + '/4cx/src/include'

extensions = [
              Extension('pycda', ['pycda.pyx'],
                        include_dirs=[numpy.get_include(),
                                      cx4include],
                        libraries=['cda', 'cx_async', 'useful', 'misc', 'cxscheduler'],
                        library_dirs=[cx4lib + '/cda',
                                      cx4lib + '/cxlib',
                                      cx4lib + '/useful',
                                      cx4lib + '/misc',
                                      ],
                        ),
              Extension('qcda', ['qcda.pyx'],
                        include_dirs=[numpy.get_include(),
                                      cx4include],
                        libraries=['cda', 'cx_async', 'useful', 'misc', 'Qcxscheduler', 'QtCore'],
                        library_dirs=[cx4lib + '/cda',
                                      cx4lib + '/cxlib',
                                      cx4lib + '/Qcxscheduler',
                                      cx4lib + '/useful',
                                      cx4lib + '/misc',
                                      ],
                       )

              ]

# Cython directives
directives = {
    'profile':   False,
    'linetrace': False,
    'c_string_type': 'bytes',
    'c_string_encoding': 'ascii',
    'boundscheck': False,
    'wraparound': False,
    'cdivision': True,
    'always_allow_keywords': False,
    'initializedcheck': False
}

setup(
    name='pycx4',
    version='0.11',
    url='https://github.com/femanov/pycx4/wiki',
    download_url='https://github.com/femanov/pycx4',
    author='Fedor Emanov',
    author_email='femanov@gmail.com',
    license='GPL',
    description='CXv4 control system framework Python bindings',
    long_description='CXv4 control system framework Python bindings, pycda and qcda modules',
    install_requires = [
        "Cython >= 0.15",
        "numpy >= 1.7",
        "PyQt4 >= 4.1",
        ],
    platforms='Linux',
    classifiers=[
        "Intended Audience :: Developers",
        "License :: OSI Approved :: GNU General Public License (GPL)",
        "Operating System :: POSIX",
        "Operating System :: POSIX :: BSD",
        "Operating System :: POSIX :: Linux",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 2.6",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.2",
        "Programming Language :: Python :: 3.3",
        "Programming Language :: Python :: 3.4",
        "Programming Language :: Python :: 3.5",
        "Programming Language :: Python :: Implementation :: CPython",
        "Programming Language :: Cython",
        "Topic :: Scientific/Engineering",
        "Topic :: Software Development",
    ],

    ext_modules=cythonize(extensions, compiler_directives=directives)
)

