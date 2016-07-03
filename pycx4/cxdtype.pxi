# data types declarations and utility functions

CXDTYPE_UNKNOWN = cx.CXDTYPE_UNKNOWN
CXDTYPE_INT8 = cx.CXDTYPE_INT8
CXDTYPE_INT16 = cx.CXDTYPE_INT16
CXDTYPE_INT32 = cx.CXDTYPE_INT32
CXDTYPE_INT64 = cx.CXDTYPE_INT64
CXDTYPE_UINT8 = cx.CXDTYPE_UINT8
CXDTYPE_UINT16 = cx.CXDTYPE_UINT16
CXDTYPE_UINT32 = cx.CXDTYPE_UINT32
CXDTYPE_UINT64 = cx.CXDTYPE_UINT64
CXDTYPE_SINGLE = cx.CXDTYPE_SINGLE
CXDTYPE_DOUBLE = cx.CXDTYPE_DOUBLE
CXDTYPE_TEXT = cx.CXDTYPE_TEXT
CXDTYPE_UCTEXT = cx.CXDTYPE_UCTEXT


# function for pythonize cx-any-val
# not to effective, but not a bottleneck
cdef:
    aval_value(CxAnyVal_t *aval, cxdtype_t dtype):
        if dtype == cx.CXDTYPE_DOUBLE: return aval.f64
        if dtype == cx.CXDTYPE_INT32:  return aval.i32
        if dtype == cx.CXDTYPE_INT8:   return aval.i8
        if dtype == cx.CXDTYPE_INT16:  return aval.i16
        if dtype == cx.CXDTYPE_INT64:  return aval.i64
        if dtype == cx.CXDTYPE_UINT8:  return aval.u8
        if dtype == cx.CXDTYPE_UINT16: return aval.u16
        if dtype == cx.CXDTYPE_UINT32: return aval.u32
        if dtype == cx.CXDTYPE_UINT64: return aval.u64
        if dtype == cx.CXDTYPE_SINGLE: return aval.f32
        if dtype == cx.CXDTYPE_TEXT:   return aval.c8
        if dtype == cx.CXDTYPE_UCTEXT: return aval.c32
        return None

    void aval_setvalue(value, CxAnyVal_t *aval, cxdtype_t dtype):
        if dtype == cx.CXDTYPE_DOUBLE: aval.f64 = value
        if dtype == cx.CXDTYPE_INT32:  aval.i32 = value
        if dtype == cx.CXDTYPE_INT8:   aval.i8 = value
        if dtype == cx.CXDTYPE_INT16:  aval.i16 = value
        if dtype == cx.CXDTYPE_INT64:  aval.i64 = value
        if dtype == cx.CXDTYPE_UINT8:  aval.u8 = value
        if dtype == cx.CXDTYPE_UINT16: aval.u16 = value
        if dtype == cx.CXDTYPE_UINT32: aval.u32 = value
        if dtype == cx.CXDTYPE_UINT64: aval.u64 = value
        if dtype == cx.CXDTYPE_SINGLE: aval.f32 = value
        if dtype == cx.CXDTYPE_TEXT:   aval.c8 = value
        if dtype == cx.CXDTYPE_UCTEXT: aval.c32 = value

    # dtype conversion numpy <--> CX
    # there are no text or unicode text.
    # Cause text and unicode text can't be mixed with numbers in a good way
    object cxdtype2np(cxdtype_t dtype):
        if dtype == cx.CXDTYPE_DOUBLE: return np.double
        if dtype == cx.CXDTYPE_INT32:  return np.int32
        if dtype == cx.CXDTYPE_INT8:   return np.int8
        if dtype == cx.CXDTYPE_INT16:  return np.int16
        if dtype == cx.CXDTYPE_INT64:  return np.int64
        if dtype == cx.CXDTYPE_UINT8:  return np.uint8
        if dtype == cx.CXDTYPE_UINT16: return np.uint16
        if dtype == cx.CXDTYPE_UINT32: return np.uint32
        if dtype == cx.CXDTYPE_UINT64: return np.uint64
        if dtype == cx.CXDTYPE_SINGLE: return np.single
        return None

    cxdtype_t np2cxdtype(object dtype):
        if dtype == np.double:      return cx.CXDTYPE_DOUBLE
        if dtype == np.int32:       return cx.CXDTYPE_INT32
        if dtype == np.int8:        return cx.CXDTYPE_INT8
        if dtype == np.int16:       return cx.CXDTYPE_INT16
        if dtype == np.int64:       return cx.CXDTYPE_INT64
        if dtype == np.uint8:       return cx.CXDTYPE_UINT8
        if dtype == np.uint16:      return cx.CXDTYPE_UINT16
        if dtype == np.uint32:      return cx.CXDTYPE_UINT32
        if dtype == np.uint64:      return cx.CXDTYPE_UINT64
        if dtype == np.single:      return cx.CXDTYPE_SINGLE
        return 0

