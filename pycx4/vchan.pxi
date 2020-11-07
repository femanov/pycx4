

# vector-data channel class
cdef class VChan(BaseChan):
    cdef:
        readonly object val # showing data to numpy
        readonly array.array aval
        readonly int nelems

    def __cinit__(self, str name, **kwargs):
        self.aval = array.array(cxdtype2pycode(self.dtype))
        self.resize_val(1)

    cdef void resize_val(self, int size):
        array.resize(self.aval, size)
        if using_numpy:
            self.val = np.asarray(self.aval)
        self.nelems = size

    cdef void cb(self):
        cdef int c_len
        cdef int nelems = self.current_nelems()
        if self.nelems != nelems:
            self.resize_val(nelems)
        c_len = self.get_data(0, self.itemsize * nelems, self.aval.data.as_voidptr)
        #nelems_read = int(c_len/self.itemsize)
        self.valueMeasured.emit(self)
        self.valueChanged.emit(self)

    cpdef void setValue(self, atype[::1] value):
        if value.size > self.max_nelems:
            raise Exception('value size greater than channel.max_nelems')
        cdef cxdtype_t dtype
        if atype is float64: dtype = CXDTYPE_DOUBLE
        elif atype is float32: dtype = CXDTYPE_SINGLE
        elif atype is int32: dtype = CXDTYPE_INT32
        elif atype is int16: dtype = CXDTYPE_INT16
        elif atype is int8: dtype = CXDTYPE_INT8
        elif atype is uint32: dtype = CXDTYPE_UINT32
        elif atype is uint16: dtype = CXDTYPE_UINT16
        elif atype is uint8: dtype = CXDTYPE_UINT8
        elif atype is char8: dtype = CXDTYPE_TEXT
        elif atype is char32: dtype = CXDTYPE_UCTEXT
        self.snd_data(dtype, value.size, <void*>&value[0])

    # older version can work with int64, not yet totally removed
    # cpdef void setValue(self, np.ndarray value):
    #     if value.size > self.max_nelems:
    #         raise Exception('value size greater than channel.max_nelems')
    #     dtype = np2cxdtype(value.dtype)
    #     self.snd_data(dtype, value.size, <void*>value.data)
