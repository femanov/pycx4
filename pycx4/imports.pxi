import numpy as np
cimport numpy as np
from cpython.version cimport PY_MAJOR_VERSION
from libc.stdlib cimport realloc, free, malloc
from libc.string cimport memmove
from cx4 cimport cx
from cx4.cda cimport *

RSLVSTAT_NOTFOUND = CDA_RSLVSTAT_NOTFOUND
RSLVSTAT_SEARCHING = CDA_RSLVSTAT_SEARCHING
RSLVSTAT_FOUND = CDA_RSLVSTAT_FOUND