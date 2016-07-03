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
