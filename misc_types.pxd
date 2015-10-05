# Cython wrapper for cxv4 cda
# misc types declarations from bolkhov's misc_types.h
# by Fedor Emanov

cdef extern from "misc_types.h" nogil:
    ctypedef   signed int    int32
    ctypedef unsigned int    uint32
    ctypedef   signed short  int16
    ctypedef unsigned short  uint16
    ctypedef   signed char   int8
    ctypedef unsigned char   uint8

    ctypedef unsigned char   char8
    ctypedef        uint32   char32

    ctypedef   signed long long int int64
    ctypedef unsigned long long int uint64

    ctypedef float   float32
    ctypedef double  float64
