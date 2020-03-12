np.import_array()

# vector-data channel class
cdef class VChan(BaseChan):
    cdef:
        readonly np.ndarray val
        readonly object npdtype
        readonly int nelems
        int change_sign

    def __init__(self, str name, **kwargs):
        BaseChan.__init__(self, name, **kwargs)
        self.change_sign = kwargs.get('change_sign', False)
        self.npdtype = cxdtype2np(self.dtype)
        self.val = np.zeros(1, self.npdtype, order='C')
        self.nelems = 1

    cdef void cb(self):
        nelems = self.current_nelems()
        if self.nelems != nelems:
            self.nelems = nelems
            self.val.resize(nelems)
        c_len = self.get_data(0, self.itemsize * nelems, <void*>self.val.data)
        nelems_read = int(c_len/self.itemsize)
        if self.change_sign:
            self.val *= -1

        self.valueMeasured.emit(self)
        self.valueChanged.emit(self)

    cpdef void setValue(self, np.ndarray value):
        if value.size > self.max_nelems:
            raise Exception('value size greater than channel.max_nelems')
        dtype = np2cxdtype(value.dtype)
        self.snd_data(dtype, value.size, <void*>value.data)
