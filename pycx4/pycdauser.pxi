# user-level channel classes
import numpy as np
cimport numpy as np
from cpython.version cimport *

# scalar double channel
cdef class sdchan(BaseChan):
    cdef:
        # all general properties defined in base classes
        readonly double val, prev_val, tolerance

    def __init__(self, str name, object context=None):
        BaseChan.__init__(self, name, context)
        self.tolerance = 0.0

    cdef void cb(self):
        self.prev_val = self.val
        cda_check_exception(cda_get_dcval(self.ref, &self.val))
        if abs(self.val - self.prev_val) > self.tolerance or self.first_cycle:
            self.valueChanged.emit(self)
            self.first_cycle = False
        self.valueMeasured.emit(self)

    cpdef void setValue(self, double value):
        cda_check_exception( cda_set_dcval(self.ref, value) )

    cpdef void setTolerance(self, double new_tolerance):
        self.tolerance = new_tolerance


cdef class strchan(BaseChan):
    cdef:
        readonly str val
        char *cval
        int allocated

    def __init__(self, str name, object context=None, int max_nelems=1024):
        BaseChan.__init__(self, name, context, CXDTYPE_TEXT, max_nelems)
        self.cval = <char*>malloc(max_nelems)
        if not self.cval: raise MemoryError()
        self.allocated = 1

    def __dealloc__(self):
        if self.allocated:
            free(self.cval)

    cdef void cb(self):
        len = self.get_data(0, self.max_nelems, <void*>self.cval)
        if PY_MAJOR_VERSION > 2:
            self.val = (<bytes>self.cval[:len]).decode('UTF-8')
        else:
            self.val = self.cval[:len]
        self.valueMeasured.emit(self)
        self.valueChanged.emit(self)

    cpdef void setValue(self, str value):
        if PY_MAJOR_VERSION > 2:
            bv = value.encode('UTF-8')
        else:
            bv = unicode(value).encode('UTF-8')

        cdef char *v = bv
        self.snd_data(CXDTYPE_TEXT, len(bv), <void*>v)


# function for pythonize cx-any-val
# not to effective, but not a bottleneck
cdef:
    aval_value(CxAnyVal_t *aval, cxdtype_t dtype):
        if dtype == CXDTYPE_DOUBLE: return aval.f64
        if dtype == CXDTYPE_INT32:  return aval.i32
        if dtype == CXDTYPE_INT8:   return aval.i8
        if dtype == CXDTYPE_INT16:  return aval.i16
        if dtype == CXDTYPE_INT64:  return aval.i64
        if dtype == CXDTYPE_UINT8:  return aval.u8
        if dtype == CXDTYPE_UINT16: return aval.u16
        if dtype == CXDTYPE_UINT32: return aval.u32
        if dtype == CXDTYPE_UINT64: return aval.u64
        if dtype == CXDTYPE_SINGLE: return aval.f32
        if dtype == CXDTYPE_TEXT:   return aval.c8
        if dtype == CXDTYPE_UCTEXT: return aval.c32
        return None

    void aval_setvalue(value, CxAnyVal_t *aval, cxdtype_t dtype):
        if dtype == CXDTYPE_DOUBLE: aval.f64 = value
        if dtype == CXDTYPE_INT32:  aval.i32 = value
        if dtype == CXDTYPE_INT8:   aval.i8 = value
        if dtype == CXDTYPE_INT16:  aval.i16 = value
        if dtype == CXDTYPE_INT64:  aval.i64 = value
        if dtype == CXDTYPE_UINT8:  aval.u8 = value
        if dtype == CXDTYPE_UINT16: aval.u16 = value
        if dtype == CXDTYPE_UINT32: aval.u32 = value
        if dtype == CXDTYPE_UINT64: aval.u64 = value
        if dtype == CXDTYPE_SINGLE: aval.f32 = value
        if dtype == CXDTYPE_TEXT:   aval.c8 = value
        if dtype == CXDTYPE_UCTEXT: aval.c32 = value

    # dtype conversion numpy <--> CX
    # there are no text or unicode text.
    # Cause text and unicode text can't be mixed with numbers in a good way
    object cxdtype2np(cxdtype_t dtype):
        if dtype == CXDTYPE_DOUBLE: return np.double
        if dtype == CXDTYPE_INT32:  return np.int32
        if dtype == CXDTYPE_INT8:   return np.int8
        if dtype == CXDTYPE_INT16:  return np.int16
        if dtype == CXDTYPE_INT64:  return np.int64
        if dtype == CXDTYPE_UINT8:  return np.uint8
        if dtype == CXDTYPE_UINT16: return np.uint16
        if dtype == CXDTYPE_UINT32: return np.uint32
        if dtype == CXDTYPE_UINT64: return np.uint64
        if dtype == CXDTYPE_SINGLE: return np.single
        return None

    cxdtype_t np2cxdtype(object dtype):
        if dtype == np.double:      return CXDTYPE_DOUBLE
        if dtype == np.int32:       return CXDTYPE_INT32
        if dtype == np.int8:        return CXDTYPE_INT8
        if dtype == np.int16:       return CXDTYPE_INT16
        if dtype == np.int64:       return CXDTYPE_INT64
        if dtype == np.uint8:       return CXDTYPE_UINT8
        if dtype == np.uint16:      return CXDTYPE_UINT16
        if dtype == np.uint32:      return CXDTYPE_UINT32
        if dtype == np.uint64:      return CXDTYPE_UINT64
        if dtype == np.single:      return CXDTYPE_SINGLE
        return 0


# general channel (any cx type)
cdef class schan(BaseChan):
    cdef:
        readonly object val, prev_val

    def __init__(self, str name, object context=None, cxdtype_t dtype=CXDTYPE_DOUBLE):
        BaseChan.__init__(self, name, context, dtype)

    cdef void cb(self):
        cdef CxAnyVal_t aval
        self.prev_val = self.val
        self.get_data(0, self.itemsize, <void*>&aval)
        self.val = aval_value(&aval, self.dtype)
        if self.val != self.prev_val or self.first_cycle:
            self.valueChanged.emit(self)
            self.first_cycle = False
        self.valueMeasured.emit(self)

    cpdef void setValue(self, value):
        cdef CxAnyVal_t aval
        aval_setvalue(value, &aval, self.dtype)
        self.snd_data(self.dtype, 1, <void*>&aval)


# vector-data channel class
cdef class vchan(BaseChan):
    cdef:
        readonly np.ndarray val
        readonly object npdtype

    def __init__(self, str name, object context=None, cxdtype_t dtype=CXDTYPE_DOUBLE, int max_nelems=1):
        BaseChan.__init__(self, name, context, dtype, max_nelems)
        self.npdtype = cxdtype2np(dtype)
        self.val = np.zeros(max_nelems, self.npdtype, order='C')

    cdef void cb(self):
        self.get_data(0, self.itemsize * self.max_nelems, <void*>self.val.data)
        self.valueMeasured.emit(self)
        self.valueChanged.emit(self)

    cpdef void setValue(self, np.ndarray value):
        if value.size > self.max_nelems:
            raise Exception('value size greater than channel.max_nelems')
        dtype = np2cxdtype(value.dtype)
        self.snd_data(dtype, value.size, <void*>value.data)

