from libc.stdlib cimport realloc, free, malloc
from libc.string cimport memmove
from cx4.cx cimport *
from cx4.cda cimport *

from cython cimport view
import numpy as np
cimport numpy as np
np.import_array()



RSLVSTAT_NOTFOUND = CDA_RSLVSTAT_NOTFOUND
RSLVSTAT_SEARCHING = CDA_RSLVSTAT_SEARCHING
RSLVSTAT_FOUND = CDA_RSLVSTAT_FOUND
