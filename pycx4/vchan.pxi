# vector-data channel class
cdef class VChan(BaseChan):
    cdef:
        readonly np.ndarray val
        readonly view.array cval
        readonly np.ndarray background
        readonly int nelems
        int average
        int bg_count
        bint change_sign, dont_update, getting_background, bg_apply, bg_ready

    def __cinit__(self, str name, **kwargs):
        #BaseChan.__init__(self, name, **kwargs)
        self.change_sign = kwargs.get('change_sign', False)
        #self.cval = view.array(shape=(1,), itemsize=sizeof_cxdtype(self.dtype), format=dtype_format(self.dtype))
        self.val = np.empty(1, cxdtype2np(self.dtype), order='C')
        self.nelems = 1
        self.getting_background = False
        self.bg_ready = False

    cdef void init_val(self, int size):
        self.cval = view.array(shape=(size,), itemsize=sizeof_cxdtype(self.dtype), format=dtype_format(self.dtype))
        self.val = np.asarray(self.cval.memview)
        self.nelems = size

    cdef void cb(self):
        cdef int nelems = self.current_nelems()
        if self.nelems != nelems:
            self.nelems = nelems
            self.val.resize(nelems)

        c_len = self.get_data(0, self.itemsize * nelems, <void*>self.val.data)
        nelems_read = int(c_len/self.itemsize)
        if self.change_sign:
            self.val *= -1
        if self.getting_background:
            self.background += self.val/10
            self.bg_count -= 1
            if self.bg_count == 0:
                self.getting_background = False

        self.valueMeasured.emit(self)
        self.valueChanged.emit(self)

    # this version can work with almost any contigouos buffer
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

    # cpdef void setValue(self, np.ndarray value):
    #     if value.size > self.max_nelems:
    #         raise Exception('value size greater than channel.max_nelems')
    #     dtype = np2cxdtype(value.dtype)
    #     self.snd_data(dtype, value.size, <void*>value.data)

    cpdef void getBackgroung(self):
        self.getting_background = True
        self.bgcount = 10
        self.bg_apply = False
        self.bg_ready = False
        self.background = np.zeros(self.nelems)

    cpdef void setApplyBackground(self):
        if self.getting_background:
            return
