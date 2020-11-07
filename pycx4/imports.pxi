cimport cython
from libc.stdlib cimport realloc, free, malloc
from libc.string cimport memmove
from cpython cimport array

cdef bint using_numpy
try:
    import numpy as np
    using_numpy = True
except ImportError:
    using_numpy = False

from cx4.cx cimport *
from cx4.cda cimport *


RSLVSTAT_NOTFOUND = CDA_RSLVSTAT_NOTFOUND
RSLVSTAT_SEARCHING = CDA_RSLVSTAT_SEARCHING
RSLVSTAT_FOUND = CDA_RSLVSTAT_FOUND

