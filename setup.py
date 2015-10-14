from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import numpy
from searchcx import cxpath
import sys

cxdir = cxpath()
if cxdir is None:
    print('unable to locate CX')
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
    name='pycx',
    version='0.1',
    author='Fedor Emanov',
    license='GPL',
    description='CX control system framework Python bindings',
    ext_modules=cythonize(extensions, compiler_directives=directives),
    install_requires = [
        "Cython >= 0.15",
        "numpy >= 1.7",
        "PyQt4 >= 4.1",
]
)

