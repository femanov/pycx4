
from misc_types cimport *


cdef extern from "cx.h" nogil:
    ctypedef uint32 rflags_t
    ctypedef uint8  cxdtype_t

    ctypedef int32  cx_ival_t
    ctypedef int64  cx_lval_t
    ctypedef double cx_dval_t

    ctypedef struct cx_time_t:
        int sec
        int nsec


    enum:
        CXDTYPE_SIZE_MASK
        CXDTYPE_REPR_MASK
        CXDTYPE_REPR_SHIFT
        CXDTYPE_USGN_MASK

        #/* Representations */
        CXDTYPE_REPR_UNKNOWN
        CXDTYPE_REPR_INT
        CXDTYPE_REPR_FLOAT
        CXDTYPE_REPR_TEXT

    enum:
        CXDTYPE_UNKNOWN
        CXDTYPE_INT8
        CXDTYPE_INT16
        CXDTYPE_INT32
        CXDTYPE_INT64
        CXDTYPE_UINT8
        CXDTYPE_UINT16
        CXDTYPE_UINT32
        CXDTYPE_UINT64
        CXDTYPE_SINGLE
        CXDTYPE_DOUBLE
        CXDTYPE_TEXT
        CXDTYPE_UCTEXT

    inline size_t sizeof_cxdtype(cxdtype_t t)