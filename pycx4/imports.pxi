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


cdef class RslvStatsClass:
    cdef readonly:
        long found
        long searching
        long notfound
    def __cinit__(self):
        self.found = CDA_RSLVSTAT_FOUND
        self.searching = CDA_RSLVSTAT_SEARCHING
        self.notfound = CDA_RSLVSTAT_NOTFOUND

RslvStats = RslvStatsClass()
