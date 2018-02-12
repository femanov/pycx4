np.import_array()

# vector-data channel class
cdef class VChan(BaseChan):
    cdef:
        readonly np.ndarray val, buf_val
        readonly object npdtype

    def __init__(self, str name, object context=None, cxdtype_t dtype=CXDTYPE_DOUBLE, int max_nelems=1, **kwargs):
        BaseChan.__init__(self, name, context, dtype, max_nelems, **kwargs)
        self.npdtype = cxdtype2np(dtype)
        self.buf_val = np.zeros(max_nelems, self.npdtype, order='C')
        self.val = np.zeros(0, self.npdtype, order='C')

    cdef void cb(self):
        c_len = self.get_data(0, self.itemsize * self.max_nelems, <void*>self.buf_val.data)
        nelems_read = int(c_len/self.itemsize)
        self.val = self.buf_val[:nelems_read]
        self.valueMeasured.emit(self)
        self.valueChanged.emit(self)

    cpdef void setValue(self, np.ndarray value):
        if value.size > self.max_nelems:
            raise Exception('value size greater than channel.max_nelems')
        dtype = np2cxdtype(value.dtype)
        self.snd_data(dtype, value.size, <void*>value.data)
