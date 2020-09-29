
from .misc_types cimport *

cdef extern from "cx_common_types.h" nogil:
    ctypedef unsigned long         CxPixel

    ctypedef int CxDataRef_t
    enum:
        NULL_CxDataRef

    ctypedef struct CxKnobParam_t:
        char   *ident
        char   *label
        int     readonly
        int     modified
        double  value
        double  minalwd
        double  maxalwd
        double  rsrvd_d

