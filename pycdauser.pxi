# user-level channel classes
import numpy as np
cimport numpy as np

# scalar double channel
cdef class sdchan(cda_base_chan):
    cdef:
        # all general properties defined in base classes
        readonly double val, prev_val, tolerance

    def __cinit__(self, str name, object context=None):
        self.tolerance = 0.0

    cdef void cb(self):
        self.prev_val = self.val
        cda_check_exception(cda_get_dcval(self.ref, &self.val))
        if abs(self.val - self.prev_val) > self.tolerance or self.first_cycle:
            self.valueChanged.emit(self)
            self.first_cycle = False
        self.valueMeasured.emit(self)

    cpdef setValue(self, double value):
        cda_check_exception( cda_set_dcval(self.ref, value) )

    cpdef setTolerance(self, double new_tolerance):
        self.tolerance = new_tolerance

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
        if dtype == CXDTYPE_TEXT:   return np.ubite
        if dtype == CXDTYPE_UCTEXT: return np.uint32
        return None

# general channel (any cx type)
cdef class schan(cda_base_chan):
    cdef:
        readonly object val, prev_val

    def __cinit__(self, str name, object context=None, cxdtype_t dtype=CXDTYPE_DOUBLE):
        pass

    cdef void cb(self):
        cdef CxAnyVal_t aval
        self.prev_val = self.val
        self.get_data(0, self.itemsize, <void*>&aval)
        self.val = aval_value(&aval, self.dtype)
        if self.val != self.prev_val or self.first_cycle:
            self.valueChanged.emit(self)
            self.first_cycle = False
        self.valueMeasured.emit(self)

    cpdef setValue(self, value):
        cdef CxAnyVal_t aval
        aval_setvalue(value, &aval, self.dtype)
        self.snd_data(self.dtype, 1, <void*>&aval)


# vector-data channel class
cdef class vchan(cda_base_chan):
    cdef:
        readonly np.ndarray val
        readonly object npdtype

    def __cinit__(self, str name, object context=None, cxdtype_t dtype=CXDTYPE_DOUBLE, int max_nelems=1):
        self.npdtype = cxdtype2np(dtype)
        self.val = np.zeros(max_nelems, self.npdtype, order='C')

    cdef void cb(self):
        self.get_data(0, self.itemsize * self.max_nelems, <void*>self.val.data)
        self.valueMeasured.emit(self)

    cpdef setValue(self, np.ndarray value):
        if value.size > self.max_nelems:
            raise Exception('value size greater than channel.max_nelems')
        arr = value.astype(self.npdtype, order='C')
        self.snd_data(self.dtype, arr.size, <void*>arr.data)
