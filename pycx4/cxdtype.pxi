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
# currently int64 generates the same func prototype as int and will not work
# that's cython behavior, not cpp for example

# this needed for independent typing of 2-args functions
ctypedef fused atype2:
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
        if atype is int64: aval.i64 = value
        if atype is int32: aval.i32 = value
        if atype is int16: aval.i16 = value
        if atype is int8: aval.i8 = value
        if atype is uint64: aval.u64 = value
        if atype is uint32: aval.u32 = value
        if atype is uint16: aval.u16 = value
        if atype is uint8: aval.u8 = value
        if atype is char8: aval.c8 = value
        if atype is char32: aval.c32 = value

    str cxdtype2pycode(cxdtype_t dtype):
        if dtype == CXDTYPE_DOUBLE: return 'd'
        elif dtype == CXDTYPE_SINGLE: return 'f'
        elif dtype == CXDTYPE_INT32:  return 'l'
        elif dtype == CXDTYPE_INT8:   return 'b'
        elif dtype == CXDTYPE_INT16:  return 'h'
        elif dtype == CXDTYPE_INT64:  return 'q'
        elif dtype == CXDTYPE_UINT8:  return 'B'
        elif dtype == CXDTYPE_UINT16: return 'H'
        elif dtype == CXDTYPE_UINT32: return 'L'
        elif dtype == CXDTYPE_UINT64: return 'Q'
        return None


