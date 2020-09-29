# data types declarations and utility functions

DTYPE_UNKNOWN = CXDTYPE_UNKNOWN
DTYPE_INT8 = CXDTYPE_INT8
DTYPE_INT16 = CXDTYPE_INT16
DTYPE_INT32 = CXDTYPE_INT32
DTYPE_INT64 = CXDTYPE_INT64
DTYPE_UINT8 = CXDTYPE_UINT8
DTYPE_UINT16 = CXDTYPE_UINT16
DTYPE_UINT32 = CXDTYPE_UINT32
DTYPE_UINT64 = CXDTYPE_UINT64
DTYPE_SINGLE = CXDTYPE_SINGLE
DTYPE_DOUBLE = CXDTYPE_DOUBLE
DTYPE_TEXT = CXDTYPE_TEXT
DTYPE_UCTEXT = CXDTYPE_UCTEXT

cx_dtype_map = {
    'int8': CXDTYPE_INT8,
    'int16': CXDTYPE_INT16,
    'int32': CXDTYPE_INT32,
    'int': CXDTYPE_INT32,
    'int64': CXDTYPE_INT64,
    'uint8': CXDTYPE_UINT8,
    'uint16': CXDTYPE_UINT16,
    'uint32': CXDTYPE_UINT32,
    'uint': CXDTYPE_UINT32,
    'uint64': CXDTYPE_UINT64,
    'single': CXDTYPE_SINGLE,
    'float': CXDTYPE_SINGLE,
    'double': CXDTYPE_DOUBLE,
    'text': CXDTYPE_TEXT,
    'str': CXDTYPE_TEXT,
    'uctext': CXDTYPE_UCTEXT,
    #'unknown': CXDTYPE_UNKNOWN,
}

ctypedef fused atype:
    float64
    float32
    int32
    int16
    int8
    uint32
    uint16
    uint8
    char8
    char32
    #int64 yet unsupported
    #uint64  yet unsupported


# function for pythonize cx-any-val
# not to effective, but not a bottleneck
cdef:
    str dtype_format(cxdtype_t t):
        cdef int t_r = reprof_cxdtype(t)
        if t_r == CXDTYPE_REPR_INT:
            return 'i'
        elif t_r == CXDTYPE_REPR_FLOAT:
            return 'f'
        elif t_r == CXDTYPE_REPR_TEXT:
            return 't'
        elif t_r == CXDTYPE_REPR_UNKNOWN:
            return 'u'


    #size_t sizeof_cxdtype(cxdtype_t t)
    #int    reprof_cxdtype(cxdtype_t t)


    aval_value(CxAnyVal_t *aval, cxdtype_t dtype):
        if dtype == CXDTYPE_DOUBLE: return aval.f64
        elif dtype == CXDTYPE_INT32:  return aval.i32
        elif dtype == CXDTYPE_INT8:   return aval.i8
        elif dtype == CXDTYPE_INT16:  return aval.i16
        elif dtype == CXDTYPE_INT64:  return aval.i64
        elif dtype == CXDTYPE_UINT8:  return aval.u8
        elif dtype == CXDTYPE_UINT16: return aval.u16
        elif dtype == CXDTYPE_UINT32: return aval.u32
        elif dtype == CXDTYPE_UINT64: return aval.u64
        elif dtype == CXDTYPE_SINGLE: return aval.f32
        elif dtype == CXDTYPE_TEXT:   return aval.c8
        elif dtype == CXDTYPE_UCTEXT: return aval.c32
        return None

    void aval_setvalue(value, CxAnyVal_t *aval, cxdtype_t dtype):
        if dtype == CXDTYPE_DOUBLE: aval.f64 = value
        elif dtype == CXDTYPE_INT32:  aval.i32 = value
        elif dtype == CXDTYPE_INT8:   aval.i8 = value
        elif dtype == CXDTYPE_INT16:  aval.i16 = value
        elif dtype == CXDTYPE_INT64:  aval.i64 = value
        elif dtype == CXDTYPE_UINT8:  aval.u8 = value
        elif dtype == CXDTYPE_UINT16: aval.u16 = value
        elif dtype == CXDTYPE_UINT32: aval.u32 = value
        elif dtype == CXDTYPE_UINT64: aval.u64 = value
        elif dtype == CXDTYPE_SINGLE: aval.f32 = value
        elif dtype == CXDTYPE_TEXT:   aval.c8 = value
        elif dtype == CXDTYPE_UCTEXT: aval.c32 = value

    void aval_set(atype value,  CxAnyVal_t *aval):
        if atype is float64: aval.f64 = value
        if atype is float32: aval.f32 = value
        #if atype is int64: aval.i64 = value
        if atype is int32: aval.i32 = value
        if atype is int16: aval.i16 = value
        if atype is int8: aval.i8 = value
        #if atype is uint64: aval.u64 = value
        if atype is uint32: aval.u32 = value
        if atype is uint16: aval.u16 = value
        if atype is uint8: aval.u8 = value
        if atype is char8: aval.c8 = value
        if atype is char32: aval.c32 = value


    # dtype conversion numpy <--> CX
    # there are no text or unicode text.
    # Cause text and unicode text can't be mixed with numbers in a good way
    object cxdtype2np(cxdtype_t dtype):
        if dtype == CXDTYPE_DOUBLE: return np.double
        elif dtype == CXDTYPE_INT32:  return np.int32
        elif dtype == CXDTYPE_INT8:   return np.int8
        elif dtype == CXDTYPE_INT16:  return np.int16b
        elif dtype == CXDTYPE_INT64:  return np.int64
        elif dtype == CXDTYPE_UINT8:  return np.uint8
        elif dtype == CXDTYPE_UINT16: return np.uint16
        elif dtype == CXDTYPE_UINT32: return np.uint32
        elif dtype == CXDTYPE_UINT64: return np.uint64
        elif dtype == CXDTYPE_SINGLE: return np.single
        return None

    # cxdtype_t np2cxdtype(object dtype):
    #     if dtype == np.double:      return CXDTYPE_DOUBLE
    #     elif dtype == np.int32:       return CXDTYPE_INT32
    #     elif dtype == np.int8:        return CXDTYPE_INT8
    #     elif dtype == np.int16:       return CXDTYPE_INT16
    #     elif dtype == np.int64:       return CXDTYPE_INT64
    #     elif dtype == np.uint8:       return CXDTYPE_UINT8
    #     elif dtype == np.uint16:      return CXDTYPE_UINT16
    #     elif dtype == np.uint32:      return CXDTYPE_UINT32
    #     elif dtype == np.uint64:      return CXDTYPE_UINT64
    #     elif dtype == np.single:      return CXDTYPE_SINGLE
    #     return 0

