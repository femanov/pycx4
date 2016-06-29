
from misc_types cimport *

cdef extern from "cx_common_types.h" nogil:
    ctypedef unsigned long         CxPixel
    #ctypedef struct _CxWidgetType *CxWidget

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

    ctypedef union CxAnyVal_t:
        float64  f64
        float32  f32
        int64    i64
        uint64   u64
        uint32   u32
        int32    i32
        int16    i16
        uint16   u16
        int8     i8
        uint8    u8
        char8    c8
        char32   c32
