from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import numpy

cxdir = '/home/femanov/control_system/4cx'

cx4incdir = cxdir + '/src/include'

extensions = [
              Extension('pycda', ['pycda.pyx'],
                        include_dirs=[numpy.get_include(),
                                      cx4incdir],
                        libraries=['cda', 'cx_async', 'useful', 'misc', 'cxscheduler'],
                        library_dirs=[cxdir + '/src/lib/cda',
                                      cxdir + '/src/lib/cxlib',
                                      cxdir + '/src/lib/useful',
                                      cxdir + '/src/lib/misc',
                                      ],
                        ),
              Extension('qcda', ['qcda.pyx'],
                        include_dirs=[numpy.get_include(),
                                      cx4incdir],
                        libraries=['cda', 'cx_async', 'useful', 'misc', 'Qcxscheduler', 'QtCore'],
                        library_dirs=[cxdir + '/src/lib/cda',
                                      cxdir + '/src/lib/cxlib',
                                      cxdir + '/src/lib/Qcxscheduler',
                                      cxdir + '/src/lib/useful',
                                      cxdir + '/src/lib/misc',
                                      ],
                       )

              ]


setup(ext_modules=cythonize(extensions))